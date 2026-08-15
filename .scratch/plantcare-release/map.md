# Map: plantcare release build

## Destination

A verified route from "code committed, never compiled" to **plantcare compiled clean, tested, running with real Firebase + PlantNet credentials, and releasable — a signed Android APK and a TestFlight-ready iOS build**. The app has never run; every step to the first release build is on this map.

## Notes

- **Domain**: Flutter (Dart 3.6, Flutter 3.44.9 stable on this machine), Firebase (auth / firestore / storage / messaging), PlantNet REST API, flutter_local_notifications, provider, sizer. macOS M1 dev machine — iOS simulator + Android emulator both available.
- **Skills to consult**: `treehouse` (each ticket is worked in its own git worktree by a subagent), `tdd` / `test-driven-development` (tests are on the route), `systematic-debugging` (issues when the app first boots), `verification-before-completion` (every ticket claims done only with evidence), `gh-axi` (PRs handled later, not during this effort).
- **Standing preferences**:
  - Each ticket is claimed and worked in a separate git worktree. PRs are handled later, after the map resolves.
  - PlantNet key is wired via `--dart-define=PLANTNET_API_KEY` (see `origin/fix/setup-and-cleanup`).
  - `env.json` is legacy — the app never reads it; the app reads Firebase via `firebase_options.dart` + native config files.
  - Never commit secrets or real API keys; CI-visible values stay out of the repo.
  - **Execution override**: this effort carries execution — the destination is a release build, so tickets *do* the work, they don't just decide it.
  - **Images live in Firestore, one doc per photo — NOT Cloud Storage, NOT fields inside the plant doc.** Format: WebP (NOT WebM — that's a video format), max width ~1600px, lossy quality ~80 → ~150–400 KB typical. Collection: `plant_images/{plantId}/{timestamp}` style (photo history = separate docs; plant doc carries only the latest-photo reference). Stays free: 1 GiB tier ≈ 2.5–6K photos, view = 1 doc read (50K/day). No firebase_storage code exists in lib/ (verified 2026-08-15), so this touches zero current paths. Encode via `flutter_image_compress` (WebP on Android + iOS). Migrate to a Cloud Storage bucket (Blaze, Always Free 5 GB / 100 GB egress) only if/when photo volume outgrows the Firestore tier — that's a later ticket, not now.
- **Baseline reality**: `main` (d4de6c1, Nov 2025) has never passed `flutter analyze`: 9 errors + ~30 warnings, no tests, no `firebase_options.dart`, dead scaffolding (`custom_inspector.dart`, `main-updated.dart`, `test_service.dart`). `origin/fix/setup-and-cleanup` (2026-08-01) already removes the scaffolding, adds `firebase_options.dart` template + PlantNet key wiring + first test (`test/plantnet_service_test.dart`) — unmerged.

## Decisions so far

- [Establish the working baseline from origin/fix/setup-and-cleanup](https://github.com/pxlcrtiv/plantcare/issues/2) — baseline branch `baseline/setup-and-cleanup` @ 87c6f22 (5 commits ahead of main, local, no push): cleanup folded via merge, PlantNet key via `--dart-define=PLANTNET_API_KEY`, 7/7 PlantNetService tests green. Two deliberate fix commits: test-harness `final` fields un-finaled (suite never compiled as shipped), and dio `Options(validateStatus: (_) => true)` so the service's own non-200 branch runs — do not revert in 1-fix-the-compile.
- [Make flutter analyze pass with zero errors and warnings](https://github.com/pxlcrtiv/plantcare/issues/7) — analyze clean: 43 issues (30E/12W/1I) → 0; branch `fix/analyze-clean` @ 6a656ca; PlantResult was a missing import, not a rename; `TargetPlatform.web` removed in Flutter 3.44, stray `}` in main.dart, 7 missing widget imports also fixed; suite 7/7. Fog added: FCM background handler never registered; SyncService.isConnected() always-true list comparison.
- [Test suite along the critical path](https://github.com/pxlcrtiv/plantcare/issues/8) — 44/44 tests, analyze clean; branch `test/critical-path` @ 23bc4b5. Suite: widget smokes (dashboard/login/splash/plant detail), unit seams (plant model, repository, care schedule, sync). Real bugs fixed + pinned: species interpolation off-by-brace (plant detail showed literal "PlantInfoWidget.species}"), SyncService.isConnected always-true (now list-aware), dashboard overflow. Screens gained injection seams for testability.
- [Provision Firebase project and native config](https://github.com/pxlcrtiv/plantcare/issues/3) — project `plantcareai-0` (dev) wired. Android + iOS apps registered (`com.plantcare.app`; iOS bundle id had `.testProject` template artifact — fixed in branch); `google-services.json` + `GoogleService-Info.plist` + real `firebase_options.dart` on `chore/firebase-config` (base test/critical-path, no push). Firestore provisioned + rules deployed (dev: authed read/write). Cloud Storage NOT provisioned — **superseded by design**: images go to Firestore docs (see standing preferences); the console Get Started / Blaze upgrade is deferred until a migration ticket exists. Firestore rules apply to image bytes too (audit with the security skill before public).
- [First verified run on Android emulator](https://github.com/pxlcrtiv/plantcare/issues/9) — **resolved 2026-08-15**: runnable end-to-end (boot/auth/manual-add/AI-identify/persistence); 3 fix commits on run/first-boot; findings + evidence in the ticket Answer; notifications verification graduates into its own ticket. iOS simulator unavailable (runtime not installed) — Android-only this round.
- [PlantNet API key](https://github.com/pxlcrtiv/plantcare/issues/4) — key supplied + validated live against v2 (400 on missing image = key accepted; 404 "Species not found" = full identify pipeline ran). **Unblocks the first verified run.** Key lives in the human's password manager only — run form: `flutter run --dart-define=PLANTNET_API_KEY=<key>`; never committed (standing preference).

## Not yet specified

- **Rules audit** — Firestore rules are dev defaults (authed read/write) and now cover image bytes too; run firebase-security-rules-auditor before anything public.
- **Image pipeline concrete wiring** — `flutter_image_compress` (WebP params in standing preferences) + `plant_images/{plantId}/...` collection model get implemented when the camera/PlantNet flow (#9-first-run / structural work) lands; PlantNet itself only needs raw bytes over HTTP, so image storage doesn't gate identification.
- **#9 First verified run: ANSWERED** (Android emulator, 2026-08-15) — app runs end-to-end; works list + 9 findings + evidence in `05-verify-the-app-boots.md` (Answer). Three fix commits landed on `run/first-boot` (care-schedule setState-during-build crash; PlantNet api-key must be a query param + v2 commonNames List shape; google-services plugin apply). Graduated: notifications wiring ticket (exact-alarm permission request + FCM background handler). Fog: onboarding overflow (19px), sign-in/Create Account navigation quirks, identified-data prefill.
- **FCM background handler is never registered** (found in #7) — `onMessage`/`onBackgroundMessage` wiring incomplete; the notifications flow in 5-verify-the-app-boots must decide whether background push is required.
- **`SyncService.isConnected()` always true** (found in #7) — connectivity_plus v6 list compared with `!=`; latent bug, never reached by analyze; 6-tests-along-the-route should cover it.
- Whatever breaks at first boot once 1-fix-the-compile and 2-fold-the-cleanup-baseline land: runtime API drift, missing config, permission flows. Tickets graduate as the frontier reaches them.
- Whether AVDs are set up on this machine and which iOS targets/team are available for signing — graduates into the release tickets (7-android-release-build / 8-ios-release-build).
- Whether the camera/PlantNet identification flow actually works on a simulator (camera plugin limits) — the first run will reveal; may graduate into its own ticket.
- Whether upstream guides (10-settle-the-guides) change the release steps recorded in them.

## Out of scope

- App store listing, marketing, and *submitting* to Play / App Store review — destination is the build, not the launch.
- New feature work surfaced while running the app — release first, features after.
- Anything beyond iOS + Android (the repo has no other platform folders; `web/` is gitignored).
- Performance or architecture refactors that don't block compiling, running, or releasing.
- Plant identification accuracy or PlantNet model work.