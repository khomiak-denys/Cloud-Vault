import 'package:cloud_vault/api/api_client.dart';
import 'package:cloud_vault/api/api_repository.dart';
import 'package:cloud_vault/l10n/app_localizations.dart';
import 'package:cloud_vault/screens/analytics_screen.dart';
import 'package:cloud_vault/state/providers/analytics_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('AnalyticsScreen renders populated analytics state', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final _FakeAnalyticsRepository repository = _FakeAnalyticsRepository();
    final AnalyticsProvider provider = AnalyticsProvider(repository: repository);
    await provider.ensureLoaded(forceRefresh: true);

    await tester.pumpWidget(
      ChangeNotifierProvider<AnalyticsProvider>.value(
        value: provider,
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: const AnalyticsScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Total space'), findsOneWidget);
    expect(find.text('Used'), findsOneWidget);
    expect(find.text('Free'), findsOneWidget);
    expect(find.text('Distribution by storages'), findsOneWidget);
    expect(find.text('Usage vs free space'), findsOneWidget);
    expect(find.text('Recommendations'), findsOneWidget);
    expect(find.text('Export PDF'), findsOneWidget);
    expect(find.text('Dropbox'), findsWidgets);
    expect(find.text('Google Drive'), findsWidgets);

    await tester.tap(find.text('Export PDF'), warnIfMissed: false);
    await tester.pumpAndSettle();
  });
}

class _FakeAnalyticsRepository extends ApiRepository {
  _FakeAnalyticsRepository() : super(ApiClient());

  @override
  Future<List<ApiConnection>> storageUsage() async {
    return const <ApiConnection>[
      ApiConnection(
        id: 'c1',
        providerId: 'dropbox',
        providerName: 'Dropbox',
        usedBytes: 90,
        totalBytes: 100,
      ),
      ApiConnection(
        id: 'c2',
        providerId: 'google-drive',
        providerName: 'Google Drive',
        usedBytes: 20,
        totalBytes: 100,
      ),
    ];
  }

  @override
  Future<List<ApiStorageRecommendation>> recommendations() async {
    return const <ApiStorageRecommendation>[
      ApiStorageRecommendation(
        title: 'Clean Dropbox',
        body: 'Remove old archives',
      ),
      ApiStorageRecommendation(
        title: 'Move media',
        body: 'Shift large videos to Drive',
      ),
    ];
  }
}
