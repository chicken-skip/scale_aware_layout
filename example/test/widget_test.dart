import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scale_aware_layout_example/main.dart';

void main() {
  testWidgets('example app builds', (tester) async {
    await tester.pumpWidget(const ExampleApp());
    expect(find.text('Text Scale Torture Chamber'), findsOneWidget);
    expect(find.byType(Slider), findsOneWidget);
  });
}
