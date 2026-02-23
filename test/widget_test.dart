import 'package:flutter_test/flutter_test.dart';

import 'package:cloud_vault/app.dart';

void main() {
  testWidgets('Search screen renders', (WidgetTester tester) async {
    await tester.pumpWidget(const CloudVaultApp());

    expect(find.text('Пошук'), findsWidgets);
    expect(find.text('Знайдено 5 файлів'), findsOneWidget);
    expect(find.text('Презентація проекту.pptx'), findsOneWidget);
  });
}
