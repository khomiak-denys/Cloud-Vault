import 'package:flutter/material.dart';

import 'screens/search_screen.dart';

class CloudVaultApp extends StatelessWidget {
  const CloudVaultApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CloudVault',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF00071A),
        fontFamily: 'SF Pro Display',
      ),
      home: const SearchScreen(),
    );
  }
}
