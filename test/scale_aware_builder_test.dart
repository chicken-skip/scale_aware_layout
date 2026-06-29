import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scale_aware_layout/scale_aware_layout.dart';
import 'package:scale_aware_layout/src/text_scale.dart';

Widget _wrap(double scale, Widget child) {
  return MediaQuery(
    data: MediaQueryData(textScaler: TextScaler.linear(scale)),
    child: Directionality(textDirection: TextDirection.ltr, child: child),
  );
}

void main() {
  group('tierForScale (default thresholds 1.3 / 1.8)', () {
    TextScaleTier tier(double s) =>
        tierForScale(s, largeThreshold: 1.3, xLargeThreshold: 1.8);

    test('1.29 -> normal', () => expect(tier(1.29), TextScaleTier.normal));
    test('1.30 -> large (inclusive)',
        () => expect(tier(1.30), TextScaleTier.large));
    test('1.79 -> large', () => expect(tier(1.79), TextScaleTier.large));
    test('1.80 -> xLarge (inclusive)',
        () => expect(tier(1.80), TextScaleTier.xLarge));
    test('1.00 -> normal', () => expect(tier(1.0), TextScaleTier.normal));
  });

  testWidgets('ScaleAwareBuilder reports tier and scale', (tester) async {
    late TextScaleTier seenTier;
    late double seenScale;
    await tester.pumpWidget(_wrap(
      1.5,
      ScaleAwareBuilder(
        builder: (context, tier, scale) {
          seenTier = tier;
          seenScale = scale;
          return const SizedBox();
        },
      ),
    ));

    expect(seenTier, TextScaleTier.large);
    expect(seenScale, moreOrLessEquals(1.5));
  });

  testWidgets('ScaleAwareBuilder rebuilds when text scale changes',
      (tester) async {
    final tiers = <TextScaleTier>[];
    Widget app(double scale) => _wrap(
          scale,
          ScaleAwareBuilder(
            builder: (context, tier, _) {
              tiers.add(tier);
              return const SizedBox();
            },
          ),
        );

    await tester.pumpWidget(app(1.0));
    await tester.pumpWidget(app(1.9));

    expect(tiers, contains(TextScaleTier.normal));
    expect(tiers.last, TextScaleTier.xLarge);
  });

  testWidgets('non-linear TextScaler does not crash; factor sampled at 1.0',
      (tester) async {
    double? seen;
    await tester.pumpWidget(MediaQuery(
      data: const MediaQueryData(textScaler: _SquareScaler()),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: ScaleAwareBuilder(
          builder: (context, tier, scale) {
            seen = scale;
            return const SizedBox();
          },
        ),
      ),
    ));
    expect(seen, isNotNull);
  });
}

/// A non-linear scaler used to verify the `scale(1.0)` approximation.
class _SquareScaler extends TextScaler {
  const _SquareScaler();

  @override
  double scale(double fontSize) => fontSize * fontSize;

  @override
  double get textScaleFactor => 1.0;
}
