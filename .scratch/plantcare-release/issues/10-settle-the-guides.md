Type: grilling
Status: open
Blocked by:

## Question

The two docs deleted in the working tree — restore or commit the deletion?

`deployment_guide_macbook_air.md` (297 lines, added in d4de6c1) and `test_guide_macos_m1.md` are deleted in the working tree, deletion uncommitted. Both are still in git history — nothing is lost. They document running/testing this app on this exact machine (MacBook Air M1) and may have bearing on 5-verify-the-app-boots, 7-android-release-build and 8-ios-release-build.

Grilling — one question at a time:

- Should they be committed as deleted (tree cleaned), restored as-is, or folded/rewritten into the route's docs?
- If kept, do they belong in the repo root or under `docs/`?
- Do they contain steps/commands this effort should reuse — or stale/wrong steps to drop (e.g., PlantNet key handling before the `--dart-define` wiring)?

Resolved when the human decides and the choice is executed (delete or restore committed in a worktree). The Answer records the decision and, if kept, the canonical locations.