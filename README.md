# scale_aware_layout

[![pub package](https://img.shields.io/pub/v/scale_aware_layout.svg)](https://pub.dev/packages/scale_aware_layout)
[![likes](https://img.shields.io/pub/likes/scale_aware_layout)](https://pub.dev/packages/scale_aware_layout/score)
[![CI](https://github.com/chicken-skip/scale_aware_layout/actions/workflows/ci.yaml/badge.svg)](https://github.com/chicken-skip/scale_aware_layout/actions)

**Other packages shrink the text. `scale_aware_layout` keeps the text and adapts
the layout — the accessibility-correct way to kill `RenderFlex` overflow.**

![Plain Flutter overflows while scale_aware_layout reflows Row to Column as the text scale increases](https://raw.githubusercontent.com/chicken-skip/scale_aware_layout/main/doc/demo.gif)

▶ **[Live demo](https://chicken-skip.github.io/scale_aware_layout/)** · 📦 [pub.dev](https://pub.dev/packages/scale_aware_layout)

## The problem

When a user turns up their system font size for accessibility, Flutter raises
`MediaQuery.textScaler`. Horizontal layouts that assumed default text overflow —
the dreaded yellow-and-black stripes, clipped labels, broken screens.

The usual "fixes" are wrong: shrinking the font (`auto_size_text`) throws away
the user's explicit choice, and width-based responsive libraries
(`responsive_framework`) react to screen size, not text scale.

## The fix

Wrap the layout. Keep the font. Let the structure adapt.

```dart
import 'package:scale_aware_layout/scale_aware_layout.dart';

AdaptiveRowColumn(
  breakScale: 1.3, // becomes a Column once text scale hits 130%
  spacing: 8,
  children: [
    const Icon(Icons.bolt),
    const Text('Lots of text that would overflow at large font sizes'),
    FilledButton(onPressed: () {}, child: const Text('Action')),
  ],
)
```

At normal text size this is a `Row`. When the user scales text up, it becomes a
`Column` automatically — no overflow, no shrinking, reading order preserved.

## How it compares

| Package | Strategy | Driven by | Keeps user's font? |
|---|---|---|---|
| **scale_aware_layout** | **reflow structure (Row→Column)** | **text scale** | **✅ yes** |
| auto_size_text / adaptive_text | shrink / truncate text | available space | ❌ no |
| responsive_framework | scale whole UI / breakpoints | screen width | n/a |
| accessibility_tools | *detects* overflow (dev-only) | text scale | — (no runtime fix) |

> Already using `accessibility_tools` and seeing `checkFontOverflows` warnings?
> This package is the runtime fix for exactly those warnings.

## Widgets

### `AdaptiveRowColumn`

Lays its children out as a `Row` at normal text size and reflows them into a
`Column` once the text scale reaches `breakScale`. Child order — and therefore
reading and semantics order — is preserved, and `Directionality` (RTL) is
respected.

```dart
AdaptiveRowColumn(
  breakScale: 1.3,
  spacing: 8,
  children: [
    const Icon(Icons.bolt),
    const Text('Lots of text that would overflow at large font sizes'),
    FilledButton(onPressed: () {}, child: const Text('Action')),
  ],
)
```

Key parameters:

- `mode` — `AdaptiveAxisMode.threshold` (default; reflow at `breakScale`) or
  `AdaptiveAxisMode.measure` (roadmap; falls back to threshold in v0.1).
- `breakScale` — the text scale at which the `Row` becomes a `Column`.
- `spacing` — gap inserted between children on the active axis (no trailing gap).
- `rowMainAxisAlignment` / `rowCrossAxisAlignment` / `rowMainAxisSize` and the
  matching `column*` fields — per-axis alignment and sizing.
- `animateTransition` / `animationDuration` — optional cross-fade between the
  two layouts (off by default).

### `ScaleAwareBuilder`

Gives you `(tier, scale)` so you can branch your own UI on the user's text size
without reading `MediaQuery` yourself. The builder re-runs when the scale
changes.

```dart
ScaleAwareBuilder(
  builder: (context, tier, scale) {
    return tier == TextScaleTier.normal
        ? const Row(children: [Icon(Icons.star), Text('Featured')])
        : const Column(children: [Icon(Icons.star), Text('Featured')]);
  },
)
```

### `OverflowGuard`

Shows `child`, and falls back to `fallback` when `child` would overflow along
`axis`. The decision comes from a real dry layout of the child (not just a scale
threshold) and is cached by `(constraints, textScaler)`.

```dart
OverflowGuard(
  axis: Axis.horizontal,
  fallback: const Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [Icon(Icons.info), Text('Detailed status message')],
  ),
  child: const Row(
    mainAxisSize: MainAxisSize.min,
    children: [Icon(Icons.info), Text('Detailed status message')],
  ),
)
```

## Installation

```bash
flutter pub add scale_aware_layout
```

## Accessibility notes

- **Never shrinks fonts.** The user's chosen text scale is always honored; only
  the layout structure changes.
- **Preserves semantics / reading order.** Children keep their order across a
  reflow, so screen-reader traversal is unchanged. `OverflowGuard` reports only
  the visible subtree to the semantics tree.
- **Respects RTL.** Everything works under `TextDirection.rtl`.
- **Works with non-linear `TextScaler`.** The effective factor is sampled via
  `textScaler.scale(1.0)`; for non-linear scalers this is a documented
  approximation and never throws.

## Roadmap

- `measure` mode (reflow only on real overflow, not just a scale threshold)
- `AdaptiveWrap`, spacing/density tokens

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). Issues and PRs welcome.

## License

MIT © chicken-skip
