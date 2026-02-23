import 'package:flutter_test/flutter_test.dart';

import 'package:cloud_vault/main.dart';

void main() {
  testWidgets('CloudVault screen renders', (WidgetTester tester) async {
    await tester.pumpWidget(const CloudVaultApp());

    expect(find.text('CloudVault'), findsOneWidget);
    expect(find.text('Мої сховища'), findsOneWidget);
    expect(find.text('Google Drive'), findsOneWidget);
  });
}
