Type: grilling
Status: open
Blocked by: 13, 14

## Question

Design AI-generated watering schedules and smart reminder text:

- Where generation lives: the add-plant wizard's care-setup step (prefill an AI schedule) and/or the detail screen's care-reminders sheet (regenerate).
- Application model: auto-apply vs suggest-then-confirm — and the deeper question (graduates later): may the LLM ever mutate the plant doc directly?
- How the LLM output maps onto `careSchedule` (wateringFrequency etc.) and `reminderTime` fields without clobbering sibling keys.
- Reminder text: what the notification says, generated from plant state (e.g. "Smoke Fern is thirsty — 6 days overdue").
- Grounding: species + environment (humidity/light/location) + recent health logs.

HITL — grill with the user. Skills: `grilling`, `firebase-ai-logic-basics`, `tdd`. Blocked by 13 and 14.