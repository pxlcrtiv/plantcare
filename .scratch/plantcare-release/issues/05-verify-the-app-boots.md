Type: task
Status: open
Blocked by: 01, 02, 03, 04

## Question

First verified boot: is the app runnable end-to-end on a simulator, and what breaks?

Run the app on iOS simulator and Android emulator (both available on this M1 Mac; if no Android AVD exists, note it — may graduate a setup ticket). Smoke the whole flow: splash → onboarding → sign-up/login (Firebase) → add plant (manual entry *and* PlantNet camera path — camera plugin may not work on simulator; record what actually works) → dashboard persistence → plant detail → notifications setup.

AFK where possible. This is the frontier's curiosity ticket — expected to surface runtime blockers that graduate into new tickets. Record a numbered list of "works / broken" per flow per platform, with evidence (screenshots, logs, console). Nothing resolves here but the question "does it run?" — every issue found feeds the Not-yet-specified fog and may become its own ticket.

HITL note: if your environment can't reach something only the human can provide (device, account), hand back a precise checklist and record the blocker.