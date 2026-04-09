import 'package:cloud_vault/l10n/app_localizations.dart';
import 'package:cloud_vault/screens/analytics_screen.dart';
import 'package:cloud_vault/screens/cloud_vault_screen.dart';
import 'package:cloud_vault/screens/profile_screen.dart';
import 'package:cloud_vault/screens/settings_screen.dart';
import 'package:cloud_vault/state/providers/analytics_provider.dart';
import 'package:cloud_vault/state/providers/connections_provider.dart';
import 'package:cloud_vault/state/providers/favorites_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

void main() {
  group('Provider migration widget parity', () {
    testWidgets('Dashboard pull-to-refresh triggers force refresh', (
      WidgetTester tester,
    ) async {
      final connections = SpyConnectionsProvider();
      final favorites = SpyFavoritesProvider();

      await tester.pumpWidget(
        _buildTestApp(
          providers: <SingleChildWidget>[
            ChangeNotifierProvider<ConnectionsProvider>.value(
              value: connections,
            ),
            ChangeNotifierProvider<FavoritesProvider>.value(value: favorites),
            ChangeNotifierProvider<AnalyticsProvider>(
              create: (_) => SpyAnalyticsProvider(),
            ),
          ],
          home: const CloudVaultScreen(),
        ),
      );
      await tester.pump();

      expect(connections.calls, 1);
      expect(favorites.calls, 1);

      await tester.drag(
        find.byType(SingleChildScrollView).first,
        const Offset(0, 350),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(connections.forceRefreshCalls, 1);
      expect(favorites.forceRefreshCalls, 1);
    });

    testWidgets('Analytics pull-to-refresh triggers force refresh', (
      WidgetTester tester,
    ) async {
      final analytics = SpyAnalyticsProvider();

      await tester.pumpWidget(
        _buildTestApp(
          providers: <SingleChildWidget>[
            ChangeNotifierProvider<ConnectionsProvider>(
              create: (_) => SpyConnectionsProvider(),
            ),
            ChangeNotifierProvider<FavoritesProvider>(
              create: (_) => SpyFavoritesProvider(),
            ),
            ChangeNotifierProvider<AnalyticsProvider>.value(value: analytics),
          ],
          home: const AnalyticsScreen(),
        ),
      );
      await tester.pump();

      expect(analytics.calls, 1);

      await tester.drag(
        find.byType(SingleChildScrollView).first,
        const Offset(0, 350),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(analytics.forceRefreshCalls, 1);
    });

    testWidgets('Settings and Profile pull-to-refresh trigger force refresh', (
      WidgetTester tester,
    ) async {
      final settingsConnections = SpyConnectionsProvider();

      await tester.pumpWidget(
        _buildTestApp(
          providers: <SingleChildWidget>[
            ChangeNotifierProvider<ConnectionsProvider>.value(
              value: settingsConnections,
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
      expect(settingsConnections.calls, 2);

      await tester.drag(
        find.byType(SingleChildScrollView).first,
        const Offset(0, 350),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(settingsConnections.forceRefreshCalls, 1);

      final profileConnections = SpyConnectionsProvider();

      await tester.pumpWidget(
        _buildTestApp(
          providers: <SingleChildWidget>[
            ChangeNotifierProvider<ConnectionsProvider>.value(
              value: profileConnections,
            ),
            ChangeNotifierProvider<FavoritesProvider>(
              create: (_) => SpyFavoritesProvider(),
            ),
            ChangeNotifierProvider<AnalyticsProvider>(
              create: (_) => SpyAnalyticsProvider(),
            ),
          ],
          home: const ProfileScreen(),
        ),
      );
      await tester.pump();
      expect(profileConnections.calls, 1);

      await tester.drag(
        find.byType(SingleChildScrollView).first,
        const Offset(0, 350),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(profileConnections.forceRefreshCalls, 1);
    });
  });
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

  int calls = 0;
  int forceRefreshCalls = 0;

  @override
  Future<void> ensureLoaded({bool forceRefresh = false}) async {
    calls += 1;
    if (forceRefresh) {
      forceRefreshCalls += 1;
    }
  }
}

class SpyFavoritesProvider extends FavoritesProvider {
  SpyFavoritesProvider() : super();

  int calls = 0;
  int forceRefreshCalls = 0;

  @override
  Future<void> ensureLoaded({bool forceRefresh = false}) async {
    calls += 1;
    if (forceRefresh) {
      forceRefreshCalls += 1;
    }
  }
}

class SpyAnalyticsProvider extends AnalyticsProvider {
  SpyAnalyticsProvider() : super();

  int calls = 0;
  int forceRefreshCalls = 0;

  @override
  Future<void> ensureLoaded({bool forceRefresh = false}) async {
    calls += 1;
    if (forceRefresh) {
      forceRefreshCalls += 1;
    }
  }
}
