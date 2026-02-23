import 'package:flutter/material.dart';

class AppPageHeader extends StatelessWidget {
  const AppPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.padding = const EdgeInsets.fromLTRB(16, 24, 16, 14),
    this.titleSize = 26,
  });

  final String title;
  final String? subtitle;
  final EdgeInsetsGeometry padding;
  final double titleSize;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final headerBg = isDark ? const Color(0xFF0F1D36) : Colors.white;
    final headerBorder = isDark
        ? const Color(0xFF1E2E46)
        : const Color(0xFFDCE5F2);
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor = isDark
        ? const Color(0xFF93A1B7)
        : const Color(0xFF64748B);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: headerBg,
        border: Border(bottom: BorderSide(color: headerBorder)),
      ),
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: titleSize,
              fontWeight: FontWeight.w700,
              color: titleColor,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: TextStyle(
                fontSize: 13,
                color: subtitleColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
