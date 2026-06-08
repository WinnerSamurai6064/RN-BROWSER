# Veil Browser Beta 0.5

Veil Browser is a privacy-first Android browser for shared phones.

The beta goal:

> One phone, two separated browser spaces.

## Beta 0.5 scope

- Flutter Android app
- Guest-first onboarding
- Two local profiles: My Space and Guest Space
- WebView browser shell
- URL/search bar
- Profile switcher
- Local privacy settings
- Location, camera, and microphone blocked by default
- Clear-on-exit mode
- Supabase-ready auth layer
- VM backend starter for config and session events
- GitHub Actions APK build

## Product rules

- No forced signup
- Maximum 2 profiles in beta
- Do not sync cookies, passwords, or browsing history in beta
- Keep privacy claims realistic

## Repo structure

```txt
lib/                       Flutter app
backend/                   VM backend starter
supabase/                  SQL schema
.github/workflows/         APK build workflow
pubspec.yaml               Flutter dependencies
```

## Local run

```bash
flutter pub get
flutter create . --platforms=android --project-name veil_browser
flutter run
```

## Build APK

```bash
flutter create . --platforms=android --project-name veil_browser
flutter pub get
flutter build apk --release
```

APK output:

```txt
build/app/outputs/flutter-apk/app-release.apk
```

## Backend run

```bash
cd backend
cp .env.example .env
npm install
npm start
```

Default backend port: 8080.

## Supabase

Run `supabase/schema.sql` in your Supabase SQL editor.

## Roadmap

### Beta 0.5

- Product shell
- Identity profiles
- Permission firewall
- APK build workflow
- Backend starter

### Beta 0.6

- Stronger Android WebView profile isolation
- Blocklist engine
- Auth UI polish

### Beta 0.7

- Optional network profile controls
- Quota control
- More backend configuration
