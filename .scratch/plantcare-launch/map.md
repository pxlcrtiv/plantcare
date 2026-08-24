# Map: plantcare launch effort

## Destination

A verified route from "app runs on-device" to **launch readiness**: a live Google Play listing, a public closed beta, a working monetization pipeline (Pro tier + AdMob), and a running growth engine (content + referrals) — built on the market research the human supplied.

## Source research

- `research/plant-care-market-research.png` (the human's original image)
- `research/plant-care-market-research.md` (vision transcription — read this; images are unreadable to non-vision agents)

## Notes

- **Domain**: Flutter app already at `main` (analyze clean, 183/183 tests, AI layer verified on-device). This effort adds launch/monetization work on top. The release effort (`.scratch/plantcare-release`) owns producing the signed builds; this effort owns what happens after — listing, beta, monetization, growth.
- **Relationship to release map**: the release map's "Out of scope" section (store listing, marketing, store submission) is exactly this effort's scope. Do not duplicate release tickets 01–10; consume their outputs (07-android-release-build APK, 08-ios-release-build).
- **Budget reality**: the only hard cost in the research is the Google Play Developer account ($25 one-time). Everything else is free-tier (Firebase Spark, PlantNet 500/day, CapCut, Buffer/Later, Canva, free LLM tiers).
- **Skills**: `treehouse` (worktrees per ticket), `tdd`/`test-driven-development`, `verification-before-completion` (evidence before "resolved"), `gh-axi` (GitHub), `firebase-security-rules-auditor` (ticket 12), `grilling` (decision tickets 01, 11).
- **Standing preferences** (from release map, still apply): no secrets in commits; PlantNet key + any API keys via `--dart-define` only; verify subagent work; single concern per commit; evidence (screenshots/logs/tests) recorded before resolving a ticket.
- **Naming tension**: the ASO research suggests "LeafAI — Plant Identifier & Care", but the app, repo, Firebase project, and landing page are all branded **PlatCare** (`com.plantcare.app`, `platcare.app`, waitlist page). Ticket 01 resolves this before any listing/marketing work.

## Tickets

| # | Ticket | Type | Blocked by |
|---|---|---|---|
| 01 | Naming & brand decision (LeafAI vs PlatCare) | grilling | — |
| 02 | Google Play listing + ASO | task | 01 |
| 03 | Closed beta (Play internal testing) | task | 02, 12 |
| 04 | FCM background notifications wiring | task | — |
| 05 | PlantNet 500/day rate-cap strategy | task | — |
| 06 | Pro tier & paywall ($29.99/yr) | task | 05 |
| 07 | AdMob for free tier | task | 06 |
| 08 | In-app referral program + community | task | 06 |
| 09 | AI content engine (1.5h/day) | task | 01 |
| 10 | Unit economics validation | task | — |
| 11 | iOS deferral decision | grilling | — |
| 12 | Firestore rules audit | task | — |

## Out of scope

- Launch execution itself (posting content, paying the $25, creating the Play account) — HITL steps are flagged per ticket, AFK everywhere else.
- Anything not in the research: no paid ads strategy, no app-store listing graphics beyond the research's screenshot spec, no iOS work before ticket 11 resolves.