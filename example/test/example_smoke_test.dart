import 'package:design_scale_example/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('example app renders through DesignScale', (tester) async {
    await tester.pumpWidget(const ExampleApp());

    expect(find.text('design_scale example'), findsOneWidget);
    expect(find.text('Reference-based design space'), findsOneWidget);
  });
}
