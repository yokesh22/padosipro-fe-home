---
paths:
  - "lib/features/*/presentation/**"
---

# Presentation layer conventions

- State lives in `Notifier`/`AsyncNotifier` classes under `presentation/providers/`. Widgets don't hold mutable state that represents async/server data.
- Notifiers call repositories (from the same feature's `data/`) via `ref.read` on a repository provider. They never construct `Dio`, parse JSON, or import `dio` directly — that belongs to the repository.
- Async operations (anything that hits the network through a repository) are modeled with `AsyncNotifier`/`AsyncValue`, not manual `isLoading`/`error` booleans.
- Widgets/screens read state via `ref.watch` on the feature's providers and never call a repository method directly.
