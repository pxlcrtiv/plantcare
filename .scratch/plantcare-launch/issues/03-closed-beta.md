# 03 — Closed beta (Play internal testing)

Type: task
Status: open
Blocked by: 02, 12

## Question

Run the research's Day-7 close: invite 20–50 beta testers through Play internal testing and collect feedback before production launch.

Path:

1. **Prereqs**: Google Play internal testing track live (02), Firestore rules audited (12) — the beta is the first real external users on the app's data.
2. **Tester pool**: invite to Reddit r/plants, r/houseplants, r/gardening + plant Discord servers (research Phase 1: soft-launch to plant communities). Also mine the existing waitlist signups (they're already captured via the landing page).
3. **Feedback loop**: define how feedback is collected (Play internal testing feedback / Discord / in-app?). Seed the plant-care-tips content pipeline from beta user questions (feeds ticket 09's script engine).
4. **Fix cycle**: beta findings become their own tickets (or land in the fix queue); nothing public until the blockers list is clean.
5. **Exit criteria**: N testers onboarded, crash-free usage, feedback triaged, decision to move listing to production (or iterate).

## Checklist

- [ ] Rules audit (12) resolved first
- [ ] Internal testing track live with release APK (02)
- [ ] 20–50 testers invited, evidence of invites recorded
- [ ] Feedback triaged; blockers either fixed or ticketed
- [ ] Go/no-go on production listing recorded here