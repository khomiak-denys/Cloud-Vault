import 'package:flutter/material.dart';

class RecentFileItem {
  const RecentFileItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    this.badgeIcon,
    this.badgeColor,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final IconData? badgeIcon;
  final Color? badgeColor;
}
