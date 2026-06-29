import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// The two subtrees managed by [RenderOverflowGuard].
enum OverflowGuardSlot {
  /// The preferred subtree, shown when it fits.
  child,

  /// The replacement subtree, shown when [OverflowGuardSlot.child] would
  /// overflow.
  fallback,
}

/// Renders [OverflowGuardSlot.child] when it fits along [axis] within the
/// incoming constraints, otherwise renders [OverflowGuardSlot.fallback].
///
/// The decision is made with a dry layout of the child along an unconstrained
/// main axis, and cached by `(constraints, textScaler)` so it is not recomputed
/// when nothing relevant has changed.
class RenderOverflowGuard extends RenderBox
    with SlottedContainerRenderObjectMixin<OverflowGuardSlot, RenderBox> {
  /// Creates the render object backing `OverflowGuard`.
  RenderOverflowGuard({
    required Axis axis,
    required double textScale,
  })  : _axis = axis,
        _textScale = textScale;

  Axis _axis;

  /// The axis on which overflow is evaluated.
  Axis get axis => _axis;
  set axis(Axis value) {
    if (_axis == value) return;
    _axis = value;
    _invalidateCache();
    markNeedsLayout();
  }

  double _textScale;

  /// The effective text scale; part of the cache key so a scale change forces a
  /// fresh decision.
  double get textScale => _textScale;
  set textScale(double value) {
    if (_textScale == value) return;
    _textScale = value;
    _invalidateCache();
    markNeedsLayout();
  }

  RenderBox? get _child => childForSlot(OverflowGuardSlot.child);
  RenderBox? get _fallback => childForSlot(OverflowGuardSlot.fallback);

  // Cached decision.
  BoxConstraints? _cachedConstraints;
  double? _cachedTextScale;
  bool? _cachedOverflow;

  void _invalidateCache() {
    _cachedConstraints = null;
    _cachedTextScale = null;
    _cachedOverflow = null;
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! BoxParentData) {
      child.parentData = BoxParentData();
    }
  }

  BoxConstraints _childProbe(BoxConstraints constraints) {
    // Leave the main axis unbounded so we learn the child's desired extent.
    return axis == Axis.horizontal
        ? BoxConstraints(maxHeight: constraints.maxHeight)
        : BoxConstraints(maxWidth: constraints.maxWidth);
  }

  bool _wouldOverflow(BoxConstraints constraints) {
    if (_cachedOverflow != null &&
        _cachedConstraints == constraints &&
        _cachedTextScale == textScale) {
      return _cachedOverflow!;
    }

    final child = _child;
    var overflow = false;
    if (child != null) {
      final available = axis == Axis.horizontal
          ? constraints.maxWidth
          : constraints.maxHeight;
      if (available.isFinite) {
        final desired = child.getDryLayout(_childProbe(constraints));
        final extent = axis == Axis.horizontal ? desired.width : desired.height;
        overflow = extent > available + precisionErrorTolerance;
      }
    }

    _cachedConstraints = constraints;
    _cachedTextScale = textScale;
    _cachedOverflow = overflow;
    return overflow;
  }

  RenderBox? _activeChild(BoxConstraints constraints) =>
      _wouldOverflow(constraints) ? _fallback : _child;

  @override
  double computeMinIntrinsicWidth(double height) =>
      _child?.getMinIntrinsicWidth(height) ?? 0.0;

  @override
  double computeMaxIntrinsicWidth(double height) =>
      _child?.getMaxIntrinsicWidth(height) ?? 0.0;

  @override
  double computeMinIntrinsicHeight(double width) =>
      _child?.getMinIntrinsicHeight(width) ?? 0.0;

  @override
  double computeMaxIntrinsicHeight(double width) =>
      _child?.getMaxIntrinsicHeight(width) ?? 0.0;

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    final active = _activeChild(constraints);
    if (active == null) return constraints.smallest;
    return constraints.constrain(active.getDryLayout(constraints));
  }

  @override
  void performLayout() {
    final active = _activeChild(constraints);
    if (active == null) {
      size = constraints.smallest;
      return;
    }
    active.layout(constraints, parentUsesSize: true);
    (active.parentData! as BoxParentData).offset = Offset.zero;
    size = constraints.constrain(active.size);
  }

  @override
  void visitChildrenForSemantics(RenderObjectVisitor visitor) {
    // Only the painted subtree participates in semantics, so a screen reader
    // never announces the hidden alternative.
    final active = _activeChild(constraints);
    if (active != null) visitor(active);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final active = _activeChild(constraints);
    if (active == null) return;
    final childParentData = active.parentData! as BoxParentData;
    context.paintChild(active, offset + childParentData.offset);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    final active = _activeChild(constraints);
    if (active == null) return false;
    final childParentData = active.parentData! as BoxParentData;
    return result.addWithPaintOffset(
      offset: childParentData.offset,
      position: position,
      hitTest: (result, transformed) =>
          active.hitTest(result, position: transformed),
    );
  }
}
