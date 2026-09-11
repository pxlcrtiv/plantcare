# 01 — Naming & brand decision

Type: grilling
Status: resolved
Blocked by: —
Resolved: d56516f (platcare-waitlist) — waitlist page + privacy page rebranded to PlantCare

## Decision

**Brand: PlantCare.** Consistent across app, package (`com.plantcare.app`), and all user-facing assets.

- Store title: "PlantCare — Plant Identifier & Care" (keyword-loaded for ASO)
- Waitlist page: rebranded from PlatCare → PlantCare (`d56516f`)
- Privacy policy: rebranded to PlantCare
- No LeafAI rebrand needed — the existing brand is clean

## Store-name collisions (checked Sep 11, 2026)

- **App Store: EXACT match** — "PlantCare: AI Plant Identifier" (seller 建逢 陈,
  released Apr 2026, v1.6.8, ~11 ratings). Tiny but a direct competitor with our exact
  name. Apple allows duplicate names; mitigation is the keyword-loaded title
  "PlantCare — Plant Identifier & Care" + distinct Seed of Life icon. Revisit if/when
  iOS ships (ticket 11). Trademark search still open.
- **Play Store: no exact match** — nearest are "PlantCare+: AI Plant Assistant"
  (Pakdata) and "PlantCare Hub". Our full title differentiates. Package
  `com.plantcare.app` is first-to-claim on publish — no evidence of conflict.

## Preliminary trademark search (Sep 11, 2026 — NOT a legal opinion)

Sources: USPTO records via uspto.report mirror; WIPO/Justia/Trademarkia walled (403/CAPTCHA).

US federal — all historic PLANTCARE marks DEAD:
- 79043951 / reg 3480968, Plantcare AG (Swiss irrigation hardware) — Dead/Cancelled.
  Same company family likely behind plantcare.app hardware. Goods were irrigation
  sensors, not software.
- 76387831 / reg 2859368, Endress+Hauser — Dead/Cancelled.
- 74098069, Plantcare Inc. — Dead/Abandoned.
- 73373553 / reg 1273118 + 73116220, Plantlife (landscaping services) — Dead since 1990.
- PROVEN WINNERS PLANTCARE 90279028 — live-ish but Class 1 plant food + composite
  mark; low conflict for an app.
- No live US mark found covering PlantCare for mobile software (Cl. 9/42).

Gaps: Nigeria registry is paper-based (needs a local IP agent search);
common-law users exist (iOS app, plantcare.app hardware, getplantcare.com).

## WIPO IR 937862 deep-dive (Sep 11, 2026 — primary source, Madrid Monitor)

Holder: PlantCare AG, Russikon, Switzerland (the hardware company).
Goods: Cl. 9 irrigation sensors, Cl. 11 irrigation/lighting equipment,
Cl. 21 pots/planters — ALL hardware. No software, no Cl. 42, no apps.
- USA: total provisional refusal (2007) → partial grant (2013) → TOTAL
  INVALIDATION Feb 2016 → US designation NOT renewed 2017. Dead in the US.
- EU (EM): granted 2008, renewed 2017 — LIVE until Jun 2027, hardware goods only.
- JP: refused 2009, not renewed.

Implication: no live mark anywhere covers PlantCare for mobile software. Residual
risk is EU-only (live hardware mark, same plant-care field, shared Cl. 9) — needs
attorney read if/when filing an EUTM or if the Swiss company expands to software.
NG: file locally (Cl. 9 + 42, consider 44) after agent clearance search.
Recommendation: proceed with PlantCare for Android; run agent searches (NG + US)
and consider intent-to-use filing once Reddit validation lands. Confirm with a
trademark attorney before paid spend scales.

## Checklist

- [x] Human decides brand name and store title
- [x] Decision recorded here (and in the launch map)
- [x] Waitlist page + privacy page rebranded to PlantCare
- [x] No listing/marketing work (tickets 02, 09) starts before this resolves