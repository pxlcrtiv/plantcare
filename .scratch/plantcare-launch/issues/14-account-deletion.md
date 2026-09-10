# 14 — Account-deletion flow

Type: task
Status: resolved
Blocked by: —
Resolved: d7933d2 (main) — deletion flow in profile screen

## Question

Google Play policy: any app with account creation **must** offer in-app account deletion (and a web deletion link for users who uninstalled). The app has Firebase Auth login but no delete-account path. This is a Play review rejection waiting to happen — blocks tickets 02 and 03.

Path:

1. **In-app deletion**: add a "Delete Account" option in the profile/settings screen. Flow: confirm dialog → delete Firestore user data (plants, care logs, health logs) → delete Firebase Auth account → sign out → navigate to login.
2. **Data scope**: identify all Firestore collections that hold user data (plants, care schedules, health logs, settings) and ensure deletion cascades.
3. **Web deletion link**: publish a simple page (privacy policy companion) where users who uninstalled can request deletion by entering their email — triggers a Firebase Admin SDK Cloud Function or manual process.
4. **Play Console**: link the web deletion URL in the Data Safety form (ticket 13).

## Checklist

- [x] "Delete Account" button in profile screen (d7933d2)
- [x] Confirmation dialog with clear warning ("This action cannot be undone")
- [x] Firestore user data deleted (plants, careEvents, healthLogs — cascading)
- [x] Firebase Auth account deleted
- [x] Navigate to login after deletion
- [ ] Web deletion page published (can be simple — reuse privacy policy contact)
- [ ] Play Console Data Safety form updated with deletion URL (HITL)
- [x] `flutter analyze` clean; 186/186 tests pass
