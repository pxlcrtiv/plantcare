Type: task
Status: resolved
Blocked by:

## Question

Provision a real Firebase project so the app can initialize Firebase at runtime.

The app needs Firebase Auth, Cloud Firestore, Cloud Storage, and Firebase Messaging. Today `main.dart` calls `Firebase.initializeApp(options: DefaultFirebaseOptions...)` and `lib/firebase_options.dart` (from the cleanup baseline) holds placeholders. Missing native config: `android/app/google-services.json` and `ios/Runner/GoogleService-Info.plist`.

HITL — the human speaks for themselves. The human has `firebase` CLI installed. Hand them a precise checklist:

1. Create a Firebase project (or reuse an existing one) — record project id + env (dev/prod)
2. Enable **Email/Password** auth provider (the app's google_sign_in import is unused — email login is the active path; confirm on screen)
3. Register Android app (package id from `android/app/build.gradle`) → download `google-services.json` into `android/app/`
4. Register iOS app (bundle id from `ios/Runner.xcodeproj`) → download `GoogleService-Info.plist` into `ios/Runner/`
5. Confirm Firestore + Storage rules exist (defaults acceptable for dev — note them)
6. Provide any values needed to fill non-placeholder `firebase_options.dart`

Resolved when the four files are real, `flutter build` picks them up, and runtime `Firebase.initializeApp()` succeeds in 5-verify-the-app-boots. Record what was provisioned (project id, bundle id, package id, rule state) in the Answer — later tickets depend on it.

## Answer

**Project**: `plantcareai-0` (dev). User created it; account eeddie456@gmail.com; CLI authed effectively — note the account listing quirk: `firebase projects:list` did not show plantcareai-0 while direct `-P plantcareai-0` commands worked; treat both as fine.

**Native apps registered** (2026-08-15):
- Android: `com.plantcare.app` → app id `1:242968093308:android:e010e679f47eae25ac1ff9` → `android/app/google-services.json`
- iOS: `com.plantcare.app` → app id `1:242968093308:ios:8fd9a0c45c4bab82ac1ff9` → `ios/Runner/GoogleService-Info.plist`
- Bundle id had a template artifact (`com.plantcare.app.testProject`) in `ios/Runner.xcodeproj/project.pbxproj` — fixed to `com.plantcare.app` in this branch; verified via `xcodebuild -list`.

**`lib/firebase_options.dart`**: filled with real values from the native configs (api keys, app ids, messagingSenderId 242968093308, projectId plantcareai-0, storage bucket `plantcareai-0.firebasestorage.app`, androidClientId + iosClientId, iosBundleId com.plantcare.app). Web block untouched (web is unsupported; `kIsWeb` guard still routes to it — dead path, fine).

**Firestore**: provisioned + rules deployed (dev default `allow read, write: if request.auth != null`). `firebase.json`, `.firebaserc`, `firestore.rules`, `firestore.indexes.json`, `storage.rules` committed. Storage API enabled during deploy attempt.

**Storage: NOT yet provisioned — one console click needed.** `firebase deploy --only storage` failed with "Firebase Storage has not been set up on project 'plantcareai-0'". Action: open https://console.firebase.google.com/project/plantcareai-0/storage → Get Started (creates default bucket), then run `firebase deploy --only storage` from repo root to publish the dev rules. **Watch item for 05-verify-the-app-boots: storage flows will fail until the bucket exists.**

**Auth**: Email/Password enabled by user (confirm Google is also on if google_sign_in is ever re-enabled — currently unused).

**Verification**: `flutter analyze` 0 issues; `flutter test` 44/44 on `chore/firebase-config` (base: `test/critical-path`).

**Committed**: branch `chore/firebase-config`, local, no push. PR can be raised when the map resolves (baseline stack).

**Security note**: dev rules are wide-open-for-authed — run firebase-security-rules-auditor before any public release.