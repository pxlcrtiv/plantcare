Type: grilling
Status: open
Blocked by: 13, 14

## Question

Design the graceful degradation UX when AI calls fail — quota exhausted, blocked, timeout, offline, malformed output:

- What the user sees for each error class (from 14's taxonomy): the "AI assistant is resting, try again in a moment" card, retry semantics, where the message appears per feature (hub, doctor result, chat, schedule, summary).
- Offline behavior: can features degrade to non-AI paths (e.g. manual care schedule stays available)?
- Whether errors surface metrics (analytics) for the developer.

HITL — grill with the user. Skills: `grilling`, `prototype` (if the fallback states need visual fidelity). Blocked by 13 and 14.