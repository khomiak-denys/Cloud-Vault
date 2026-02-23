import 'package:flutter/material.dart';

class StorageUsageItem {
  const StorageUsageItem({
    required this.id,
    required this.name,
    required this.color,
    required this.totalBytes,
    required this.usedBytes,
  });

  final String id;
  final String name;
  final Color color;
  final double totalBytes;
  final double usedBytes;

  double get freeBytes => totalBytes - usedBytes;
  double get usagePercent => (usedBytes / totalBytes) * 100;
}
