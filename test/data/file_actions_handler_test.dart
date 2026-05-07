import 'package:cloud_vault/data/file_actions_handler.dart';
import 'package:cloud_vault/models/recent_file_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('copy and unknown actions return false', (
    WidgetTester tester,
  ) async {
    final _ActionHarnessState harness = await _pumpHarness(
      tester,
      file: _file(),
    );

    await harness.run('copy');
    expect(harness.lastResult, isFalse);

    await harness.run('unknown');
    expect(harness.lastResult, isFalse);
  });

  testWidgets('star action rejects missing scoped connectionId', (
    WidgetTester tester,
  ) async {
    final _ActionHarnessState harness = await _pumpHarness(
      tester,
      file: _file(connectionId: 'all'),
    );

    await harness.run('star');
    expect(harness.lastResult, isFalse);
  });

  testWidgets('download and share handle api errors', (WidgetTester tester) async {
    final _ActionHarnessState harness = await _pumpHarness(
      tester,
      file: _file(),
    );

    await harness.run('download');
    expect(harness.lastResult, isFalse);

    await harness.run('share');
    expect(harness.lastResult, isFalse);
  });

  testWidgets('rename and delete dialogs complete and handle api errors', (
    WidgetTester tester,
  ) async {
    final _ActionHarnessState harness = await _pumpHarness(
      tester,
      file: _file(),
    );

    final Future<void> renameFuture = harness.run('rename');
    await tester.pumpAndSettle();
    expect(find.text('Rename file'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'renamed.txt');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    await renameFuture;
    expect(harness.lastResult, isFalse);

    final Future<void> deleteFuture = harness.run('delete');
    await tester.pumpAndSettle();
    expect(find.text('Delete file'), findsOneWidget);
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    await deleteFuture;
    expect(harness.lastResult, isFalse);

  });
}

Future<_ActionHarnessState> _pumpHarness(
  WidgetTester tester, {
  required RecentFileItem file,
}) async {
  final GlobalKey<_ActionHarnessState> key = GlobalKey<_ActionHarnessState>();
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: _ActionHarness(
          key: key,
          file: file,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return key.currentState!;
}

class _ActionHarness extends StatefulWidget {
  const _ActionHarness({super.key, required this.file});

  final RecentFileItem file;

  @override
  State<_ActionHarness> createState() => _ActionHarnessState();
}

class _ActionHarnessState extends State<_ActionHarness> {
  bool? lastResult;

  Future<void> run(String actionId) async {
    lastResult = await handleFileAction(context, actionId, widget.file);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(lastResult?.toString() ?? 'null');
  }
}

RecentFileItem _file({String connectionId = 'connection-1'}) {
  return RecentFileItem(
    id: 'file-1',
    connectionId: connectionId,
    providerId: 'dropbox',
    title: 'sample.txt',
    subtitle: 'Dropbox',
    icon: Icons.insert_drive_file_outlined,
    iconColor: const Color(0xFF2563EB),
    storageName: 'Dropbox',
    sizeLabel: '1 KB',
    modifiedLabel: '2026-01-01',
    sizeBytes: 1024,
    modifiedAt: DateTime.parse('2026-01-01T00:00:00.000Z'),
    pathLabel: '/sample.txt',
    kind: 'file',
    isFavorite: false,
  );
}
