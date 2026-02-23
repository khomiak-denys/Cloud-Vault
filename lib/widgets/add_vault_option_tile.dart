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
          color: const Color(0xFF0D1D38),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF4A90FF)
                : const Color(0xFF334866),
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
                color: option.iconBackground ?? const Color(0xFF16325E),
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
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
