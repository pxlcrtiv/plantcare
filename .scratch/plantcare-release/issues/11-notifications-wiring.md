Type: task
Status: open
Blocked by: 05

## Question

Wire up local notifications end-to-end and verify them on the Android emulator.

Graduated from 05-verify-the-app-boots (finding 8): the app declares `SCHEDULE_EXACT_ALARM` / `POST_NOTIFICATIONS` / `RECEIVE_BOOT_COMPLETED` in the manifest and schedules via `zonedSchedule(..., androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle)` (flutter_local_notifications 18.x, `notification_service.dart`), but **the user is never asked to grant exact alarms** — `requestExactAlarmsPermission()` is never called — and on API 33+ that permission defaults to denied, so reminder alarms silently fail. FCM `onBackgroundMessage` remains unregistered (fog, found in #7).

Work:
1. Request `SCHEDULE_EXACT_ALARM` (and `POST_NOTIFICATIONS` if not auto-granted) at the right moment in the add-plant/save flow, with a graceful deny path (Android 14+ also offers `USE_EXACT_ALARM`-style check — prefer `canScheduleExactAlarms()`).
2. Verify on-device: save a plant with watering/fertilizing reminders → confirm the alarm appears (`adb shell dumpsys alarm` / notification appears at the scheduled time or can be triggered for test).
3. Hook up the FCM `onBackgroundMessage` path or explicitly document why push is out of scope for release 1 (5-verify-the-app-boots note: decide whether background push is required).

Evidence required: on-device confirmation of a scheduled notification or a precise blocker note.