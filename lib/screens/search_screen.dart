import 'dart:async';

import 'package:cloud_vault/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../api/api_exception.dart';
import '../api/api_repository.dart';
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

enum SearchSort { modifiedDesc, sizeDesc, extensionAsc }

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
  List<ApiProviderFacet> _providerFacets = const [];
  Set<String> _selectedProviderIds = <String>{};

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
      late final List<ApiFileItem> files;
      late final List<ApiProviderFacet> facets;
      if (query.isEmpty) {
        files = await appApiRepository.recentFiles(pageSize: 50);
        facets = _deriveProviderFacets(files);
      } else {
        final result = await appApiRepository.searchFiles(
          query,
          pageSize: 50,
          providerIds: _selectedProviderIds.isEmpty
              ? null
              : _selectedProviderIds.toList(),
        );
        files = result.items;
        facets = result.providerFacets.isEmpty
            ? _deriveProviderFacets(files)
            : result.providerFacets;
      }
      final normalizedFacets = _sortProviderFacets(facets);

      if (!mounted) return;
      final validProviderIds =
          normalizedFacets.map((item) => item.providerId).toSet();
      setState(() {
        _providerFacets = normalizedFacets;
        _selectedProviderIds =
            _selectedProviderIds.where(validProviderIds.contains).toSet();
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
    final providerFiltered = _applyProviderFilter(_results);
    final filtered = _applyCategoryFilter(providerFiltered);
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
                        if (sorted.isNotEmpty ||
                            _providerFacets.isNotEmpty ||
                            _selectedProviderIds.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (_providerFacets.isNotEmpty ||
                                    _selectedProviderIds.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: FilledButton.tonalIcon(
                                      onPressed: () =>
                                          _showProviderFilterSheet(context),
                                      icon: const Icon(Icons.filter_alt_outlined),
                                      label: Text(
                                        _selectedProviderIds.isEmpty
                                            ? l10n.provider
                                            : '${l10n.provider} (${_selectedProviderIds.length})',
                                      ),
                                    ),
                                  ),
                                PopupMenuButton<SearchSort>(
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
                                      value: SearchSort.extensionAsc,
                                      checked: _sort == SearchSort.extensionAsc,
                                      child: Text(l10n.sortByType),
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
                              ],
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

  List<RecentFileItem> _applyProviderFilter(List<RecentFileItem> files) {
    if (_selectedProviderIds.isEmpty) return files;
    return files
        .where((file) => _selectedProviderIds.contains(file.providerId))
        .toList();
  }

  List<ApiProviderFacet> _deriveProviderFacets(List<ApiFileItem> files) {
    final counts = <String, int>{};
    final names = <String, String>{};
    for (final file in files) {
      if (file.providerId.isEmpty) continue;
      counts[file.providerId] = (counts[file.providerId] ?? 0) + 1;
      if (!names.containsKey(file.providerId)) {
        names[file.providerId] = file.providerName;
      }
    }
    return counts.entries
        .map(
          (entry) => ApiProviderFacet(
            providerId: entry.key,
            providerName: names[entry.key] ?? entry.key,
            count: entry.value,
          ),
        )
        .toList();
  }

  List<ApiProviderFacet> _sortProviderFacets(List<ApiProviderFacet> facets) {
    final sorted = List<ApiProviderFacet>.from(facets);
    sorted.sort((a, b) {
      final nameCompare = a.providerName.compareTo(b.providerName);
      if (nameCompare != 0) return nameCompare;
      return a.providerId.compareTo(b.providerId);
    });
    return sorted;
  }

  Future<void> _showProviderFilterSheet(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final selected = Set<String>.from(_selectedProviderIds);
    final facets = _providerFacets;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.provider,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () => setModalState(() => selected.clear()),
                      child: Text(l10n.all),
                    ),
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: facets.length,
                        itemBuilder: (context, index) {
                          final facet = facets[index];
                          final isChecked = selected.contains(facet.providerId);
                          return CheckboxListTile(
                            dense: true,
                            value: isChecked,
                            title: Text('${facet.providerName} (${facet.count})'),
                            onChanged: (_) {
                              setModalState(() {
                                if (isChecked) {
                                  selected.remove(facet.providerId);
                                } else {
                                  selected.add(facet.providerId);
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          setState(() {
                            _selectedProviderIds = selected;
                          });
                          _fetch();
                        },
                        child: Text(l10n.close),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
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
      case SearchSort.extensionAsc:
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
      SearchSort.extensionAsc => l10n.sortByType,
    };
  }

  String _fileExtension(String fileName) {
    final parts = fileName.split('.');
    if (parts.length < 2) return '';
    return parts.last.toLowerCase();
  }
}
