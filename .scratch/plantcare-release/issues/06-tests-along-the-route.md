Type: task
Status: open
Blocked by: 01, 02

## Question

Build the test suite that rides the route — how much coverage does this effort carry?

The cleanup baseline ships `test/plantnet_service_test.dart` (mock adapter, no network). The route decision: **tests are part of this effort**. Decide and implement the suite for this release effort:

1. Services with pure/network logic: `plantnet_service` (exists), `plant_care_service`, `sync_service` (careful — connectivity_plus needs mocking), `notification_service` (injectable?), repository layer (`plant_repository_impl`)
2. Widget/presentation smoke tests for the critical path screens: splash, login, dashboard, plant detail — enough to catch "screen can't build"
3. Any test that 1-fix-the-compile forced to change

AFK. Ground rule: no network, no Firebase emulator dependency in unit tests — fixtures/mocks like the existing PlantNet suite. Evidence: `flutter test` green + a one-line inventory of what's covered per file. If deep coverage of a service needs an interface change that risks scope creep, note it in the Answer rather than silently refactoring.