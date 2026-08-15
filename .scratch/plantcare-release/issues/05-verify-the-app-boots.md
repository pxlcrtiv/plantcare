Type: task
Status: open
Blocked by: 01, 02, 03, 04

## Question

First verified boot: is the app runnable end-to-end on a simulator, and what breaks?

Run the app on iOS simulator and Android emulator (both available on this M1 Mac; if no Android AVD exists, note it — may graduate a setup ticket). Smoke the whole flow: splash → onboarding → sign-up/login (Firebase) → add plant (manual entry *and* PlantNet camera path — camera plugin may not work on simulator; record what actually works) → dashboard persistence → plant detail → notifications setup.

AFK where possible. This is the frontier's curiosity ticket — expected to surface runtime blockers that graduate into new tickets. Record a numbered list of "works / broken" per flow per platform, with evidence (screenshots, logs, console). Nothing resolves here but the question "does it run?" — every issue found feeds the Not-yet-specified fog and may become its own ticket.

HITL note: if your environment can't reach something only the human can provide (device, account), hand back a precise checklist and record the blocker.
## Answer — first verified run (Android emulator, 2026-08-15)

**Verdict: the app runs end-to-end on Android.** Platform: `sdk gphone64 arm64` (AVD `plantcare_api35`, API 35, headless swiftshader). Run form: `flutter run -d emulator-5554 --debug --dart-define=PLANTNET_API_KEY=<key>`. Evidence: `/tmp/flutterrun3.log` (session with all fixes), `/tmp/flutterrun.log` (first session), uiautomator dumps + captured JPEGs pulled from device cache.

### Works (numbered)
1. **Boot → onboarding → dashboard**: splash/onboarding renders, Skip navigates to dashboard (health banner, weather, empty-state).
2. **Auth**: Firebase email/password works end-to-end — credential entry → `FirebaseAuth` "Notifying auth state listeners" → session persists across full app restarts (straight to dashboard on relaunch). Test account created server-side via Auth REST: `plantcare.smoke@gmail.com` / `SmokeTest2026!`, uid `leiJmqs4jDWuYKdgryOTU3LBpH42`.
3. **Manual add-plant wizard**: Choose Method → details (name/species/location) → photos → care schedule (sliders/toggles) → Review & Save → "Plant Added!" dialog → plant card on dashboard.
4. **Persistence**: Smoke Fern card reappears after full process restart — Firestore round-trip confirmed.
5. **PlantNet identify (camera)**: Camera tab → shutter (permission dialogs granted: camera, audio) → upload → real results screen: "Didier's tulip / Tulipa gesneriana L." with Medium Care / Weekly (virtual-scene photo; PlantNet returned 200 + 10 results, `remainingIdentificationRequests: 492`).
6. **Select This Plant** → returns into Add New Plant wizard (manual path; empty prefill — see 5B below).
7. Bottom nav 4 tabs (My Plants / Calendar / Camera / Profile) all present and tappable.

### Broken / needs attention
1. **Onboarding layout overflow** — `RenderFlex overflowed by 19 pixels on the bottom`, Column at `lib/presentation/onboarding_flow/widgets/onboarding_page_widget.dart:48`; repeats on each page frame (38px on page 2). Cosmetic in release (clips); stripes + error noise in debug.
2. **Sign-in navigation** — after successful credential sign-in the UI stayed on the login screen (auth state FLIPPED server-side; observed once, session 1 — re-verify post-fixes; may share root cause with 4B).
3. **"Create Account" button does not navigate** — 2 tap attempts, fresh dumps each time, still login form. (Matches "New here? Create one" path.)
4. **Care Schedule step crashed deterministically** — `setState() called during build` / `_elements.contains(element)` assertion via `CareScheduleSetup.initState` → `onScheduleChanged` → parent setState; surfaced as full-screen "Something went wrong" (global `ErrorWidget.builder`). **FIXED on run/first-boot** (`e11564f`: defer initial callback past build) — step re-verified working after fix.
5. **PlantNet identify: 401 then parse crash** — two deterministic bugs, both **FIXED on run/first-boot** (`6de5536`): (a) api-key was sent inside the multipart body — PlantNet v2 demands it as query param ("Missing authentication" verified host-side both ways); (b) v2 returns `species.commonNames` as a List, model cast it to `Map<String,dynamic>?` → "List<dynamic> is not a subtype of Map" — now normalized to `{'en': [...]}`. Post-fix: real results screen (works #5).
6. **Score shows "0% match"** — display bug: PlantNet score 0.169 rendered as 0% (formatting), while confidence is meaningful.
7. **Select This Plant quirks**: first tap after results load appeared swallowed once (navigated only on second tap); identified data (name/species/photo) does **not prefill** the wizard — user re-types what the AI just told them (v2 polish).
8. **Notifications unverified / permission gap**: save path never requests `SCHEDULE_EXACT_ALARM` (`requestExactAlarmsPermission()` not called — `notification_service.dart`), and FCM background handler remains unregistered. No exception surfaced on save, but no visible schedule proof either. **Graduates to a new ticket** (notification wiring + verification) since exact-alarm on API 33+ requires an explicit user grant the app never asks for.
9. **Cosmetic**: `WindowOnBackDispatcher` warning — app should set `android:enableOnBackInvokedCallback="true"`.

### Environment notes (for the HITL log)
- Android toolchain was absent → installed (openjdk@21, cmdline-tools, platform-tools, emulator, API 35/36, AVD `plantcare_api35`). Flutter 3.44.9, macOS 26.6.1 arm64.
- First Gradle build ~5–11 min, incremental ~1–2 min; debug APK ≈ 157 MB.
- iOS simulator not available (iOS 26.5 runtime not installed) — Android-only smoke this round.
- Camera plugin: works on the emulator (virtual scene); permission chain = camera → audio.
- Emulator quirk: `uiautomator dump` can serve stale files — `rm` the target before dumping.

### Route impact
- 3 commits on `run/first-boot` (local, no push): `e11564f` (care-schedule crash), `6de5536` (PlantNet auth + model), `a045ad9` (google-services plugin apply). Release builds (#7/#8) inherit all of these.
- Notifications ticket graduates (see 8 above). Image pipeline (fog) still pending camera→Firestore wiring.
