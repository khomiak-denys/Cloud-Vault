import 'package:flutter/material.dart';

import '../theme/app_theme_colors.dart';

class MobileScreenShell extends StatelessWidget {
  const MobileScreenShell({
    super.key,
    required this.child,
    this.maxWidth = 430,
    this.radius = 0,
  });

  final Widget child;
  final double maxWidth;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);

    return Container(
      color: colors.outerBackground,
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Container(
              decoration: BoxDecoration(
                color: colors.shellBackground,
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
