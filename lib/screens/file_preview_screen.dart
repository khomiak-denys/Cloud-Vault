import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_vault/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:printing/printing.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

import '../api/api_exception.dart';
import '../data/app_services.dart';
import '../models/recent_file_item.dart';
import '../theme/app_theme_colors.dart';
import '../widgets/mobile_screen_shell.dart';

enum _PreviewKind { image, pdf, video, unsupported }

class FilePreviewScreen extends StatefulWidget {
  const FilePreviewScreen({super.key, required this.file});

  final RecentFileItem file;

  @override
  State<FilePreviewScreen> createState() => _FilePreviewScreenState();
}

class _FilePreviewScreenState extends State<FilePreviewScreen> {
  static const _maxPdfPreviewBytes = 25 * 1024 * 1024; // 25 MB
  static const _downloadTimeout = Duration(seconds: 20);

  bool _isLoading = true;
  String? _previewUrl;
  String? _errorMessage;
  Uint8List? _pdfBytes;
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadPreview();
    });
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _loadPreview() async {
    final l10n = AppLocalizations.of(context)!;

    if (widget.file.kind.toLowerCase() == 'folder') {
      setState(() {
        _errorMessage = l10n.filePreviewFolderUnsupported;
        _isLoading = false;
      });
      return;
    }

    try {
      final url = await appApiRepository.downloadUrl(
        connectionId: widget.file.connectionId,
        fileId: widget.file.id,
      );

      if (!mounted) return;

      if (url == null || url.isEmpty) {
        setState(() {
          _errorMessage = l10n.filePreviewUnavailable;
          _isLoading = false;
        });
        return;
      }
      final uri = Uri.tryParse(url);
      if (uri == null || !_isAllowedRemoteUri(uri)) {
        setState(() {
          _errorMessage = l10n.filePreviewBlockedUrlScheme;
          _isLoading = false;
        });
        return;
      }

      final kind = _resolveKind(widget.file);

      if (kind == _PreviewKind.pdf) {
        final fileSize = widget.file.sizeBytes;
        final exceedsMaxSize =
            fileSize > 0 && fileSize > _maxPdfPreviewBytes.toDouble();
        if (exceedsMaxSize) {
          _errorMessage = l10n.filePreviewPdfTooLarge;
        } else {
          final bytes = await _downloadPdfWithLimit(uri, l10n);
          if (bytes == null) {
            _errorMessage ??= l10n.filePreviewPdfLoadFailed;
          } else {
            _pdfBytes = bytes;
          }
        }
      }

      if (kind == _PreviewKind.video) {
        if (!mounted) return;
        final previousController = _videoController;
        final controller = VideoPlayerController.networkUrl(uri);
        _videoController = controller;
        await previousController?.dispose();

        try {
          await controller.initialize();
          if (!mounted) {
            if (identical(_videoController, controller)) {
              _videoController = null;
            }
            await controller.dispose();
            return;
          }
          await controller.setLooping(true);
        } catch (_) {
          if (identical(_videoController, controller)) {
            _videoController = null;
          }
          await controller.dispose();
          _errorMessage = l10n.filePreviewVideoInitFailed;
        }
      }

      if (!mounted) return;
      setState(() {
        _previewUrl = url;
        _isLoading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      final status = e.statusCode?.toString() ?? '-';
      setState(() {
        _errorMessage = l10n.filePreviewApiError(e.message, status);
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = l10n.filePreviewLoadFailed;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = AppThemeColors.of(context);

    return Scaffold(
      body: MobileScreenShell(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: colors.headerBackground,
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
              child: SafeArea(
                bottom: false,
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: colors.primaryText,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        widget.file.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: colors.primaryText,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (_previewUrl != null)
                      IconButton(
                        onPressed: _openExternal,
                        icon: Icon(
                          Icons.open_in_new_rounded,
                          color: colors.primaryText,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: _isLoading
                  ? Center(
                      child: Text(
                        l10n.filePreviewLoading,
                        style: TextStyle(
                          color: colors.secondaryText,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  : _buildContent(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_errorMessage != null) {
      return _buildError(l10n, _errorMessage!);
    }

    final url = _previewUrl;
    if (url == null || url.isEmpty) {
      return _buildError(l10n, l10n.filePreviewUnavailable);
    }

    final kind = _resolveKind(widget.file);

    return switch (kind) {
      _PreviewKind.image => _buildImagePreview(url),
      _PreviewKind.pdf => _buildPdfPreview(l10n),
      _PreviewKind.video => _buildVideoPreview(l10n),
      _PreviewKind.unsupported => _buildError(
        l10n,
        l10n.filePreviewUnsupportedType,
      ),
    };
  }

  Widget _buildImagePreview(String url) {
    return InteractiveViewer(
      minScale: 0.5,
      maxScale: 5,
      child: Center(
        child: Image.network(
          url,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            final l10n = AppLocalizations.of(context)!;
            return _buildError(l10n, l10n.filePreviewLoadFailed);
          },
        ),
      ),
    );
  }

  Widget _buildPdfPreview(AppLocalizations l10n) {
    final bytes = _pdfBytes;
    if (bytes == null || bytes.isEmpty) {
      return _buildError(l10n, l10n.filePreviewPdfLoadFailed);
    }

    return PdfPreview(
      canChangePageFormat: false,
      canChangeOrientation: false,
      canDebug: false,
      allowPrinting: false,
      allowSharing: false,
      maxPageWidth: 900,
      build: (format) async => bytes,
    );
  }

  Widget _buildVideoPreview(AppLocalizations l10n) {
    final controller = _videoController;
    if (controller == null || !controller.value.isInitialized) {
      return _buildError(l10n, l10n.filePreviewVideoInitFailed);
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: controller.value.aspectRatio,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: VideoPlayer(controller),
            ),
          ),
          const SizedBox(height: 12),
          VideoProgressIndicator(
            controller,
            allowScrubbing: true,
            padding: const EdgeInsets.symmetric(vertical: 8),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ValueListenableBuilder<VideoPlayerValue>(
                valueListenable: controller,
                builder: (context, value, child) {
                  return FilledButton.tonalIcon(
                    onPressed: () {
                      if (value.isPlaying) {
                        controller.pause();
                      } else {
                        controller.play();
                      }
                    },
                    icon: Icon(
                      value.isPlaying ? Icons.pause : Icons.play_arrow,
                    ),
                    label: Text(
                      value.isPlaying
                          ? l10n.filePreviewPause
                          : l10n.filePreviewPlay,
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildError(AppLocalizations l10n, String message) {
    final colors = AppThemeColors.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.visibility_off_outlined,
              size: 42,
              color: colors.mutedText,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.secondaryText,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (_previewUrl != null) ...[
              const SizedBox(height: 16),
              FilledButton.tonalIcon(
                onPressed: _openExternal,
                icon: const Icon(Icons.open_in_new_rounded),
                label: Text(l10n.filePreviewOpenExternal),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _openExternal() async {
    final l10n = AppLocalizations.of(context)!;
    final url = _previewUrl;
    if (url == null || url.isEmpty) return;

    final uri = Uri.tryParse(url);
    if (uri == null || !_isAllowedRemoteUri(uri)) {
      _showSnack(l10n.filePreviewBlockedUrlScheme);
      return;
    }
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      _showSnack(l10n.filePreviewOpenExternalFailed);
    }
  }

  bool _isAllowedRemoteUri(Uri uri) {
    final scheme = uri.scheme.toLowerCase();
    return scheme == 'http' || scheme == 'https';
  }

  Future<Uint8List?> _downloadPdfWithLimit(
    Uri uri,
    AppLocalizations l10n,
  ) async {
    final client = http.Client();
    try {
      final request = http.Request('GET', uri);
      final response = await client.send(request).timeout(_downloadTimeout);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return null;
      }

      final contentLength = response.contentLength;
      if (contentLength != null && contentLength > _maxPdfPreviewBytes) {
        _errorMessage = l10n.filePreviewPdfTooLarge;
        return null;
      }

      final bytesBuilder = BytesBuilder(copy: false);
      var downloadedBytes = 0;
      final completer = Completer<Uint8List?>();
      late final StreamSubscription<List<int>> subscription;

      void completeOnce(Uint8List? value) {
        if (!completer.isCompleted) {
          completer.complete(value);
        }
      }

      subscription = response.stream
          .timeout(_downloadTimeout)
          .listen(
            (chunk) {
              downloadedBytes += chunk.length;
              if (downloadedBytes > _maxPdfPreviewBytes) {
                _errorMessage = l10n.filePreviewPdfTooLarge;
                subscription.cancel();
                completeOnce(null);
                return;
              }
              bytesBuilder.add(chunk);
            },
            onError: (Object error, StackTrace stackTrace) {
              if (error is TimeoutException) {
                _errorMessage = l10n.filePreviewDownloadTimeout;
              }
              completeOnce(null);
            },
            onDone: () => completeOnce(bytesBuilder.takeBytes()),
            cancelOnError: true,
          );

      final result = await completer.future;
      await subscription.cancel();
      return result;
    } on TimeoutException {
      _errorMessage = l10n.filePreviewDownloadTimeout;
      return null;
    } catch (_) {
      return null;
    } finally {
      client.close();
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
  }

  _PreviewKind _resolveKind(RecentFileItem file) {
    final lowerMime = file.mimeType?.toLowerCase();
    if (lowerMime != null) {
      if (lowerMime.startsWith('image/')) return _PreviewKind.image;
      if (lowerMime == 'application/pdf') return _PreviewKind.pdf;
      if (lowerMime.startsWith('video/')) return _PreviewKind.video;
    }

    final ext = _extension(file.title);
    if (['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'].contains(ext)) {
      return _PreviewKind.image;
    }
    if (ext == 'pdf') {
      return _PreviewKind.pdf;
    }
    if (['mp4', 'mov', 'm4v', 'webm', 'avi', 'mkv'].contains(ext)) {
      return _PreviewKind.video;
    }
    return _PreviewKind.unsupported;
  }

  String _extension(String name) {
    final parts = name.split('.');
    if (parts.length < 2) return '';
    return parts.last.toLowerCase();
  }
}
