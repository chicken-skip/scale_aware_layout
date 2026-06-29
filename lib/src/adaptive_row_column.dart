import 'package:flutter/widgets.dart';

import 'text_scale.dart';

/// How [AdaptiveRowColumn] decides between a [Row] and a [Column].
enum AdaptiveAxisMode {
  /// Reflow `Row` -> `Column` once the effective text scale reaches
  /// `breakScale`. This is the default and the only fully-implemented mode in
  /// v0.1.
  threshold,

  /// Measure actual content against the incoming constraints and reflow only
  /// when it would truly overflow.
  ///
  /// Roadmap for v0.2. In v0.1 this falls back to [threshold] behavior so the
  /// API is stable.
  measure,
}

/// Lays its [children] out as a [Row] at normal text size and reflows them into
/// a [Column] once the user's text scale grows past [breakScale].
///
/// This keeps the user's chosen font size and changes the layout *structure*
/// instead of shrinking text — the accessibility-correct way to avoid
/// `RenderFlex` overflow. Child order is preserved in both axes, so reading and
/// semantics order never change, and [Directionality] is respected.
///
/// ```dart
/// AdaptiveRowColumn(
///   breakScale: 1.3, // becomes a Column once text scale hits 130%
///   spacing: 8,
///   children: [
///     const Icon(Icons.bolt),
///     const Text('Lots of text that would overflow at large font sizes'),
///     FilledButton(onPressed: () {}, child: const Text('Action')),
///   ],
/// )
/// ```
class AdaptiveRowColumn extends StatelessWidget {
  /// Creates an adaptive row/column.
  const AdaptiveRowColumn({
    super.key,
    required this.children,
    this.mode = AdaptiveAxisMode.threshold,
    this.breakScale = 1.3,
    this.spacing = 0.0,
    this.rowMainAxisAlignment = MainAxisAlignment.start,
    this.rowMainAxisSize = MainAxisSize.max,
    this.rowCrossAxisAlignment = CrossAxisAlignment.center,
    this.columnMainAxisAlignment = MainAxisAlignment.start,
    this.columnMainAxisSize = MainAxisSize.min,
    this.columnCrossAxisAlignment = CrossAxisAlignment.start,
    this.animateTransition = false,
    this.animationDuration = const Duration(milliseconds: 200),
  });

  /// The children laid out in order, as either a row or a column.
  final List<Widget> children;

  /// Strategy used to choose the axis. Defaults to [AdaptiveAxisMode.threshold].
  final AdaptiveAxisMode mode;

  /// In [AdaptiveAxisMode.threshold], reflow to a [Column] when the effective
  /// text scale is `>= breakScale`. Defaults to `1.3`.
  final double breakScale;

  /// Gap inserted between adjacent children, in logical pixels, on whichever
  /// axis is active. No gap is added before the first or after the last child.
  /// Defaults to `0`.
  final double spacing;

  /// [Row.mainAxisAlignment] applied while in row layout.
  final MainAxisAlignment rowMainAxisAlignment;

  /// [Row.mainAxisSize] applied while in row layout.
  final MainAxisSize rowMainAxisSize;

  /// [Row.crossAxisAlignment] applied while in row layout.
  final CrossAxisAlignment rowCrossAxisAlignment;

  /// [Column.mainAxisAlignment] applied while in column layout.
  final MainAxisAlignment columnMainAxisAlignment;

  /// [Column.mainAxisSize] applied while in column layout.
  final MainAxisSize columnMainAxisSize;

  /// [Column.crossAxisAlignment] applied while in column layout.
  final CrossAxisAlignment columnCrossAxisAlignment;

  /// When true, cross-fade between the row and column layouts using an
  /// [AnimatedSwitcher]. Defaults to `false` for zero surprise.
  final bool animateTransition;

  /// Duration of the cross-fade when [animateTransition] is true.
  final Duration animationDuration;

  /// Inserts [spacing] gaps between [children] without a trailing gap.
  List<Widget> _spaced(Axis axis) {
    if (spacing <= 0.0 || children.length < 2) return children;
    final result = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0) {
        result.add(axis == Axis.horizontal
            ? SizedBox(width: spacing)
            : SizedBox(height: spacing));
      }
      result.add(children[i]);
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    // `measure` mode delegates to threshold behavior in v0.1.
    // TODO(v0.2): true measurement of content vs. incoming constraints.
    final scale = effectiveTextScaleFactor(context);
    final asColumn = scale >= breakScale;

    final Widget layout = asColumn
        ? Column(
            key: const ValueKey<bool>(true),
            mainAxisAlignment: columnMainAxisAlignment,
            mainAxisSize: columnMainAxisSize,
            crossAxisAlignment: columnCrossAxisAlignment,
            children: _spaced(Axis.vertical),
          )
        : Row(
            key: const ValueKey<bool>(false),
            mainAxisAlignment: rowMainAxisAlignment,
            mainAxisSize: rowMainAxisSize,
            crossAxisAlignment: rowCrossAxisAlignment,
            children: _spaced(Axis.horizontal),
          );

    if (!animateTransition) return layout;
    return AnimatedSwitcher(duration: animationDuration, child: layout);
  }
}
