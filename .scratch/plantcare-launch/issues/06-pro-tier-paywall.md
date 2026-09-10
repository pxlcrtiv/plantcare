# 06 — Pro tier & paywall ($29.99/yr)

Type: task
Status: open
Blocked by: —

## Question

Build the Free vs Pro split from the research's monetization playbook — the app currently has no paid tier at all.

Spec (research table):

| | Free | Pro ($29.99/yr) |
|---|---|---|
| Plant ID | 5 identifications/day | Unlimited |
| Care plans | Basic watering schedule (3 plants) | Unlimited plants |
| Community | Community access | AI conversational diagnoses |
| Analytics | — | Advanced analytics |
| Offline | — | Offline mode, fast alerts |
| Ads | Non-intrusive ads (ticket 07) | No ads |

Conversion triggers (research):
1. After successful ID → success screen → "Get a detailed care plan for this plant → Go Pro"
2. Sick plant (high emotion) → basic diagnosis free, Pro gets "Advanced AI diagnosis + recovery plan"
3. Adding the 6th plant → "Your garden is growing! Upgrade to Pro to add unlimited plants"
4. Day-4 active users → 50% off first year offer

Revenue math baseline: 1M × 2.5% D14 × 3% conversion = 2,500 × $29.99 ≈ $75K/yr.

Decisions needed before/within:
- **Billing SDK**: RevenueCat vs Google Play Billing directly (nothing in the repo today; free-tier-first suggests RevenueCat's free plan, but decide).
- **"5 identifications/day"** counting: PlantNet API calls (tie to ticket 05's cap strategy) or identification results shown?
- **Entitlements enforcement**: server-side (Firestore flag + rules) vs client-side only. Rules audit (12) touches this.
- **Subscription vs one-time**: research says $29.99/yr subscription.

## Checklist

- [ ] Billing SDK decision recorded (RevenueCat vs Play Billing)
- [ ] Entitlement model + enforcement decided (server vs client; rules implications)
- [ ] Free limits enforced: 5 IDs/day, 3 plants, basic schedule only
- [ ] 4 conversion triggers implemented with UI evidence (screenshots)
- [ ] Purchase/restore flow verified on-device (test account; no real charges in dev)
- [ ] `flutter analyze` clean; full test suite green