---
name: bootstrap-deps
description: One-time setup to add Riverpod, Dio, and GoRouter to pubspec.yaml and wire them into main.dart/app.dart. Use when these packages aren't installed yet and the user is starting real implementation work.
---

# Bootstrap core dependencies

This project's `pubspec.yaml` currently only has `flutter`/`cupertino_icons`. Before implementing
against the `core/`/`features/` stubs, add the packages the architecture assumes:

1. Add to `pubspec.yaml` `dependencies:`:
   - `flutter_riverpod` (state management)
   - `dio` (networking)
   - `go_router` (routing)

2. Run:
   ```bash
   fvm flutter pub get
   ```

3. Wrap the app in a `ProviderScope`:
   - In `lib/main.dart`, wrap `runApp(...)` with `ProviderScope(child: ...)`.

4. Switch to router-based navigation in `lib/app.dart`:
   - Replace `MaterialApp(...)` with `MaterialApp.router(...)`, wired to the `GoRouter` instance built in `core/router/app_router.dart`.

5. Verify:
   ```bash
   fvm flutter analyze
   fvm flutter run
   ```
