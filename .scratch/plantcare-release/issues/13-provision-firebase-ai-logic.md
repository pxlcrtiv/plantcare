Type: task
Status: open
Blocked by:

## Question

Enable Firebase AI Logic in the `plantcareai-0` project and wire it so the app can call Gemini 2.5 Flash with Firebase's security model — no API key in the APK.

Work (AFK where possible, HITL only for console steps the agent cannot reach):
1. Enable AI Logic for the project (console or CLI) and confirm Gemini 2.5 Flash availability.
2. Install the AI Logic SDK in the Flutter app; initialize alongside the existing Firebase apps.
3. Wire App Check + Firestore-rule gating so access is per-authenticated-user (per-user quotas, deny anonymous/unauthed).
4. Prove the spine: a minimal request from the app (or a headless test) that returns a real Gemini response, with evidence.
5. Record the answer: config locations, rules snippet, quota notes, any dev-mode App Check bypass needed on the emulator (graduates fog "App Check attestation on dev emulator" if found).

Unblocks: 14 (service design), 17, 18, 19, 20, 21. Skills: `firebase-ai-logic-basics`, `firebase-basics`, `verification-before-completion`.