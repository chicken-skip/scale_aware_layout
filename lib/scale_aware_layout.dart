/// Keep the user's text scale and reflow layout structure (Row -> Column) to
/// prevent overflow at large accessibility font sizes.
///
/// This library is the accessibility-correct alternative to shrinking text:
/// instead of overriding the user's chosen font size, it changes the layout
/// structure so content keeps fitting.
///
/// See [AdaptiveRowColumn], [ScaleAwareBuilder] and [OverflowGuard].
library;

// Public API is exported here. Implementation lives under `lib/src/` and is
// not exported directly.

export 'src/adaptive_row_column.dart';
export 'src/scale_aware_builder.dart';
export 'src/text_scale_tier.dart';
