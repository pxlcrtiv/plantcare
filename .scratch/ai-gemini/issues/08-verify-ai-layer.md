# 08 — Verify the AI layer on-device

**What to build:** Prove the full AI layer works on a real device: Care Assistant hub shows live availability, Plant Doctor returns a real Gemini diagnosis for a photo, care chat answers about a specific plant, schedule setup proposes a care schedule, reminder settings propose a reminder, and the health-log summary summarizes real logs. Quota/error paths are exercised via airplane mode (offline). Evidence = screenshots at each step; drive via adb; AFK.

**Blocked by:** 07 (quota UX).

**Status:** in-progress

## Verification checklist (drive plan)
1. Boot emulator `plantcare_api35b` (port 5554), install `app-debug.apk` built from `feat/ai-assistant` tip.
2. Sign in as `plantcare.smoke@gmail.com` / `SmokeTest2026!` (session was wiped with AVD data).
3. Hub: Care Assistant card visible, availability probe returns live state. Screenshot.
4. Plant Doctor: pick sample leaf photo (`/tmp/leaf3.jpg`), tap Diagnose → real Gemini diagnosis card (condition, severity, treatment). Screenshot.
5. Doctor apply: Save to health log → entry appears in Health tab; care adjustments card on plant with attached profile. Screenshot.
6. Care chat: ask "how often should I water my smoke fern?" → real answer grounded in the plant profile. Screenshot.
7. Schedule setup (add plant flow): propose schedule → real JSON schedule rendered. Screenshot.
8. Reminder settings sheet: propose reminder → real reminder text. Screenshot.
9. Health-log summary: summarize → real summary card. Screenshot.
10. Offline: airplane mode → each AI surface shows resting card (AiErrorCard, "You're offline"), manual paths still work. Screenshot. Exit airplane mode.
11. Quota (if reachable): hammer diagnose until quota → resting card with retry. Optional — free tier may not exhaust quickly.

## Evidence
- Code-level (done): `flutter analyze` clean; `flutter test` 178/178 green on `wf/08-verify-ai-layer` @ `3b33d8e` (same tree as `feat/ai-assistant` tip).
- APK: `build/app/outputs/flutter-apk/app-debug.apk` built from the same tree.
- Sample photo staged at `/tmp/leaf3.jpg` (Unsplash plant photo, 640x853).
- On-device screenshots: PENDING — blocked by host memory pressure; emulator guest fails to boot (adbd never registers; host load 18, ~90MB free RAM, VMware Fusion + OpenSuperWhisper + 2× VS Code + 2× opencode hogging memory).

## Resolution path
Free host memory (suspend VMware VM / quit OpenSuperWhisper / close VS Code windows), cold boot `plantcare_api35b` (`-no-snapshot -no-window`), reinstall APK, drive checklist above.
