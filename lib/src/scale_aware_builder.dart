import 'package:flutter/widgets.dart';

import 'text_scale.dart';
import 'text_scale_tier.dart';

/// Rebuilds its subtree against the current text scale, exposing both a coarse
/// [TextScaleTier] and the raw linear scale factor.
///
/// Use it to branch your own layout on the user's accessibility text size
/// without reading [MediaQuery] yourself. The builder is re-invoked whenever the
/// text scale changes.
///
/// ```dart
/// ScaleAwareBuilder(
///   builder: (context, tier, scale) {
///     if (tier == TextScaleTier.normal) {
///       return Row(children: const [Icon(Icons.star), Text('Featured')]);
///     }
///     return Column(children: const [Icon(Icons.star), Text('Featured')]);
///   },
/// )
/// ```
class ScaleAwareBuilder extends StatelessWidget {
  /// Creates a builder that reacts to the ambient text scale.
  ///
  /// [largeThreshold] and [xLargeThreshold] define the (inclusive) factor
  /// boundaries used to compute the [TextScaleTier] passed to [builder].
  const ScaleAwareBuilder({
    super.key,
    required this.builder,
    this.largeThreshold = 1.3,
    this.xLargeThreshold = 1.8,
  });

  /// Called with the current [TextScaleTier] and the effective linear scale
  /// factor (`MediaQuery.textScalerOf(context).scale(1.0)`).
  ///
  /// ```dart
  /// builder: (context, tier, scale) => Text('x$scale');
  /// ```
  final Widget Function(BuildContext context, TextScaleTier tier, double scale)
      builder;

  /// A factor `>= largeThreshold` maps to [TextScaleTier.large].
  ///
  /// Defaults to `1.3` (130% of the default text size).
  final double largeThreshold;

  /// A factor `>= xLargeThreshold` maps to [TextScaleTier.xLarge].
  ///
  /// Defaults to `1.8` (180% of the default text size).
  final double xLargeThreshold;

  @override
  Widget build(BuildContext context) {
    final scale = effectiveTextScaleFactor(context);
    final tier = tierForScale(
      scale,
      largeThreshold: largeThreshold,
      xLargeThreshold: xLargeThreshold,
    );
    return builder(context, tier, scale);
  }
}
