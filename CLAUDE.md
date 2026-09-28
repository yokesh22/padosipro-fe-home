# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project state

`padosipro` is a Flutter app in its very earliest scaffolding stage. `lib/main.dart` and `lib/app.dart`
still contain the default `flutter create` counter-app boilerplate (entry point renders
`padosiproMainWrapper`, an empty `Scaffold`). The following files exist as empty placeholders
outlining the intended architecture but have no implementation yet:

- `lib/core/router/app_router.dart`, `lib/core/router/routes.dart`
- `lib/core/network/api_client.dart`, `lib/core/network/api_endpoints.dart`, `lib/core/network/auth_interceptor.dart`
- `lib/core/error/app_exception.dart`, `lib/core/error/error_mapper.dart`
- `lib/core/theme/app_theme.dart`
- `lib/core/constants/app_colors.dart`, `lib/core/constants/app_sizes.dart`
- `lib/core/utils/validators.dart`
- `lib/features/auth/data/auth_repository.dart`

`pubspec.yaml` currently declares only the default `flutter`/`cupertino_icons` dependencies — no
router, HTTP client, or state management package has been added yet, even though the folder layout
implies a `core` (networking/router/theme) + `features/<feature>/data` structure. When implementing
against these stub files, you'll need to choose and add the appropriate packages (e.g. an HTTP
client for `api_client.dart`, a router package for `app_router.dart`) since none are currently
wired up — check with the user if the choice isn't obvious from context.

This directory is **not yet a git repository**. If version control is needed, offer to run `git init`.

## Commands

Standard Flutter CLI workflow (no custom scripts/Makefile present):

```bash
fvm flutter pub get              # install dependencies
fvm flutter run                  # run on a connected device/emulator/simulator
fvm flutter analyze              # static analysis (uses analysis_options.yaml / flutter_lints)
fvm flutter test                 # run all tests
fvm flutter test test/widget_test.dart   # run a single test file
fvm flutter test --plugin-sha "testName" # or use --name "<test name>" to filter by test name
fvm flutter build apk|ios|web|linux|macos|windows   # platform builds
```

The project pins its Flutter SDK via FVM (`.fvmrc` → Flutter `3.47.5`). If `fvm` is installed,
prefix commands with `fvm flutter ...` (e.g. `fvm flutter pub get`) instead of calling the global
`flutter` binary, to stay on the pinned version.

The Dart SDK constraint is `^3.12.2` (see `pubspec.yaml`).

## Architecture

The intended structure (per the current empty scaffolding) is a `core` + `features` split:

- **`lib/core/`** — cross-cutting infrastructure shared by all features:
  - `network/` — `ApiClient`, `ApiEndpoints`, `AuthInterceptor` for HTTP calls and auth token injection
  - `router/` — `AppRouter` / `Routes` for navigation
  - `error/` — `AppException` and `ErrorMapper` for translating errors (e.g. network/API failures) into user-facing app exceptions
  - `theme/` — `AppTheme`
  - `constants/` — `AppColors`, `AppSizes` (design tokens)
  - `utils/` — shared helpers like `validators.dart`
- **`lib/features/<feature_name>/`** — feature modules, each with its own `data/` layer (e.g.
  `features/auth/data/auth_repository.dart`). Follow this pattern for new features: put
  repositories/data sources under `features/<name>/data/`, and add sibling `domain/`/`presentation/`
  directories as needed when building out a feature (none exist yet, so there's no established
  convention to match beyond `data/`).

Custom fonts (`Eina` family) and a logo (`assets/images/padosipro-logo.png`) are already registered
in `pubspec.yaml`/`assets/`, so use `AppColors`/`AppSizes`/the `Eina` font family for consistent
styling once `app_theme.dart` is implemented, rather than hardcoding values inline.

The `.metadata` file lists `lib/main.dart` as unmanaged by `flutter migrate`, meaning it's expected
to diverge from the stock template as the app is built out.
