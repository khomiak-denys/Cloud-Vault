import 'package:cloud_vault/l10n/app_localizations.dart';
import 'package:cloud_vault/models/vault_item.dart';
import 'package:cloud_vault/screens/storage_browser_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('StorageBrowserScreen renders controls and handles local actions', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: StorageBrowserScreen(storage: _sampleVault()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Dropbox'), findsOneWidget);
    expect(find.text('Root'), findsOneWidget);
    expect(find.text('New folder'), findsOneWidget);
    expect(find.text('Upload'), findsOneWidget);

    await tester.ensureVisible(find.text('Documents'));
    await tester.tap(find.text('Documents'), warnIfMissed: false);
    await tester.pump();
    await tester.ensureVisible(find.text('Images'));
    await tester.tap(find.text('Images'), warnIfMissed: false);
    await tester.pump();
    await tester.ensureVisible(find.text('Videos'));
    await tester.tap(find.text('Videos'), warnIfMissed: false);
    await tester.pump();
    await tester.ensureVisible(find.text('All'));
    await tester.tap(find.text('All'), warnIfMissed: false);
    await tester.pump();

    await tester.tap(find.byIcon(Icons.sort_rounded), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.sort_rounded), findsOneWidget);
  });
}

VaultItem _sampleVault() {
  return VaultItem(
    id: 'connection-1',
    providerId: 'dropbox',
    title: 'Dropbox',
    usageText: '1 GB / 2 GB',
    percentLabel: '50%',
    progress: 0.5,
    progressColor: Color(0xFF2563EB),
    icon: Icons.cloud_outlined,
  );
}
