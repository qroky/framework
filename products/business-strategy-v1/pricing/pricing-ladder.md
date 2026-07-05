# RPF Pricing Ladder + Founder-Month Token Economics

**Atom:** ATOM-011 · **Role:** venture-strategist · **Date:** 2026-07-05 · **Maturity:** draft
**Inputs:** ATOM-006 INPUT §3.7/§3.9; `segments/segment-map.md` (budget-for-the-job, margin factors); repo cost blocks cited below; model tiers S/M/L per `runtime/claude/README.md`.

---

## 1. Founder-month token cost — computed from real repo cost blocks

### 1.1 Real cost blocks used (cited by path)

| # | Cost block | Value | Kind |
| :- | :---- | :---- | :---- |
| 1 | `knowledge/precedent/verify-envelope-calibration.md` — measured-runs table | 123 814 / 139 394 / 138 342 tokens per blind verify atom (tier L) | real runtime counters (source: cited file) |
| 2 | `products/business-strategy-v1/status.yaml` — ATOM-008-VERIFY entry | 105,273 tokens | real runtime counter (source: cited file) |
| 3 | `products/framework-v1/status.yaml` — ATOM-005-VERIFY entry | 138,342 tokens | real runtime counter (source: cited file) |
| 4 | `products/business-strategy-v1/009-segments/RESULT.md` — cost block | ~6k tokens for a light tier-M analysis atom | `~` BC4 estimate, not a counter (source: cited file) |
| 5 | `decisions/GATE-008-atom-006-g1-direction.md` — envelope decision | ~320k tokens for one full orchestrated strategy product tree | envelope, part-real part-estimate (source: cited file) |

Derived unit costs:
- **Blind verify atom (tier L):** four real measurements, 105,273–139,394; mean ≈ 127k tokens.
- **Full atom cycle:** ≈ 90–120k tokens (source: ATOM-006 INPUT §3.7, accepted input).
- **Light inline analysis atom (tier M):** ~3–10k tokens (source: block 4; estimate).
- **Full orchestrated product (strategy-grade):** ~320k tokens envelope (source: block 5).

### 1.2 Price inputs

Per-tier prices, current vendor API price list (retrieval logged in this atom's run log per RC3; cached 2026-06-24; tier mapping per `runtime/claude/README.md`):

| Tier | Input $/MTok | Output $/MTok | Blended $/MTok at 80/20 in/out (assumption: repo work is read-dominated — verify measurements above are ~3.5× read) |
| :- | :- | :- | :- |
| L | $10 | $50 | $18.00 |
| M | $3 | $15 | $5.40 |
| S | $1 | $5 | $1.80 |

Subscription-plan prices were not available from the source — **excluded from computation** (unsourced, §3.9). API prices are the conservative (highest-cost) basis anyway.

### 1.3 The computation (recomputable)

- Active founder runs ~10 atom cycles/month (assumption — ≈2–3 orchestrated sub-products; pilot measures the real number).
- 10 cycles × ~105k (midpoint of 90–120k, source §3.7) ≈ 1.05M tokens; + 30–50% orchestration/verify overhead observed in this tree (source: block 5 — ~320k tree vs ~200k of child work) → **~1.0–1.6M tokens/founder-month**.
- Tier mix: 40% L (verify + orchestration), 50% M (standard work), 10% S (mechanical) (assumption — this tree's observed pattern).
- Blended price: 0.4×$18.00 + 0.5×$5.40 + 0.1×$1.80 ≈ **$10.1/MTok**.
- **Founder-month token cost: 1.0–1.6M × ~$10/MTok ≈ $10–16/month; with a ×1.5–2 safety factor for verify returns and re-runs → ~$15–32/month** raw compute at API prices.

### 1.4 What the numbers say (the strategic finding)

Token COGS is **negligible against the WTP band**: solo-founder willingness-to-pay ceiling $50–200/mo (assumption per §3.7 — **test at pilot exit, not now**). Even the conservative $32/mo figure leaves >35% gross margin at the $50 floor and >80% at $150. Sensitivity: the conclusion survives a ×3 error in tokens-per-month (still under the $50 floor); it does **not** survive mispricing human attention. **The binding COGS in the paid rungs is human owner-review time, not tokens** — the segment map's weakest factor (unit margin, `segments/segment-map.md`) is therefore governed by hours, and the pilot must measure minutes/day, not just tokens.

---

## 2. The ladder

### Rung 1 — Self-hosted (open core), free
- **Client gets:** the framework repo, constitution, runtime binding; runs on their own keys.
- **COGS:** $0 tokens to us (client pays own ~$15–32/mo compute, computed above); marginal support ≈ 0 by policy (community-only).
- **Price basis:** $0 — funnel and brand (accepted channel hypothesis §3.6c); converts by upgrade pressure, not sales.

### Rung 2 — Flow Support (observation as a service)
- **Client gets:** daily owner review of their atom flows, sentinel-prepared interventions (human approves/sends), monthly report, SLA: reaction to `blocked` within one business day (terms framing per `decisions/INFO-001-pilot-terms-startup-moldova.md`).
- **COGS:** tokens ~$15–32/mo (computed above) + **human attention 15–30 min/day ≈ 8–15 h/founder-month (assumption — pilot measures)** — the dominant term.
- **Price basis:** anchor **$150/founder-month** (assumption — inside the $50–200 WTP band, test at pilot exit); pilot cohort pays in kind instead of cash: case study + 2–3 bank/fund intros (source: `decisions/INFO-001-pilot-terms-startup-moldova.md`). B2B2C variant — the program pays per cohort — is priced by the channels atom, not here.

### Rung 3 — Managed
- **Client gets:** we run everything — keys, infra, flows, gates prepared for their sign-off; for organizations that cannot self-host (segment C, `segments/segment-map.md`).
- **COGS:** tokens (passthrough above an included quota) + infra + named-human support; scales with attention like Rung 2 but with compliance overhead (segment C is regulated).
- **Price basis:** 3–5× the Flow Support anchor per seat/portfolio (assumption — no sourced comparable; priced properly only after a segment-C conversation, which the pilot's bank intros open).

---

## 3. Sensitivity and what the pilot must measure

| Assumption | If wrong by ×2–3 | Pilot instrument |
| :---- | :---- | :---- |
| ~10 cycles/founder-month | token COGS still < $50 WTP floor — margin conclusion holds | telemetry consent counters (ATOM-012) |
| Tier mix 40/50/10 | blended $/MTok shifts $5–18 — bounded, holds | status.yaml real counters |
| 15–30 min/day owner review | **breaks Rung 2 margin** — the real risk | measured human-hours per founder (ATOM-013 metric) |
| WTP $50–200/mo | re-anchor Rung 2; Rung 1 unaffected | pilot-exit pricing conversation |

Re-validation: this file decays with the vendor price list; re-touch at the quarterly strategy gate (§3.8).
