# 03 — Plant Doctor: apply

**What to build:** What happens after the diagnosis: the user can save the diagnosis as a care-log entry so the plant's health history stays complete, and — per the doctor grilling decision — apply any suggested care adjustments with explicit confirmation (suggest-then-confirm; the assistant never silently rewrites the plant). Re-diagnose is covered by 02; this ticket owns persistence and application.

**Blocked by:** 02 (diagnose); wayfinder 17 (apply half of the doctor grilling).

**Status:** ready-for-agent

- [ ] Saving a diagnosis creates a care-log entry on the plant, visible in its health history
- [ ] Suggested care adjustments are presented and only applied after user confirmation
- [ ] Confirmation writes the plant fields without clobbering sibling keys
- [ ] Widget tests (fake service): save-to-log and confirm-apply flows; cancel leaves the plant unchanged
- [ ] `flutter analyze` clean; full test suite green