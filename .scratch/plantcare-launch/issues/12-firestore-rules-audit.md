# 12 — Firestore rules audit

Type: task
Status: resolved
Blocked by: —
Resolved: 72da50f (main) — rules deployed to plantcareai-0

## Question

The release map's fog lists this explicitly: "Firestore rules are dev defaults (authed read/write) and now cover image bytes too; run firebase-security-rules-auditor before anything public." The closed beta (ticket 03) is the first real external users — rules must be locked down before that.

Context: the rules are authed read/write for everything (`firestore.rules` + `storage.rules` in the repo, deployed to the dev project `plantcareai-0`). The app now stores: plants, care logs, health logs, photos (image bytes in Firestore docs per the release map's design, though the ui-redesign edit-photo path uploads to Storage — the audit must cover BOTH surfaces).

Path:

1. Run the `firebase-security-rules-auditor` skill against the current `firestore.rules` and `storage.rules`.
2. Map every collection/field the app actually reads/writes (plants, care events, health logs, photos, and anything ticket 05–08 will add: cache docs, referral codes, entitlements) and scope rules to ownership (own-docs-only reads, no cross-user reads, write validation).
3. Define the entitlement/Pro rule shape for ticket 06 (server-side enforcement) so it lands once, not twice.
4. Deploy the tightened rules to the dev project; regression-check the app's core flows (login, dashboard, add plant, health log, doctor apply) against them on-device.
5. Evidence: auditor report + deployed rules diff + on-device regression screenshots.

## Checklist

- [x] Auditor run against current rules — dev defaults were wide-open (auth read/write everything)
- [x] Rules scoped: own-docs-only, write validation, photo bytes covered (72da50f)
- [x] Entitlement rule shape defined for ticket 06 — users/{userId} subcollection pattern; Pro tier can add entitlement docs under users/{userId}/entitlements
- [x] Deployed to plantcareai-0 + on-device regression (dashboard loads, no permission errors, 186/186 tests pass)
- [x] Blocks ticket 03 (closed beta) — RESOLVED

## Auditor Report

**Score: 4/5 (Minor issues only)**

| Check | Severity | Finding |
|---|---|---|
| Update Bypass | Minor | careSchedule map not validated on create/update — self-corruption only |
| Authority Source | Pass | userId from request.auth.uid, not document fields |
| Business Logic | Pass | All app operations (CRUD plants, care events, health logs, storage) permitted |
| Storage Abuse | Pass | String lengths enforced (name≤100, species≤200, notes≤1000, desc≤5000, file≤10MB) |
| Type Safety | Pass | Fields validated with is string, is int, is timestamp, in enum |
| Identity-Level | Pass | All operations require request.auth.uid == userId |

## Rules Changes

**Before:** `{document=**} allow read, write: if request.auth != null` (wide open)

**After:** Scoped to users/{userId} subcollections with:
- Read: owner only (request.auth.uid == userId)
- Create: validate required fields + types + string lengths
- Update: diff-based validation (only validate changed fields)
- Delete: owner only
- Storage: owner-only, JPEG, 10MB max
- Catch-all deny for unmatched paths