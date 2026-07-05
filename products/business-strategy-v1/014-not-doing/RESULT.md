---
atom: ATOM-014
product: NOT-DOING register (products/business-strategy-v1/NOT-DOING.md)
status: delivered
maturity_claimed: draft
cost:
  units_in: ~2k             # estimate (BC4): INPUT + queued rejections already in session context
  units_out: ~1.5k
  unit: tokens
  wall_time: ~5m
  executor: claude-fable-5 (inline in ATOM-006 orchestrator session; tier M assigned, executed at L — upward substitution)
  sub_atoms_spawned: 0
  sub_atoms_cost: 0
---

# RESULT — ATOM-014

## Summary
Fourteen-entry rejection register consolidating: the five §3.8 named backfills, both naming kills (GATE-009), ATOM-009's parked segments, ATOM-010's four channel rejections, INFO-001's rejected option and red lines, the unsourced subscription-price basis (§3.9), and the no-second-channel-before-capacity-proof rule. Every entry: one-line why + revisit trigger + citable source. Parent H3 (≥5 entries) exceeded ×2.8.

## Deliverables
| File | Purpose |
| :---- | :---- |
| `products/business-strategy-v1/NOT-DOING.md` | First-class register at product root (§4 tree); quarterly-gate review input; anti-re-litigation record |

## DoD Self-Check
| Criterion | Result | Evidence |
| :---- | :---- | :---- |
| H1 file exists | met | `ls` |
| H2 ≥5 entries with why + trigger | met | grep: 14 rows, 0 empty cells |
| H3 five §3.8 backfills | met | grep: all five ×1 |
| H4 source per entry | met | grep: 0 rows without a § or path citation |
| H5 no bare platform names | met | grep 0 |
| S1 decisions not intentions | self-reviewed | every row's source column points at an actual made decision |

## Decisions Made by Executor
1. Added entries 13–14 (subscription-price basis, second-channel-before-capacity) — rejections genuinely made inside ATOM-011/010 deliverables but not on the queued list; register completeness beats list fidelity; sources cited.
2. "Never" used as a trigger only where the source decision itself is terminal (dead names, standing red lines).

## Deviations & Known Limitations
None. Consolidation atom — no new analysis performed.

## Handoff
Verification mode: self (draft) — this self-check is the delivery obligation; consumed by ATOM-015; reviewed at quarterly gate.
