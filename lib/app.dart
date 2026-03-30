import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:cloud_vault/l10n/app_localizations.dart';

import 'screens/cloud_vault_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'state/locale_controller.dart';
import 'state/theme_controller.dart';

class CloudVaultApp extends StatelessWidget {
  const CloudVaultApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([appThemeController, appLocaleController]),
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'CloudVault',
          scrollBehavior: const MaterialScrollBehavior().copyWith(
            overscroll: false,
          ),
          locale: appLocaleController.locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
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
          routes: {
            LoginScreen.routeName: (_) => const LoginScreen(),
            RegisterScreen.routeName: (_) => const RegisterScreen(),
          },
          home: const _AuthGate(),
        );
      },
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    if (Firebase.apps.isEmpty) {
      return const LoginScreen();
    }

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data ?? FirebaseAuth.instance.currentUser;
        if (user != null) {
          return const CloudVaultScreen();
        }
        return const LoginScreen();
      },
    );
  }
}
