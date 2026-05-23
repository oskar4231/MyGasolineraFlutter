# Design: Move Google Maps API Key to .env

**Date:** 2026-05-24  
**Status:** Approved

## Goal

Remove the Google Maps API key from all tracked files and manage it via `.env` (Flutter/Dart runtime) and `android/local.properties` (Android build time). The key must never appear in the git repository.

## Approach

Option A: `.env` + `local.properties` (Gradle)

- Flutter/Dart reads the key at runtime via `flutter_dotenv` (already in use for other config)
- Android reads the key at build time via Gradle `manifestPlaceholders`
- Web injects the Maps JS script dynamically from Dart using `dart:html` (web-only)
- Both `.env` and `android/local.properties` are excluded from the repo via `.gitignore`

## Files Changed

### Deleted
- `lib/API Google Maps/KeyAPI.msc` — raw key file, not imported anywhere
- `lib/core/config/KeyAPI.msc` — raw key file, not imported anywhere

### Modified
| File | Change |
|------|--------|
| `.env` | Add `GOOGLE_MAPS_API_KEY=<real_key>` |
| `.gitignore` | Add `.env` and `android/local.properties` |
| `android/local.properties` | Add `GOOGLE_MAPS_API_KEY=<real_key>` (local only) |
| `android/app/build.gradle` | Read key from `local.properties`, set `manifestPlaceholders` |
| `android/app/src/main/AndroidManifest.xml` | Replace hardcoded value with `${GOOGLE_MAPS_API_KEY}` |
| `web/index.html` | Remove static `<script>` tag for Maps JS API |
| `lib/core/config/api_config.dart` | Add `static String get mapsApiKey` reading from `dotenv.env` |
| `lib/main.dart` | On web platform, inject Maps JS `<script>` tag via `dart:html` after `dotenv.load()` |

### Created
- `.env.example` — template with variable names and placeholder values, safe to commit

## Architecture Details

### Android (build time)
`android/local.properties` → read by `android/app/build.gradle` → `manifestPlaceholders[GOOGLE_MAPS_API_KEY]` → `AndroidManifest.xml` references `${GOOGLE_MAPS_API_KEY}`

### Flutter/Dart (runtime)
`dotenv.load()` in `main.dart` → `ApiConfig.mapsApiKey` returns `dotenv.env['GOOGLE_MAPS_API_KEY']`

### Web (runtime)
After `dotenv.load()` in `main.dart`, on `kIsWeb`: inject `<script src="https://maps.googleapis.com/maps/api/js?key=<key>&libraries=places">` via `dart:html`

## .env.example
```
# Google Maps API Key
GOOGLE_MAPS_API_KEY=your_api_key_here
```

## Error Handling
- If `GOOGLE_MAPS_API_KEY` is missing from `.env`, `mapsApiKey` returns empty string and the map will fail to load — acceptable for a dev/TFG project. No silent fallback to hardcoded value.
- If `android/local.properties` is missing the key, the Android build will fail with a Gradle error — expected behavior, not a runtime surprise.

## Out of Scope
- iOS (not a target platform)
- CI/CD secret injection (no pipeline configured)
- Key rotation automation
