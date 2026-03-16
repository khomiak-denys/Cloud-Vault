import 'package:flutter/material.dart';

import '../../models/recent_file_item.dart';
import '../../theme/app_theme_colors.dart';
import '../search_result_card.dart';

class SearchResultsSection extends StatelessWidget {
  const SearchResultsSection({
    super.key,
    required this.resultsLabel,
    required this.results,
    required this.onMoreTap,
  });

  final String resultsLabel;
  final List<RecentFileItem> results;
  final ValueChanged<RecentFileItem> onMoreTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);
    final isEmpty = results.isEmpty;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
      child: isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.search_rounded,
                    size: 44,
                    color: colors.mutedText,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Type something to search',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: colors.mutedText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  resultsLabel,
                  style: TextStyle(
                    fontSize: 16,
                    color: colors.mutedText,
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
                          onMoreTap: () => onMoreTap(file),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
