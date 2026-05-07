import 'package:cloud_vault/l10n/app_localizations.dart';
import 'package:cloud_vault/modals/add_vault_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('AddVault modal opens and supports selection flow', (
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
        home: Scaffold(
          body: Builder(
            builder: (BuildContext context) {
              return Center(
                child: ElevatedButton(
                  onPressed: () => showAddVaultModal(context),
                  child: const Text('open-modal'),
                ),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('open-modal'));
    await tester.pumpAndSettle();

    expect(find.text('Add storage'), findsOneWidget);
    expect(find.text('Choose cloud storage you want to connect'), findsOneWidget);

    final Finder optionTiles = find.byType(InkWell);
    if (optionTiles.evaluate().isNotEmpty) {
      await tester.tap(optionTiles.first, warnIfMissed: false);
      await tester.pump();
    }

    await tester.tap(find.text('Connect').last, warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.text('Add storage'), findsOneWidget);
  });

  testWidgets('AddVault modal supports MEGA connect dialog flow', (
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
        home: Scaffold(
          body: Builder(
            builder: (BuildContext context) {
              return Center(
                child: ElevatedButton(
                  onPressed: () => showAddVaultModal(context),
                  child: const Text('open-modal-2'),
                ),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('open-modal-2'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('MEGA'), warnIfMissed: false);
    await tester.pump();
    await tester.tap(find.text('Connect').last, warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.text('Connect MEGA'), findsOneWidget);
    expect(find.text('Email and password are required'), findsNothing);

    await tester.tap(find.text('Connect').last, warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.text('Email and password are required'), findsOneWidget);

    await tester.tap(find.text('Cancel').last, warnIfMissed: false);
    await tester.pumpAndSettle();
  });
}
