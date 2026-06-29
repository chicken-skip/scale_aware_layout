@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scale_aware_layout/scale_aware_layout.dart';

// Golden tests are tagged `golden` and excluded from the cross-platform CI gate
// (`flutter test --exclude-tags golden`) because font rasterization differs
// across operating systems. Regenerate locally with:
//
//   flutter test --update-goldens --tags golden
//
// and review the committed PNGs under test/goldens/.

Widget _sample(double scale) {
  return MediaQuery(
    data: MediaQueryData(textScaler: TextScaler.linear(scale)),
    child: Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
        width: 360,
        color: const Color(0xFFFFFFFF),
        padding: const EdgeInsets.all(12),
        child: const AdaptiveRowColumn(
          spacing: 8,
          children: [
            Icon(Icons.bolt, color: Color(0xFF6750A4)),
            Text('Label'),
            DecoratedBox(
              decoration: BoxDecoration(color: Color(0xFF6750A4)),
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Text('Go', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

void main() {
  for (final scale in const [1.0, 1.5, 2.0]) {
    testWidgets('AdaptiveRowColumn golden @ scale $scale', (tester) async {
      await tester.pumpWidget(Center(child: _sample(scale)));
      await expectLater(
        find.byType(AdaptiveRowColumn),
        matchesGoldenFile(
          'goldens/adaptive_row_column_${scale.toStringAsFixed(1)}.png',
        ),
      );
    });
  }
}
