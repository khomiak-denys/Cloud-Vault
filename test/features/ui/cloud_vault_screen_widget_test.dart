import 'package:cloud_vault/api/api_client.dart';
import 'package:cloud_vault/api/api_repository.dart';
import 'package:cloud_vault/l10n/app_localizations.dart';
import 'package:cloud_vault/models/recent_file_item.dart';
import 'package:cloud_vault/screens/cloud_vault_screen.dart';
import 'package:cloud_vault/screens/storage_browser_screen.dart';
import 'package:cloud_vault/state/providers/connections_provider.dart';
import 'package:cloud_vault/state/providers/favorites_provider.dart';
import 'package:cloud_vault/widgets/loading_skeletons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('CloudVaultScreen renders storages and favorites from providers', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final _FakeDashboardRepository repository = _FakeDashboardRepository();
    final ConnectionsProvider connectionsProvider = ConnectionsProvider(
      repository: repository,
    );
    final FavoritesProvider favoritesProvider = FavoritesProvider(
      repository: repository,
    );
    await connectionsProvider.ensureLoaded(forceRefresh: true);
    await favoritesProvider.ensureLoaded(forceRefresh: true);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<ConnectionsProvider>.value(
            value: connectionsProvider,
          ),
          ChangeNotifierProvider<FavoritesProvider>.value(
            value: favoritesProvider,
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
          home: const CloudVaultScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(CloudVaultScreen), findsOneWidget);
    expect(find.text('My storages'), findsOneWidget);
    expect(find.text('Favorites'), findsOneWidget);
    expect(find.text('Dropbox'), findsWidgets);
    expect(find.text('report.pdf'), findsOneWidget);
  });

  testWidgets('CloudVaultScreen opens storage browser on storage tap', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final _FakeDashboardRepository repository = _FakeDashboardRepository();
    final ConnectionsProvider connectionsProvider = ConnectionsProvider(
      repository: repository,
    );
    final FavoritesProvider favoritesProvider = FavoritesProvider(
      repository: repository,
    );
    await connectionsProvider.ensureLoaded(forceRefresh: true);
    await favoritesProvider.ensureLoaded(forceRefresh: true);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<ConnectionsProvider>.value(
            value: connectionsProvider,
          ),
          ChangeNotifierProvider<FavoritesProvider>.value(
            value: favoritesProvider,
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
          home: const CloudVaultScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('Dropbox').first, warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.byType(StorageBrowserScreen), findsOneWidget);
  });

  testWidgets('CloudVaultScreen shows dashboard skeleton while loading', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<ConnectionsProvider>(
            create: (_) => _LoadingConnectionsProvider(),
          ),
          ChangeNotifierProvider<FavoritesProvider>(
            create: (_) => _LoadingFavoritesProvider(),
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
          home: const CloudVaultScreen(),
        ),
      ),
    );

    await tester.pump();

    expect(find.byType(DashboardLoadingSkeleton), findsOneWidget);
  });
}

class _FakeDashboardRepository extends ApiRepository {
  _FakeDashboardRepository() : super(ApiClient());

  @override
  Future<ApiUser?> me() async {
    return const ApiUser(
      uid: 'u1',
      email: 'user@example.com',
      name: 'User',
    );
  }

  @override
  Future<List<ApiConnection>> connections() async {
    return const <ApiConnection>[
      ApiConnection(
        id: 'c1',
        providerId: 'dropbox',
        providerName: 'Dropbox',
        usedBytes: 55,
        totalBytes: 100,
      ),
    ];
  }

  @override
  Future<List<ApiFileItem>> favoriteFiles({
    int? pageSize,
    String? cursor,
    String? connectionId,
    String? providerId,
  }) async {
    return <ApiFileItem>[
      ApiFileItem(
        id: 'f1',
        connectionId: 'c1',
        name: 'report.pdf',
        displayPath: '/Docs/report.pdf',
        sizeBytes: 1024,
        modifiedAt: DateTime.parse('2026-01-01T00:00:00.000Z'),
        providerId: 'dropbox',
        providerName: 'Dropbox',
        isFavorite: true,
        kind: 'file',
        mimeType: 'application/pdf',
      ),
    ];
  }
}

class _LoadingConnectionsProvider extends ConnectionsProvider {
  _LoadingConnectionsProvider() : super();

  @override
  bool get isLoading => true;

  @override
  Future<void> ensureConnectionsLoaded({bool forceRefresh = false}) async {}

  @override
  List<ApiConnection> get connections => const <ApiConnection>[];
}

class _LoadingFavoritesProvider extends FavoritesProvider {
  _LoadingFavoritesProvider() : super();

  @override
  bool get isLoading => true;

  @override
  Future<void> ensureLoaded({bool forceRefresh = false}) async {}

  @override
  List<RecentFileItem> get favoriteFiles => const <RecentFileItem>[];
}
