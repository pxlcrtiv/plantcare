# 05 — PlantNet 500/day rate-cap strategy

Type: task
Status: open
Blocked by: —

## Question

PlantNet's free tier is 500 identifications/day (research: "PlantNet API — 500/day free"). The app currently calls PlantNet on every identification with no caching or quota awareness. At 1M downloads this is a hard scaling constraint — and the research's Pro tier ("Unlimited plant identification") must not blow through it.

Path:

1. **Cache layer**: store identification results (species, common name, image) in Firestore keyed by a fingerprint (e.g., species name) so repeat identifications of common plants skip the API. Scan history is already local (Day-2 research item) — decide cache scope: local-first, Firestore for cross-device.
2. **Quota guard**: count API calls (local or Firestore daily counter); when the 500/day budget is near, degrade gracefully: prefer cache, fall back to the in-app database browser / manual entry, or the Gemini doctor for care advice (no PlantNet call needed).
3. **429 handling**: PlantNet rate-limit responses must map to a friendly "identification temporarily unavailable — try the database or manual entry" state, not a raw error.
4. **Pro tier interplay**: "Unlimited identification" on Pro must either be backed by a PlantNet paid plan (research notes it as open) or by the cache layer absorbing most traffic. Record the decision; ticket 06 consumes it.

## Checklist

- [ ] Cache layer implemented (local and/or Firestore) — decision recorded
- [ ] Quota guard + 429 → friendly state verified on-device
- [ ] Pro-tier interplay decision recorded for ticket 06
- [ ] `flutter analyze` clean; full test suite green (new tests for cache + quota logic)