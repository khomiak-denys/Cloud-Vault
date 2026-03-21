import 'package:cloud_vault/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../api/api_exception.dart';
import '../data/api_mappers.dart';
import '../data/app_services.dart';
import '../data/file_actions_handler.dart';
import '../models/recent_file_item.dart';
import '../models/vault_item.dart';
import '../modals/file_actions_modal.dart';
import 'file_preview_screen.dart';
import '../theme/app_theme_colors.dart';
import '../widgets/mobile_screen_shell.dart';
import '../widgets/search/search_header.dart';

enum StorageBrowserSort { modifiedDesc, sizeDesc, extensionAsc }

class StorageBrowserScreen extends StatefulWidget {
  const StorageBrowserScreen({super.key, required this.storage});

  final VaultItem storage;

  @override
  State<StorageBrowserScreen> createState() => _StorageBrowserScreenState();
}

class _StorageBrowserScreenState extends State<StorageBrowserScreen> {
  static const _rootPath = '/';

  SearchCategory _category = SearchCategory.all;
  StorageBrowserSort _sort = StorageBrowserSort.modifiedDesc;
  bool _isLoading = true;
  String _currentPath = _rootPath;
  List<RecentFileItem> _items = const [];
  int _loadRequestId = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final requestedPath = _currentPath;
    final requestId = ++_loadRequestId;
    setState(() => _isLoading = true);

    try {
      final files = await appApiRepository.listFiles(
        connectionId: widget.storage.id,
        providerId: widget.storage.providerId,
        path: requestedPath,
      );

      if (!mounted ||
          requestId != _loadRequestId ||
          requestedPath != _currentPath) {
        return;
      }

      setState(() {
        _items = files.map(mapApiFileToRecentFileItem).toList();
      });
    } on ApiException catch (e) {
      if (!mounted ||
          requestId != _loadRequestId ||
          requestedPath != _currentPath) {
        return;
      }

      _showSnack(_apiErrorMessage(e));
      setState(() => _items = const []);
    } catch (_) {
      if (!mounted ||
          requestId != _loadRequestId ||
          requestedPath != _currentPath) {
        return;
      }

      final l10n = AppLocalizations.of(context)!;
      _showSnack(l10n.storageBrowserLoadFailed);
      setState(() => _items = const []);
    } finally {
      if (mounted && requestId == _loadRequestId) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _openFolder(RecentFileItem folder) async {
    final nextPath = _isMegaProvider ? folder.id : folder.pathLabel;
    setState(() => _currentPath = _normalizePath(nextPath));
    await _load();
  }

  Future<void> _goToPath(String path) async {
    setState(() => _currentPath = _normalizePath(path));
    await _load();
  }

  Future<void> _goUp() async {
    if (_currentPath == _rootPath) return;

    setState(() => _currentPath = _parentPath(_currentPath));
    await _load();
  }

  Future<void> _onCreateFolder() async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();

    final name = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.storageBrowserCreateFolderTitle),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              hintText: l10n.storageBrowserCreateFolderHint,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(controller.text),
              child: Text(l10n.storageBrowserCreateFolderAction),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (name == null || name.trim().isEmpty) return;

    try {
      await appApiRepository.createFolder(
        connectionId: widget.storage.id,
        parentId: _currentPath,
        folderName: name.trim(),
      );
      if (!mounted) return;

      _showSnack(l10n.storageBrowserFolderCreated);
      await _load();
    } on ApiException catch (e) {
      if (!mounted) return;
      _showSnack(_apiErrorMessage(e));
    } catch (_) {
      if (!mounted) return;
      _showSnack(l10n.storageBrowserCreateFolderFailed);
    }
  }

  void _onUpload() {
    final l10n = AppLocalizations.of(context)!;
    _showSnack(l10n.storageBrowserUploadNotConfigured);
  }

  Future<void> _onFileAction(String actionId, RecentFileItem file) async {
    final shouldReload = await handleFileAction(context, actionId, file);
    if (shouldReload) {
      await _load();
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = AppThemeColors.of(context);
    final filtered = _applyCategoryFilter(_items);
    final sorted = _applySort(filtered);
    final pathParts = _pathParts(_currentPath);

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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
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
                            widget.storage.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: colors.primaryText,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _PathChip(
                            label: l10n.storageBrowserRoot,
                            isActive: _currentPath == _rootPath,
                            onTap: () => _goToPath(_rootPath),
                          ),
                          ...pathParts.asMap().entries.map((entry) {
                            final part = entry.value;
                            final partPath =
                                '/${pathParts.take(entry.key + 1).join('/')}';
                            return _PathChip(
                              label: part,
                              isActive:
                                  _normalizePath(partPath) == _currentPath,
                              onTap: () => _goToPath(partPath),
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        OutlinedButton.icon(
                          onPressed: _currentPath == _rootPath ? null : _goUp,
                          icon: const Icon(Icons.drive_file_move_outline),
                          label: Text(l10n.storageBrowserUp),
                        ),
                        OutlinedButton.icon(
                          onPressed: _onCreateFolder,
                          icon: const Icon(Icons.create_new_folder_outlined),
                          label: Text(l10n.storageBrowserNewFolder),
                        ),
                        OutlinedButton.icon(
                          onPressed: _onUpload,
                          icon: const Icon(Icons.upload_file_outlined),
                          label: Text(l10n.storageBrowserUpload),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _CategoryChip(
                                  label: l10n.all,
                                  isActive: _category == SearchCategory.all,
                                  onTap: () => setState(
                                    () => _category = SearchCategory.all,
                                  ),
                                ),
                                _CategoryChip(
                                  label: l10n.documents,
                                  isActive:
                                      _category == SearchCategory.documents,
                                  onTap: () => setState(
                                    () => _category = SearchCategory.documents,
                                  ),
                                ),
                                _CategoryChip(
                                  label: l10n.images,
                                  isActive: _category == SearchCategory.images,
                                  onTap: () => setState(
                                    () => _category = SearchCategory.images,
                                  ),
                                ),
                                _CategoryChip(
                                  label: l10n.videos,
                                  isActive: _category == SearchCategory.videos,
                                  onTap: () => setState(
                                    () => _category = SearchCategory.videos,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        PopupMenuButton<StorageBrowserSort>(
                          initialValue: _sort,
                          onSelected: (value) => setState(() => _sort = value),
                          itemBuilder: (context) => [
                            CheckedPopupMenuItem<StorageBrowserSort>(
                              value: StorageBrowserSort.modifiedDesc,
                              checked: _sort == StorageBrowserSort.modifiedDesc,
                              child: Text(l10n.modified),
                            ),
                            CheckedPopupMenuItem<StorageBrowserSort>(
                              value: StorageBrowserSort.sizeDesc,
                              checked: _sort == StorageBrowserSort.sizeDesc,
                              child: Text(l10n.size),
                            ),
                            CheckedPopupMenuItem<StorageBrowserSort>(
                              value: StorageBrowserSort.extensionAsc,
                              checked: _sort == StorageBrowserSort.extensionAsc,
                              child: Text(l10n.sortByType),
                            ),
                          ],
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Icon(
                              Icons.sort_rounded,
                              color: colors.secondaryText,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: sorted.isEmpty
                          ? ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: [
                                SizedBox(
                                  height: 220,
                                  child: Center(
                                    child: Text(
                                      l10n.storageBrowserEmptyFolder,
                                      style: TextStyle(
                                        color: colors.mutedText,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : ListView.separated(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.fromLTRB(
                                16,
                                12,
                                16,
                                16,
                              ),
                              itemCount: sorted.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final item = sorted[index];
                                final isFolder =
                                    item.kind.toLowerCase() == 'folder';

                                return Material(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(14),
                                  clipBehavior: Clip.antiAlias,
                                  child: Ink(
                                    decoration: BoxDecoration(
                                      color: colors.cardBackground,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: colors.cardBorder,
                                      ),
                                    ),
                                    child: ListTile(
                                      leading: Icon(
                                        item.icon,
                                        color: item.iconColor,
                                        size: 28,
                                      ),
                                      title: Text(
                                        item.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: colors.primaryText,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      subtitle: Text(
                                        isFolder
                                            ? item.pathLabel
                                            : '${item.modifiedLabel} - ${item.sizeLabel}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: colors.secondaryText,
                                        ),
                                      ),
                                      onTap: isFolder
                                          ? () => _openFolder(item)
                                          : () => Navigator.of(context).push(
                                              MaterialPageRoute<void>(
                                                builder: (_) =>
                                                    FilePreviewScreen(
                                                      file: item,
                                                    ),
                                              ),
                                            ),
                                      trailing: isFolder
                                          ? null
                                          : IconButton(
                                              icon: Icon(
                                                Icons.more_vert,
                                                color: colors.hintText,
                                              ),
                                              onPressed: () =>
                                                  showFileActionsModal(
                                                    context,
                                                    item,
                                                    onActionTap: _onFileAction,
                                                  ),
                                            ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _apiErrorMessage(ApiException e) {
    final l10n = AppLocalizations.of(context)!;
    final status = e.statusCode?.toString() ?? '-';
    return l10n.storageBrowserApiError(e.message, status);
  }

  List<RecentFileItem> _applyCategoryFilter(List<RecentFileItem> files) {
    return files.where((file) {
      if (file.kind.toLowerCase() == 'folder') return true;

      final extension = _fileExtension(file.title);
      return switch (_category) {
        SearchCategory.all => true,
        SearchCategory.documents => [
          'pptx',
          'xlsx',
          'pdf',
          'doc',
          'docx',
          'txt',
        ].contains(extension),
        SearchCategory.images => [
          'jpg',
          'jpeg',
          'png',
          'gif',
          'webp',
        ].contains(extension),
        SearchCategory.videos => [
          'mp4',
          'mov',
          'avi',
          'mkv',
        ].contains(extension),
      };
    }).toList();
  }

  List<RecentFileItem> _applySort(List<RecentFileItem> files) {
    final sorted = List<RecentFileItem>.from(files);
    sorted.sort((a, b) {
      final aFolder = a.kind.toLowerCase() == 'folder';
      final bFolder = b.kind.toLowerCase() == 'folder';
      if (aFolder && !bFolder) return -1;
      if (!aFolder && bFolder) return 1;

      return switch (_sort) {
        StorageBrowserSort.modifiedDesc => b.modifiedAt.compareTo(a.modifiedAt),
        StorageBrowserSort.sizeDesc => b.sizeBytes.compareTo(a.sizeBytes),
        StorageBrowserSort.extensionAsc => () {
          final extensionCompare = _fileExtension(
            a.title,
          ).compareTo(_fileExtension(b.title));
          if (extensionCompare != 0) return extensionCompare;
          return a.title.toLowerCase().compareTo(b.title.toLowerCase());
        }(),
      };
    });
    return sorted;
  }

  List<String> _pathParts(String path) {
    return _normalizePath(
      path,
    ).split('/').where((part) => part.trim().isNotEmpty).toList();
  }

  String _parentPath(String path) {
    final parts = _pathParts(path);
    if (parts.length <= 1) return _rootPath;
    return '/${parts.take(parts.length - 1).join('/')}';
  }

  String _normalizePath(String path) {
    final trimmed = path.trim();
    if (trimmed.isEmpty || trimmed == _rootPath) return _rootPath;

    final compact = trimmed.replaceAll('\\', '/').replaceAll(RegExp('/+'), '/');

    if (compact == _rootPath) return _rootPath;
    return compact.startsWith('/') ? compact : '/$compact';
  }

  String _fileExtension(String fileName) {
    final parts = fileName.split('.');
    if (parts.length < 2) return '';
    return parts.last.toLowerCase();
  }

  bool get _isMegaProvider =>
      widget.storage.providerId.trim().toLowerCase() == 'mega';
}

class _PathChip extends StatelessWidget {
  const _PathChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(999),
        clipBehavior: Clip.antiAlias,
        child: Ink(
          decoration: BoxDecoration(
            color: isActive
                ? colors.accent.withValues(alpha: 0.16)
                : colors.cardBackground,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: isActive ? colors.accent : colors.cardBorder,
            ),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(999),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text(
                label,
                style: TextStyle(
                  color: isActive ? colors.accent : colors.secondaryText,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(999),
        clipBehavior: Clip.antiAlias,
        child: Ink(
          decoration: BoxDecoration(
            color: isActive
                ? colors.accent.withValues(alpha: 0.16)
                : colors.cardBackground,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: isActive ? colors.accent : colors.cardBorder,
            ),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(999),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text(
                label,
                style: TextStyle(
                  color: isActive ? colors.accent : colors.secondaryText,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
