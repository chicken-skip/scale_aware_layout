# Contributing

Thanks for your interest in improving `scale_aware_layout`! This is a small,
intentionally narrow package, so contributions that keep it focused and
solo-maintainable are the most welcome.

## Scope

The package does one thing: **keep the user's text scale and reflow layout
structure** so content does not overflow at large accessibility font sizes.

Out of scope (please don't propose these — see the spec):

- Font shrinking, auto-sizing, or truncation as a primary strategy.
- Width / device-type breakpoints (use `responsive_framework`).
- Theming systems, design tokens, or i18n logic.
- Native / platform-channel functionality.

## Development setup

```bash
flutter pub get
flutter test                 # run the suite (includes golden tests locally)
```

## Before you open a pull request

Every change must pass the same gates CI runs:

```bash
dart format --set-exit-if-changed .
dart analyze --fatal-infos
flutter test --exclude-tags golden
dart pub publish --dry-run
```

Additionally:

- New or changed public API needs a `///` dartdoc comment with an example.
- If you intentionally change a golden, regenerate it and review the diff:
  `flutter test --update-goldens --tags golden`.
- Keep the example app (`example/`) building.
- Use [Conventional Commits](https://www.conventionalcommits.org/)
  (`feat:`, `fix:`, `test:`, `docs:`, `chore:`).

## Reporting bugs and requesting features

Use the issue templates. A minimal reproduction (ideally a small widget snippet
and the text scale at which it breaks) makes fixes much faster.

By contributing, you agree that your contributions are licensed under the
project's MIT license.
