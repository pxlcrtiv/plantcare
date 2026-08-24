# 12 — Firestore rules audit

Type: task
Status: open
Blocked by: —

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

- [ ] Auditor run against current rules (report attached)
- [ ] Rules scoped: own-docs-only, write validation, photo bytes covered
- [ ] Entitlement rule shape defined for ticket 06
- [ ] Deployed + on-device regression of core flows (evidence)
- [ ] Blocks ticket 03 (closed beta) until resolved