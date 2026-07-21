import 'package:flutter_test/flutter_test.dart';

import 'package:ahassu/main.dart';

void main() {
  testWidgets('AhassuApp builds without throwing', (WidgetTester tester) async {
    await tester.pumpWidget(const AhassuApp());
    await tester.pump();
  });
}
