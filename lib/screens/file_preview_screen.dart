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
  static const _maxImagePreviewBytes = 20 * 1024 * 1024; // 20 MB
  static const _downloadTimeout = Duration(seconds: 20);

  bool _isLoading = true;
  String? _previewUrl;
  String _previewMethod = 'GET';
  Map<String, String> _previewHeaders = const {};
  String? _errorMessage;
  Uint8List? _imageBytes;
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
      _errorMessage = null;
      final kind = _resolveKind(widget.file);
      final loadedFromDirect = _supportsDirectPreviewUrl(widget.file)
          ? await _tryLoadFromPreviewUrl(kind, l10n)
          : false;
      if (!loadedFromDirect) {
        _errorMessage = null;
        await _tryLoadFromPreviewStream(kind, l10n);
      }

      if (!mounted) return;
      setState(() {
        if (_errorMessage == null && !_hasRenderableContent(kind)) {
          _errorMessage = l10n.filePreviewUnavailable;
        }
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

  Future<bool> _tryLoadFromPreviewUrl(
    _PreviewKind kind,
    AppLocalizations l10n,
  ) async {
    try {
      final preview = await appApiRepository.previewUrl(
        connectionId: widget.file.connectionId,
        fileId: widget.file.id,
      );
      if (preview == null || preview.url.isEmpty) {
        return false;
      }

      final uri = Uri.tryParse(preview.url);
      if (uri == null || !_isAllowedRemoteUri(uri)) {
        return false;
      }

      _previewUrl = preview.url;
      _previewMethod = preview.method;
      _previewHeaders = preview.headers;

      if (kind == _PreviewKind.unsupported) {
        return false;
      }

      if (kind == _PreviewKind.pdf) {
        final fileSize = widget.file.sizeBytes;
        final exceedsMaxSize =
            fileSize > 0 && fileSize > _maxPdfPreviewBytes.toDouble();
        if (exceedsMaxSize) {
          _errorMessage = l10n.filePreviewPdfTooLarge;
          return true;
        }

        final bytes = await _downloadBytesWithLimit(
          uri,
          l10n: l10n,
          method: preview.method,
          headers: preview.headers,
          maxBytes: _maxPdfPreviewBytes,
          maxBytesExceededMessage: l10n.filePreviewPdfTooLarge,
          timeoutMessage: l10n.filePreviewDownloadTimeout,
        );
        if (bytes == null) {
          _errorMessage ??= l10n.filePreviewPdfLoadFailed;
          return false;
        }
        _pdfBytes = bytes;
      }

      if (kind == _PreviewKind.image && preview.method != 'GET') {
        return false;
      }

      if (kind == _PreviewKind.image) {
        final fileSize = widget.file.sizeBytes;
        final exceedsMaxSize =
            fileSize > 0 && fileSize > _maxImagePreviewBytes.toDouble();
        if (exceedsMaxSize) {
          _errorMessage = l10n.filePreviewLoadFailed;
          return true;
        }
        final bytes = await _downloadBytesWithLimit(
          uri,
          l10n: l10n,
          method: preview.method,
          headers: preview.headers,
          maxBytes: _maxImagePreviewBytes,
          maxBytesExceededMessage: l10n.filePreviewLoadFailed,
          timeoutMessage: l10n.filePreviewDownloadTimeout,
        );
        if (bytes == null) {
          _errorMessage ??= l10n.filePreviewLoadFailed;
          return false;
        }
        _imageBytes = bytes;
      }

      if (kind == _PreviewKind.video) {
        if (preview.method != 'GET') {
          _errorMessage = l10n.filePreviewVideoInitFailed;
          return false;
        }
        final initialized = await _initializeVideo(
          uri,
          headers: preview.headers,
          l10n: l10n,
        );
        if (!initialized) return false;
      }

      return true;
    } on ApiException catch (e) {
      // Unsupported provider (HTTP 400) should fall back to preview-stream.
      if (e.statusCode == 400) return false;
      rethrow;
    } catch (_) {
      return false;
    }
  }

  Future<void> _tryLoadFromPreviewStream(
    _PreviewKind kind,
    AppLocalizations l10n,
  ) async {
    if (kind == _PreviewKind.video) {
      final loaded = await _tryLoadVideoViaDownloadUrl(l10n);
      if (!loaded) {
        _errorMessage = l10n.filePreviewVideoInitFailed;
      } else {
        _errorMessage = null;
      }
      return;
    }

    if (kind == _PreviewKind.unsupported) {
      _errorMessage = l10n.filePreviewUnsupportedType;
      return;
    }

    final maxBytes = kind == _PreviewKind.pdf
        ? _maxPdfPreviewBytes
        : _maxImagePreviewBytes;
    final fileSize = widget.file.sizeBytes;
    final exceedsMaxSize = fileSize > 0 && fileSize > maxBytes.toDouble();
    if (exceedsMaxSize) {
      _errorMessage = kind == _PreviewKind.pdf
          ? l10n.filePreviewPdfTooLarge
          : l10n.filePreviewLoadFailed;
      return;
    }

    Uint8List bytes;
    try {
      bytes = await appApiRepository.previewStreamBytes(
        connectionId: widget.file.connectionId,
        fileId: widget.file.id,
        fileName: widget.file.title,
        mimeType: widget.file.mimeType,
        maxBytes: maxBytes,
        timeout: _downloadTimeout,
      );
    } on ApiException catch (e) {
      if (e.message == 'Response exceeded max preview size') {
        _errorMessage = kind == _PreviewKind.pdf
            ? l10n.filePreviewPdfTooLarge
            : l10n.filePreviewLoadFailed;
        return;
      }
      if (e.statusCode == 400 &&
          _looksLikeUnsupportedPreviewMime(e.body ?? '')) {
        _errorMessage = l10n.filePreviewUnsupportedType;
        return;
      }
      if (e.message == 'Request timeout') {
        _errorMessage = l10n.filePreviewDownloadTimeout;
        return;
      }
      _errorMessage = l10n.filePreviewLoadFailed;
      return;
    } on TimeoutException {
      _errorMessage = l10n.filePreviewDownloadTimeout;
      return;
    } catch (_) {
      _errorMessage = l10n.filePreviewLoadFailed;
      return;
    }

    if (kind == _PreviewKind.pdf) {
      if (bytes.length > _maxPdfPreviewBytes) {
        _errorMessage = l10n.filePreviewPdfTooLarge;
        return;
      }
      _pdfBytes = bytes;
      _errorMessage = null;
      return;
    }
    if (bytes.length > _maxImagePreviewBytes) {
      _errorMessage = l10n.filePreviewLoadFailed;
      return;
    }
    _imageBytes = bytes;
    _errorMessage = null;
  }

  Future<bool> _tryLoadVideoViaDownloadUrl(AppLocalizations l10n) async {
    final url = await appApiRepository.downloadUrl(
      connectionId: widget.file.connectionId,
      fileId: widget.file.id,
    );
    if (url == null || url.isEmpty) return false;
    final uri = Uri.tryParse(url);
    if (uri == null || !_isAllowedRemoteUri(uri)) {
      _errorMessage = l10n.filePreviewBlockedUrlScheme;
      return false;
    }
    _previewUrl = url;
    _previewMethod = 'GET';
    _previewHeaders = const {};
    return _initializeVideo(uri, headers: const {}, l10n: l10n);
  }

  Future<bool> _initializeVideo(
    Uri uri, {
    required Map<String, String> headers,
    required AppLocalizations l10n,
  }) async {
    if (!mounted) return false;
    final previousController = _videoController;
    final controller = VideoPlayerController.networkUrl(
      uri,
      httpHeaders: headers,
    );
    _videoController = controller;
    await previousController?.dispose();

    try {
      await controller.initialize();
      if (!mounted) {
        if (identical(_videoController, controller)) {
          _videoController = null;
        }
        await controller.dispose();
        return false;
      }
      await controller.setLooping(true);
      return true;
    } catch (_) {
      if (identical(_videoController, controller)) {
        _videoController = null;
      }
      await controller.dispose();
      _errorMessage = l10n.filePreviewVideoInitFailed;
      return false;
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
                    if (_canOpenExternal)
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

    final kind = _resolveKind(widget.file);
    if (kind == _PreviewKind.pdf && _pdfBytes != null) {
      return _buildPdfPreview(l10n);
    }
    if (kind == _PreviewKind.image && _imageBytes != null) {
      return _buildImagePreview(l10n);
    }

    final url = _previewUrl;
    if (url == null || url.isEmpty) {
      return _buildError(l10n, l10n.filePreviewUnavailable);
    }

    return switch (kind) {
      _PreviewKind.image => _buildImagePreview(l10n),
      _PreviewKind.pdf => _buildPdfPreview(l10n),
      _PreviewKind.video => _buildVideoPreview(l10n),
      _PreviewKind.unsupported => _buildError(
        l10n,
        l10n.filePreviewUnsupportedType,
      ),
    };
  }

  Widget _buildImagePreview(AppLocalizations l10n) {
    final imageBytes = _imageBytes;
    if (imageBytes != null && imageBytes.isNotEmpty) {
      return InteractiveViewer(
        minScale: 0.5,
        maxScale: 5,
        child: Center(
          child: Image.memory(
            imageBytes,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return _buildError(l10n, l10n.filePreviewLoadFailed);
            },
          ),
        ),
      );
    }
    return _buildError(l10n, l10n.filePreviewLoadFailed);
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
            if (_canOpenExternal) ...[
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
    try {
      var url = _previewUrl;
      final requiresDownloadUrl =
          _previewHeaders.isNotEmpty ||
          _previewMethod != 'GET' ||
          url == null ||
          url.isEmpty;
      if (requiresDownloadUrl) {
        url = await appApiRepository.downloadUrl(
          connectionId: widget.file.connectionId,
          fileId: widget.file.id,
        );
      }
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
    } on ApiException {
      if (!mounted) return;
      _showSnack(l10n.filePreviewOpenExternalFailed);
    } catch (_) {
      if (!mounted) return;
      _showSnack(l10n.filePreviewOpenExternalFailed);
    }
  }

  bool _isAllowedRemoteUri(Uri uri) {
    final scheme = uri.scheme.toLowerCase();
    return scheme == 'http' || scheme == 'https';
  }

  Future<Uint8List?> _downloadBytesWithLimit(
    Uri uri, {
    required AppLocalizations l10n,
    required String timeoutMessage,
    String method = 'GET',
    Map<String, String> headers = const <String, String>{},
    int? maxBytes,
    String? maxBytesExceededMessage,
  }) async {
    final client = http.Client();
    try {
      final normalizedMethod = method.trim().toUpperCase();
      if (normalizedMethod != 'GET' && normalizedMethod != 'POST') {
        _errorMessage = l10n.filePreviewLoadFailed;
        return null;
      }

      final request = http.Request(normalizedMethod, uri);
      request.headers.addAll(headers);
      final response = await client.send(request).timeout(_downloadTimeout);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return null;
      }

      final contentLength = response.contentLength;
      if (maxBytes != null &&
          contentLength != null &&
          contentLength > maxBytes) {
        _errorMessage = maxBytesExceededMessage ?? l10n.filePreviewLoadFailed;
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
              if (maxBytes != null && downloadedBytes > maxBytes) {
                _errorMessage =
                    maxBytesExceededMessage ?? l10n.filePreviewLoadFailed;
                subscription.cancel();
                completeOnce(null);
                return;
              }
              bytesBuilder.add(chunk);
            },
            onError: (Object error, StackTrace stackTrace) {
              if (error is TimeoutException) {
                _errorMessage = timeoutMessage;
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
      _errorMessage = timeoutMessage;
      return null;
    } catch (_) {
      return null;
    } finally {
      client.close();
    }
  }

  bool _looksLikeUnsupportedPreviewMime(String body) {
    final normalized = body.toLowerCase();
    return normalized.contains('preview is not supported for mimetype');
  }

  bool _hasRenderableContent(_PreviewKind kind) {
    return switch (kind) {
      _PreviewKind.image => _imageBytes != null && _imageBytes!.isNotEmpty,
      _PreviewKind.pdf => _pdfBytes != null,
      _PreviewKind.video => _videoController?.value.isInitialized == true,
      _PreviewKind.unsupported => false,
    };
  }

  bool _supportsDirectPreviewUrl(RecentFileItem file) {
    final providerId = file.providerId.trim().toLowerCase();
    if (providerId == 'dropbox' || providerId == 'mega') {
      return false;
    }
    return true;
  }

  bool get _canOpenExternal => widget.file.kind.toLowerCase() != 'folder';

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
