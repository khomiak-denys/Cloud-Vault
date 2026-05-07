import 'package:cloud_vault/l10n/app_localizations.dart';
import 'package:cloud_vault/screens/search_screen.dart';
import 'package:cloud_vault/utils/tab_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('handleBottomNavTap does nothing for current index', (WidgetTester tester) async {
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
        home: Builder(
          builder: (BuildContext context) {
            return Scaffold(
              body: Center(
                child: TextButton(
                  onPressed: () => handleBottomNavTap(context, 1, 1),
                  child: const Text('go'),
                ),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();

    expect(find.text('go'), findsOneWidget);
  });

  testWidgets('handleBottomNavTap opens search for index 1', (WidgetTester tester) async {
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
        home: Builder(
          builder: (BuildContext context) {
            return Scaffold(
              body: Center(
                child: TextButton(
                  onPressed: () => handleBottomNavTap(context, 0, 1),
                  child: const Text('go-search'),
                ),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('go-search'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 220));

    expect(find.byType(SearchScreen), findsOneWidget);
  });
}
