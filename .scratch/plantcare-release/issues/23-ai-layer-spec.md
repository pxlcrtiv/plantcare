Type: spec
Status: open
Labels: ready-for-agent
Map: map-ai-gemini.md

# Spec: plantcare AI layer — Gemini via Firebase AI Logic

## Problem Statement

As a plant parent, I can identify my plant's species, but the app goes quiet when the plant is sick: yellow leaves, drooping stems, brown tips — I'm left googling and guessing. Meanwhile the app already holds everything a plant doctor would need: my plant's photo, species, light and humidity readings, watering history, and care logs — it just never does anything with them. The Flask tab sits as an empty "coming soon" promise. My plant's data has intelligence latent in it, and the app gives me none of it.

## Solution

The app gains a Gemini-powered AI layer, accessible from the Flask tab — reborn as the **Care Assistant** hub — and woven into the places care decisions already happen. Snap a photo of a sick leaf and get a diagnosis with treatment steps. Ask "why are my fern's leaves browning?" in plain chat and get an answer grounded in my plant's actual profile and history. Get an AI-proposed watering schedule and smarter reminder messages. Have my month of care logs summarized into a readable story. All powered by Gemini 2.5 Flash served through Firebase AI Logic — no API key in the APK, access gated behind my sign-in, and a friendly "the assistant is resting" fallback when the free quota is exhausted.

## User Stories

1. As a plant parent, I want to open the Flask tab and find a Care Assistant hub, so that I can discover and reach every AI feature from one place.
2. As a plant parent, I want the hub to explain what Plant Doctor and Care chat do, so that I can choose the right tool without guessing.
3. As a plant parent, I want to photograph a sick leaf and receive a diagnosis, so that I know what is wrong with my plant.
4. As a plant parent, I want the diagnosis to include severity, so that I know whether to act now or wait.
5. As a plant parent, I want step-by-step treatment advice, so that I can act on the diagnosis.
6. As a plant parent, I want the diagnosis to be grounded in my plant's species (from PlantNet) and profile, so that the advice matches my actual plant rather than generic text.
7. As a plant parent, I want to take the photo with the camera or pick one from my gallery, so that I can diagnose photos I already have.
8. As a plant parent, I want to re-run a diagnosis on a new photo, so that I can track whether treatment is working.
9. As a plant parent, I want a diagnosis result to be storable as a care-log entry, so that my plant's health history stays complete.
10. As a plant parent, I want to chat with the assistant about my plant's health in plain language, so that I can ask follow-up questions conversationally.
11. As a plant parent, I want the chat to be grounded in my plant's data — profile, schedule, and logs — so that answers reflect my plant, not generic gardening text.
12. As a plant parent, I want to start a chat about a specific plant from its detail screen, so that context is set without retyping.
13. As a plant parent, I want to attach a photo to a chat message, so that I can ask about something visual mid-conversation.
14. As a plant parent, I want suggested question chips in chat, so that I can get started without composing prompts.
15. As a plant parent, I want my chat history to persist, so that I can revisit advice from earlier conversations.
16. As a plant parent, I want an AI-proposed watering schedule when adding a plant, so that a new plant starts with sensible care defaults.
17. As a plant parent, I want to regenerate the schedule on the care-reminders sheet, so that changing seasons or conditions are reflected.
18. As a plant parent, I want to confirm before an AI schedule is applied, so that the app never silently rewrites my care plan.
19. As a plant parent, I want reminder notifications with AI-written text reflecting plant state, so that "water Smoke Fern — 6 days overdue" replaces "Reminder".
20. As a plant parent, I want my plant's care log summarized into a readable story, so that I can see the arc of its health at a glance.
21. As a plant parent, I want to regenerate a summary, so that it reflects the latest log entries.
22. As a plant parent, I want the hub to look right even before I sign in or when offline, so that the tab never dead-ends.
23. As a plant parent, I want a friendly "assistant is resting, try again in a moment" state when the quota is exhausted, so that failures never look like crashes.
24. As a plant parent, I want manual care features (schedule, reminders, logs) to keep working when AI is unavailable, so that the app degrades gracefully.
25. As a plant parent, I want the Privacy screen to state that photos may be sent to Gemini, so that I know where my data goes.
26. As a plant parent, I want all AI features behind my sign-in, so that my data and quota stay mine.

## Implementation Decisions

- **Model and transport**: Gemini 2.5 Flash via **Firebase AI Logic**. The Gemini key lives server-side; the APK carries no key (this is the reason AI Logic is chosen over the raw `google_generative_ai` SDK). Access gated per-authenticated-user via App Check + Firestore rules; per-user quotas are rule-controlled.
- **The one seam**: a `PlantAiService` interface is the single path every AI feature uses. It exposes feature-level operations (diagnose, chat, propose schedule, reminder text, summarize) and owns: prompt assembly, grounding, output parsing/validation, and the error taxonomy. It is constructor-injected into screens, following the existing repository-injection pattern (`PlantRepository` in the dashboard/detail screens).
- **Hub**: the Flask dock tab's `DiagnosticsTab` placeholder is replaced by the Care Assistant hub — Plant Doctor and Care chat entry cards, with the hub's empty/offline states defined. Contextual entry points deep-link into the same features: Home scan area and plant detail (doctor), detail "ask about my plant" (chat), add-plant wizard care-setup (schedule prefill), detail care-reminders sheet (regenerate + reminder text), Health tab (summarize).
- **Grounding**: diagnosis/schedule/summary prompts are grounded in: the photo bytes (no new storage path — images already live in Firestore docs), the PlantNet species result, and the plant profile (humidity, light, location, careSchedule), plus the `healthLogs` subcollection and notes where relevant (summary, chat).
- **Apply model**: AI schedules/reminders are **suggest-then-confirm** — the LLM never mutates a plant doc directly; the user confirms before `careSchedule` / `reminderTime` fields are written (dot-notation update, sibling keys preserved).
- **Error taxonomy → UI**: the service classifies failures (quota, blocked, timeout, malformed output, offline) and each feature maps them to its state — the "assistant is resting" card with retry for quota; manual paths stay available for schedules/reminders/logs.
- **Open decisions** (prompt templates, chat storage shape, history retention, per-feature cost guardrails, summary persistence) are deliberately **not** settled here — they are wayfinder tickets on this map (`map-ai-gemini.md`): 14 (service design), 16 (hub), 17 (doctor), 18 (chat), 19 (schedules/reminders), 20 (summaries), 21 (quota/error UX), resolved before or with implementation per ticket.

## Testing Decisions

- **What makes a good test here**: external behavior only — screens respond correctly to what the service returns (diagnosis rendered, chat message appears, resting card on quota). Tests never assert on prompt internals or model output; prompt/parse logic is tested for determinism, not content.
- **The seam**: `PlantAiService` is the single test boundary. Two levels, one seam:
  - **Widget tests** (highest seam): a fake `PlantAiService` with canned responses is injected into the screens; tests cover hub rendering, doctor flow, chat send/receive, schedule propose-confirm, summary card, and quota/error states.
  - **Service unit tests**: the real `PlantAiService` against a mocked AI Logic client — covering prompt assembly shape, output parsing/validation of well-formed and malformed responses, and error-taxonomy mapping.
- **Modules tested**: hub widget, doctor screen/widgets, chat screen/widgets, schedule-propose UI, summary UI, fallback states; service parsing/prompt/error logic.
- **Prior art**: `test/widget_smoke_test.dart` (44 tests, injected seams), `test/health_log_tab_widget_test.dart` (5 widget tests added with the Add Log fix), `test/plantnet_service_test.dart` (service unit tests against a mocked dio client — the pattern for mocking the AI Logic client).
- **No live Gemini in CI**: real-model end-to-end is the on-device verification ticket (22), driven once on the emulator with evidence, not part of the suite.

## Out of Scope

- On-device / self-hosted LLM fallbacks (llama.cpp, MediaPipe, Ollama) — cloud-only per the user's decision.
- Replacing PlantNet with Gemini for species identification — PlantNet stays the identification engine.
- Release builds, signing, store submission (the release map's destination, not this one).
- Notification infrastructure beyond reminder text content (permissions/alarm wiring is the notifications ticket on the release map).

## Further Notes

- The grilling decisions pinned 2026-08-16 (destination shape C, Flask hub, auth gating, Flash model, graceful fallback, privacy copy, cloud-only) are recorded on `map-ai-gemini.md`; this spec is the PRD they produce.
- Base branch: `feat/ui-redesign` (UI redesign + 12 dead-feature fixes merged; PR not yet opened).
- Each ticket is worked in its own git worktree by a subagent; PRs are batched later.
- Verification standard: on-device emulator evidence per `verification-before-completion`, recorded in ticket 22.