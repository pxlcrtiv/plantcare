# 08 — In-app referral program + community

Type: task
Status: open
Blocked by: 06

## Question

Research Phase 3: dual-sided referral program ("Give 50 coins" / "Trending Now" tab), 20–35% referral lift, community flywheel (Discord + micro-influencers 1K–50K + UGC "My Plant Came Back Story"). The app has no referral/community mechanics today.

Path:

1. **Prereq**: Pro tier exists (06) — the referral reward economy ("coins") and the trending tab are monetization-adjacent; decide whether coins are a free-trial currency, a Pro discount, or cosmetic.
2. **Referral mechanics**: share link (deep link into the app), dual-sided reward (inviter + invitee), attribution (Firestore doc per invite code), redeem flow.
3. **"Trending Now" tab**: surfaced plant/community content inside the app — scope decision: is this a simple "popular plants" list reusing the existing database browser, or a real community feed? Record the decision.
4. **Community**: Discord server (HITL: human owns creating it) + micro-influencer outreach kit (one-pager + invite links) — the agent can draft the kit, the human sends it.
5. **UGC campaign**: "My Plant Came Back Story" — in-app prompt after a plant recovers (ties to the doctor/health-log data) + social amplification.

## Checklist

- [ ] Coins/reward economy design decision recorded (06 interplay)
- [ ] Deep-link + referral code + attribution implemented and tested (widget tests)
- [ ] Trending tab decision recorded (reuse vs new feed) and implemented
- [ ] Discord created (HITL) + outreach kit drafted
- [ ] UGC prompt implemented at plant-recovery moment
- [ ] `flutter analyze` clean; full test suite green