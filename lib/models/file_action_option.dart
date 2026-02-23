import 'package:flutter/material.dart';

class FileActionOption {
  const FileActionOption({
    required this.icon,
    required this.label,
    required this.actionId,
    this.color,
  });

  final IconData icon;
  final String label;
  final String actionId;
  final Color? color;
}
