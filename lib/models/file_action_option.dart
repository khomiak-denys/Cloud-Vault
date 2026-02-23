import 'package:flutter/material.dart';

class FileActionOption {
  const FileActionOption({
    required this.icon,
    required this.label,
    this.color,
  });

  final IconData icon;
  final String label;
  final Color? color;
}
