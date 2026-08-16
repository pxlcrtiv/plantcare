Type: task
Status: open
Blocked by: 17, 18, 19, 20, 21

## Question

Verify the AI layer end-to-end on the Android emulator against the real Firebase AI Logic project, and record evidence:

- Drive every feature on-device: Flask hub, Plant Doctor (real photo → real diagnosis), care chat (multi-turn), AI schedule generation + reminder text, health-log summary, and the quota/error fallback states (force an error path where possible).
- Record evidence screenshots + findings in this ticket's Answer, per `verification-before-completion`.
- Check the app still passes analyze + the full test suite after the AI work lands.

AFK (agent drives the emulator per repo convention — see prior tickets' drive sessions). Skills: `verification-before-completion`, `chrome-devtools-axi` is web-only — use adb/emulator + multimodal subagent for screenshots.