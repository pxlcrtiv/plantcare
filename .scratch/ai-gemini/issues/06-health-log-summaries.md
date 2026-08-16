# 06 — Health-log summaries

**What to build:** A "Summarize" action on the plant detail screen's Health tab. Tapping it produces a readable summary of the plant's care-log history (grounded in the logs, notes, and profile), shown as a summary card with a regenerate affordance. Persistence vs ephemeral follows the wayfinder 20 decision; cost guardrails for long histories apply.

**Blocked by:** 01 (hub); wayfinder 13, 14, 20.

**Status:** ready-for-agent

- [ ] Summarize action on the Health tab produces a grounded summary card
- [ ] Regenerate produces an updated summary reflecting the latest entries
- [ ] Long histories are handled within the token budget (truncate/roll up per wayfinder 20)
- [ ] Quota/error path shows the resting state with retry
- [ ] Widget tests (fake service): summarize renders, regenerate updates, resting state
- [ ] Service unit tests: history assembly and summary parsing (mocked AI Logic client)
- [ ] `flutter analyze` clean; full test suite green