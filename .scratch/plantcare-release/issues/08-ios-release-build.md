Type: task
Status: open
Blocked by: 05

## Question

Produce a TestFlight-ready iOS build — what does Xcode signing look like for this app?

The iOS release path: bundle id (recorded in 3-firebase-project) → Xcode project signing (team, provisioning via automatic signing) → `flutter build ipa --release` → `xcrun altool`/Transporter upload to TestFlight. The human must hold/supply the Apple Developer team and any credentials; the agent drives Xcode config and builds.

HITL for credentials/decisions (Apple Developer team id, whether the app is in App Store Connect yet); AFK for mechanical work. Steps:

1. Confirm bundle id + set signing team in `ios/Runner.xcodeproj`
2. Fix any iOS-side issues surfaced by 5-verify-the-app-boots (camera permissions plist entries already present — verify)
3. `flutter build ipa --release` succeeds (or `flutter build ios --release --no-codesign` if signing material isn't ready — record which)
4. Upload to TestFlight if the human wants it (else record the command for them)

Resolved when the IPA builds and its destined owner (human) has the upload command / it is uploaded. Record team id, bundle id, artifact path.