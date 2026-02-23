import 'package:flutter/material.dart';

class MobileScreenShell extends StatelessWidget {
  const MobileScreenShell({
    super.key,
    required this.child,
    this.maxWidth = 430,
    this.radius = 36,
  });

  final Widget child;
  final double maxWidth;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final outerBg = isDark ? const Color(0xFF2D2D2D) : const Color(0xFFE7ECF4);
    final shellBg = isDark ? const Color(0xFF00081C) : const Color(0xFFF8FBFF);

    return Container(
      color: outerBg,
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Container(
              decoration: BoxDecoration(
                color: shellBg,
                borderRadius: BorderRadius.circular(radius),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(radius),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
