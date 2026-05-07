import 'package:cloud_vault/widgets/loading_skeletons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('renders all loading skeleton variants', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: [
                DashboardLoadingSkeleton(),
                SearchLoadingSkeleton(),
                AnalyticsLoadingSkeleton(),
                ProfileLoadingSkeleton(),
                SettingsLoadingSkeleton(),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 950));

    expect(find.byType(SkeletonBlock), findsWidgets);
    expect(find.byType(DashboardLoadingSkeleton), findsOneWidget);
    expect(find.byType(SearchLoadingSkeleton), findsOneWidget);
    expect(find.byType(AnalyticsLoadingSkeleton), findsOneWidget);
    expect(find.byType(ProfileLoadingSkeleton), findsOneWidget);
    expect(find.byType(SettingsLoadingSkeleton), findsOneWidget);
  });
}
