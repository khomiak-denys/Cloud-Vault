import 'dart:ui';

import 'package:cloud_vault/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme_colors.dart';
import '../utils/interaction_styles.dart';

Future<String?> showLanguageModal(BuildContext context) async {
  final l10n = AppLocalizations.of(context)!;
  final colors = AppThemeColors.of(context);
  final isDark = Theme.of(context).brightness == Brightness.dark;
  var selectedCode = Localizations.localeOf(context).languageCode;

  return showGeneralDialog<String>(
    context: context,
    barrierLabel: 'Language',
    barrierDismissible: true,
    barrierColor: Colors.black.withValues(alpha: 0.40),
    pageBuilder: (dialogContext, animation, secondaryAnimation) {
      return StatefulBuilder(
        builder: (dialogContext, setModalState) {
          return Material(
            type: MaterialType.transparency,
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.2),
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: 430,
                      maxHeight: MediaQuery.sizeOf(dialogContext).height * 0.55,
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(22, 20, 22, 14),
                      decoration: BoxDecoration(
                        color: colors.modalBackground,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(28),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  l10n.language,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: colors.primaryText,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () =>
                                    Navigator.of(dialogContext).pop(),
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
                          Divider(color: colors.modalDivider, height: 24),
                          Text(
                            l10n.chooseLanguage,
                            style: TextStyle(
                              fontSize: 13,
                              color: colors.modalMutedText,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _LanguageTile(
                            label: l10n.languageUkrainian,
                            isSelected: selectedCode == 'uk',
                            isDark: isDark,
                            onTap: () {
                              setModalState(() => selectedCode = 'uk');
                              Navigator.of(dialogContext).pop('uk');
                            },
                          ),
                          const SizedBox(height: 8),
                          _LanguageTile(
                            label: l10n.languageEnglish,
                            isSelected: selectedCode == 'en',
                            isDark: isDark,
                            onTap: () {
                              setModalState(() => selectedCode = 'en');
                              Navigator.of(dialogContext).pop('en');
                            },
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: TextButton(
                              onPressed: () =>
                                  Navigator.of(dialogContext).pop(),
                              style: TextButton.styleFrom(
                                backgroundColor:
                                    colors.secondaryButtonBackground,
                                foregroundColor:
                                    colors.secondaryButtonForeground,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                overlayColor: Colors.transparent,
                              ),
                              child: Text(
                                l10n.cancel,
                                style: const TextStyle(
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
              ],
            ),
          );
        },
      );
    },
  );
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.label,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        overlayColor: pressOnlyOverlay(const Color(0x334BA2FF)),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C2C46) : const Color(0xFFF0F5FD),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF4BA2FF)
                  : (isDark
                        ? const Color(0xFF2A3C59)
                        : const Color(0xFFD0DCF0)),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle,
                  size: 22,
                  color: Color(0xFF4BA2FF),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
