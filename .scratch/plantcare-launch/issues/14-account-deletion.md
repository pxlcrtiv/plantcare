# 14 — Account-deletion flow

Type: task
Status: open
Blocked by: —

## Question

Google Play policy: any app with account creation **must** offer in-app account deletion (and a web deletion link for users who uninstalled). The app has Firebase Auth login but no delete-account path. This is a Play review rejection waiting to happen — blocks tickets 02 and 03.

Path:

1. **In-app deletion**: add a "Delete Account" option in the profile/settings screen. Flow: confirm dialog → delete Firestore user data (plants, care logs, health logs) → delete Firebase Auth account → sign out → navigate to login.
2. **Data scope**: identify all Firestore collections that hold user data (plants, care schedules, health logs, settings) and ensure deletion cascades.
3. **Web deletion link**: publish a simple page (privacy policy companion) where users who uninstalled can request deletion by entering their email — triggers a Firebase Admin SDK Cloud Function or manual process.
4. **Play Console**: link the web deletion URL in the Data Safety form (ticket 13).

## Checklist

- [ ] "Delete Account" button in profile/settings
- [ ] Confirmation dialog with clear warning
- [ ] Firestore user data deleted (all collections)
- [ ] Firebase Auth account deleted
- [ ] Sign-out + navigate to login after deletion
- [ ] Web deletion page published (can be simple)
- [ ] Play Console Data Safety form updated with deletion URL
- [ ] `flutter analyze` clean; tests for deletion flow
