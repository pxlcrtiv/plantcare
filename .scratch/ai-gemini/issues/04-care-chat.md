# 04 — Care chat

**What to build:** A conversation with the assistant about the user's plants. The user starts a chat from a plant's detail screen (context set for that plant) or from the hub, asks follow-up questions in plain language, can attach a photo mid-conversation, and gets suggested-question chips to get started. Answers are grounded in the plant's profile, schedule, and health history. Chat history persists so earlier advice can be revisited; the resting state covers quota/errors.

**Blocked by:** 01 (hub); wayfinder 13, 14, 18.

**Status:** resolved

- [ ] Multi-turn chat from hub entry and from a plant's detail screen
- [ ] Chat answers grounded in the plant's data; suggested-question chips render
- [ ] Attaching a photo to a message works
- [ ] History persists and reloads (per the storage shape decided in wayfinder 18)
- [ ] Quota/error path shows the resting state with retry
- [ ] Widget tests (fake service): send/receive a message, chips, photo attach, resting state
- [ ] Service unit tests: history assembly and message parsing (mocked AI Logic client)
- [ ] `flutter analyze` clean; full test suite green