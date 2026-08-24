# 04 — FCM background notifications wiring

Type: task
Status: open
Blocked by: —

## Question

The release effort found (ticket 07 of the release map): "FCM background handler is never registered — `onMessage`/`onBackgroundMessage` wiring incomplete". The watering reminders are the app's core promise ("Never forget to water again") and must arrive when the app is closed — the research's Day 5–6 step and screenshot 3 both depend on this.

Path:

1. Confirm current state: what `notification_service.dart` does today (local notifications? remote FCM?) and whether `firebase_messaging` is wired in `main.dart`.
2. Register `onBackgroundMessage` (top-level handler, no closure) + `onMessage` foreground handling (or delegate to local notifications when app is foregrounded).
3. Wire the reminder scheduling path (care schedule → notification trigger) to actually deliver.
4. Verify on-device: schedule a watering reminder, force-stop the app, confirm delivery. Evidence: logcat + screenshot.
5. Android 13+ notification permission flow — the emulator drive must include granting permission.

## Checklist

- [ ] Current FCM/notification state documented in the Answer
- [ ] `onBackgroundMessage` + `onMessage` registered
- [ ] Reminder delivery verified with app killed (evidence: logcat/screenshot)
- [ ] Permission flow verified on-device
- [ ] `flutter analyze` clean; full test suite green