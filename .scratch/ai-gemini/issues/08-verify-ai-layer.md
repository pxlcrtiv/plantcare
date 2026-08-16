# 08 — Verify the AI layer on-device

**What to build:** End-to-end verification of the whole AI layer on the Android emulator against the real Firebase AI Logic project. Drive every feature — hub, doctor diagnose and apply, chat, schedules/reminder text, summaries, and the quota/error states — and record evidence per verification-before-completion. Pairs with wayfinder 22, which stays the map's closing ticket.

**Blocked by:** 02, 03, 04, 05, 06, 07; wayfinder 22.

**Status:** ready-for-agent

- [ ] On-device pass of every feature with evidence screenshots recorded
- [ ] Quota/error path exercised (forced where possible) with resting state observed
- [ ] `flutter analyze` clean; full test suite green after the AI work lands
- [ ] Findings recorded in this ticket and any residual issues filed