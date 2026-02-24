import 'package:flutter/material.dart';

import '../../theme/app_theme_colors.dart';

class SearchCategoryChip extends StatelessWidget {
  const SearchCategoryChip({
    super.key,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          backgroundColor: isActive
              ? const Color(0xFF2662E7)
              : colors.inputBackground,
          foregroundColor: isActive ? Colors.white : colors.secondaryText,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          overlayColor: Colors.transparent,
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
