# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

padosipro is a Flutter mobile app using feature-first MVVM (the Flutter team's recommended
architecture). State management is Riverpod, networking is Dio, routing is GoRouter. The
backend is a separate Node/Express repo; auth is OTP login + JWT with refresh handled in
`core/network/auth_interceptor.dart`.

The codebase is an early scaffold: `lib/main.dart`/`lib/app.dart` still hold the default
`flutter create` counter app, and the `core`/`features/auth` files are empty stubs. Riverpod,
Dio, and GoRouter are not yet in `pubspec.yaml` — add them when you start implementing rather
than assuming they're installed.

See `.claude/rules/` for conventions scoped to specific layers and `.claude/skills/` for
scaffolding procedures.

This directory is not yet a git repository. Offer to run `git init` if version control is needed.

## Commands

```bash
fvm flutter pub get              # install dependencies
fvm flutter run                  # run on a connected device/emulator/simulator
fvm flutter analyze              # static analysis
fvm flutter test                 # run all tests
fvm flutter test test/some_test.dart   # run a single test file
fvm flutter test --name "test name"    # filter tests by name
fvm flutter build apk|ios|web|linux|macos|windows   # platform builds
```

Prefix commands with `fvm` — the SDK is pinned via `.fvmrc` to Flutter 3.47.5. Dart constraint
is `^3.12.2`.

## Layering (applies everywhere)

- Layers nest **inside** each feature: `features/<name>/{data,presentation}/...`. Never the
  reverse — no shared top-level `data/` or `presentation/` spanning multiple features.
- Within a feature, `presentation/` depends on `data/`; `data/` never imports `presentation/`.
- Cross-feature reuse goes through `core/`, not by importing one feature from another.
