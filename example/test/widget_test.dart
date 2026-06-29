import 'package:flutter_test/flutter_test.dart';
import 'package:scale_aware_layout_example/main.dart';

void main() {
  testWidgets('example app builds', (tester) async {
    await tester.pumpWidget(const ExampleApp());
    expect(find.text('scale_aware_layout'), findsOneWidget);
  });
}
