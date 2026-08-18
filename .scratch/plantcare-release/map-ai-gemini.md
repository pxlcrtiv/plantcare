# Map: plantcare AI layer (Gemini via Firebase AI Logic)

## Destination

plantcare ships a Gemini-powered AI layer via **Firebase AI Logic (Gemini 3.7 Flash)**: Plant Doctor (photo → diagnosis + treatment advice), care chat, AI-generated watering schedules, smart reminder text, and health-log summaries — the **Flask tab becomes the "Care Assistant" hub** with contextual entry points, all **auth-gated**, with a graceful quota/error fallback, privacy copy updated, verified on-device on the Android emulator, and merged into the redesigned app.

## Notes

- **Domain**: Flutter (Dart 3.6, Flutter 3.44.9), Firebase (auth / firestore / storage / AI Logic), Gemini 3.7 Flash, PlantNet REST (stays — species identification only). macOS M1 dev machine, Android emulator for verification.
- **Model note (2026-08-17)**: provisioned with `gemini-3.7-flash` — Gemini 2.5 Flash shuts down 2026-10-16; 3.7 Flash is current stable, free tier, no billing (3.5-flash-lite also free; 3.1 Pro needs billing). Supersedes the 2.5 Flash pre-session decision.
- **Skills to consult**: `firebase-ai-logic-basics` (the Gemini-via-Firebase integration is the spine of this effort), `grilling` / `domain-modeling` (feature tickets are HITL), `prototype` (Flask hub + Plant Doctor UX), `tdd` / `test-driven-development`, `treehouse` (each ticket claimed in its own git worktree by a subagent), `verification-before-completion` (on-device evidence before claiming done), `gh-axi` (PRs handled later).
- **Standing preferences**:
  - Each ticket is claimed and worked in a separate git worktree. PRs are handled later, after the map resolves.
  - Base branch: `feat/ai-assistant` (created 2026-08-17 off `feat/ui-redesign` @ `2261f9e`; frontier wf/13-16 merged + pushed @ `e9b35a8` tip incl. wf/01 hub).
  - Never commit secrets or API keys. AI Logic keeps the Gemini key server-side — nothing in the APK (that is the point of AI Logic over the raw SDK).
  - Images live in Firestore docs (`plant_images/...`); Plant Doctor sends photo bytes to Gemini directly — no new storage path.
  - AI features are gated behind Firebase sign-in like the rest of the app.
  - **Execution override**: like the release map, this effort carries execution — feature tickets decide *and* build their feature; the map is done when the AI layer is built, verified on-device, and merged.
  - Tracker: local markdown in `.scratch/plantcare-release/` on `chore/firebase-config` (tickets 13+ belong to this map). Blocking is expressed in the ticket header (`Blocked by:`).
- **Pre-session decisions (2026-08-16 grilling)**: cloud Gemini via Firebase AI Logic (not raw SDK, not self-hosted, not on-device); Gemini 3.7 Flash default (2.5 Flash shut down 2026-10-16); full feature set (shape C); Flask tab = Care Assistant hub + contextual entries; auth-gated; graceful quota fallback; privacy copy updated.

## Decisions so far

- [Provision Firebase AI Logic](issues/13-provision-firebase-ai-logic.md) — resolved 2026-08-17: AI Logic enabled for Android app; Firebase stack upgraded (core 4.x, auth 6.x, firestore 6.x, storage 13.x, messaging 16.x, ai 3.15.0, app_check 0.4.6); Kotlin 2.2.20; App Check debug provider wired (enforcement off in project); model `gemini-3.7-flash`; spine proven on emulator (AI_SPINE_OK)
- [Design the PlantAiService](issues/14-plant-ai-service.md) — resolved 2026-08-17 (grilled): one typed method per feature (Q1); prompts as const Dart strings in the service, caller-supplied grounding, service never reads Firestore (Q2); JSON schema output for diagnosis/schedule/summary, plain text chat/reminder, one-shot no retry (Q3); gemini-3.7-flash for all features with per-feature temperature/token table (Q4); sealed 6-way error taxonomy (Q5); `ModelCall` function-type seam + hermetic test scope, no live Gemini in CI (Q6)
- [Privacy copy for Gemini photos](issues/15-privacy-copy-gemini-photos.md) — resolved 2026-08-17: copy updated in-app (PlantNet for identification, Gemini API for diagnosis, photos never shared publicly); committed `826b0d0` on wf/15, merged
- [Flask tab → Care Assistant hub](issues/16-care-assistant-hub.md) — resolved 2026-08-17: hub shell prototyped (header + subtitle + Plant Doctor/Care chat entry cards), stubs for not-yet-built destinations; verified on-device; ticket 01 turned prototype into the hub (resting + offline states, PlantAiService seam + provider, 54 tests) committed `e9b35a8` on wf/01, merged
- [Plant Doctor feature](issues/17-plant-doctor.md) — <filled when resolved>
- [Care chat](issues/18-care-chat.md) — <filled when resolved>
- [AI watering schedules + smart reminders](issues/19-ai-schedules-reminders.md) — <filled when resolved>
- [Health-log summaries](issues/20-health-log-summaries.md) — <filled when resolved>
- [Quota/error degradation UX](issues/21-quota-error-ux.md) — <filled when resolved>
- [Verify the AI layer on-device](issues/22-verify-ai-layer.md) — <filled when resolved>

## Not yet specified

- **Chat history retention** — where conversations persist (Firestore shape), how much history is sent as context, deletion policy; graduates from 18.
- **Free-tier quota numbers** — actual per-user/per-project limits for AI Logic + Flash in this project's region; graduates from 21.
- **Model upgrade path** — Flash → Pro for Plant Doctor if diagnosis quality demands it; not ticketable until real diagnoses are in hand (after 17).
- **Schedule generation application model** — auto-apply vs suggest-then-confirm lives in 19, but the deeper question (does the LLM ever mutate the plant doc directly?) may graduate later.

## Out of scope

- **On-device / self-hosted LLMs** (user chose cloud-only Gemini, 2026-08-16) — no llama.cpp/MediaPipe/Ollama fallbacks in this effort.
- **Replacing PlantNet with Gemini identification** — PlantNet stays the species-identification engine; Gemini handles diagnosis/care, not taxonomy.
- **Release builds / signing / store submission** — that is the release map's destination (`map.md`), not this one.