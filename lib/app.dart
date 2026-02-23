import 'package:flutter/material.dart';

import 'screens/search_screen.dart';
import 'state/theme_controller.dart';

class CloudVaultApp extends StatelessWidget {
  const CloudVaultApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appThemeController,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'CloudVault',
          themeMode: appThemeController.themeMode,
          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: const Color(0xFFF3F5F9),
            fontFamily: 'SF Pro Display',
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF2662E7),
              brightness: Brightness.light,
            ),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF00071A),
            fontFamily: 'SF Pro Display',
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF2662E7),
              brightness: Brightness.dark,
            ),
          ),
          home: const SearchScreen(),
        );
      },
    );
  }
}
