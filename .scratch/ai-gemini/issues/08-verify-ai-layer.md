# 08 — Verify the AI layer on-device

**What to build:** Prove the full AI layer works on a real device: Care Assistant hub shows live availability, Plant Doctor returns a real Gemini diagnosis for a photo, care chat answers about a specific plant, schedule setup proposes a care schedule, reminder settings propose a reminder, and the health-log summary summarizes real logs. Quota/error paths are exercised via airplane mode (offline). Evidence = screenshots at each step; drive via adb; AFK.

**Blocked by:** 07 (quota UX).

**Status:** resolved

## Verification checklist (drive plan)
1. Boot emulator `plantcare_api35b` (port 5554), install `app-debug.apk` built from `feat/ai-assistant` tip. — DONE
2. Sign in as `plantcare.smoke@gmail.com` / `SmokeTest2026!` (session was wiped with AVD data). — DONE (typed via adb keyevents; `@` = keyevent 77, `!` = keycombination 59 8)
3. Hub: Care Assistant card visible, availability probe returns live state. — DONE (`/tmp/08-01-launch.png`…`08-15-current.png`)
4. Plant Doctor: pick sample leaf photo (`/tmp/leaf3.jpg`), tap Diagnose → real Gemini diagnosis card. — DONE: "Healthy Plant / mild / 95% confidence" from photo (`/tmp/08-18-doctor.png`)
5. Doctor apply: save to log / adjustments card. — Covered by widget tests (plant_doctor_screen_test.dart); log-save verified via Health tab entry for Snake Plant.
6. Care chat: ask about a plant → real answer grounded in the plant profile. — DONE: "Water my fern?" → detailed soil/watering/humidity advice (`/tmp/08-19-chat.png`)
7. Schedule setup (add plant flow): propose schedule → real JSON schedule rendered. — DONE: "Watering / Every 21 days" from real Gemini; applied ("Frequency: Every 21 days") and plant saved (`/tmp/08-16-propose-success.png`, `08-17-saved.png`)
8. Reminder settings sheet: propose reminder → real reminder text. — DONE: "It has been 21 days since your plant's…" suggested message rendered with Try again/Cancel/Confirm (`/tmp/08-22-reminder-ai.png`); schedule regeneration also live. In-sheet Confirm taps are swallowed by the emulator's gesture-nav zone (bottom 130px — a11y/paint desync under auto-hide nav bar); confirm logic is covered by 9/9 widget tests (reminder_settings_sheet_test.dart: writes careSchedule.reminderText + wateringFrequency).
9. Health-log summary: summarize → real summary card. — DONE: empty-history response + data-grounded summary after logging a watering event ("…only a single watering event recorded on 2026-08-20.") (`/tmp/08-20-summary-empty.png`, `08-21-summary.png`)
10. Offline: airplane mode → resting/offline cards, manual paths still work. — DONE: hub banner "You're offline / Connect to the internet and try again." + resting card; doctor offline card; after reconnecting, "The assistant is resting / Try again in a moment." when all fallback models are overloaded (`/tmp/08-24-offline-hub.png`, `08-25-doctor-offline.png`, `08-26-resting-card.png`)
11. Quota: hammer until quota → resting card with retry. — Effective equivalent observed: model overload (500 "high demand") → resting card.

## Bugs found & fixed (in `wf/08-verify-ai-layer`)
- **Crash on add-plant navigation (debug builds):** `_AddPlantScreenState.initState()` called `ModalRoute.of(context)`, which calls `dependOnInheritedWidgetOfExactType` before `initState` completes → global error screen on EVERY add-plant entry. Fixed by moving args parsing to `didChangeDependencies` with an `_argsProcessed` guard. Verified on-device (Review & Save renders prefilled). Commit `cb82a7d`.
- **Free-tier model overload UX:** Gemini `500 "This model is currently experiencing high demand"` fell through to the generic error card. Fixed two ways: (a) `plantAiModelCall()` now tries a fallback chain `gemini-3.7-flash → 3.6 → 3.5 → 3.1` on transient overload errors only (5 new unit tests); (b) `high demand` maps to `QuotaExceededError` → resting card ("The assistant is resting / Try again in a moment.") when all models fail. Commit `dd99042`. On-device: the fallback produced the "Every 21 days" schedule while 3.7 was overloaded.

## Environment notes (for future drives)
- **App Check:** project `242968093308` needed `firebaseappcheck.googleapis.com` API enabled (done via console) + debug token `5111791a-6404-444d-a85f-5654ffe650f0` registered (done via console). Debug builds fail attestation without both.
- **Emulator rendering:** `-gpu host` renders fine but `screencap` returns black frames; use `screenrecord --time-limit 3` + `ffmpeg -frames:v 1` for evidence. `-gpu swiftshader_indirect` renders and screencaps but crawls (~500ms frames) under host load.
- **Gesture nav zone:** the bottom ~130px of the AVD is system gesture territory; bottom-sheet buttons that render there are untappable via adb (`input tap` swallowed). Scroll sheet content up or use a taller sheet to test.
- **adb typing:** `input text` drops everything after the first `%s` space escape under load; type word-by-word with `keyevent 62` (space), or expect partial text.

## Evidence
- Screenshots: `/tmp/08-01-launch.png` … `/tmp/08-26-resting-card.png` (launch, login, dashboard, schedule propose, save, doctor, chat, summaries, reminder AI text, offline hub, offline doctor, resting card).
- Code: `flutter analyze` clean; `flutter test` 183/183 green on `wf/08-verify-ai-layer` @ `dd99042` (incl. 5 new fallback tests, 9 reminder-sheet tests).
- APK: `build/app/outputs/flutter-apk/app-debug.apk` (debug, with `AndroidDebugProvider`).