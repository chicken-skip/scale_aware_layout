import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scale_aware_layout/scale_aware_layout.dart';

// The active subtree is identified by the guard's resulting size: `child` and
// `fallback` are given deliberately different extents on the cross axis.

Widget _host({
  required double? width,
  required double? height,
  required Axis axis,
}) {
  return MediaQuery(
    data: const MediaQueryData(textScaler: TextScaler.linear(1.0)),
    child: Directionality(
      textDirection: TextDirection.ltr,
      child: Align(
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: width,
          height: height,
          child: OverflowGuard(
            axis: axis,
            fallback: SizedBox(
              width: axis == Axis.horizontal ? 10 : 50,
              height: axis == Axis.horizontal ? 50 : 10,
            ),
            child: SizedBox(
              width: axis == Axis.horizontal ? 200 : 20,
              height: axis == Axis.horizontal ? 20 : 200,
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  group('horizontal', () {
    testWidgets('narrow constraints -> fallback', (tester) async {
      await tester.pumpWidget(
        _host(width: 100, height: null, axis: Axis.horizontal),
      );
      // fallback has cross-axis height 50.
      expect(tester.getSize(find.byType(OverflowGuard)).height, 50);
    });

    testWidgets('generous constraints -> child', (tester) async {
      await tester.pumpWidget(
        _host(width: 400, height: null, axis: Axis.horizontal),
      );
      // child has cross-axis height 20.
      expect(tester.getSize(find.byType(OverflowGuard)).height, 20);
    });
  });

  group('vertical', () {
    testWidgets('narrow constraints -> fallback', (tester) async {
      await tester.pumpWidget(
        _host(width: null, height: 100, axis: Axis.vertical),
      );
      // fallback has cross-axis width 50.
      expect(tester.getSize(find.byType(OverflowGuard)).width, 50);
    });

    testWidgets('generous constraints -> child', (tester) async {
      await tester.pumpWidget(
        _host(width: null, height: 400, axis: Axis.vertical),
      );
      // child has cross-axis width 20.
      expect(tester.getSize(find.byType(OverflowGuard)).width, 20);
    });
  });

  testWidgets('unbounded main axis never overflows (shows child)',
      (tester) async {
    await tester.pumpWidget(
      _host(width: null, height: null, axis: Axis.horizontal),
    );
    expect(tester.getSize(find.byType(OverflowGuard)).height, 20);
  });

  testWidgets('re-decides when constraints change', (tester) async {
    await tester.pumpWidget(
      _host(width: 400, height: null, axis: Axis.horizontal),
    );
    expect(tester.getSize(find.byType(OverflowGuard)).height, 20);

    await tester.pumpWidget(
      _host(width: 100, height: null, axis: Axis.horizontal),
    );
    expect(tester.getSize(find.byType(OverflowGuard)).height, 50);
  });
}
