Type: grilling
Status: open
Blocked by: 13, 14

## Question

Design the Plant Doctor feature — photo → Gemini diagnosis → treatment advice:

- Entry: which camera/photo flow feeds it (reuse the Target tab camera? gallery? both?), and whether it sits alongside PlantNet identification (identify first, then diagnose? or diagnose-only mode?).
- Grounding: what context goes to Gemini — the photo + species (from PlantNet) + plant profile (humidity/light/location/careSchedule)?
- Result UI: diagnosis, severity, treatment steps, suggested care adjustments; where results are stored (care log entry? Firestore doc?) and how suggested changes apply (auto vs confirm).
- Cost guardrails: image size/compression before upload.

HITL — grill with the user; prototype the result card if fidelity demands it. Skills: `grilling`, `prototype`, `firebase-ai-logic-basics`, `tdd`. Blocked by 13 (provisioning) and 14 (service design).