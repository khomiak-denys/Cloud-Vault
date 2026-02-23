import 'package:flutter/material.dart';

class ProgressTrack extends StatelessWidget {
  const ProgressTrack({super.key, required this.value, required this.color});

  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      height: 14,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: LinearProgressIndicator(
          value: value,
          backgroundColor:
              isDark ? const Color(0xFF45526B) : const Color(0xFFD6DEEA),
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ),
    );
  }
}
