Type: prototype
Status: open
Blocked by:

## Question

What does the Flask tab look like as the "Care Assistant" hub? The destination pins it as the AI home; this ticket decides the concrete UX shell:

- Hub layout: Plant Doctor entry card + Care chat entry card (and where schedule/reminder/summary actions surface, if at all).
- How the dock's Flask destination changes from the current "coming soon" placeholder.
- Contextual entry points and their routing: Home scan area, plant detail screen actions → do they land on the hub, or deep-link into doctor/chat?
- Empty/offline states of the hub.

HITL — build a cheap prototype via the `prototype` skill (stub UI, no backend calls yet) and react to it together. Skills: `prototype`, `grilling`. Unblocked (UX shell needs no backend).