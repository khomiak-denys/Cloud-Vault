import 'package:flutter/material.dart';

import '../models/add_vault_option.dart';

class AddVaultOptionTile extends StatelessWidget {
  const AddVaultOptionTile({
    super.key,
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  final AddVaultOption option;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tileBg = isDark ? const Color(0xFF0D1D38) : const Color(0xFFF4F7FD);
    final tileBorder = isDark
        ? const Color(0xFF334866)
        : const Color(0xFFC9D6EA);
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final defaultIconBg = isDark
        ? const Color(0xFF16325E)
        : const Color(0xFFDDEAFE);

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      hoverColor: Colors.transparent,
      focusColor: Colors.transparent,
      splashColor: const Color(0x334A90FF),
      highlightColor: const Color(0x22000000),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: tileBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF4A90FF) : tileBorder,
            width: isSelected ? 1.6 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: option.iconBackground ?? defaultIconBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                option.icon,
                color: option.iconColor ?? Colors.white,
                size: 26,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              option.title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: titleColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
