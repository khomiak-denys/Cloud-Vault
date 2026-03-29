import 'package:flutter/material.dart';

class AddVaultOption {
  const AddVaultOption({
    required this.providerId,
    required this.title,
    required this.icon,
    this.iconColor,
    this.iconBackground,
  });

  final String providerId;
  final String title;
  final IconData icon;
  final Color? iconColor;
  final Color? iconBackground;
}
