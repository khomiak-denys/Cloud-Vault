import 'package:flutter/material.dart';

class AddVaultOption {
  const AddVaultOption({
    required this.title,
    required this.icon,
    this.iconColor,
    this.iconBackground,
  });

  final String title;
  final IconData icon;
  final Color? iconColor;
  final Color? iconBackground;
}
