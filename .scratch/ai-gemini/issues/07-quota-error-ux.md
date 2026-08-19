# 07 — Quota/error degradation UX

**What to build:** One consistent degradation story across every AI feature. When the quota is exhausted, a call is blocked, times out, or the output is malformed, the user sees the friendly "assistant is resting, try again in a moment" state with a working retry — never a crash or dead end. Offline, every manual care path (schedule entry, reminders, logs, PlantNet identification) keeps working untouched. This ticket applies the error taxonomy from the service design across the four features and verifies each mapped UI state.

**Blocked by:** 02 (diagnose), 03 (apply), 04 (chat), 05 (schedules), 06 (summaries); wayfinder 21.

**Status:** resolved

- [ ] Every error class from the taxonomy (quota, blocked, timeout, malformed, offline) maps to its UI state in each feature
- [ ] Resting card + retry renders in doctor, chat, schedules, and summaries
- [ ] Offline behavior verified: manual paths fully functional, AI surfaces show the resting state
- [ ] Widget tests (fake service): each feature's quota/error state renders with working retry
- [ ] `flutter analyze` clean; full test suite green
## Answer

Merged + pushed on `feat/ai-assistant` @ `3b33d8e` (commit `3b33d8e` on wf/07, verified 178/178 tests, analyze clean).

Canonical resting card: `lib/widgets/ai_error_card.dart` (`AiErrorCard` — icon + title + body + optional "Try again" `OutlinedButton`), used across doctor, chat, schedule setup, reminder sheet, summary, hub.

Title/body mapping (single source of truth): QuotaExceededError → "The assistant is resting / Try again in a moment."; BlockedError → "The assistant could not answer / Try rephrasing or summarize again."; TimeoutError → "The assistant took too long / Try again in a moment."; MalformedOutputError → "The assistant is resting / Try again in a moment."; OfflineError → "You're offline / Connect to the internet and try again."; UnknownError → "Something went wrong / Try again in a moment."

Retry per surface: doctor re-diagnoses same photo; chat re-sends last message; schedule setup + reminder sheet re-propose; summary re-summarizes; hub re-checks availability. Offline: AI surfaces rest, all manual paths (schedule sliders, reminders, Add Log, PlantNet) untouched; chat disables composer offline. Divergent copy sets removed (doctor's "Photo not reviewable", schedules' "couldn't answer that", chat raw message).
