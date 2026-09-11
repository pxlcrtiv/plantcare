# 18 — Firebase Spark quota + Gemini AI cost at scale

Type: task
Status: in-progress
Blocked by: —
Progress: batched deleteAccount writes (83c1090, main). Left (HITL, Firebase Console): usage audit, budget alerts, Blaze threshold sign-off.

## Question

Ticket 05 covers PlantNet's 500/day cap, but the app has **two more quota walls** that hit before 1M users:

1. **Firestore Spark**: 50K reads/day, 20K writes/day. With 10K daily active users each reading their plant list + care schedules, this fills fast. The research's cost model (ticket 10) mentions Spark→Blaze migration but doesn't model the technical quota walls.
2. **Gemini AI Logic free tier**: the plant doctor, care chat, schedule proposals, and health log summaries all run on Gemini's free tier. The high-demand fallback chain (4 models) was built to handle quota exhaustion, but the free tier limits are undocumented and may throttle heavily at real usage.
3. **Firebase Storage**: 5GB free — plant photos accumulate. At 100KB/photo × 1000 users × 10 photos = 1GB. Manageable initially, but needs monitoring.

Path:

1. **Audit current usage**: check Firebase Console for Firestore reads/writes, Storage usage, AI Logic invocations. Establish baselines.
2. **Firestore optimization**: batch reads, paginate queries, use Firestore's `limit()` aggressively. Consider Firestore's "count" API instead of fetching full documents just to count.
3. **AI Logic cost model**: document Gemini free-tier limits (requests/day, tokens/day). Model cost at 1K, 10K, 100K DAU. Compare with Blaze plan pricing.
4. **Blaze migration plan**: when to upgrade from Spark to Blaze (likely around 5K-10K DAU). What triggers the upgrade: Firestore quota exhaustion, Storage limits, or AI Logic throttling.
5. **Monitoring**: set up Firebase budget alerts (Console → Billing → Budget) so quota surprises don't cause downtime.

## Checklist

- [ ] Current Firebase usage audited (Firestore, Storage, AI Logic)
- [ ] Firestore optimization implemented (batching, pagination, limits)
- [ ] AI Logic free-tier limits documented with cost model
- [ ] Blaze migration threshold identified (DAU number)
- [ ] Firebase budget alerts configured
- [ ] Implications recorded for ticket 10 (unit economics)
