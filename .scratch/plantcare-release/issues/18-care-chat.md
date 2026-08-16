Type: grilling
Status: open
Blocked by: 13, 14

## Question

Design the care chat feature — a conversation with the assistant about the user's plants:

- Surface: chat UI (hub entry + "ask about my plant" from a plant's detail screen?).
- Conversation storage: Firestore shape (per-plant threads? one global thread? per-user collection?), how much history is sent as context, and deletion policy (graduates fog "chat history retention").
- Grounding: plant data + care guides in the prompt; can the user attach a photo to a chat message (multimodal)?
- Streaming vs single-response UX; suggested-question chips.

HITL — grill with the user. Skills: `grilling`, `domain-modeling`, `firebase-ai-logic-basics`, `tdd`. Blocked by 13 and 14.