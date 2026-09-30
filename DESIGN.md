# PadosiPro Design

## Architecture

Feature-first MVVM with Riverpod:

```
Screen (View)  →  Notifier / Provider (ViewModel)  →  Repository  →  Dio (ApiClient)
```

- **Screens** only render state and forward user actions.
- **Notifiers** hold screen state (loading / error / data) and call repositories.
- **Repositories** call the API, map JSON to models, and turn errors into
  `AppException` (`core/error/`).
- Layers live inside each feature: `features/<name>/{data,presentation}`.
  `data/` never imports `presentation/`; features never import each other —
  shared code goes in `core/` or `shared/`.

## Auth & session

- Sign up / sign in with email OTP; the backend returns a JWT access + refresh token.
- `Session` (tokens + user) is saved in secure storage and restored on launch.
- `AuthInterceptor` attaches `Bearer <token>` and, on a 401, refreshes once and
  retries. Failed refresh logs the user out.

## Navigation

GoRouter with a session-driven `redirect`:

| State                    | Goes to              |
| ------------------------ | -------------------- |
| No session               | `/sign-in`, `/sign-up`, `/verify-otp` |
| Session, profile missing | `/details`           |
| Signed in                | `/home`, `/services`, `/requests/:id`, `/account` |

Service request flow: `/services` → `/services/when` → `/services/details`,
with a shared draft provider holding choices between steps.

Home lists open requests (`GET /api/tasks?status=active`) and refetches after a
booking; tapping one opens `/requests/:id`, which offers Cancel while the
status is `pending` or `assigned`. That section belongs to the tasks feature; the router passes it into
`HomeScreen`, so Home never imports another feature.

## UI

- Tokens in `core/constants/app_colors.dart` and `app_sizes.dart`; theme in
  `core/theme/app_theme.dart` (Material 3, light).
- Primary green `#1E5B4A`, background `#F9F9F5`, ink `#18202B`, accent gold `#C9A24A`.
- Font: **Eina** (Regular 400, Semi-Bold 600) for headings.
- Page padding 24, radius 12–16, buttons and fields 56 high.
- Reusable widgets in `lib/shared/widgets/` (primary button, text field, back button).

## Testing

Unit tests for core logic (`test/core/`) and widget tests for feature flows
(`test/features/`). Fake dependencies are injected with Riverpod provider overrides.
