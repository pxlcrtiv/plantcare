# 11 — iOS deferral decision

Type: grilling
Status: open
Blocked by: —

## Question

The research is explicitly Android-first ("Flutter → single codebase, Android-first, iOS later") and the release map already has an iOS release-build ticket (08) that's parked behind the Android one (07). The app's iOS side exists (`ios/` folder, `GoogleService-Info.plist` committed) but has never been built or run.

Grilling — one question at a time:

- Defer iOS until Android hits a milestone (research Phase 2: 10K downloads? Phase 3: 100K?)?
- Bundle iOS into the release effort now (consume `08-ios-release-build`), so both platforms launch together?
- iOS is the primary market for plant apps (PictureThis/Planta both monetize iOS heavily) — is Android-first actually right for THIS app's audience (research says the gap is conversational AI + community)?

## Checklist

- [ ] Human decides the deferral trigger (milestone-based) or bundles iOS now
- [ ] Decision recorded here; release ticket 08's status updated to match
- [ ] If deferred: re-trigger criteria written so the decision is revisited, not forgotten