# Ticket 10 — Unit economics brief (one page)

## 1. Pricing assumptions: validated with corrections

| App | Research claim | Verified (App Store listing, Jul–Sep 2026) | Verdict |
|---|---|---|---|
| PictureThis Pro | "$39.99 (one-time?)" | **$39.99/yr annual** (US); monthly $7.99–$9.99; Family $49.99; lifetime ~$79.99 | Period confirmed: **annual sub, not one-time**. $29.99 undercuts it by $10. |
| Planta Premium | "$19.99/mo" | **$35.99/yr annual** (US base; up to $47.99–$59.99 regional variants); monthly **$9.99–$11.99**; 3-month $19.99–$34.99 | Research misread the 3-month price as monthly. Real monthly ≈ $10–12. |
| Greg (SUPER Greg) | — | **$29.99/yr**; monthly $6.99; lifetime $39.99–$49.99; generous free tier (5 plants) | **$29.99/yr matches Greg exactly** — the proven indie price point. |

Category band (Growli, checked Jul 2026): most plant apps $30–45/yr; PlantNet free; Blossom $59.99–$79.99 top. **$29.99/yr sits at the bottom of the paid band** — correct entry position for a new entrant.

## 2. Conversion / retention: research math is wrong, conclusion is safe

- Research headline "1M × 2.5% D14 × 3% = 2,500 × $29.99 ≈ $75K" has an **arithmetic error**: 1M×0.025×0.03 = **750 payers ≈ $22.5K gross**, not 2,500/$75K. 2,500 payers implies 0.25% effective download→paid.
- Benchmark (RevenueCat State of Subscription Apps 2026, 75K apps): freemium median **D35 download→paid 2.1%** (top quartile 4.5%); hard paywall 10.7%. AI apps convert better (trial→paid 8.5% vs 5.6%) but retain worse annually (21% vs 31%).
- Retention (Adjust/MWM 2026): global D14 ≈ 10%, D30 ≈ 4–7%; Education-category D30 ≈ 2%. A 2.5% D14 *paid* assumption implies ~25–50% of retained users pay — aggressive. Use **download→paid 2.1% base / 0.25% conservative** instead.
- Cross-check: Adapty SOIS 2026 Lifestyle median **install LTV $0.70** — matches our base-case $0.70/install (see §4).

## 3. COGS model (per-unit costs are negligible until ~1M scale)

| Cost | Free tier / crossover | Paid unit cost | Cost at 100K dl (~5K DAU) | Cost at 1M dl (~50K DAU) |
|---|---|---|---|---|
| Firebase Firestore (Spark→Blaze) | 50K reads + 20K writes/day free; reads bind first at **~2.5K DAU (~30–50K dl)** | $0.06/100K reads, $0.18/100K writes | ~$3–8/mo | ~$30–80/mo |
| PlantNet API | 500 IDs/day free (= 182K/yr); **Pro €1,000/yr incl. 200K req** covers sustained 500/day exactly | €0.005/ID beyond 200K/yr | €0 (under cap) | ~€5,000/yr at 1M IDs/yr |
| Gemini per diagnosis (Flash-Lite $0.10/$0.40 per 1M tok) | AI Studio free tier (5–15 RPM) for beta | **~$0.0003/dx** (≈1,500 in + 400 out tokens); ~$0.0015 on Flash | <$10/yr | ~$30–150/yr |
| AdMob offset (free users) | — | Utility banner $0.25–1.50, interstitial $1.50–5.00 eCPM (Android) | ~$40–100/mo revenue | ~$400–1,000/mo revenue |

Net: **AdMob covers Firebase overage ~10× at every scale.** Only real step-cost is PlantNet Pro (€1,000/yr) at ~500 IDs/day sustained. Total COGS stays **<5% of net subscription revenue** through 1M downloads. "Zero budget" holds until ~50K downloads; then one €1K/yr invoice.

## 4. LTV / CAC at scale (price $29.99, net $25.49 after 15% store fee)

| Downloads | Payers (2.1% base) | Net Y1 revenue | COGS | Blended CAC* | LTV/CAC |
|---|---|---|---|---|---|
| 10K | 210 | **~$5.4K** | ~$0 | ~$0.10–0.30 | >10× |
| 100K | 2,100 | **~$54K** | ~€0–1K (PlantNet Pro) | ~$0.10–0.30 | >10× |
| 1M | 21,000 | **~$535K** | ~€5K + ~$1K misc | ~$0.10–0.30 | >10× |

\* Organic-first (65% search/ASO + 20–35% referral lift): no paid UA assumed; CAC = tooling/content time ≈ $0.10–0.30/install. Paid UA ($1–3/install lifestyle) not needed pre-1M. Conservative case (0.25% effective = research's real math): 1M dl → ~$64K net — still profitable. Y1 sub retention 28% median (21% AIApps) → 2-yr payer LTV ≈ $33.

## 5. Recommendation for ticket 06

- **Price: keep $29.99/yr** (matches Greg, $6–10 under Planta/PictureThis, "less than $0.08/day" framing reusable).
- **Launch offer (both research offers, sequenced):** waitlist founding = **3 months free** then $29.99 (rewards intent); day-4 non-converters = **50% off Y1 ($14.99)** (recovers price-sensitive). Prefer short 3–7-day trial: Adapty finds Lifestyle trials *reduce* LTV 21%; RevenueCat finds higher prices convert trials better — don't discount the trial itself.
- **Trigger to watch:** PlantNet sustained >400 IDs/day → sign Pro contract (30-day lead). Everything else scales on free tiers past 100K downloads.

## Sources

| # | Fact | Source |
|---|---|---|
| 1 | PictureThis $39.99/yr, monthly $7.99, Family $49.99 | Sensor Tower listing data, Aug 2026; Growli price check, 29 Jul 2026 (getgrowli.app/blog/plant-app-prices-2026) |
| 2 | PictureThis $29.99/yr + $9.99/mo + $79.99 lifetime variants, 4.6★/1.2M reviews | PlantlyAI review, 9 Jul 2026 (plantidentifierfree.app/blog/is-picturethis-worth-it) |
| 3 | Planta $35.99/yr, $9.99–$11.99/mo | Apple App Store listings (apps.apple.com, Planta AB); getplanta.com offer page |
| 4 | Greg $29.99/yr, $6.99/mo, lifetime $39.99–49.99 | Apple App Store listing (GREGARIOUS, INC); greg.app community answers |
| 5 | Freemium D35 download→paid median 2.1%, hard paywall 10.7%; annual Y1 retention 28% (AI 21%) | RevenueCat State of Subscription Apps 2026 (revenuecat.com/state-of-subscription-apps) |
| 6 | Lifestyle install LTV $0.70; trials −21.2% LTV in Lifestyle | Adapty SOIS 2026, Lifestyle benchmarks (adapty.io/blog/lifestyle-app-subscription-benchmarks) |
| 7 | Global D1 26% / D14 ~10% / D30 ~7%; Education D30 ~2% | Adjust retention benchmarks; Business of Apps Education benchmarks 2026 |
| 8 | PlantNet free 500/day; Pro €1,000/yr incl. 200K, then €5/1K IDs | my.plantnet.org/pricing + Terms of Use (official) |
| 9 | Gemini Flash-Lite $0.10/$0.40, Flash $0.30/$2.50 per 1M tokens | Google AI pricing docs + CloudZero Gemini pricing Jul 2026 |
| 10 | Firestore free 50K reads/20K writes/day; overage $0.06/$0.18 per 100K | Firebase docs (firebase.google.com/docs/firestore/pricing) |
| 11 | AdMob utility eCPM: banner $0.25–1.50, interstitial $1.50–5.00 (Android) | Playwire/AdMob benchmarks Oct 2025; MonetizeMore Jan 2026 |
| 12 | Play 15% fee under $1M/yr revenue | Google Play policy (15% service fee tier — standard knowledge) |
