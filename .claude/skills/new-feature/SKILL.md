---
name: new-feature
description: Scaffold a new feature module end-to-end (repository, notifier, screen, route) following this project's feature-first MVVM structure. Use when the user asks to add a new feature/screen/section to the padosipro app.
---

# Scaffold a new feature

Given a feature name `<name>` (snake_case, e.g. `bookings`):

1. **Repository** — create `lib/features/<name>/data/<name>_repository.dart`.
   - Only this file (within the feature) touches `Dio`/raw JSON.
   - Use `ApiClient` and add any new paths to `core/network/api_endpoints.dart`.
   - Map errors via `ErrorMapper`/`AppException`; return domain models.
   - Follow `.claude/rules/repositories.md`.

2. **State** — create `lib/features/<name>/presentation/providers/<name>_notifier.dart`.
   - An `AsyncNotifier` (or `Notifier`) that reads the repository via a provider.
   - No Dio/JSON here — call repository methods only.
   - Follow `.claude/rules/presentation.md`.

3. **UI** — create `lib/features/<name>/presentation/<name>_screen.dart` (add a subfolder for widgets if the screen has several).
   - Watch the notifier provider with `ref.watch`; render `AsyncValue` states (loading/error/data).

4. **Routing** — register the feature:
   - Add the path/name to `core/router/routes.dart`.
   - Add the `GoRoute` in `core/router/app_router.dart`, wrapped with the auth redirect guard if the screen requires login.
   - Follow `.claude/rules/router.md`.

5. **Verify**:
   ```bash
   fvm flutter analyze
   fvm flutter test
   ```
