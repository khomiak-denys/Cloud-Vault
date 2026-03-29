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
    this.compact = false,
  });

  final VaultItem item;
  final VoidCallback? onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = AppThemeColors.of(context);
    final borderRadius = compact ? 18.0 : 22.0;
    final iconSize = compact ? 56.0 : 68.0;
    final iconGlyphSize = compact ? 30.0 : 36.0;
    final titleSize = compact ? 16.0 : 17.0;
    final verticalPaddingTop = compact ? 16.0 : 22.0;
    final verticalPaddingBottom = compact ? 14.0 : 20.0;
    final horizontalPadding = compact ? 18.0 : 22.0;
    final rowGap = compact ? 12.0 : 16.0;
    final trackGap = compact ? 10.0 : 12.0;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(borderRadius),
      clipBehavior: Clip.antiAlias,
      child: Ink(
        decoration: BoxDecoration(
          color: colors.cardBackground,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: colors.cardBorder),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              verticalPaddingTop,
              horizontalPadding,
              verticalPaddingBottom,
            ),
            child: Column(
              children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: iconSize,
                  height: iconSize,
                  decoration: BoxDecoration(
                    color: colors.iconTileBackground,
                    borderRadius: BorderRadius.circular(compact ? 14 : 18),
                  ),
                  child: Icon(item.icon, color: Colors.white, size: iconGlyphSize),
                ),
                SizedBox(width: compact ? 12 : 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: TextStyle(
                          fontSize: titleSize,
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
            SizedBox(height: rowGap),
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
            SizedBox(height: trackGap),
            ProgressTrack(value: item.progress, color: item.progressColor),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
