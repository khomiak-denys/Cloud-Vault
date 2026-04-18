import 'package:cloud_vault/l10n/app_localizations.dart';
import 'package:cloud_vault/models/recent_file_item.dart';
import 'package:cloud_vault/screens/file_preview_screen.dart';
import 'package:cloud_vault/screens/login_screen.dart';
import 'package:cloud_vault/screens/register_screen.dart';
import 'package:cloud_vault/widgets/bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Auth and navigation UI coverage', () {
    testWidgets('Login screen toggles remember-me and navigates to register', (
      WidgetTester tester,
    ) async {
      _setLargeViewport(tester);
      await tester.pumpWidget(_buildTestApp(home: const LoginScreen()));
      await tester.pump();

      final AppLocalizations l10n = AppLocalizations.of(
        tester.element(find.byType(LoginScreen)),
      )!;

      Checkbox checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.value, isFalse);

      await tester.tap(find.byType(Checkbox));
      await tester.pump();
      checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.value, isTrue);

      await tester.tap(find.text(l10n.authGoRegister));
      await tester.pumpAndSettle();

      expect(find.byType(RegisterScreen), findsOneWidget);
    });

    testWidgets(
      'Login submit with empty fields stays on login and does not open home',
      (WidgetTester tester) async {
        _setLargeViewport(tester);
        await tester.pumpWidget(
          _buildRoutedTestApp(
            initialRoute: '/login',
            routes: <String, WidgetBuilder>{
              '/login': (_) => const LoginScreen(),
              '/': (_) => const Scaffold(body: Text('home-destination')),
            },
          ),
        );
        await tester.pump();

        final Finder signInButton = find.byType(ElevatedButton).first;
        await tester.ensureVisible(signInButton);
        await tester.tap(signInButton);
        await tester.pumpAndSettle();

        expect(find.byType(LoginScreen), findsOneWidget);
        expect(find.text('home-destination'), findsNothing);
        expect(find.byType(SnackBar), findsNothing);
      },
    );

    testWidgets(
      'Register submit validates fields then navigates to home when valid',
      (WidgetTester tester) async {
        _setLargeViewport(tester);
        await tester.pumpWidget(
          _buildRoutedTestApp(
            initialRoute: '/register',
            routes: <String, WidgetBuilder>{
              '/register': (_) => const RegisterScreen(),
              '/': (_) => const Scaffold(body: Text('home-destination')),
            },
          ),
        );
        await tester.pump();

        final Finder signUpButton = find.byType(ElevatedButton).first;
        await tester.ensureVisible(signUpButton);
        await tester.tap(signUpButton);
        await tester.pumpAndSettle();
        expect(find.byType(RegisterScreen), findsOneWidget);
        expect(find.text('home-destination'), findsNothing);

        final Finder textFields = find.byType(TextField);
        expect(textFields, findsNWidgets(4));
        await tester.enterText(textFields.at(0), 'Denys Tester');
        await tester.enterText(textFields.at(1), 'denys@example.com');
        await tester.enterText(textFields.at(2), 'strong-password');
        await tester.enterText(textFields.at(3), 'strong-password');
        final Finder termsCheckbox = find.byType(Checkbox).first;
        await tester.ensureVisible(termsCheckbox);
        await tester.tap(termsCheckbox);
        await tester.pump();

        await tester.ensureVisible(signUpButton);
        await tester.tap(signUpButton);
        await tester.pumpAndSettle();

        expect(find.text('home-destination'), findsOneWidget);
      },
    );

    testWidgets('Register "go login" pops back to LoginScreen', (
      WidgetTester tester,
    ) async {
      _setLargeViewport(tester);
      await tester.pumpWidget(_buildTestApp(home: const LoginScreen()));
      await tester.pump();

      final AppLocalizations loginL10n = AppLocalizations.of(
        tester.element(find.byType(LoginScreen)),
      )!;

      await tester.tap(find.text(loginL10n.authGoRegister));
      await tester.pumpAndSettle();
      expect(find.byType(RegisterScreen), findsOneWidget);

      final AppLocalizations registerL10n = AppLocalizations.of(
        tester.element(find.byType(RegisterScreen)),
      )!;
      await tester.tap(find.text(registerL10n.authGoLogin));
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('BottomNavBar emits tap index for all tabs', (
      WidgetTester tester,
    ) async {
      _setLargeViewport(tester);
      final List<int> taps = <int>[];
      await tester.pumpWidget(
        _buildTestApp(
          home: Scaffold(
            body: Align(
              alignment: Alignment.bottomCenter,
              child: BottomNavBar(
                activeIndex: 2,
                onTap: (int index) => taps.add(index),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      final AppLocalizations l10n = AppLocalizations.of(
        tester.element(find.byType(BottomNavBar)),
      )!;

      await tester.tap(find.text(l10n.navHome));
      await tester.tap(find.text(l10n.navSearch));
      await tester.tap(find.text(l10n.navAnalytics));
      await tester.tap(find.text(l10n.navSettings));
      await tester.pump();

      expect(taps, <int>[0, 1, 2, 3]);
    });

    testWidgets('File preview for folder shows unsupported state only', (
      WidgetTester tester,
    ) async {
      _setLargeViewport(tester);
      await tester.pumpWidget(
        _buildTestApp(home: FilePreviewScreen(file: _sampleFolderFile())),
      );
      await tester.pump();
      await tester.pump();

      final AppLocalizations l10n = AppLocalizations.of(
        tester.element(find.byType(FilePreviewScreen)),
      )!;

      expect(find.text(l10n.filePreviewFolderUnsupported), findsOneWidget);
      expect(find.text(l10n.filePreviewOpenExternal), findsNothing);
    });
  });
}

void _setLargeViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(1200, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

Widget _buildTestApp({required Widget home}) {
  return MaterialApp(
    locale: const Locale('en'),
    localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: home,
  );
}

Widget _buildRoutedTestApp({
  required String initialRoute,
  required Map<String, WidgetBuilder> routes,
}) {
  return MaterialApp(
    locale: const Locale('en'),
    localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    initialRoute: initialRoute,
    routes: routes,
  );
}

RecentFileItem _sampleFolderFile() {
  return RecentFileItem(
    id: 'folder-1',
    connectionId: 'connection-1',
    providerId: 'dropbox',
    title: 'Folder',
    subtitle: 'Dropbox',
    icon: Icons.folder_outlined,
    iconColor: const Color(0xFF2563EB),
    storageName: 'Dropbox',
    sizeLabel: '--',
    modifiedLabel: '2026-01-01',
    sizeBytes: 0,
    modifiedAt: DateTime.parse('2026-01-01T00:00:00.000Z'),
    pathLabel: '/Folder',
    kind: 'folder',
  );
}
