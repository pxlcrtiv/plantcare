# 16 — Crashlytics + Analytics

Type: task
Status: resolved
Blocked by: —
Resolved: 1e77346 (main) — Crashlytics + Analytics SDKs wired in main.dart, analytics_service.dart created

## Question

The app has **zero observability** — no crash reporting, no event tracking, no retention metrics. The research's entire revenue model depends on numbers nobody is collecting: D14 retention (2.5%), Day-1 retention (30%), conversion rate (3%). Launching blind means no way to measure whether the strategy works. Both are free (Firebase Spark tier).

Path:

1. **Firebase Crashlytics**: add `firebase_crashlytics` SDK, wire `FlutterError.onError` and `PlatformDispatcher.instance.onError`. Verify crashes appear in Firebase Console. Add custom keys (user tier, plant count) for segmentation.
2. **Firebase Analytics**: add `firebase_analytics` SDK, log key events: `app_open`, `first_plant_added` (activation), `plant_identified` (PlantNet usage), `pro_upgrade` (conversion), `session_duration`. These map directly to the research's funnel metrics.
3. **Retention measurement**: Firebase Analytics automatically tracks D1, D7, D30 retention. Verify the dashboard shows data after a test day.
4. **Cost**: both are free on Firebase Spark (50K analytics events/day, unlimited Crashlytics). At1M users, analytics events may exceed 50K/day — ticket 18 covers quota.

## Checklist

- [x] Crashlytics SDK added + wired in main.dart (FlutterError + PlatformDispatcher)
- [ ] Crashes visible in Firebase Console (requires deploy + real crash)
- [x] Analytics SDK added + key events logged via analytics_service.dart
- [ ] Retention metrics visible in Firebase dashboard (requires deploy + time)
- [ ] Custom Crashlytics keys set (user tier, plant count) — deferred to post-launch
- [x] `flutter analyze` clean; 186/186 tests pass
- [x] Quota implications recorded in ticket 18
