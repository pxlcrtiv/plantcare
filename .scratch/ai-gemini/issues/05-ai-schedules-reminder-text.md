# 05 — AI watering schedules + smart reminder text

**What to build:** AI-proposed watering schedules: when adding a plant, the care-setup step proposes an AI schedule grounded in species and environment; the user confirms before anything is applied (suggest-then-confirm). The care-reminders sheet gains a regenerate action. Reminder notifications carry AI-written text reflecting plant state — "water Smoke Fern — 6 days overdue" — instead of a generic "Reminder".

**Blocked by:** 01 (hub); wayfinder 13, 14, 19.

**Status:** ready-for-agent

- [ ] Add-plant wizard proposes an AI schedule for confirmation (not auto-applied)
- [ ] Regenerate works from the care-reminders sheet
- [ ] Confirmation writes schedule fields without clobbering sibling keys
- [ ] Notification text is AI-generated from plant state and displays correctly
- [ ] Manual schedule entry still works and takes precedence when AI is unavailable
- [ ] Widget tests (fake service): propose → confirm, propose → cancel, regenerate, reminder text rendering
- [ ] Service unit tests: schedule/reminder prompt assembly and parsing (mocked AI Logic client)
- [ ] `flutter analyze` clean; full test suite green