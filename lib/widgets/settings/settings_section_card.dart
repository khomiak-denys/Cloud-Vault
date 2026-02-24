import 'package:flutter/material.dart';

import '../../theme/app_theme_colors.dart';
import 'settings_models.dart';

class SettingsSectionCard extends StatelessWidget {
  const SettingsSectionCard({super.key, required this.section});

  final SettingsSectionData section;

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 8),
          child: Text(
            section.title,
            style: TextStyle(
              color: colors.mutedText,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark ? colors.headerBackground : colors.cardBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? const Color(0xFF20344F) : colors.cardBorder,
            ),
          ),
          child: Column(
            children: section.items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final rowColor = item.isDanger
                  ? const Color(0xFFFF626D)
                  : colors.primaryText;

              return Column(
                children: [
                  InkWell(
                    onTap: item.onTap,
                    overlayColor: const WidgetStatePropertyAll(
                      Colors.transparent,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                      child: Row(
                        children: [
                          Icon(item.icon, color: rowColor, size: 25),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              item.label,
                              style: TextStyle(
                                color: rowColor,
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (item.value != null &&
                              item.value!.isNotEmpty &&
                              !item.isToggle)
                            Text(
                              item.value!,
                              style: TextStyle(
                                color: colors.secondaryText,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          if (item.isToggle)
                            _SwitchChip(isChecked: item.isChecked)
                          else
                            Icon(
                              Icons.chevron_right,
                              color: isDark
                                  ? const Color(0xFF5F6F87)
                                  : const Color(0xFF94A3B8),
                              size: 24,
                            ),
                        ],
                      ),
                    ),
                  ),
                  if (index != section.items.length - 1)
                    Divider(height: 1, color: colors.headerBorder),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _SwitchChip extends StatelessWidget {
  const _SwitchChip({required this.isChecked});

  final bool isChecked;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 48,
      height: 26,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: isChecked
            ? const Color(0xFF2662E7)
            : (isDark ? const Color(0xFF44546D) : const Color(0xFFCBD5E1)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Align(
        alignment: isChecked ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 22,
          height: 22,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
