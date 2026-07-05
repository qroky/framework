# RPF Success Metrics System

**Atom:** ATOM-013 · **Role:** market-analyst · **Date:** 2026-07-05 · **Maturity:** draft
**Inputs:** ATOM-006 INPUT §4 (four named metrics); `pilot/pilot-design.md` (instruments, telemetry scope); `pricing/pricing-ladder.md` (assumptions under measurement).

Design rule: every metric is computable from **operational files inside the accepted telemetry scope** (STATUS, RESULT cost blocks, run.log, status.yaml, verify verdicts — §3.4) or from an explicitly human-kept log — and names the decision it changes. A metric with no decision attached is excluded by design (see final note). No targets are invented where no baseline exists (§3.9): such rows say `baseline TBD (pilot)`.

## 1. Framework metrics (the four named in ATOM-006 INPUT §4)

| Metric | Formula | Data source | Cadence | Decision informed | Baseline / target |
| :---- | :---- | :---- | :---- | :---- | :---- |
| **Escalation rate** | escalations (E1–E7) ÷ atoms closed, per tree | run.log `E*`/gate entries + status.yaml atom count | per product close | Is the constitution complete enough for unsupervised runs? Rising rate → constitutional touch, falling → wider autonomy tiers | day-one baseline: this tree ≈ 5 records / 10 atoms (source: `decisions/` GATE-007..009, INFO-001; `products/business-strategy-v1/status.yaml`) |
| **Verify returns** | return verdicts ÷ verify rounds | verify VERDICT.md files (verdict + returns_used) | per verify | Are executors delivering to DoD on round 1? Rising returns → formulation quality problem (LP5 side), not executor problem first | day-one baseline: 0 returns / 3 verified atoms in framework-v1 + this tree (source: verdicts in `products/*/`; small n — treat as anecdote) |
| **Cost per product type** | Σ real counters + Σ BC4 `~`-estimates per closed tree, split verify vs execute | RESULT cost blocks + status.yaml counters | per product close | Pricing re-anchor (founder-month model in `pricing/pricing-ladder.md`); envelope calibration (`knowledge/precedent/verify-envelope-calibration.md`) | strategy-grade tree ≈ ~320k tokens envelope (source: `decisions/GATE-008-atom-006-g1-direction.md`); verify atom 105–139k real (source: `knowledge/precedent/verify-envelope-calibration.md`) |
| **Founder-hours per gate** | minutes of human attention per gate/decision record, summed per tree | human-kept log (accepted §3.4: human-hours measured); decision-record count from `decisions/` | per gate; reviewed per product close | Is the framework actually cheap in founder attention — the product's core promise and Rung-2's binding COGS (`pricing/pricing-ladder.md` §1.4) | baseline TBD (pilot) — this tree's gates were not clocked; pilot logs minutes from day one |

## 2. Commercial metrics (pilot instruments — defined in `pilot/pilot-design.md`, referenced not redefined)

| Metric | Pilot criterion | Decision informed |
| :---- | :---- | :---- |
| Active cycles/founder-month + tokens/cycle | criterion 2 | founder-month token model re-anchor |
| Owner-review minutes/day/founder | criterion 3 | Rung-2 margin viability |
| Concurrent-founder capacity without SLA breach | criterion 4 | channel kill trigger (`channels/channel-comparison.md`) |
| WTP signal at exit ($50–200/mo band — assumption under test) | criterion 5 | Rung-2 price anchor; B2B2C rescue trigger |
| Case study + intros delivered | criterion 6 | bank-channel opening (INFO-001 exchange) |

## 3. Cadence & review

Framework metrics roll up **per product close** into the tree's RESULT; commercial metrics run on the pilot calendar. Both feed the **quarterly re-validation gate** (accepted §3.8) — the strategy re-touch reads this file's current numbers, not opinions. Collection cost is near zero by construction: every framework metric is a grep over files the constitution already obliges atoms to write.

**Excluded by design** (no decision attached, or outside telemetry scope): vanity counts (total atoms run, lines of constitution), founder-NPS-style surveys during the pilot (n≈2, noise), any metric requiring business content of pilot repos (violates accepted §3.4 scope).
