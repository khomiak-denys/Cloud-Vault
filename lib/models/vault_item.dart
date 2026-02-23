import 'package:flutter/material.dart';

class VaultItem {
  const VaultItem({
    required this.title,
    required this.usageText,
    required this.percentLabel,
    required this.progress,
    required this.progressColor,
    required this.icon,
    this.hasWarning = false,
  });

  final String title;
  final String usageText;
  final String percentLabel;
  final double progress;
  final Color progressColor;
  final IconData icon;
  final bool hasWarning;
}
