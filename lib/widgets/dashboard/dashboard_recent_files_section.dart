import 'package:cloud_vault/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../models/recent_file_item.dart';
import '../../theme/app_theme_colors.dart';
import '../recent_file_card.dart';

class DashboardRecentFilesSection extends StatelessWidget {
  const DashboardRecentFilesSection({
    super.key,
    required this.items,
    required this.onMoreTap,
  });

  final List<RecentFileItem> items;
  final ValueChanged<RecentFileItem> onMoreTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = AppThemeColors.of(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 14),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              l10n.recentFiles,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: colors.primaryText,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: items
                .map(
                  (file) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: RecentFileCard(
                      item: file,
                      onMoreTap: () => onMoreTap(file),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
