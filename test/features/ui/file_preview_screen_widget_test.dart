import 'package:cloud_vault/l10n/app_localizations.dart';
import 'package:cloud_vault/models/recent_file_item.dart';
import 'package:cloud_vault/screens/file_preview_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('FilePreview shows unsupported type for text file', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_app(file: _file('notes.txt', kind: 'file')));
    await tester.pumpAndSettle();

    expect(
      find.text('This file type is not supported for in-app preview'),
      findsOneWidget,
    );
  });

  testWidgets('FilePreview shows pdf too large for oversized dropbox pdf', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _app(
        file: _file(
          'report.pdf',
          kind: 'file',
          providerId: 'dropbox',
          sizeBytes: 40 * 1024 * 1024,
          mimeType: 'application/pdf',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('PDF is too large for in-app preview. Open externally.'),
      findsOneWidget,
    );
  });

  testWidgets('FilePreview shows load failed for oversized dropbox image', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _app(
        file: _file(
          'photo.jpg',
          kind: 'file',
          providerId: 'dropbox',
          sizeBytes: 30 * 1024 * 1024,
          mimeType: 'image/jpeg',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Failed to load preview'), findsOneWidget);
  });

  testWidgets('FilePreview shows video init failure on missing stream path', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _app(
        file: _file(
          'clip.mp4',
          kind: 'file',
          providerId: 'dropbox',
          mimeType: 'video/mp4',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('API error:'), findsOneWidget);
  });
}

Widget _app({required RecentFileItem file}) {
  return MaterialApp(
    locale: const Locale('en'),
    localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: FilePreviewScreen(file: file),
  );
}

RecentFileItem _file(
  String title, {
  required String kind,
  String providerId = 'google-drive',
  double sizeBytes = 1024,
  String? mimeType,
}) {
  return RecentFileItem(
    id: 'file-1',
    connectionId: 'connection-1',
    providerId: providerId,
    title: title,
    subtitle: 'Storage',
    icon: Icons.insert_drive_file_outlined,
    iconColor: const Color(0xFF2563EB),
    storageName: 'Storage',
    sizeLabel: '1 KB',
    modifiedLabel: '2026-01-01',
    sizeBytes: sizeBytes,
    modifiedAt: DateTime.parse('2026-01-01T00:00:00.000Z'),
    pathLabel: '/$title',
    kind: kind,
    mimeType: mimeType,
  );
}
