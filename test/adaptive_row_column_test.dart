import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scale_aware_layout/scale_aware_layout.dart';

Widget _wrap(double scale, Widget child) {
  return MediaQuery(
    data: MediaQueryData(textScaler: TextScaler.linear(scale)),
    child: Directionality(textDirection: TextDirection.ltr, child: child),
  );
}

const _children = <Widget>[
  Text('A'),
  Text('B'),
  Text('C'),
];

void main() {
  testWidgets('renders a Row below breakScale', (tester) async {
    await tester.pumpWidget(
      _wrap(1.0, const AdaptiveRowColumn(children: _children)),
    );
    expect(find.byType(Row), findsOneWidget);
    expect(find.byType(Column), findsNothing);
  });

  testWidgets('reflows to a Column at/above breakScale', (tester) async {
    await tester.pumpWidget(
      _wrap(1.3, const AdaptiveRowColumn(children: _children)),
    );
    expect(find.byType(Column), findsOneWidget);
    expect(find.byType(Row), findsNothing);
  });

  testWidgets('preserves child order after reflow', (tester) async {
    await tester.pumpWidget(
      _wrap(2.0, const AdaptiveRowColumn(children: _children)),
    );
    final texts =
        tester.widgetList<Text>(find.byType(Text)).map((t) => t.data).toList();
    expect(texts, ['A', 'B', 'C']);
  });

  testWidgets('measure mode falls back to threshold in v0.1', (tester) async {
    await tester.pumpWidget(
      _wrap(
        1.5,
        const AdaptiveRowColumn(
          mode: AdaptiveAxisMode.measure,
          children: _children,
        ),
      ),
    );
    expect(find.byType(Column), findsOneWidget);
  });

  testWidgets('zero and one child do not crash', (tester) async {
    await tester.pumpWidget(_wrap(1.0, const AdaptiveRowColumn(children: [])));
    await tester.pumpWidget(
      _wrap(2.0, const AdaptiveRowColumn(children: [Text('solo')])),
    );
    expect(find.text('solo'), findsOneWidget);
  });
}
