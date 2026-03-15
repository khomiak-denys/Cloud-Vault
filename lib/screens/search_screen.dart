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

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  SearchCategory _category = SearchCategory.all;
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
    final filtered = _applyCategoryFilter(_results);

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
                  : SearchResultsSection(
                      resultsLabel: l10n.foundFiles(filtered.length),
                      results: filtered,
                      onMoreTap: (file) => showFileActionsModal(
                        context,
                        file,
                        onActionTap: _onFileAction,
                      ),
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

  String _fileExtension(String fileName) {
    final parts = fileName.split('.');
    if (parts.length < 2) return '';
    return parts.last.toLowerCase();
  }
}
