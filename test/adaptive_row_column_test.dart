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

  testWidgets('spacing inserts gaps with no trailing gap (Row)',
      (tester) async {
    await tester.pumpWidget(
      _wrap(
        1.0,
        const AdaptiveRowColumn(spacing: 8, children: _children),
      ),
    );
    // 3 children -> exactly 2 interior gaps, none after the last.
    expect(find.byType(SizedBox), findsNWidgets(2));
  });

  testWidgets('spacing inserts gaps with no trailing gap (Column)',
      (tester) async {
    await tester.pumpWidget(
      _wrap(
        2.0,
        const AdaptiveRowColumn(spacing: 8, children: _children),
      ),
    );
    expect(find.byType(SizedBox), findsNWidgets(2));
  });

  testWidgets('no spacing widgets when spacing is 0', (tester) async {
    await tester.pumpWidget(
      _wrap(1.0, const AdaptiveRowColumn(children: _children)),
    );
    expect(find.byType(SizedBox), findsNothing);
  });

  testWidgets(
      'respects RTL: children keep logical order, laid out right-to-left',
      (tester) async {
    await tester.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(1.0)),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: AdaptiveRowColumn(spacing: 8, children: _children),
        ),
      ),
    );
    // Logical (semantic) order is preserved...
    final texts =
        tester.widgetList<Text>(find.byType(Text)).map((t) => t.data).toList();
    expect(texts, ['A', 'B', 'C']);
    // ...but visually the first child sits to the right of the last child.
    final firstDx = tester.getCenter(find.text('A')).dx;
    final lastDx = tester.getCenter(find.text('C')).dx;
    expect(firstDx, greaterThan(lastDx));
  });
}
