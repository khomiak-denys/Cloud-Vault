import 'package:flutter/material.dart';

class RecentFileItem {
  const RecentFileItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.storageName,
    required this.sizeLabel,
    required this.modifiedLabel,
    required this.pathLabel,
    this.badgeIcon,
    this.badgeColor,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final String storageName;
  final String sizeLabel;
  final String modifiedLabel;
  final String pathLabel;
  final IconData? badgeIcon;
  final Color? badgeColor;
}
