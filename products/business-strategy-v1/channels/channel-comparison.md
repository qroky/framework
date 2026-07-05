# RPF Channel Comparison + Recommendation

**Atom:** ATOM-010 · **Role:** venture-strategist · **Date:** 2026-07-05 · **Maturity:** draft
**Inputs:** ATOM-006 INPUT §3.6/§3.9; `segments/segment-map.md` (G1-confirmed sequence A→C→B); `pricing/pricing-ladder.md` (founder-month economics); `decisions/INFO-001-pilot-terms-startup-moldova.md` (pilot exchange terms).

Shared economics used below (source: `pricing/pricing-ladder.md`): token COGS ~$15–32/founder-month; Flow Support anchor $150/founder-month (assumption, pilot-tested); binding capacity constraint is human owner-review attention, 8–15 h/founder-month (assumption) — one operator sustains roughly **6–10 concurrent Flow Support founders** at 2–3 attention-hours/day (assumption; ATOM-013 measures).

---

## Option (a) — Accelerator B2B2C (cohort license + graduate discount)

Program licenses Flow Support for its cohort; equity with founders frozen (accepted §3.6a); possible success-fee with the program itself. First conversation open — Startup Moldova (source: §3.6a; terms per `decisions/INFO-001-pilot-terms-startup-moldova.md`).

| Row | Value |
| :---- | :---- |
| Acquisition | ≈ $0 cash — warm single relationship; the pilot itself is the acquisition event (source: INFO-001: paid in kind — case study + 2–3 bank/fund intros) |
| Capacity | one cohort ≈ 6–10 founders — exactly one operator's attention budget (source: shared economics above); second cohort requires a second operator or heavier sentinel automation |
| Revenue basis | **B2B2C rescue priced:** cohort license **$1,000–1,500/cohort-month for ~10 founders** = $100–150/founder-month, program pays (assumption — consistent with the ladder anchor; this is the rescue the segment map flagged if founder WTP fails). Graduate discount: 50% of Rung-2 for 3 months post-demo-day (assumption) |
| Margin | $100–150/founder-mo − $15–32 tokens ≈ **$68–135/founder-mo (~70–90%) before operator hours** (source: `pricing/pricing-ladder.md`); hours are opportunity cost of the founder-operator at pilot stage, cash cost after first hire |

## Option (b) — Bank as GTM partner (after pilot proof)

Paid pilot only; co-branding mandatory; exclusivity short and expensive if at all; the risk-acceptance journal is the liability answer for bank compliance (accepted §3.6b verbatim). Segment C scored highest raw attractiveness but the channel is gated on pilot proof (source: `segments/segment-map.md`, gate accepted §3.6b).

| Row | Value |
| :---- | :---- |
| Acquisition | 2–3 warm bank/fund intros delivered by the accelerator pilot (source: INFO-001) — channel (a) is the acquisition mechanism for channel (b); cycle 6–12 months (assumption) |
| Capacity | 1–2 concurrent bank engagements max at current team size (assumption — regulated-client overhead per `pricing/pricing-ladder.md` Rung 3) |
| Revenue basis | Managed-rung pricing, 3–5× Flow Support anchor per portfolio (source: `pricing/pricing-ladder.md` Rung 3, assumption); pilot ticket itself is **conversation-gated — not computable from repo data, no number invented** (§3.9); paid-pilot floor: never free (accepted §3.6b) |
| Margin | structurally highest of the three (managed-rung price over the same token COGS), but realized only after pilot proof; compliance overhead reduces it by an unmeasured factor (assumption; first bank conversation prices it) |

## Option (c) — Self-serve on open core

Brand/funnel, slow (accepted §3.6c verbatim). Segment B background funnel (source: `segments/segment-map.md`).

| Row | Value |
| :---- | :---- |
| Acquisition | content/repo visibility; $0 paid; conversion low and slow (source: §3.6c "slow"; no rate invented — §3.9) |
| Capacity | unbounded — $0 our-side COGS, clients run own keys (source: `pricing/pricing-ladder.md` Rung 1) |
| Revenue basis | $0 direct; feeds Rung-2 upgrades and credibility for (a)/(b) |
| Margin | n/a — funnel, not a revenue channel this year |

---

## Recommendation

**Accelerator → paid bank pilot → second bank as leverage** — the accepted §3.6 sequence hypothesis, now confirmed by the unit economics rather than assumed: (a) is the only option whose acquisition cost is ~$0 today and whose capacity exactly matches one operator; its INFO-001 terms convert it into (b)'s acquisition mechanism (bank intros) while the case study de-risks (b)'s compliance ask via the risk-acceptance journal; (b) carries the margin ceiling but is unreachable without (a)'s proof; (c) runs passively underneath at zero marginal cost. The B2B2C cohort license is the priced rescue if founder-level WTP fails at pilot exit — same channel, payer flips from founder to program.

**Kill trigger:** if the pilot cannot hold 6+ founders inside the operator's attention budget, capacity — not demand — is the binding failure; escalate to the quarterly re-validation gate before adding any second channel.

## Rejected variants → NOT-DOING

- Bank GTM before pilot proof (unpaid or "free pilot" entry) → NOT-DOING — violates accepted §3.6b; revisit: never (paid-only is a standing red line).
- Equity-for-tooling with cohort founders → NOT-DOING — frozen by accepted §3.6a; revisit: only by explicit human decision.
- Paid acquisition for segment B (ads/outbound to solo builders) → NOT-DOING — lowest-scored segment, WTP unproven, funnel already free via (c); revisit: after Rung-2 WTP is measured at pilot exit.
- Long/cheap exclusivity for a first bank → NOT-DOING — accepted §3.6b: short and expensive if at all; revisit: per-deal at G-gate.
