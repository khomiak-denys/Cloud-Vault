import 'package:flutter/material.dart';
import 'package:cloud_vault/l10n/app_localizations.dart';

import '../models/vault_item.dart';
import '../theme/app_theme_colors.dart';
import 'progress_track.dart';

class VaultCard extends StatelessWidget {
  const VaultCard({
    super.key,
    required this.item,
    this.onTap,
  });

  final VaultItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = AppThemeColors.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        margin: const EdgeInsets.only(bottom: 2),
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
        decoration: BoxDecoration(
          color: colors.cardBackground,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: colors.cardBorder),
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: colors.iconTileBackground,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(item.icon, color: Colors.white, size: 36),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.usageText,
                        style: TextStyle(
                          fontSize: 11,
                          color: colors.secondaryText,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (item.hasWarning)
                  const Icon(
                    Icons.error_outline,
                    color: Color(0xFFFF7B1B),
                    size: 30,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.used,
                  style: TextStyle(
                    color: colors.mutedText,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  item.percentLabel,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ProgressTrack(value: item.progress, color: item.progressColor),
          ],
        ),
      ),
    );
  }
}
