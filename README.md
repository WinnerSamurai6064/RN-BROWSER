# RN Browser Beta 0.5

RN Browser is a liquid-glass Android browser beta focused on shared-phone privacy.

The product goal:

> One phone, two separated browser spaces, with no forced signup.

## Current beta status

The repo now contains the beta 0.5 Flutter app foundation and WebView engine wiring.

Implemented:

- Flutter Android app config
- RN liquid glass visual system
- OLED black base with lemon green accent
- Full-screen start page
- Youth-focused hero image card
- Pilled Start Secure Browsing button
- Login / Sync entry under the button
- My Space and Guest Space profile chips
- Live InAppWebView browser engine
- URL/search loading
- WebView back, forward, home, and refresh controls
- WebView progress bar
- Slide-out browser menu
- Settings screen
- Microphone permission toggle
- Camera permission toggle
- Gallery/files toggle placeholder
- Region mode toggle
- Region zoom from 50 percent to 150 percent
- Pinch zoom allowlist behavior
- Desktop site toggle
- Dark page filter toggle
- Clear cookies and web storage on profile switch when enabled
- GitHub Actions Android APK build workflow

## Product rules

- No forced signup
- Maximum 2 profiles in beta
- Guest-first browsing
- Do not sync cookies, passwords, or browsing history in beta
- Do not put database URLs, Postgres passwords, service-role keys, or VM secrets inside the APK
- The APK should only call the VM backend over HTTPS when backend wiring starts

## Repo structure

```txt
lib/                       Flutter app
android/                   Android metadata and manifest
.github/workflows/         APK build workflow
pubspec.yaml               Flutter dependencies
README.md                  Product and build notes
```

## Local setup

First generate the Android platform files if they are missing:

```bash
flutter create . --platforms=android --project-name rn_browser
```

Then run:

```bash
flutter pub get
flutter run
```

## Build APK locally

```bash
flutter create . --platforms=android --project-name rn_browser
flutter pub get
flutter build apk --release
```

APK output:

```txt
build/app/outputs/flutter-apk/app-release.apk
```

## GitHub Actions build

The workflow at `.github/workflows/android-build.yml` builds the release APK and uploads it as an artifact named:

```txt
rn-browser-beta-0-5-apk
```

## Backend plan

The backend will live in a separate repo and run on the VM behind Caddy.

Expected structure later:

```txt
RN Browser APK
    ↓ HTTPS
Caddy domain
    ↓
VM backend API
    ↓
Postgres or Supabase using .env secrets
```

The Android app should never receive raw database credentials.

## Next commits

1. Persist settings with local storage.
2. Add local bookmarks and history models.
3. Add a clean VM API client once the Caddy domain is ready.
4. Add file upload bridge for gallery/files.
5. Add a stronger profile-isolation bridge for Android WebView data directories.
