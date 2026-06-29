import 'package:flutter/widgets.dart';

import 'render_overflow_guard.dart';
import 'text_scale.dart';

/// Shows [child] when it fits along [axis] within the incoming constraints, and
/// swaps to [fallback] when [child] would otherwise overflow.
///
/// Unlike font-shrinking approaches, this keeps the user's text scale and simply
/// chooses a layout that fits. The decision is computed from a dry layout of
/// [child] along an unconstrained main axis and cached by
/// `(constraints, textScaler)`, so it is not recomputed every frame.
///
/// ```dart
/// OverflowGuard(
///   // A compact row that may not fit at very large text sizes...
///   child: Row(
///     mainAxisSize: MainAxisSize.min,
///     children: const [Icon(Icons.info), Text('Detailed status message')],
///   ),
///   // ...falls back to a stacked, always-fitting layout.
///   fallback: Column(
///     crossAxisAlignment: CrossAxisAlignment.start,
///     children: const [Icon(Icons.info), Text('Detailed status message')],
///   ),
/// )
/// ```
class OverflowGuard
    extends SlottedMultiChildRenderObjectWidget<OverflowGuardSlot, RenderBox> {
  /// Creates an overflow guard.
  const OverflowGuard({
    super.key,
    required this.child,
    required this.fallback,
    this.axis = Axis.horizontal,
  });

  /// Shown when it fits along [axis].
  final Widget child;

  /// Shown when [child] would overflow along [axis].
  final Widget fallback;

  /// The axis on which overflow is evaluated. Defaults to [Axis.horizontal].
  final Axis axis;

  @override
  Widget? childForSlot(OverflowGuardSlot slot) {
    return switch (slot) {
      OverflowGuardSlot.child => child,
      OverflowGuardSlot.fallback => fallback,
    };
  }

  @override
  Iterable<OverflowGuardSlot> get slots => OverflowGuardSlot.values;

  @override
  RenderOverflowGuard createRenderObject(BuildContext context) {
    return RenderOverflowGuard(
      axis: axis,
      textScale: effectiveTextScaleFactor(context),
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderOverflowGuard renderObject,
  ) {
    renderObject
      ..axis = axis
      ..textScale = effectiveTextScaleFactor(context);
  }
}
