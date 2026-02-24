import 'package:flutter/material.dart';

import '../models/file_action_option.dart';

class FileActionRow extends StatelessWidget {
  const FileActionRow({super.key, required this.action, required this.onTap});

  final FileActionOption action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final rowColor =
        action.color ?? (isDark ? Colors.white : const Color(0xFF0F172A));

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      hoverColor: Colors.transparent,
      focusColor: Colors.transparent,
      splashColor: isDark ? const Color(0x33FFFFFF) : const Color(0x334BA2FF),
      highlightColor: const Color(0x22000000),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 13),
        child: Row(
          children: [
            Icon(action.icon, size: 28, color: rowColor),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                action.label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: rowColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
