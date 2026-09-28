---
paths:
  - "lib/core/network/**"
---

# Network layer conventions

- `ApiClient` is the single configured `Dio` instance for the whole app. Nothing outside `core/network/` and the repository layer constructs its own `Dio`.
- All request paths are constants in `api_endpoints.dart` — no inline path strings in interceptors or elsewhere.
- `auth_interceptor.dart` owns attaching the JWT and refreshing it on a 401. Guard against infinite retry loops (mark a request as already-retried before re-issuing it after a refresh).
- The interceptor's token refresh must match the OTP/JWT contract used by `features/auth`'s `AuthRepository` — check that repository before changing token storage or refresh request/response shape.
