Type: task
Status: open
Blocked by:

## Question

Establish the working baseline the rest of the map rides on.

`origin/fix/setup-and-cleanup` (2026-08-01, commits 5d7f21b + 0af8766) is 2 commits ahead of main and already:

- removes dead scaffolding (`lib/custom_inspector.dart` 788 lines, `lib/main-updated.dart`, `lib/services/test_service.dart`)
- adds `lib/firebase_options.dart` (template — placeholder values)
- wires the PlantNet key via `--dart-define=PLANTNET_API_KEY` in the camera screen
- trims unresolved deps from `pubspec.yaml`
- adds `test/plantnet_service_test.dart` (209 lines, mock adapter, no network)
- updates README with setup docs

Question: what is the baseline branch this effort works from — main folded with that remote's content, cherry-picked, or rebuilt? Work in a worktree; **do not push / do not open PRs** (PRs are handled later per the map Notes). Record the decision + the baseline branch name in the Answer, so 1-fix-the-compile and 6-test-along-the-route work on the same base.

AFK. Evidence: a clean branch with those commits applied/tests runnable (`flutter test` picks up the suite).