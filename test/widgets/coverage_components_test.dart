import 'package:cloud_vault/l10n/app_localizations.dart';
import 'package:cloud_vault/modals/file_actions_modal.dart';
import 'package:cloud_vault/modals/language_modal.dart';
import 'package:cloud_vault/models/add_vault_option.dart';
import 'package:cloud_vault/models/file_action_option.dart';
import 'package:cloud_vault/models/recent_file_item.dart';
import 'package:cloud_vault/models/storage_usage_item.dart';
import 'package:cloud_vault/models/vault_item.dart';
import 'package:cloud_vault/utils/interaction_styles.dart';
import 'package:cloud_vault/widgets/add_vault_option_tile.dart';
import 'package:cloud_vault/widgets/analytics/analytics_components.dart';
import 'package:cloud_vault/widgets/file_action_row.dart';
import 'package:cloud_vault/widgets/recent_file_card.dart';
import 'package:cloud_vault/widgets/search/search_category_chip.dart';
import 'package:cloud_vault/widgets/search/search_header.dart';
import 'package:cloud_vault/widgets/search/search_results_section.dart';
import 'package:cloud_vault/widgets/search_result_card.dart';
import 'package:cloud_vault/widgets/settings/connected_storages_card.dart';
import 'package:cloud_vault/widgets/vault_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('UI components coverage', () {
    testWidgets('SearchCategoryChip triggers callback on tap', (
      WidgetTester tester,
    ) async {
      int taps = 0;
      await tester.pumpWidget(
        _testApp(
          child: SearchCategoryChip(
            label: 'Documents',
            isActive: true,
            onTap: () => taps += 1,
          ),
        ),
      );

      await tester.tap(find.text('Documents'));
      await tester.pump();

      expect(taps, 1);
    });

    testWidgets('SearchHeader renders and emits interactions', (
      WidgetTester tester,
    ) async {
      final TextEditingController controller = TextEditingController(text: 'abc');
      addTearDown(controller.dispose);

      String changedQuery = '';
      SearchCategory? selectedCategory;
      int clearTapCount = 0;

      await tester.pumpWidget(
        _testApp(
          child: SearchHeader(
            title: 'Search',
            hintText: 'Search files',
            controller: controller,
            labels: const SearchHeaderLabels(
              all: 'All',
              documents: 'Documents',
              images: 'Images',
              videos: 'Videos',
            ),
            selectedCategory: SearchCategory.all,
            onQueryChanged: (String value) => changedQuery = value,
            onClearTap: () => clearTapCount += 1,
            onCategoryChanged: (SearchCategory category) {
              selectedCategory = category;
            },
            showTitle: true,
          ),
        ),
      );

      expect(find.text('Search'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'invoice');
      await tester.pump();

      expect(changedQuery, 'invoice');

      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();
      expect(clearTapCount, 1);

      await tester.tap(find.text('Images'));
      await tester.pump();
      expect(selectedCategory, SearchCategory.images);
    });

    testWidgets('SearchResultCard shows favorite badge and handles more tap', (
      WidgetTester tester,
    ) async {
      int moreTapCount = 0;
      final RecentFileItem item = _sampleFile(isFavorite: true);

      await tester.pumpWidget(
        _testApp(
          child: SearchResultCard(
            item: item,
            onMoreTap: () => moreTapCount += 1,
          ),
        ),
      );

      expect(find.text(item.title), findsOneWidget);
      expect(find.byIcon(Icons.star), findsOneWidget);

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pump();

      expect(moreTapCount, 1);
    });

    testWidgets('SearchResultsSection supports empty and non-empty states', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _testApp(
          child: const SearchResultsSection(
            resultsLabel: 'Found 0 files',
            results: <RecentFileItem>[],
            emptyStateMessage: 'Nothing found',
            onMoreTap: _noOpFileCallback,
          ),
        ),
      );

      expect(find.text('Nothing found'), findsOneWidget);
      expect(find.byIcon(Icons.search_rounded), findsOneWidget);

      await tester.pumpWidget(
        _testApp(
          child: SearchResultsSection(
            resultsLabel: 'Found 1 files',
            results: <RecentFileItem>[_sampleFile()],
            emptyStateMessage: 'Nothing found',
            onMoreTap: _noOpFileCallback,
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Found 1 files'), findsOneWidget);
      expect(find.byType(SearchResultCard), findsOneWidget);
    });

    testWidgets('RecentFileCard handles more tap and renders metadata', (
      WidgetTester tester,
    ) async {
      int moreTapCount = 0;
      final RecentFileItem item = _sampleFile(isFavorite: true);

      await tester.pumpWidget(
        _testApp(
          child: RecentFileCard(
            item: item,
            onMoreTap: () => moreTapCount += 1,
          ),
        ),
      );

      expect(find.text(item.title), findsOneWidget);
      expect(find.byIcon(Icons.star), findsOneWidget);

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pump();

      expect(moreTapCount, 1);
    });

    testWidgets('VaultCard renders warning branch and onTap callback', (
      WidgetTester tester,
    ) async {
      int taps = 0;

      await tester.pumpWidget(
        _testApp(
          child: VaultCard(
            item: const VaultItem(
              id: 'v1',
              providerId: 'dropbox',
              title: 'Dropbox',
              usageText: '95 GB / 100 GB',
              percentLabel: '95%',
              progress: 0.95,
              progressColor: Colors.blue,
              icon: Icons.inventory_2,
              hasWarning: true,
            ),
            onTap: () => taps += 1,
            compact: true,
          ),
        ),
      );

      expect(find.text('Dropbox'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);

      await tester.tap(find.text('Dropbox'));
      await tester.pump();

      expect(taps, 1);
    });

    testWidgets('AddVaultOptionTile reacts to tap', (WidgetTester tester) async {
      int taps = 0;

      await tester.pumpWidget(
        _testApp(
          child: AddVaultOptionTile(
            option: const AddVaultOption(
              providerId: 'dropbox',
              title: 'Dropbox',
              icon: Icons.inventory_2,
            ),
            isSelected: true,
            onTap: () => taps += 1,
          ),
        ),
      );

      await tester.tap(find.text('Dropbox'));
      await tester.pump();

      expect(taps, 1);
    });

    testWidgets('FileActionRow invokes callback', (WidgetTester tester) async {
      int taps = 0;

      await tester.pumpWidget(
        _testApp(
          child: FileActionRow(
            action: const FileActionOption(
              icon: Icons.share_outlined,
              label: 'Share',
              actionId: 'share',
            ),
            onTap: () => taps += 1,
          ),
        ),
      );

      await tester.tap(find.text('Share'));
      await tester.pump();

      expect(taps, 1);
    });

    testWidgets('ConnectedStoragesCard supports add and disconnect actions', (
      WidgetTester tester,
    ) async {
      int addTapCount = 0;
      int disconnectTapCount = 0;

      await tester.pumpWidget(
        _testApp(
          child: ConnectedStoragesCard(
            title: 'Connected storages',
            addLabel: 'Add',
            connectedLabel: 'Connected',
            items: const <VaultItem>[
              VaultItem(
                id: 'v1',
                providerId: 'dropbox',
                title: 'Dropbox',
                usageText: '10 / 100',
                percentLabel: '10%',
                progress: 0.1,
                progressColor: Colors.blue,
                icon: Icons.inventory_2,
              ),
              VaultItem(
                id: 'v2',
                providerId: 'google-drive',
                title: 'Google Drive',
                usageText: '20 / 100',
                percentLabel: '20%',
                progress: 0.2,
                progressColor: Colors.blue,
                icon: Icons.folder,
              ),
            ],
            onAddTap: () => addTapCount += 1,
            onDisconnect: (_) => disconnectTapCount += 1,
          ),
        ),
      );

      await tester.tap(find.text('Add'));
      await tester.pump();
      expect(addTapCount, 1);

      await tester.tap(find.byIcon(Icons.delete_outline).first);
      await tester.pump();
      expect(disconnectTapCount, 1);
    });

  });
}
Widget _testApp({required Widget child}) {
  return MaterialApp(
    locale: const Locale('en'),
    localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  );
}

RecentFileItem _sampleFile({bool isFavorite = false}) {
  return RecentFileItem(
    id: 'f1',
    connectionId: 'c1',
    providerId: 'dropbox',
    title: 'report.pdf',
    subtitle: 'Dropbox - 2026-01-01',
    icon: Icons.description_outlined,
    iconColor: const Color(0xFFFF7A00),
    storageName: 'Dropbox',
    sizeLabel: '10 MB',
    modifiedLabel: '2026-01-01',
    sizeBytes: 10,
    modifiedAt: DateTime.parse('2026-01-01T00:00:00.000Z'),
    pathLabel: '/report.pdf',
    isFavorite: isFavorite,
    badgeIcon: isFavorite ? Icons.star : null,
    badgeColor: isFavorite ? const Color(0xFFF6C215) : null,
    kind: 'file',
    mimeType: 'application/pdf',
  );
}

void _noOpFileCallback(RecentFileItem _) {}
