# 02 — Play Listing Copy Draft

Status: draft for review (Ticket 02)
Date: 2026-09-11
Sources: `02-google-play-listing.md`, `01-naming-decision.md`
Brand: **PlantCare** — package `com.plantcare.app`, Seed of Life icon
Collision note: Play has no exact match; nearest are "PlantCare+: AI Plant Assistant" (Pakdata) and "PlantCare Hub". Our full title + icon + screenshots differentiate. Do not use "Plus" or "Hub" anywhere in copy.

## Title (Play limit ≤30 chars)

Proposed in 01 (`PlantCare — Plant Identifier & Care`) = **35 chars — OVER limit**, cannot ship as-is.

Primary (compliant, 28 chars):
> PlantCare - Plant Identifier

Char counts verified (`python3 -c len()`):
- `PlantCare — Plant Identifier & Care` = 35 — REJECT (over)
- `PlantCare - Plant Identifier` = 28 — SHIP (keeps "PlantCare" + top keyword "plant identifier")

## Short description (Play limit ≤80 chars, 67 chars)

> Snap a photo to identify plants, spot disease & get care reminders.

67 chars — compliant.

## Long description (Play limit ≤4000 chars, ~1850 chars)

> Meet PlantCare — the friendly plant identifier and plant care helper in your pocket.
>
> Snap a photo to identify plant friends in seconds. PlantCare's fast plant recognition handles houseplants, garden plants, succulents, and weeds, then gives you simple care steps in plain English. No jargon, no guessing.
>
> Got a struggling plant? Think of PlantCare as your pocket plant doctor. Snap a leaf to check for plant disease, yellow leaves, brown spots, pests, and watering problems — then get a clear fix-it plan: what it is, what to do today, and how to stop it coming back.
>
> Never forget to water again. Smart plant watering reminders adapt to each plant and the season, with a simple calendar so all your houseplant care stays on track. Perfect as a daily garden app for balconies, backyards, and living-room jungles alike.
>
> HOW IT WORKS
> 1. Snap or upload a photo
> 2. Get the name + care card instantly
> 3. Set reminders and watch it thrive
>
> BUILT FOR ANDROID
> Fast, lightweight, works with your camera and gallery. Free to download with core ID and reminders included. PlantCare Pro ($29.99/yr) unlocks unlimited IDs, full diagnosis history, and priority support.
>
> Founding offer: early Android users get 3 months of Pro free. No card needed to try.
>
> Download PlantCare today — identify, heal, and grow.

Keyword coverage (all 9 required phrases present): plant identifier, plant care, identify plant, plant doctor, plant disease, garden app, houseplant care, plant watering, plant recognition.

## Screenshot shot list (3, vibrant greens, captioned)

1. ID demo — camera → results
   - Visual: phone camera pointed at monstera, arrow to result card showing name + confidence + care buttons.
   - Caption: "Identify any plant instantly with AI"
   - Alt text: PlantCare identifying a monstera from a photo
2. Diagnosis — problem solved
   - Visual: yellow-spotted leaf photo beside diagnosis card ("Likely overwatering") + 3-step fix list.
   - Caption: "Plant struggling? AI diagnosis + fix"
   - Alt text: PlantCare plant doctor diagnosing leaf disease
3. Reminders — care calendar
   - Visual: calendar view with watering drops on Mon/Thu, "Water Snake Plant" notification card.
   - Caption: "Never forget to water again"
   - Alt text: PlantCare watering reminders calendar

Post-100-downloads: A/B test 2–3 sets (order swap 1↔2, caption-only variant).

## A/B title variants (both ≤30 chars, keep "PlantCare")

- Variant A (27 chars): `PlantCare - Identify Plants`
  Angle: action verb, tests "identify" vs "identifier".
- Variant B (26 chars): `PlantCare: Identify & Care`
  Angle: benefit pair, tests "& Care" pull-through.

Control stays `PlantCare - Plant Identifier` (28 chars).

## Next steps

- [ ] Human approves title + short + long
- [ ] Produce 3 screenshots per shot list above
- [ ] Paste as-submitted copy back into `02-google-play-listing.md` checklist on upload
- [ ] Upload release APK (`com.plantcare.app`) to internal testing track first
