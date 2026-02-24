import 'package:flutter/material.dart';
import 'package:cloud_vault/l10n/app_localizations.dart';

import '../data/recent_file_mock_data.dart';
import '../modals/file_actions_modal.dart';
import '../models/recent_file_item.dart';
import '../utils/tab_navigation.dart';
import '../widgets/bottom_nav_bar.dart';
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final results = _filteredFiles();

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
              onQueryChanged: (_) => setState(() {}),
              onClearTap: () {
                _controller.clear();
                setState(() {});
              },
              onCategoryChanged: (value) => setState(() => _category = value),
            ),
            Expanded(
              child: SearchResultsSection(
                resultsLabel: l10n.foundFiles(results.length),
                results: results,
                onMoreTap: (file) => showFileActionsModal(context, file),
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

  List<RecentFileItem> _filteredFiles() {
    final query = _controller.text.trim().toLowerCase();

    return recentFileItems.where((file) {
      final extension = _fileExtension(file.title);
      final categoryMatches = switch (_category) {
        SearchCategory.all => true,
        SearchCategory.documents => ['pptx', 'xlsx', 'pdf'].contains(extension),
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

      final queryMatches = query.isEmpty
          ? true
          : file.title.toLowerCase().contains(query) ||
                file.subtitle.toLowerCase().contains(query);

      return categoryMatches && queryMatches;
    }).toList();
  }

  String _fileExtension(String fileName) {
    final parts = fileName.split('.');
    if (parts.length < 2) return '';
    return parts.last.toLowerCase();
  }
}
