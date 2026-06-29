import 'package:flutter/widgets.dart';

import 'text_scale_tier.dart';

/// Returns the effective linear text-scale factor for [context].
///
/// Derived from `MediaQuery.textScalerOf(context).scale(1.0)`. For non-linear
/// [TextScaler]s this is an approximation sampled at a font size of `1.0`; it
/// never throws.
///
/// Reading this inside a build method registers a dependency on the ambient
/// [MediaQuery], so the widget rebuilds when the user changes their text scale.
double effectiveTextScaleFactor(BuildContext context) =>
    MediaQuery.textScalerOf(context).scale(1.0);

/// Maps a linear [scale] factor to a [TextScaleTier].
///
/// Boundaries are inclusive: a factor exactly equal to [largeThreshold] maps to
/// [TextScaleTier.large], and one equal to [xLargeThreshold] maps to
/// [TextScaleTier.xLarge].
TextScaleTier tierForScale(
  double scale, {
  required double largeThreshold,
  required double xLargeThreshold,
}) {
  if (scale >= xLargeThreshold) return TextScaleTier.xLarge;
  if (scale >= largeThreshold) return TextScaleTier.large;
  return TextScaleTier.normal;
}
