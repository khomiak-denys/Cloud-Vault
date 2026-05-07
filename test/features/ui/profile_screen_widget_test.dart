import 'package:cloud_vault/api/api_repository.dart';
import 'package:cloud_vault/l10n/app_localizations.dart';
import 'package:cloud_vault/screens/profile_screen.dart';
import 'package:cloud_vault/state/providers/connections_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('ProfileScreen supports edit and save flow', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      ChangeNotifierProvider<ConnectionsProvider>(
        create: (_) => _FakeConnectionsProvider(),
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: const ProfileScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('Jane Tester'), findsWidgets);
    expect(find.text('jane@test.dev'), findsWidgets);

    await tester.tap(find.text('Edit'));
    await tester.pump();
    await tester.enterText(find.byType(TextField).first, 'Jane Updated');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Profile updated'), findsOneWidget);
  });
}

class _FakeConnectionsProvider extends ConnectionsProvider {
  _FakeConnectionsProvider() : super();

  @override
  ApiUser? get me => const ApiUser(
    uid: 'u1',
    email: 'jane@test.dev',
    name: 'Jane Tester',
  );

  @override
  List<ApiConnection> get connections => const <ApiConnection>[
    ApiConnection(
      id: 'c1',
      providerId: 'dropbox',
      providerName: 'Dropbox',
      usedBytes: 64,
      totalBytes: 128,
    ),
  ];

  @override
  double get profileUsedBytes => 64;

  @override
  bool get isLoading => false;

  @override
  Future<void> ensureLoaded({
    bool forceRefresh = false,
    bool includeMe = true,
  }) async {}
}
