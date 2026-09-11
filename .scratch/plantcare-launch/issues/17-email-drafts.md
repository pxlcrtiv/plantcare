# 17 — Email drafts + setup guide (Waitlist → launch pipeline)

Brand: PlantCare. Store title: "PlantCare — Plant Identifier & Care".
Voice (matched to waitlist page): friendly, plain-English, no botany degree required. "Never kill another plant."
Offer: founding members get 3 months of Premium free, no card needed + early-adopter tips + founding badge.

---

## Email 1 — Welcome (send immediately on signup, via automation)

**Subject:** You're on the PlantCare waitlist 🌱 (your 3 free months are locked in)
**Preview text:** What happens next + one tip to keep your plants happy today.

Hi {{ first_name | fallback: "there" }},

You're in! You've claimed your early-access spot for PlantCare — Plant Identifier & Care.

What you locked in as a founding member:
- 3 months of PlantCare Premium free (no card needed)
- Early invite — earliest signups get in first
- Founding member badge in the app

What happens next: one short email when your invite is ready, plus the occasional plant tip. No spam, ever.

One thing you can do today: check your brightest windowsill. Most "low light" casualties are just plants sitting 2m too far from the window. Move strugglers 30–50cm closer and watch them perk up in a week.

Talk soon,
The PlantCare team 🌿

P.S. Know a fellow plant killer? Forward this — they'll thank you later.

**CTA button:** [See how PlantCare works →] (link to waitlist page #how)

---

## Email 2 — Launch announcement (send on launch day)

**Subject:** PlantCare is live — claim your 3 free months 🌿
**Preview text:** Your early-access invite is inside. Founding perks expire soon.

Hi {{ first_name | fallback: "there" }},

It's here. PlantCare — Plant Identifier & Care is live on Android, and your early-access invite is ready:

**CTA button:** [Get PlantCare + claim 3 months free →] (store link)

How to start (3 taps):
1. Add your first plant — snap a photo or search 4,000+ species.
2. Follow your first gentle nudge (water, light, feed).
3. Watch it thrive — we'll catch problems before they spread.

Your founding perks (already attached to your invite, no card needed):
3 months Premium free · founding member badge · grandfathered pricing.

One ask: hit **reply** and tell us — what plant are you adding first, and what's killing it? We read every reply and it shapes what we build next.

Happy growing,
The PlantCare team 🌿

P.S. Founding invites go out in waves — if your friend is still waiting, send them here: [waitlist link].

**Reply-with-feedback CTA (explicit):** Just reply to this email — "My monstera has yellow leaves, help!" is a perfect reply.

---

## Email 3 — Nurture #1: plant care tip (send ~5–7 days after welcome, or 3–4 days post-launch for non-converters)

**Subject:** The #1 reason houseplants die (it's not what you think) 💧
**Preview text:** A 30-second finger test beats any watering schedule.

Hi {{ first_name | fallback: "there" }},

Most houseplants don't die of thirst. They die of overwatering — usually from a rigid "water every week" schedule.

Try the finger test instead:
1. Stick your finger ~2cm into the soil.
2. Dry? Water deeply until it drains out the bottom.
3. Damp? Wait 2 days and check again.

That's it. In PlantCare this is automatic — we nudge you only when your plant's soil, season, and species actually call for water, not on a generic timer.

**CTA button:** [Set up my watering reminders →] (store link)

One more: yellow, mushy lower leaves = too much water. Crispy brown edges = too little (or too much sun). Your plant is already telling you — you just need the translation.

Grow on,
The PlantCare team 🌿

---

## Email 4 — Nurture #2: behind-the-scenes (send ~2 weeks after nurture #1)

**Subject:** Why we built PlantCare (our own body count 🌿)
**Preview text:** 14 dead plants, one spreadsheet, and the app we wish we'd had.

Hi {{ first_name | fallback: "there" }},

Confession: between us we've killed 14 houseplants. A fiddle-leaf fig (overwatered). Three succulents (too little light, then too much love). A fern we still don't talk about.

PlantCare started as a spreadsheet: each plant, its light, its last watering, a photo when leaves looked weird. It worked — but it was tedious. So we built the app we wish we'd had:

- Know each plant by name (photo or 4,000+ species search)
- Timely nudges that make sense (soil + season, not "water weekly")
- Plain-English fixes ("yellow leaves? here's the 2-minute check")

We're a small team polishing the first public build now. Every reply from waitlist members shapes the roadmap — keep them coming.

**CTA button:** [Join us at launch →] (waitlist or store link, depending on timing)

Thanks for being a founding grower,
The PlantCare team 🌿

P.S. What's your hardest plant right now? Reply and tell us — we answer, and the most common answers become our next in-app guides.

---

## Setup guide — ConvertKit (Kit) / Mailchimp free tier

Recommendation: **ConvertKit (now "Kit")** free tier — up to 10,000 subscribers, visual automation for the welcome email, embeddable forms. Fallback: **Mailchimp** free (500 contacts) or **Buttondown** free — fine for a small waitlist but you'll outgrow Mailchimp free fast.

### 1. Create account + list
1. Sign up at kit.com (or mailchimp.com). Confirm sender email (use your real domain email, e.g. hello@plantcare.app — not the GitHub noreply).
2. Create a Form (Kit: Grow → Landing Pages & Forms → Form → Inline) named "PlantCare waitlist". Fields: Name, Email (+ optional "plants" custom field).
3. Kit: tag all subscribers from this form `waitlist`. Mailchimp: create Audience "PlantCare waitlist".
4. Turn on double opt-in (Kit: Settings → default ON; keep it — better deliverability). Customize confirm subject: "One click to lock in your 3 free months 🌱".

### 2. Export + import existing Formsubmit signups
1. Formsubmit currently emails each signup to the inbox in the form `action` — there is no dashboard. Search that inbox for subject "🌿 New PlantCare waitlist signup", collect name/email/plants into a CSV (`email,name,plants`).
2. Kit: Subscribers → Add subscribers → Import CSV → tag `waitlist-import`. Mailchimp: Audience → Add contacts → Import.
3. Send imported contacts a short re-permission note (use Welcome email above, first line changed to "We're moving the waitlist to a proper list — you're still locked in for 3 free months").

### 3. Welcome automation
1. Kit: Automate → New automation → "Join a form" trigger (waitlist form) → Email step → paste Email 1 above. Delay: immediately.
2. Mailchimp: Automations → Welcome new subscribers → single email → paste Email 1.
3. Test with your own address before enabling.

### 4. Launch email
1. Draft Email 2 as a Broadcast (Kit: Broadcasts) / Campaign (Mailchimp) now; schedule for launch day morning (~10am audience-local).
2. Personalize `{{ first_name }}`, test reply-to goes to a monitored inbox (replies are the feedback channel).

### 5. Swap Formsubmit for the embeddable form
1. Kit: Form → Embed → copy JS snippet or raw HTML. Replace the entire `<form action="https://formsubmit.co/...">...</form>` block in `platcare-waitlist/index.html` `#waitlist .form-card` with the Kit embed, keeping the surrounding card + privacy line ("No spam. One launch email + your perks. Unsubscribe anytime.").
2. Keep the "plants" field if the provider supports custom fields (Kit does); otherwise drop to name+email to reduce friction.
3. Keep `_next`-style redirect: Kit form settings → "Show success message" ("You're in! Check your inbox to confirm 🌱") or redirect to `https://plantcare.app/?joined=1`.
4. Test an end-to-end signup → confirm → welcome email. Delete/deactivate the Formsubmit address after.

---

## Recommended nurture cadence

- **Welcome:** immediately (automation).
- **Pre-launch:** max 1 email/month (tip or behind-the-scenes alternate) — the only promise on the page is "one launch email + perks."
- **Launch week:** launch announcement (day 0) + one reminder to non-openers (day +4).
- **Post-launch:** monthly "early-adopter plant tips" (this is a promised perk — keep it) + app updates only when there's real news. Never more than 2/month.
- **Hygiene:** one-click unsubscribe in every email; prune hard bounces; don't add anyone who didn't opt in.
