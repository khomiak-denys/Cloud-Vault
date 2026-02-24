import 'dart:ui';

import 'package:cloud_vault/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../models/recent_file_item.dart';
import '../theme/app_theme_colors.dart';
import '../utils/interaction_styles.dart';

Future<void> showFileInfoModal(
  BuildContext context,
  RecentFileItem file,
) async {
  final l10n = AppLocalizations.of(context)!;
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final colors = AppThemeColors.of(context);
  final storageColor = isDark ? const Color(0xFFA1AEC2) : colors.secondaryText;
  final iconTileBg = isDark ? const Color(0xFF1C3F84) : const Color(0xFFE8F1FF);
  final iconColor = isDark ? const Color(0xFF66A8FF) : const Color(0xFF2662E7);
  final closeBtnBg = isDark ? const Color(0xFF2662E7) : const Color(0xFF2662E7);
  final closeBtnFg = isDark ? Colors.white : const Color(0xFFEAF2FF);
  await showGeneralDialog<void>(
    context: context,
    barrierLabel: 'File info',
    barrierDismissible: true,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    pageBuilder: (context, animation, secondaryAnimation) {
      return Material(
        type: MaterialType.transparency,
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(color: Colors.black.withValues(alpha: 0.2)),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 430,
                  maxHeight: MediaQuery.sizeOf(context).height * 0.78,
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
                  decoration: BoxDecoration(
                    color: colors.modalBackground,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                l10n.fileInfo,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: colors.primaryText,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: ButtonStyle(
                                overlayColor: pressOnlyOverlay(
                                  const Color(0x3397A5BD),
                                ),
                              ),
                              icon: Icon(
                                Icons.close,
                                color: colors.modalCloseIcon,
                              ),
                            ),
                          ],
                        ),
                        Divider(color: colors.modalDivider, height: 28),
                        Row(
                          children: [
                            Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                color: iconTileBg,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Icon(
                                Icons.description_outlined,
                                color: iconColor,
                                size: 46,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    file.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    file.storageName,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: storageColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 26),
                        _InfoTile(
                          icon: Icons.sd_storage_outlined,
                          label: l10n.size,
                          value: file.sizeLabel,
                          isDark: isDark,
                        ),
                        const SizedBox(height: 12),
                        _InfoTile(
                          icon: Icons.calendar_today_outlined,
                          label: l10n.modified,
                          value: file.modifiedLabel,
                          isDark: isDark,
                        ),
                        const SizedBox(height: 12),
                        _InfoTile(
                          icon: Icons.description_outlined,
                          label: l10n.path,
                          value: file.pathLabel,
                          isDark: isDark,
                        ),
                        const SizedBox(height: 26),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: closeBtnBg,
                              foregroundColor: closeBtnFg,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              overlayColor: Colors.transparent,
                            ),
                            child: Text(
                              l10n.close,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: isDark ? colors.softCardBackground : const Color(0xFFEAF0FA),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: isDark ? const Color(0xFF95A3B9) : colors.secondaryText,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? const Color(0xFF95A3B9)
                        : colors.secondaryText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : colors.primaryText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
