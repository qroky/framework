---
atom: ATOM-011
product: Pricing ladder + founder-month token economics (products/business-strategy-v1/pricing/pricing-ladder.md)
status: delivered
maturity_claimed: draft
cost:
  units_in: ~3k             # estimate (BC4): INPUT + §3.7 context + precedent table + status.yaml counters (in session context)
  units_out: ~3.5k
  unit: tokens
  wall_time: ~10m
  executor: claude-fable-5 (inline in ATOM-006 orchestrator session; tier M assigned, executed at L — upward substitution)
  sub_atoms_spawned: 0
  sub_atoms_cost: 0
---

# RESULT — ATOM-011

## Summary
Three-rung ladder priced (self-hosted free → Flow Support $150/mo anchor → managed 3–5×), with founder-month token cost computed from five repo cost blocks (four real runtime counters + one BC4 estimate + the GATE-008 envelope): **~1.0–1.6M tokens/founder-month ≈ $15–32/mo raw compute** at current per-tier API prices (blended ~$10/MTok at a 40/50/10 L/M/S mix, 80/20 read/write). Strategic finding: token COGS is negligible against the $50–200 WTP band (>35% gross margin even at the floor with conservative tokens); **the binding COGS is human owner-review time (8–15 h/founder-month assumed)** — the pilot must measure minutes/day, not just tokens. Subscription-plan prices unsourced → excluded (§3.9).

## Deliverables
| File | Purpose |
| :---- | :---- |
| `products/business-strategy-v1/pricing/pricing-ladder.md` | Unit-economics input to ATOM-010 (channels), ATOM-012 (pilot), ATOM-015 (Pricing section); satisfies parent H5 |

## DoD Self-Check
| Criterion | Result | Evidence |
| :---- | :---- | :---- |
| H1 file exists | met | `ls` |
| H2 three rungs, COGS + price-basis line each | met | grep: 3 `### Rung`, 3 `**COGS:**`, 3 `**Price basis:**` |
| H3 founder-month cost from ≥3 real cost blocks cited by path | met | grep: 6 distinct repo paths in §1 incl. 3 with real counters (`knowledge/precedent/verify-envelope-calibration.md`, both `status.yaml`) |
| H4 quantitative claims sourced or marked | met | grep; interpretation: price-table rows inherit the table-level source declaration (run-log RC3 + cache date); computed results inherit markers of their shown inputs |
| H5 WTP marked assumption + pilot-exit test | met | grep: 2 matches |
| H6 zero bare platform names | met | grep after excluding the mandated path-citation form `runtime/claude/README.md` → 0; raw grep's 2 hits are that path itself (H9 discipline requires citing it) |
| S1 recomputable + sensitivity | self-reviewed | §1.3 shows arithmetic line by line; §3 sensitivity table names which assumption breaks the conclusion (human-hours, not tokens) |

## Decisions Made by Executor
1. Vendor API prices used as the sole price basis; subscription plans excluded as unsourced (§3.9) — API prices are also the conservative bound.
2. Input/output blend fixed at 80/20 by analogy to measured verify runs (~3.5× read); declared as assumption.
3. Rung-2 anchor set at $150/mo (upper-middle of WTP band) rather than a range — a single anchor is testable at pilot exit; declared as assumption.
4. B2B2C per-cohort pricing explicitly deferred to ATOM-010 (channels) — it is channel economics, not ladder economics.

## Deviations & Known Limitations
Tier mix and cycles/month are this tree's observed pattern generalized to one data point — the widest error bars in the model; sensitivity table shows the margin conclusion is robust to them but fragile to human-hours. Executed before ATOM-010 per parent resequencing decision (logged in parent run.log 14:40:00Z).

## Handoff
Verification mode: self (draft) — this self-check is the delivery obligation; consumed by ATOM-010/012/015 whose assembly is independently verified; human sees pricing at G2.
