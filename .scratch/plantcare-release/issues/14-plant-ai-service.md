Type: grilling
Status: open
Blocked by: 13

## Question

Design the `PlantAiService` — the single seam through which every AI feature talks to Gemini (via Firebase AI Logic). The decision this ticket resolves:

- Provider/service shape (one service, one method per feature? or one service with a generic `generate`?).
- Prompt templates per feature: diagnosis, care chat, watering schedule, reminder text, health-log summary — grounding strategy for each (species from PlantNet result, plant profile fields, careSchedule, healthLogs subcollection, notes).
- How the LLM output is validated/parsed into app types (structured output — JSON schema? plain text with rules?).
- Model config: 2.5 Flash default; per-feature temperature/length; cost guardrails (max output tokens).
- Error/quota taxonomy that 21 maps to UI states (quota, blocked, timeout, malformed output, offline).
- Testability: the seam that lets tests mock Gemini (graduates fog "test strategy for AI-dependent code").

HITL — grill with the user (one decision at a time, recommendations required). Skills: `grilling`, `domain-modeling`, `firebase-ai-logic-basics`. Unblocks: 17, 18, 19, 20, 21.