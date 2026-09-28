---
name: add-endpoint
description: Add a new API call to an existing feature (endpoint constant, repository method, model, notifier, UI wiring). Use when the user asks to call a new backend endpoint from an existing feature.
---

# Add a new endpoint to an existing feature

1. **Endpoint constant** — add the path to `core/network/api_endpoints.dart`. Don't inline URLs elsewhere.

2. **Repository method** — add/extend a method on the feature's `<Feature>Repository` in `data/`:
   - Call it through `ApiClient`.
   - Catch `DioException` and rethrow via `ErrorMapper`/`AppException`.
   - Return a domain model, not raw JSON/`Response`.
   - Follow `.claude/rules/repositories.md`.

3. **Model** — add or extend the domain model representing the response shape, alongside the repository (or in a `data/models/` subfolder if the feature already has one).

4. **Notifier** — expose the new capability as a method on the feature's `AsyncNotifier` in `presentation/providers/`, calling the repository method.

5. **UI** — wire the action (button press, form submit, etc.) in the screen/widget to call the notifier method, and render the resulting `AsyncValue` state.

6. **Verify**:
   ```bash
   fvm flutter analyze
   fvm flutter test
   ```
