import 'package:flutter/material.dart';

import '../screens/analytics_screen.dart';
import '../screens/cloud_vault_screen.dart';
import '../screens/search_screen.dart';
import '../screens/settings_screen.dart';

void handleBottomNavTap(
  BuildContext context,
  int currentIndex,
  int targetIndex,
) {
  if (currentIndex == targetIndex) {
    return;
  }

  final targetScreen = switch (targetIndex) {
    0 => const CloudVaultScreen(),
    1 => const SearchScreen(),
    2 => const AnalyticsScreen(),
    3 => const SettingsScreen(),
    _ => const CloudVaultScreen(),
  };

  Navigator.of(context).pushReplacement(
    PageRouteBuilder<void>(
      transitionDuration: const Duration(milliseconds: 180),
      reverseTransitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (context, animation, secondaryAnimation) =>
          FadeTransition(opacity: animation, child: targetScreen),
    ),
  );
}
