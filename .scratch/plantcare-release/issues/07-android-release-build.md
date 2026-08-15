Type: task
Status: open
Blocked by: 05

## Question

Produce a signed, releasable Android APK — and decide the signing identity.

Path: Android signing needs a keystore (generate with `keytool`), `key.properties` or gradle wiring, `signingConfigs` in `android/app/build.gradle`, then `flutter build appbundle --release` (and/or `--apk`). The keystore + `key.properties` must be gitignored; the signing material is the human's to hold.

HITL where the human must own decisions/credentials (keystore password, alias, file location); AFK for the mechanical gradle + build work. Steps:

1. Confirm package id (recorded in 3-firebase-project) — release build must match
2. Generate keystore (human holds passwords) + gitignore it (`android/key.properties`, `*.jks`)
3. Wire `signingConfigs`/`buildTypes` in `android/app/build.gradle`
4. `flutter build appbundle --release` and `flutter build apk --release` succeed
5. Evidence: artifact paths + sizes, build output; note app version code/name bumps if needed

Resolved when both artifacts build with the signing config. Record keystore location, alias, and gitignored paths (never passwords — those stay with the human).