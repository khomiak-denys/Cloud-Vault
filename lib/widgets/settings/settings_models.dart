import 'package:flutter/material.dart';

class SettingsSectionData {
  const SettingsSectionData({required this.title, required this.items});

  final String title;
  final List<SettingsItemData> items;
}

class SettingsItemData {
  const SettingsItemData({
    required this.icon,
    required this.label,
    this.value,
    this.isDanger = false,
    this.isToggle = false,
    this.isChecked = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String? value;
  final bool isDanger;
  final bool isToggle;
  final bool isChecked;
  final VoidCallback? onTap;
}
