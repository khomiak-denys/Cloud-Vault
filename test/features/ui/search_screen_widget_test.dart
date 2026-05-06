import 'package:cloud_vault/l10n/app_localizations.dart';
import 'package:cloud_vault/screens/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('SearchScreen renders and handles basic interactions', (
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
        home: const SearchScreen(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(SearchScreen), findsOneWidget);
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Documents'), findsOneWidget);
    expect(find.text('Images'), findsOneWidget);
    expect(find.text('Videos'), findsOneWidget);

    await tester.tap(find.text('Documents'), warnIfMissed: false);
    await tester.pump();
    await tester.tap(find.text('Images'), warnIfMissed: false);
    await tester.pump();
    await tester.tap(find.text('Videos'), warnIfMissed: false);
    await tester.pump();
    await tester.tap(find.text('All'), warnIfMissed: false);
    await tester.pump();

    final Finder queryField = find.byType(TextField).first;
    await tester.enterText(queryField, 'budget');
    await tester.pump(const Duration(milliseconds: 450));
    await tester.pumpAndSettle();

    expect(find.byType(SearchScreen), findsOneWidget);
  });
}
