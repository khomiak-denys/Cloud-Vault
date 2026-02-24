import 'package:flutter_test/flutter_test.dart';

import 'package:cloud_vault/app.dart';

void main() {
  testWidgets('Search screen renders', (WidgetTester tester) async {
    await tester.pumpWidget(const CloudVaultApp());

    expect(find.text('Вхід'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Пароль'), findsOneWidget);
  });
}
