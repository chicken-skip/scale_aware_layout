## 0.1.1

- Docs: route the Code of Conduct contact through GitHub's private reporting
  instead of an email address.
- No API changes.

## 0.1.0

Initial release.

- `AdaptiveRowColumn` — reflows a `Row` into a `Column` when the text scale
  reaches `breakScale`, keeping child/reading order and respecting RTL. Supports
  per-axis alignment/size, `spacing` gaps, and an optional cross-fade transition.
  `AdaptiveAxisMode.measure` is reserved for v0.2 and falls back to threshold
  behavior.
- `ScaleAwareBuilder` — rebuilds against the current text scale, exposing a
  coarse `TextScaleTier` and the raw linear factor.
- `TextScaleTier` — `normal` / `large` / `xLarge` buckets with inclusive
  thresholds.
- `OverflowGuard` — swaps `child` for `fallback` when `child` would overflow on a
  given axis, decided via a cached dry layout.
