import 'package:cloud_vault/l10n/app_localizations.dart';
import 'package:cloud_vault/screens/profile_screen.dart';
import 'package:cloud_vault/screens/settings_screen.dart';
import 'package:cloud_vault/state/locale_controller.dart';
import 'package:cloud_vault/state/providers/analytics_provider.dart';
import 'package:cloud_vault/state/providers/connections_provider.dart';
import 'package:cloud_vault/state/providers/favorites_provider.dart';
import 'package:cloud_vault/state/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SettingsScreen interactions', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      await appLocaleController.init();
      await appLocaleController.setLocale('en');
      await appThemeController.init();
      if (!appThemeController.isDarkMode) {
        await appThemeController.toggleTheme();
      }
    });

    tearDown(() async {
      await _resetGlobalControllersToDefaults();
    });

    tearDownAll(() async {
      await _resetGlobalControllersToDefaults();
    });

    testWidgets('notification and theme rows show corresponding toasts', (
      WidgetTester tester,
    ) async {
      final SpyConnectionsProvider connections = SpyConnectionsProvider();

      await tester.pumpWidget(
        _buildTestApp(
          providers: <SingleChildWidget>[
            ChangeNotifierProvider<ConnectionsProvider>.value(
              value: connections,
            ),
            ChangeNotifierProvider<FavoritesProvider>(
              create: (_) => SpyFavoritesProvider(),
            ),
            ChangeNotifierProvider<AnalyticsProvider>(
              create: (_) => SpyAnalyticsProvider(),
            ),
          ],
          home: const SettingsScreen(),
        ),
      );
      await tester.pump();

      final AppLocalizations l10n = AppLocalizations.of(
        tester.element(find.byType(SettingsScreen)),
      )!;

      expect(connections.ensureLoadedCalls, greaterThanOrEqualTo(1));

      await tester.tap(find.text(l10n.notifications));
      await tester.pump();
      expect(find.text(l10n.notificationsDisabledToast), findsOneWidget);

      await tester.tap(find.text(l10n.darkTheme));
      await tester.pump();
      expect(find.text(l10n.themeDisabledToast), findsOneWidget);
    });

    testWidgets('language modal opens, selects language, and closes', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _buildTestApp(
          providers: <SingleChildWidget>[
            ChangeNotifierProvider<ConnectionsProvider>(
              create: (_) => SpyConnectionsProvider(),
            ),
            ChangeNotifierProvider<FavoritesProvider>(
              create: (_) => SpyFavoritesProvider(),
            ),
            ChangeNotifierProvider<AnalyticsProvider>(
              create: (_) => SpyAnalyticsProvider(),
            ),
          ],
          home: const SettingsScreen(),
        ),
      );
      await tester.pump();

      final AppLocalizations l10n = AppLocalizations.of(
        tester.element(find.byType(SettingsScreen)),
      )!;

      expect(appLocaleController.locale.languageCode, 'en');

      await tester.tap(find.text(l10n.language));
      await tester.pumpAndSettle();

      expect(find.text(l10n.chooseLanguage), findsOneWidget);
      await tester.tap(find.text(l10n.languageUkrainian));
      await tester.pumpAndSettle();

      expect(appLocaleController.locale.languageCode, 'uk');

      await tester.tap(find.text(l10n.language));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.cancel));
      await tester.pumpAndSettle();
    });

    testWidgets('privacy and help rows show toasts', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _buildTestApp(
          providers: <SingleChildWidget>[
            ChangeNotifierProvider<ConnectionsProvider>(
              create: (_) => SpyConnectionsProvider(),
            ),
            ChangeNotifierProvider<FavoritesProvider>(
              create: (_) => SpyFavoritesProvider(),
            ),
            ChangeNotifierProvider<AnalyticsProvider>(
              create: (_) => SpyAnalyticsProvider(),
            ),
          ],
          home: const SettingsScreen(),
        ),
      );
      await tester.pump();

      final AppLocalizations l10n = AppLocalizations.of(
        tester.element(find.byType(SettingsScreen)),
      )!;

      await tester.ensureVisible(find.text(l10n.privacy));
      await tester.tap(find.text(l10n.privacy));
      await tester.pump();
      expect(find.byType(SnackBar), findsOneWidget);

      await tester.ensureVisible(find.text(l10n.helpSupport));
      await tester.tap(find.text(l10n.helpSupport));
      await tester.pump();
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('profile row navigates to ProfileScreen', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _buildTestApp(
          providers: <SingleChildWidget>[
            ChangeNotifierProvider<ConnectionsProvider>(
              create: (_) => SpyConnectionsProvider(),
            ),
            ChangeNotifierProvider<FavoritesProvider>(
              create: (_) => SpyFavoritesProvider(),
            ),
            ChangeNotifierProvider<AnalyticsProvider>(
              create: (_) => SpyAnalyticsProvider(),
            ),
          ],
          home: const SettingsScreen(),
        ),
      );
      await tester.pump();

      final AppLocalizations l10n = AppLocalizations.of(
        tester.element(find.byType(SettingsScreen)),
      )!;

      await tester.tap(find.text(l10n.profile));
      await tester.pumpAndSettle();

      expect(find.byType(ProfileScreen), findsOneWidget);
    });

    testWidgets('logout navigates to root route', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: <SingleChildWidget>[
            ChangeNotifierProvider<ConnectionsProvider>(
              create: (_) => SpyConnectionsProvider(),
            ),
            ChangeNotifierProvider<FavoritesProvider>(
              create: (_) => SpyFavoritesProvider(),
            ),
            ChangeNotifierProvider<AnalyticsProvider>(
              create: (_) => SpyAnalyticsProvider(),
            ),
          ],
          child: MaterialApp(
            locale: const Locale('en'),
            localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            initialRoute: '/settings',
            routes: <String, WidgetBuilder>{
              '/settings': (_) => const SettingsScreen(),
              '/': (_) => const Scaffold(body: Text('root-destination')),
            },
          ),
        ),
      );
      await tester.pump();

      final AppLocalizations l10n = AppLocalizations.of(
        tester.element(find.byType(SettingsScreen)),
      )!;

      await tester.ensureVisible(find.text(l10n.logout));
      await tester.tap(find.text(l10n.logout));
      await tester.pumpAndSettle();

      expect(find.text('root-destination'), findsOneWidget);
    });
  });
}

Future<void> _resetGlobalControllersToDefaults() async {
  SharedPreferences.setMockInitialValues(<String, Object>{});
  await appLocaleController.init();
  if (appLocaleController.locale.languageCode != 'uk') {
    await appLocaleController.setLocale('uk');
  }
  await appThemeController.init();
  if (!appThemeController.isDarkMode) {
    await appThemeController.toggleTheme();
  }
}

Widget _buildTestApp({
  required List<SingleChildWidget> providers,
  required Widget home,
}) {
  return MultiProvider(
    providers: providers,
    child: MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: home,
    ),
  );
}

class SpyConnectionsProvider extends ConnectionsProvider {
  SpyConnectionsProvider() : super();

  int ensureLoadedCalls = 0;
  int refreshConnectionsOnlyCalls = 0;

  @override
  Future<void> ensureLoaded({
    bool forceRefresh = false,
    bool includeMe = true,
  }) async {
    ensureLoadedCalls += 1;
  }

  @override
  Future<void> refreshConnectionsOnly() async {
    refreshConnectionsOnlyCalls += 1;
  }
}

class SpyFavoritesProvider extends FavoritesProvider {
  SpyFavoritesProvider() : super();

  int ensureLoadedCalls = 0;

  @override
  Future<void> ensureLoaded({bool forceRefresh = false}) async {
    ensureLoadedCalls += 1;
  }
}

class SpyAnalyticsProvider extends AnalyticsProvider {
  SpyAnalyticsProvider() : super();

  int ensureLoadedCalls = 0;

  @override
  Future<void> ensureLoaded({bool forceRefresh = false}) async {
    ensureLoadedCalls += 1;
  }
}
