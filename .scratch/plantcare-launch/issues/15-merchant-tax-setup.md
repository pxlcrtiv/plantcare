# 15 — Merchant/tax setup for subscriptions

Type: task
Status: open
Blocked by: —

## Question

Ticket 06 assumes $29.99/yr "just works" via Play Billing. But Play Console requires **bank account + tax info** (W-8BEN for non-US, VAT/MOSS for EU) before you can sell anything. This is HITL, takes days to verify, and must start before ticket 06 can complete. Missing this blocks monetization entirely.

Path:

1. **Play Console merchant setup**: complete the Payments profile — bank account, tax identification (W-8BEN or W-9), business address. Google verifies before enabling paid apps/subscriptions.
2. **Tax decision**: decide whether to collect VAT/MOSS for EU sales (Google handles this via Play Billing if you opt in to "Google as merchant of record" — simplest path for solo devs).
3. **Subscription product**: create the `$29.99/yr` subscription product in Play Console (Product ID: `pro_yearly`). This can be done before merchant verification completes — it just can't go live until verified.
4. **Timeline**: merchant verification takes 1-3 business days. Start this ticket early to avoid blocking 06.

## Checklist

- [ ] Play Console Payments profile completed (bank + tax)
- [ ] Tax classification selected (W-8BEN or W-9)
- [ ] VAT/MOSS decision recorded (Google as merchant of record recommended)
- [ ] Subscription product `pro_yearly` created in Play Console
- [ ] Merchant verification status confirmed (may take days)
- [ ] Decision recorded for ticket 06
