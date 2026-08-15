Type: task
Status: open
Blocked by: 02

## Question

Make `flutter analyze` pass with **zero errors and zero warnings** on the baseline (main folded with 2-fold-the-cleanup-baseline).

As of charting, 45 issues: 9 errors —

- `Undefined class 'PlantResult'` ×3 — `plant_identification_camera.dart:369,374,379`
- `Undefined name 'Timestamp'` ×4 — `my_plants_dashboard.dart:158,159,165,167` (missing `cloud_firestore` import)
- `notification_service.dart:101-102` — misuse of `FirebaseMessaging.onMessage` (instance access + wrong return type on background handler)
- `sync_service.dart:50` — `Stream<List<ConnectivityResult>>` vs `Stream<ConnectivityResult>` (connectivity_plus v6 API)
- `app_theme.dart:105,212,260,367` — `CardTheme`/`TabBarTheme` → `CardThemeData`/`TabBarThemeData` (Flutter 3.44)

…plus ~30 warnings (unused imports/fields). Fix them all; evidence: full `flutter analyze` output with 0 issues.

AFK — drive alone. If a fix only works by changing tested behavior of an existing test, keep the test honest; add/adjust tests in `test/` per 6-test-along-the-route conventions.