# 07 — Quota/error degradation UX

**What to build:** One consistent degradation story across every AI feature. When the quota is exhausted, a call is blocked, times out, or the output is malformed, the user sees the friendly "assistant is resting, try again in a moment" state with a working retry — never a crash or dead end. Offline, every manual care path (schedule entry, reminders, logs, PlantNet identification) keeps working untouched. This ticket applies the error taxonomy from the service design across the four features and verifies each mapped UI state.

**Blocked by:** 02 (diagnose), 03 (apply), 04 (chat), 05 (schedules), 06 (summaries); wayfinder 21.

**Status:** ready-for-agent

- [ ] Every error class from the taxonomy (quota, blocked, timeout, malformed, offline) maps to its UI state in each feature
- [ ] Resting card + retry renders in doctor, chat, schedules, and summaries
- [ ] Offline behavior verified: manual paths fully functional, AI surfaces show the resting state
- [ ] Widget tests (fake service): each feature's quota/error state renders with working retry
- [ ] `flutter analyze` clean; full test suite green