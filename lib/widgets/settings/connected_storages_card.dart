import 'package:flutter/material.dart';

import '../../models/vault_item.dart';
import '../../theme/app_theme_colors.dart';

class ConnectedStoragesCard extends StatelessWidget {
  const ConnectedStoragesCard({
    super.key,
    required this.title,
    required this.addLabel,
    required this.connectedLabel,
    required this.items,
    required this.onAddTap,
    required this.onDisconnect,
  });

  final String title;
  final String addLabel;
  final String connectedLabel;
  final List<VaultItem> items;
  final VoidCallback onAddTap;
  final ValueChanged<String> onDisconnect;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = AppThemeColors.of(context);
    final cardBorder = isDark ? const Color(0xFF20344F) : colors.cardBorder;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? colors.headerBackground : colors.cardBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cardBorder),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: colors.primaryText,
                  ),
                ),
                TextButton.icon(
                  onPressed: onAddTap,
                  style: TextButton.styleFrom(
                    overlayColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                  ),
                  icon: Icon(Icons.add, color: colors.accent),
                  label: Text(
                    addLabel,
                    style: TextStyle(
                      color: colors.accent,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: colors.headerBorder),
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final storage = entry.value;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                  child: Row(
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: colors.iconTileBackground,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          storage.icon,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              storage.title,
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              connectedLabel,
                              style: TextStyle(
                                fontSize: 12,
                                color: colors.secondaryText,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => onDisconnect(storage.title),
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Color(0xFFFF626D),
                          size: 28,
                        ),
                        style: IconButton.styleFrom(
                          overlayColor: Colors.transparent,
                        ),
                      ),
                    ],
                  ),
                ),
                if (index != items.length - 1)
                  Divider(height: 1, color: colors.headerBorder),
              ],
            );
          }),
        ],
      ),
    );
  }
}
