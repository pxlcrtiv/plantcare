# 09 — AI content engine (1.5h/day)

Type: task
Status: open
Blocked by: —

## Question

Research's growth lever: an automated daily content pipeline across TikTok, Instagram, YouTube Shorts, Reddit, X — "1.5 hours/day, batch-produce a week in ~2 hours". This is the Phase 1–2 engine (viral → 10K then 50K+ downloads) and the research's #1 non-ASO channel.

Pipeline spec (research):

- **Scripts**: free LLM tier — "Write 15s TikTok hook + 3 tips for [plant] care — conversational, friendly, end with app CTA." Hook formula: "I almost killed my (plant)… then…". Structure: Problem → Mistake → Solution → Transformation.
- **Video**: CapCut free — AI avatars, auto-captions, stock plant footage, AI voiceover.
- **Scheduling**: Buffer free (3 channels) / Later (30 posts/month). Best times: 12pm, 7–9pm, weekends. 3–4x/day.
- **User story gold**: "An AI told me my plant was overwatered — saved it!" (the app's Gemini doctor IS this story — use real on-device evidence).
- **Launch moment**: Product Hunt (top 10 → 10K+ visits) — separate HITL-ish step, flag it.

Scope note: the agent can build everything except the human's account credentials (TikTok/IG/YT/Reddit/X/Buffer/CapCut accounts, posting itself is HITL). Deliverable: a ready-to-run content kit — script generator prompt(s), a seeded content calendar (30 posts from real plant data), caption templates, hashtag sets, posting schedule — that the human executes in ~1.5h/day.

## Checklist

- [ ] Script generator prompt pack (LLM-ready, with the hook/problem→solution formulas)
- [ ] 30-post seeded calendar with captions + hashtags (grounded in the app's real species data)
- [ ] CapCut + Buffer/Later setup guide (free tiers)
- [ ] Product Hunt launch checklist (copy, timing, "maker" post)
- [ ] Brand voice aligned to ticket 01's naming decision