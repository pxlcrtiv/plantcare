Type: grilling
Status: open
Blocked by: 13, 14

## Question

Design health-log summaries — a "Summarize" action on the detail screen's Health tab:

- What it summarizes: the `healthLogs` subcollection + notes for a plant (time window? all history?).
- Output UI: inline summary card vs bottom sheet; regeneration affordance; staleness (cached vs regenerated on demand).
- Cost guardrails: token budget for long histories (truncate/roll up?), and whether summaries are persisted (Firestore) or ephemeral.

HITL — grill with the user. Skills: `grilling`, `firebase-ai-logic-basics`, `tdd`. Blocked by 13 and 14.