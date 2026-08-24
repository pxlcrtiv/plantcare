# 10 — Unit economics validation

Type: task
Status: open
Blocked by: —

## Question

The research's revenue math is a single headline: 1M downloads × 2.5% D14 × 3% conversion = 2,500 × $29.99 ≈ $75K/yr. Before pricing is locked in (ticket 06), validate the underlying numbers and fill the gaps the research left open.

Path:

1. **Validate assumptions against real market data** (sources to check: the research's own footnotes — Statista 2026, Grand View Research, AppFigures — plus current App Store/Play pricing for PictureThis, Planta, Greg):
   - Is 2–5% premium conversion still the right band for subscription plant apps (vs one-time purchase apps)?
   - Is $29.99/yr competitive against Planta's $19.99/mo and PictureThis's $39.99 (one-time? the research lists it as a price, not a period)?
   - What retention (D14/D30) do plant apps realistically see? The math assumes 2.5% D14.
2. **Cost model**: COGS at scale — Firebase Spark→Blaze migration cost, PlantNet paid tier (research flags it), LLM API cost per diagnosis (the Gemini doctor runs per diagnosis), AdMob revenue offset for free users. The research says "zero budget" but that's pre-scale; model the crossover.
3. **LTV/CAC**: with referral lift (20–35%) and 65%-from-search ASO, what's the realistic blended CAC at 10K/100K/1M downloads?
4. **Pricing sensitivity**: $29.99/yr vs $19.99/yr vs $39.99/yr — recommend a number and a launch discount (research: 50% off first year for day-4 users; founding 3-months-free from the waitlist page).
5. **Output**: a one-page unit-economics brief in this ticket's Answer — feeds ticket 06's pricing decision and the launch map.

## Checklist

- [ ] Conversion/retention/pricing assumptions validated against current data (sources cited)
- [ ] COGS model: Firebase, PlantNet paid tier, LLM per-diagnosis cost, crossover point
- [ ] LTV/CAC estimates at 10K/100K/1M downloads
- [ ] Recommended price + launch offer recorded
- [ ] One-page brief attached to this ticket; feeds ticket 06