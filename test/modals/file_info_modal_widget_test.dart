import 'package:cloud_vault/l10n/app_localizations.dart';
import 'package:cloud_vault/modals/file_info_modal.dart';
import 'package:cloud_vault/models/recent_file_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('FileInfo modal opens and closes', (WidgetTester tester) async {
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
                  onPressed: () => showFileInfoModal(context, _sampleFile()),
                  child: const Text('open-file-info'),
                ),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('open-file-info'));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('File information'), findsOneWidget);
    expect(find.text('budget.pdf'), findsOneWidget);

    expect(find.text('Close'), findsOneWidget);
  });
}

RecentFileItem _sampleFile() {
  return RecentFileItem(
    id: 'file-1',
    connectionId: 'connection-1',
    providerId: 'dropbox',
    title: 'budget.pdf',
    subtitle: 'Dropbox',
    icon: Icons.picture_as_pdf_outlined,
    iconColor: const Color(0xFFEF4444),
    storageName: 'Dropbox',
    sizeLabel: '1.2 MB',
    modifiedLabel: '2026-01-02',
    sizeBytes: 1200000,
    modifiedAt: DateTime.parse('2026-01-02T00:00:00.000Z'),
    pathLabel: '/Docs/budget.pdf',
    kind: 'file',
    mimeType: 'application/pdf',
  );
}
