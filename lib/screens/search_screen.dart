import 'package:flutter/material.dart';
import 'package:cloud_vault/l10n/app_localizations.dart';

import '../data/recent_file_mock_data.dart';
import '../modals/file_actions_modal.dart';
import '../models/recent_file_item.dart';
import '../utils/tab_navigation.dart';
import '../widgets/mobile_screen_shell.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/search_result_card.dart';

enum SearchCategory { all, documents, images, videos }

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final headerBg = isDark ? const Color(0xFF0E1B34) : Colors.white;
    final headerTitle = isDark ? Colors.white : const Color(0xFF0F172A);
    final inputBg = isDark ? const Color(0xFF24344B) : const Color(0xFFEFF3FA);
    final inputBorder = isDark
        ? const Color(0xFF34547A)
        : const Color(0xFFDCE5F2);
    final muted = isDark ? const Color(0xFF95A4BE) : const Color(0xFF64748B);
    final resultLabel = isDark
        ? const Color(0xFF93A0B6)
        : const Color(0xFF64748B);

    final results = _filteredFiles();

    return Scaffold(
      body: MobileScreenShell(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: headerBg,
              padding: const EdgeInsets.fromLTRB(16, 26, 16, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.search,
                    style: TextStyle(
                      fontSize: 46,
                      fontWeight: FontWeight.w700,
                      color: headerTitle,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: inputBg,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: inputBorder),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0xA700040A),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search, color: muted, size: 30),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            onChanged: (_) => setState(() {}),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: l10n.searchHint,
                              hintStyle: TextStyle(color: muted),
                            ),
                          ),
                        ),
                        if (_controller.text.isNotEmpty)
                          IconButton(
                            onPressed: () {
                              _controller.clear();
                              setState(() {});
                            },
                            icon: Icon(Icons.close, color: muted),
                            style: IconButton.styleFrom(
                              overlayColor: Colors.transparent,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _CategoryChip(
                          label: l10n.all,
                          isActive: _category == SearchCategory.all,
                          onTap: () =>
                              setState(() => _category = SearchCategory.all),
                        ),
                        _CategoryChip(
                          label: l10n.documents,
                          isActive: _category == SearchCategory.documents,
                          onTap: () => setState(
                            () => _category = SearchCategory.documents,
                          ),
                        ),
                        _CategoryChip(
                          label: l10n.images,
                          isActive: _category == SearchCategory.images,
                          onTap: () =>
                              setState(() => _category = SearchCategory.images),
                        ),
                        _CategoryChip(
                          label: l10n.videos,
                          isActive: _category == SearchCategory.videos,
                          onTap: () =>
                              setState(() => _category = SearchCategory.videos),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.foundFiles(results.length),
                      style: TextStyle(
                        fontSize: 16,
                        color: resultLabel,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Expanded(
                      child: ListView.builder(
                        itemCount: results.length,
                        itemBuilder: (context, index) {
                          final file = results[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: SearchResultCard(
                              item: file,
                              onMoreTap: () =>
                                  showFileActionsModal(context, file),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          backgroundColor: isActive
              ? const Color(0xFF2662E7)
              : (isDark ? const Color(0xFF24344B) : const Color(0xFFEFF3FA)),
          foregroundColor: isActive
              ? Colors.white
              : (isDark ? const Color(0xFFC5CFDC) : const Color(0xFF475569)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          overlayColor: Colors.transparent,
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
