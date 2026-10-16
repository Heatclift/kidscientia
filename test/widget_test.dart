import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kidscientia/main.dart';

void main() {
  testWidgets('KidScientia app shows the splash start button', (tester) async {
    await tester.pumpWidget(const KidScientiaApp());

    expect(find.text('START'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}
