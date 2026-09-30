# PadosiPro

Flutter app for booking home services from a local manager (LM). Users sign up
with email OTP, set their address, browse services and raise task requests.

## Versions

| Tool     | Version  |
| -------- | -------- |
| App      | 1.0.0+1  |
| Flutter  | 3.47.5 (pinned via `.fvmrc`) |
| Dart     | ^3.12.2  |

Key packages: `flutter_riverpod` (state), `dio` (HTTP), `go_router` (routing),
`flutter_secure_storage` (session), `url_launcher`.

## Installation

1. Install [FVM](https://fvm.app/documentation/getting-started/installation):
   ```bash
   dart pub global activate fvm
   ```
2. Install the pinned Flutter SDK and dependencies:
   ```bash
   fvm install
   fvm flutter pub get
   ```
3. Set up a device: Android Studio/emulator for Android, Xcode for iOS (macOS only).
   Check with `fvm flutter doctor`.

## Setup

The app talks to the PadosiPro Node/Express backend (separate repo). Start it
first, then point the app at it with `API_BASE_URL` (default `http://localhost:3002`):

```bash
# Android emulator
fvm flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3002

# iOS simulator / desktop
fvm flutter run --dart-define=API_BASE_URL=http://localhost:3002

# Physical device: use your machine's LAN IP
fvm flutter run --dart-define=API_BASE_URL=http://192.168.x.x:3002
```

## Guide

```bash
fvm flutter analyze                 # static analysis
fvm flutter test                    # all tests
fvm flutter test test/core/         # one folder / file
fvm flutter build apk --dart-define=API_BASE_URL=https://api.example.com
```

Project layout (feature-first MVVM):

```
lib/
  core/       # shared: network, router, storage, theme, constants, errors
  shared/     # reusable widgets
  features/
    auth/     # sign up, sign in, OTP, profile details
    home/     # home screen
    tasks/    # services catalog and request flow
    account/  # account screen, assigned LM
```

Each feature has `data/` (repositories, models) and `presentation/`
(providers, screens, widgets). See [DESIGN.md](DESIGN.md) for details.
