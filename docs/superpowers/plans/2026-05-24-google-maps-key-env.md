# Google Maps API Key → .env Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Remove the Google Maps API key from all tracked files and manage it via `.env` (Flutter runtime) and `android/local.properties` (Android build time).

**Architecture:** Flutter/Dart reads the key at runtime via `flutter_dotenv` (already wired up in `main.dart`). Android injects it at build time through Gradle `manifestPlaceholders`. Web: `web/index.html` is gitignored and a `.example` template is committed instead — dynamic Dart injection is not used because `google_maps_flutter_web` requires the Maps JS script to be present before the Flutter engine boots, making runtime injection unreliable.

**Tech Stack:** Flutter, `flutter_dotenv ^6.0.0`, Groovy Gradle (`android/app/build.gradle`), `android/local.properties`

---

## File Map

| File | Action | Purpose |
|------|--------|---------|
| `.gitignore` | Modify | Exclude `.env`, `android/local.properties`, `web/index.html` |
| `.env.example` | Create | Committed template with placeholder values |
| `.env` | Modify | Add `GOOGLE_MAPS_API_KEY=<real_key>` |
| `android/local.properties` | Modify | Add `GOOGLE_MAPS_API_KEY=<real_key>` |
| `android/app/build.gradle` | Modify | Read key from `local.properties`, set `manifestPlaceholders` |
| `android/app/src/main/AndroidManifest.xml` | Modify | Use `${GOOGLE_MAPS_API_KEY}` instead of hardcoded value |
| `lib/core/config/api_config.dart` | Modify | Add `static String get mapsApiKey` |
| `web/index.html.example` | Create | Template copy with `YOUR_GOOGLE_MAPS_API_KEY` placeholder |
| `web/index.html` | Local only | Stays as-is locally, now gitignored |
| `lib/API Google Maps/KeyAPI.msc` | Delete | Raw key file, unused |
| `lib/core/config/KeyAPI.msc` | Delete | Raw key file, unused |

---

## Task 1: Protect secrets — .gitignore + .env.example

**Files:**
- Modify: `.gitignore`
- Create: `.env.example`

- [ ] **Step 1: Add secret files to .gitignore**

Open `MyGasolineraFrontend/.gitignore` and append these lines at the end:

```
# Secrets — never commit
.env
android/local.properties
web/index.html
```

- [ ] **Step 2: Create .env.example**

Create `MyGasolineraFrontend/.env.example` with this content:

```
# Ejemplo de configuración — copia este archivo a .env y rellena los valores reales

# Entorno de la aplicación (development, testing, production)
FLUTTER_ENV=development

API_URL_LOCAL=http://localhost:3000
API_URL_EMULADOR=http://192.168.0.219:3000
API_URL_NGROK=https://your-ngrok-url.ngrok-free.dev

# 0 = Localhost, 1 = Ngrok
SWITCH_BACKEND=1

# Google Maps API Key — obtén la tuya en https://console.cloud.google.com
GOOGLE_MAPS_API_KEY=your_google_maps_api_key_here
```

- [ ] **Step 3: Commit**

```bash
git add .gitignore .env.example
git commit -m "chore: protect secrets from repo (.env, local.properties, web/index.html)"
```

---

## Task 2: Add key to local secret files

**Files:**
- Modify: `.env`
- Modify: `android/local.properties`

- [ ] **Step 1: Add key to .env**

Open `MyGasolineraFrontend/.env` and append:

```
# Google Maps API Key
GOOGLE_MAPS_API_KEY=AIzaSyBlcyKab5d7o0R5PXM3DGRQ-AYsMSjejHc
```

The file should now end with:
```
SWITCH_BACKEND=1

# Google Maps API Key
GOOGLE_MAPS_API_KEY=AIzaSyBlcyKab5d7o0R5PXM3DGRQ-AYsMSjejHc
```

- [ ] **Step 2: Add key to android/local.properties**

Open `MyGasolineraFrontend/android/local.properties` and append:

```
GOOGLE_MAPS_API_KEY=AIzaSyBlcyKab5d7o0R5PXM3DGRQ-AYsMSjejHc
```

The file should now look like:
```
sdk.dir=C:\\Users\\davec\\AppData\\Local\\Android\\Sdk
flutter.sdk=C:\\Users\\davec\\flutter
flutter.buildMode=release
flutter.versionName=1.0.0
flutter.versionCode=1
GOOGLE_MAPS_API_KEY=AIzaSyBlcyKab5d7o0R5PXM3DGRQ-AYsMSjejHc
```

> **Note:** These files are now gitignored — no commit needed. Verify with `git status` that neither `.env` nor `android/local.properties` appears as untracked.

---

## Task 3: Android build-time injection

**Files:**
- Modify: `android/app/build.gradle`
- Modify: `android/app/src/main/AndroidManifest.xml`

- [ ] **Step 1: Read local.properties in build.gradle**

Open `android/app/build.gradle`. After the existing `keystoreProperties` block (lines 8–12), add:

```groovy
def localProperties = new Properties()
def localPropertiesFile = rootProject.file('local.properties')
if (localPropertiesFile.exists()) {
    localProperties.load(new FileInputStream(localPropertiesFile))
}
```

The top of the file should now read:

```groovy
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

def localProperties = new Properties()
def localPropertiesFile = rootProject.file('local.properties')
if (localPropertiesFile.exists()) {
    localProperties.load(new FileInputStream(localPropertiesFile))
}
```

- [ ] **Step 2: Set manifestPlaceholders in defaultConfig**

In `android/app/build.gradle`, inside the `defaultConfig { }` block, add `manifestPlaceholders` as the last entry:

```groovy
defaultConfig {
    applicationId = "com.example.my_gasolinera"
    minSdkVersion = flutter.minSdkVersion
    targetSdk = flutter.targetSdkVersion
    versionCode = flutter.versionCode
    versionName = flutter.versionName
    manifestPlaceholders = [GOOGLE_MAPS_API_KEY: localProperties.getProperty('GOOGLE_MAPS_API_KEY', '')]
}
```

- [ ] **Step 3: Update AndroidManifest.xml**

Open `android/app/src/main/AndroidManifest.xml`. Find:

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="AIzaSyBlcyKab5d7o0R5PXM3DGRQ-AYsMSjejHc"/>
```

Replace with:

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="${GOOGLE_MAPS_API_KEY}"/>
```

- [ ] **Step 4: Verify Android build compiles**

Run:
```bash
flutter build apk --debug
```

Expected: Build succeeds with no errors. The APK file appears in `build/app/outputs/flutter-apk/`.

If you see `Manifest merger failed` or `GOOGLE_MAPS_API_KEY is not defined`, check that `android/local.properties` has the key and that `build.gradle` loads `local.properties` before `android { }`.

- [ ] **Step 5: Commit**

```bash
git add android/app/build.gradle android/app/src/main/AndroidManifest.xml
git commit -m "feat: inject Google Maps API key via Gradle manifestPlaceholders"
```

---

## Task 4: Dart accessor for the key

**Files:**
- Modify: `lib/core/config/api_config.dart`

- [ ] **Step 1: Write a failing test**

Create `test/core/config/api_config_maps_key_test.dart`:

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_gasolinera/core/config/api_config.dart';

void main() {
  group('ApiConfig.mapsApiKey', () {
    setUp(() {
      dotenv.testLoad(fileInput: 'GOOGLE_MAPS_API_KEY=test_key_123');
    });

    test('returns key from dotenv', () {
      expect(ApiConfig.mapsApiKey, equals('test_key_123'));
    });

    test('returns empty string when key is absent', () {
      dotenv.testLoad(fileInput: '');
      expect(ApiConfig.mapsApiKey, equals(''));
    });
  });
}
```

- [ ] **Step 2: Run the test to verify it fails**

```bash
flutter test test/core/config/api_config_maps_key_test.dart -v
```

Expected: FAIL — `The getter 'mapsApiKey' isn't defined for the class 'ApiConfig'`

- [ ] **Step 3: Add mapsApiKey getter to ApiConfig**

Open `lib/core/config/api_config.dart`. Add this getter after `headers`:

```dart
/// Google Maps API key loaded from .env
static String get mapsApiKey => dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
```

- [ ] **Step 4: Run the test to verify it passes**

```bash
flutter test test/core/config/api_config_maps_key_test.dart -v
```

Expected: PASS — both test cases pass.

- [ ] **Step 5: Commit**

```bash
git add lib/core/config/api_config.dart test/core/config/api_config_maps_key_test.dart
git commit -m "feat: expose mapsApiKey getter in ApiConfig via dotenv"
```

---

## Task 5: Web — gitignore index.html + create template

**Files:**
- Create: `web/index.html.example`

> **Why not dynamic injection?** `google_maps_flutter_web` calls `google.maps.Map()` when the map widget first renders. At that point, the Maps JS API must already be loaded — injecting the `<script>` tag from Dart `main()` is too late because the Flutter engine is already running. The safe approach for web is to keep the key in `index.html` locally (gitignored) and commit only a template.

- [ ] **Step 1: Create web/index.html.example**

Copy the current `web/index.html` to `web/index.html.example`, then replace the real key in the copy:

In `web/index.html.example`, find:
```html
src="https://maps.googleapis.com/maps/api/js?key=AIzaSyBlcyKab5d7o0R5PXM3DGRQ-AYsMSjejHc&libraries=places"
```

Replace with:
```html
src="https://maps.googleapis.com/maps/api/js?key=YOUR_GOOGLE_MAPS_API_KEY&libraries=places"
```

The file at `web/index.html` stays unchanged locally (it keeps the real key) and is now gitignored.

- [ ] **Step 2: Commit**

```bash
git add web/index.html.example
git commit -m "chore: add web/index.html.example template (index.html is now gitignored)"
```

---

## Task 6: Delete raw key files

**Files:**
- Delete: `lib/API Google Maps/KeyAPI.msc`
- Delete: `lib/core/config/KeyAPI.msc`

- [ ] **Step 1: Delete the files**

```bash
rm "lib/API Google Maps/KeyAPI.msc"
rm "lib/core/config/KeyAPI.msc"
```

Verify neither file is imported anywhere:
```bash
grep -r "KeyAPI" lib/
```

Expected: no results (these files are `.msc`, not Dart — they are not imported).

- [ ] **Step 2: Commit**

```bash
git add -u
git commit -m "chore: delete raw KeyAPI.msc files (key moved to .env)"
```

---

## Task 7: Final verification

- [ ] **Step 1: Confirm no secrets in tracked files**

```bash
git diff HEAD~5 -- . | grep -i "AIzaSy"
```

Expected: no output. The key string appears in no committed diff.

- [ ] **Step 2: Confirm .gitignore is effective**

```bash
git status
```

Expected: `.env`, `android/local.properties`, and `web/index.html` do NOT appear as untracked or modified files.

- [ ] **Step 3: Run all tests**

```bash
flutter test
```

Expected: all tests pass, including the new `api_config_maps_key_test.dart`.

- [ ] **Step 4: Run the app on Android emulator or device**

```bash
flutter run -d <device_id>
```

Expected: app launches, map loads with markers, no Maps API error in the console.
