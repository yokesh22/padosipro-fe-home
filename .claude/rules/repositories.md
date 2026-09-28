---
paths:
  - "lib/features/*/data/**"
---

# Repository layer conventions

- Repositories are the **only** layer allowed to import `dio` or touch raw JSON (`Map<String, dynamic>`, `Response`). Everything above this layer (notifiers, widgets) works with domain/model types only.
- Public repository methods return domain models (or `void`/`Future<void>`) — never a Dio `Response`, raw decoded JSON, or a `DioException`.
- Catch `DioException` at the repository boundary and rethrow via `ErrorMapper`/`AppException`. Don't let `DioException` escape into `presentation/`.
- Use `ApiClient` (from `core/network/`) for all requests, and reference paths from `core/network/api_endpoints.dart` — never hardcode a URL or path string inline.
- Name repositories `<Feature>Repository` (e.g. `AuthRepository`), one per feature-external concept, living directly under `features/<name>/data/`.
