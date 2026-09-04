import 'package:flutter_test/flutter_test.dart';

import 'package:cfo_shop/main.dart';

void main() {
  testWidgets('App boots to splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const CfoShopApp());
    await tester.pump();
    expect(find.text('CFO Shop'), findsWidgets);
  });
}
