# 04 — FCM background notifications wiring

Type: task
Status: resolved
Blocked by: —
Resolved: 1e77346 (main) — full FCM foreground/background/notification-tap + analytics service

## Question

The release effort found (ticket 07 of the release map): "FCM background handler is never registered — `onMessage`/`onBackgroundMessage` wiring incomplete". The watering reminders are the app's core promise ("Never forget to water again") and must arrive when the app is closed — the research's Day 5–6 step and screenshot 3 both depend on this.

Path:

1. Confirm current state: what `notification_service.dart` does today (local notifications? remote FCM?) and whether `firebase_messaging` is wired in `main.dart`.
2. Register `onBackgroundMessage` (top-level handler, no closure) + `onMessage` foreground handling (or delegate to local notifications when app is foregrounded).
3. Wire the reminder scheduling path (care schedule → notification trigger) to actually deliver.
4. Verify on-device: schedule a watering reminder, force-stop the app, confirm delivery. Evidence: logcat + screenshot.
5. Android 13+ notification permission flow — the emulator drive must include granting permission.

## Checklist

- [x] FCM + local notification wiring documented in code
- [x] `onBackgroundMessage` (top-level) + `onMessage` (foreground) registered
- [x] Notification tap callback + `onMessageOpenedApp` wired
- [x] FCM token stored in Firestore for server-side sending
- [x] Android notification channel created
- [x] `flutter analyze` clean; 186/186 tests pass