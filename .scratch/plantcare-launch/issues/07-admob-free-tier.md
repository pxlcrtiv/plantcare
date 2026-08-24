# 07 — AdMob for free tier

Type: task
Status: open
Blocked by: 06

## Question

Research Phase 4: "Add non-intrusive native ads for free users (Google AdMob)". Free users see ads; Pro = no ads (ticket 06's table). The app has no ads today.

Path:

1. **Prereq**: Pro tier exists (06) so "no ads" is a real Pro perk.
2. **AdMob account + ad unit** (HITL: human creates the account — Google requires identity/banking verification for payouts; ad unit ids are the only wiring the agent does).
3. **Integration**: `google_mobile_ads` package, native/banner format (research says "non-intrusive native ads" — NOT interstitials), placement decisions: dashboard, plant detail, identification results — never over the diagnosis/emotion moments (that's where Pro triggers live, ticket 06).
4. **Testing**: AdMob test ad unit ids in debug; verify real ads load in a release build; verify Pro users see zero ads.
5. **Privacy**: GDPR consent flow consideration (google_mobile_ads UMP) — record the decision; the app stores no ad-id-level personal data today.

## Checklist

- [ ] Human: AdMob account + ad unit created (evidence: unit id placeholder, not the real key, committed)
- [ ] Native/banner ads integrated at non-intrusive placements
- [ ] Debug uses test unit ids; release loads real ads (evidence: logcat + screenshot)
- [ ] Pro users verified ad-free
- [ ] GDPR/UMP decision recorded
- [ ] `flutter analyze` clean; full test suite green