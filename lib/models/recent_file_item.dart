import 'package:flutter/material.dart';

class RecentFileItem {
  const RecentFileItem({
    required this.id,
    required this.connectionId,
    required this.providerId,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.storageName,
    required this.sizeLabel,
    required this.modifiedLabel,
    required this.sizeBytes,
    required this.modifiedAt,
    required this.pathLabel,
    this.isFavorite = false,
    this.kind = 'file',
    this.mimeType,
    this.badgeIcon,
    this.badgeColor,
  });

  final String id;
  final String connectionId;
  final String providerId;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final String storageName;
  final String sizeLabel;
  final String modifiedLabel;
  final double sizeBytes;
  final DateTime modifiedAt;
  final String pathLabel;
  final bool isFavorite;
  final String kind;
  final String? mimeType;
  final IconData? badgeIcon;
  final Color? badgeColor;
}
