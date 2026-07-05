---
atom: ATOM-013
product: RPF success metrics system (products/business-strategy-v1/metrics/metrics-system.md)
status: delivered
maturity_claimed: draft
cost:
  units_in: ~2.5k           # estimate (BC4): INPUT + pilot/pricing outputs (in session context)
  units_out: ~2.5k
  unit: tokens
  wall_time: ~8m
  executor: claude-fable-5 (inline in ATOM-006 orchestrator session; tier M assigned, executed at L — upward substitution)
  sub_atoms_spawned: 0
  sub_atoms_cost: 0
---

# RESULT — ATOM-013

## Summary
Metrics system defined: the four §4-named framework metrics (escalation rate, verify returns, cost per product type, founder-hours per gate) each with formula, telemetry-scope-compatible data source, cadence, decision informed, and honest baselines (day-one numbers from this repo where they exist, `baseline TBD (pilot)` where they don't — founder-hours were not clocked on this tree); five commercial metrics referencing pilot instruments without redefinition; quarterly re-validation gate as the consuming review; explicit exclusion note for unactionable/out-of-scope metrics. Collection cost ≈ 0 by construction — every framework metric is a grep over constitutionally-obliged files.

## Deliverables
| File | Purpose |
| :---- | :---- |
| `products/business-strategy-v1/metrics/metrics-system.md` | Referenced from STRATEGY.md; instrument spec for pilot-era dashboards; quarterly gate input |

## DoD Self-Check
| Criterion | Result | Evidence |
| :---- | :---- | :---- |
| H1 file exists | met | `ls` |
| H2 four §4 metrics by name | met | grep: all four ×1 |
| H3 formula+source+cadence+decision per row | met | table columns present; each §1 row filled |
| H4 sources within telemetry scope | met | run.log, status.yaml, VERDICT.md, RESULT cost blocks, human-kept log — all §3.4-scope or human logs |
| H5 no invented targets | met | founder-hours row = baseline TBD (pilot); populated baselines carry (source: path) |
| H6 no bare platform names | met | grep 0 after path-citation exclusion |
| S1 every metric names its decision | self-reviewed | Decision-informed column filled; exclusion note drops decision-less metrics |

## Decisions Made by Executor
1. Day-one baselines taken from this tree itself where honest (escalation rate, verify returns marked small-n anecdote, cost per product type) — the tree is the first data set (INPUT §6 hint).
2. Verify-returns metric attributed first to formulation quality (LP5 side) — matches the constitution's incentive design; declared interpretation.
3. Founder-NPS surveys excluded during pilot (n≈2 noise) — actionable feedback comes through the daily review channel instead.

## Deviations & Known Limitations
Baselines have n between 1 and 3 — directional only until the pilot multiplies the data; the file says so inline.

## Handoff
Verification mode: self (draft) — this self-check is the delivery obligation; consumed by ATOM-015; human at G2.
