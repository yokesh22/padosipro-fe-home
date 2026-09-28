---
paths:
  - "lib/core/router/**"
---

# Router conventions

- Route paths/names are declared as constants (or an enum) in `routes.dart`; `app_router.dart` wires them into `GoRouter`'s `GoRoute` list.
- Auth-gated redirects read from the auth `Notifier`'s state (e.g. via a `ref.watch`/`refreshListenable` on the auth provider), not by reading a token directly from storage — redirects must react live to login/logout.
- New route checklist: add the path to `routes.dart`, add the `GoRoute` in `app_router.dart`, and wrap it with the auth redirect guard if the screen requires a logged-in user.
