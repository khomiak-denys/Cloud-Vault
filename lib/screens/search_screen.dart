import 'dart:async';

import 'package:cloud_vault/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../api/api_exception.dart';
import '../data/api_mappers.dart';
import '../data/app_services.dart';
import '../data/file_actions_handler.dart';
import '../modals/file_actions_modal.dart';
import '../models/recent_file_item.dart';
import '../utils/tab_navigation.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/loading_skeletons.dart';
import '../widgets/mobile_screen_shell.dart';
import '../widgets/search/search_header.dart';
import '../widgets/search/search_results_section.dart';
import '../theme/app_theme_colors.dart';

enum SearchSort { modifiedDesc, sizeDesc, typeAsc }

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  SearchCategory _category = SearchCategory.all;
  SearchSort _sort = SearchSort.modifiedDesc;
  Timer? _debounce;
  bool _isLoading = false;
  List<RecentFileItem> _results = const [];

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _fetch() async {
    final query = _controller.text.trim();
    setState(() => _isLoading = true);

    try {
      final files = query.isEmpty
          ? await appApiRepository.recentFiles(pageSize: 50)
          : await appApiRepository.searchFiles(
              query,
              pageSize: 50,
            );

      if (!mounted) return;
      setState(() {
        _results = files.map(mapApiFileToRecentFileItem).toList();
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      _showSnack('API error: ${e.statusCode ?? ''} ${e.message}'.trim());
    } catch (_) {
      if (!mounted) return;
      _showSnack('Search failed');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _onQueryChanged(String _) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), _fetch);
    setState(() {});
  }

  Future<void> _onFileAction(String actionId, RecentFileItem file) async {
    final shouldReload = await handleFileAction(context, actionId, file);
    if (shouldReload) {
      await _fetch();
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
    final query = _controller.text.trim();
    final filtered = _applyCategoryFilter(_results);
    final sorted = _applySort(filtered);
    final emptyStateMessage = query.isEmpty
        ? l10n.searchHint
        : l10n.foundFiles(0);

    return Scaffold(
      body: MobileScreenShell(
        child: Column(
          children: [
            SearchHeader(
              title: l10n.search,
              showTitle: false,
              hintText: l10n.searchHint,
              controller: _controller,
              labels: SearchHeaderLabels(
                all: l10n.all,
                documents: l10n.documents,
                images: l10n.images,
                videos: l10n.videos,
              ),
              selectedCategory: _category,
              onQueryChanged: _onQueryChanged,
              onClearTap: () {
                _controller.clear();
                _fetch();
                setState(() {});
              },
              onCategoryChanged: (value) => setState(() => _category = value),
            ),
            Expanded(
              child: _isLoading
                  ? const SearchLoadingSkeleton()
                  : Column(
                      children: [
                        if (sorted.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: PopupMenuButton<SearchSort>(
                                initialValue: _sort,
                                onSelected: (value) => setState(
                                  () => _sort = value,
                                ),
                                color: colors.cardBackground,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                itemBuilder: (context) => [
                                  CheckedPopupMenuItem<SearchSort>(
                                    value: SearchSort.modifiedDesc,
                                    checked: _sort == SearchSort.modifiedDesc,
                                    child: Text(l10n.modified),
                                  ),
                                  CheckedPopupMenuItem<SearchSort>(
                                    value: SearchSort.sizeDesc,
                                    checked: _sort == SearchSort.sizeDesc,
                                    child: Text(l10n.size),
                                  ),
                                  CheckedPopupMenuItem<SearchSort>(
                                    value: SearchSort.typeAsc,
                                    checked: _sort == SearchSort.typeAsc,
                                    child: const Text('A-Z'),
                                  ),
                                ],
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colors.cardBackground,
                                    border: Border.all(color: colors.cardBorder),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.sort_rounded,
                                        size: 18,
                                        color: colors.secondaryText,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        _sortLabel(l10n),
                                        style: TextStyle(
                                          color: colors.secondaryText,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        Expanded(
                          child: SearchResultsSection(
                            resultsLabel: l10n.foundFiles(sorted.length),
                            emptyStateMessage: emptyStateMessage,
                            results: sorted,
                            onMoreTap: (file) => showFileActionsModal(
                              context,
                              file,
                              onActionTap: _onFileAction,
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
            BottomNavBar(
              activeIndex: 1,
              onTap: (index) => handleBottomNavTap(context, 1, index),
            ),
          ],
        ),
      ),
    );
  }

  List<RecentFileItem> _applyCategoryFilter(List<RecentFileItem> files) {
    return files.where((file) {
      final extension = _fileExtension(file.title);
      return switch (_category) {
        SearchCategory.all => true,
        SearchCategory.documents => ['pptx', 'xlsx', 'pdf', 'doc', 'docx', 'txt'].contains(extension),
        SearchCategory.images => ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension),
        SearchCategory.videos => ['mp4', 'mov', 'avi', 'mkv'].contains(extension),
      };
    }).toList();
  }

  List<RecentFileItem> _applySort(List<RecentFileItem> files) {
    final sorted = List<RecentFileItem>.from(files);
    switch (_sort) {
      case SearchSort.modifiedDesc:
        sorted.sort((a, b) => b.modifiedAt.compareTo(a.modifiedAt));
        break;
      case SearchSort.sizeDesc:
        sorted.sort((a, b) => b.sizeBytes.compareTo(a.sizeBytes));
        break;
      case SearchSort.typeAsc:
        sorted.sort((a, b) {
          final typeCompare = _fileExtension(a.title).compareTo(
            _fileExtension(b.title),
          );
          if (typeCompare != 0) return typeCompare;
          return a.title.toLowerCase().compareTo(b.title.toLowerCase());
        });
        break;
    }
    return sorted;
  }

  String _sortLabel(AppLocalizations l10n) {
    return switch (_sort) {
      SearchSort.modifiedDesc => l10n.modified,
      SearchSort.sizeDesc => l10n.size,
      SearchSort.typeAsc => 'A-Z',
    };
  }

  String _fileExtension(String fileName) {
    final parts = fileName.split('.');
    if (parts.length < 2) return '';
    return parts.last.toLowerCase();
  }
}
