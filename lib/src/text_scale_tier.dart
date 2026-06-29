/// Coarse buckets of the user's current text scale.
///
/// Use a tier to branch layout decisions without recomputing thresholds in
/// every widget. The current tier is provided by `ScaleAwareBuilder`.
///
/// ```dart
/// switch (tier) {
///   case TextScaleTier.normal:
///     return const Icon(Icons.check);
///   case TextScaleTier.large:
///   case TextScaleTier.xLarge:
///     return const Text('Done');
/// }
/// ```
enum TextScaleTier {
  /// Default reading size: scale below the large threshold.
  normal,

  /// Enlarged text: scale at or above the large threshold.
  large,

  /// Greatly enlarged text: scale at or above the x-large threshold.
  xLarge,
}
