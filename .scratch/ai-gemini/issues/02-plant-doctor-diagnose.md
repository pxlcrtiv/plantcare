# 02 — Plant Doctor: diagnose

**What to build:** The Plant Doctor's core loop: the user takes a photo of a sick leaf (camera or gallery) and receives a diagnosis — what is wrong, how severe, and step-by-step treatment advice — grounded in the PlantNet species result and the plant's profile (humidity, light, location, schedule). The diagnosis renders as a result card; a quota/error failure shows the resting state rather than a crash. This is the first feature that exercises the full vertical path: UI → PlantAiService → Gemini → parsed result → UI.

**Blocked by:** 01 (hub); wayfinder 13, 14, 17 (diagnosis half of the doctor grilling).

**Status:** ready-for-agent

- [ ] Diagnose from a live camera capture or a gallery photo
- [ ] Result card shows diagnosis, severity, and treatment steps, grounded in species + profile
- [ ] Re-running a diagnosis on a new photo works
- [ ] Quota/error path shows the resting state with retry
- [ ] Widget tests (fake service): diagnose flow renders the result card; malformed/quota responses render the resting state
- [ ] Service unit tests: prompt assembly and result parsing for well-formed and malformed output (mocked AI Logic client)
- [ ] `flutter analyze` clean; full test suite green