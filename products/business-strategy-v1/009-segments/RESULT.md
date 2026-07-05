---
atom: ATOM-009
product: Jobs-based segment map (products/business-strategy-v1/segments/segment-map.md)
status: delivered
maturity_claimed: draft
cost:
  units_in: ~3k             # estimate (BC4): INPUT + §3.5/§3.6 context + MANIFEST (in session context)
  units_out: ~3k
  unit: tokens
  wall_time: ~10m
  executor: claude-fable-5 (inline in ATOM-006 orchestrator session; tier M assigned, executed at L — upward substitution)
  sub_atoms_spawned: 0
  sub_atoms_cost: 0
---

# RESULT — ATOM-009

## Summary
Three segments mapped by jobs-to-be-done with explicit hypotheses and success criteria, scored on the accepted 7-factor checklist: A non-technical accelerator founder (23/35, only live channel), C regulated-organization innovation unit (25/35, channel gated on pilot proof), B technical solo builder (18/35, background funnel). Sequence A → C → B reproduces the accepted §3.6 sequence hypothesis from evidence. Ranking sensitivity: A rests on untested WTP/margin assumptions — the B2B2C rescue (program pays) is flagged for the channels atom. Two customer-knowledge questions queued for G1.

## Deliverables
| File | Purpose |
| :---- | :---- |
| `products/business-strategy-v1/segments/segment-map.md` | Segment map for G1 direction check; input to channels, pricing, strategy assembly |

## DoD Self-Check
| Criterion | Result | Evidence |
| :---- | :---- | :---- |
| H1 file exists | met | `ls` |
| H2 ≥3 segments, ≥2 labeled hypotheses each, success criterion per job | met | grep: 3 segments, 7 `(Hypothesis)` labels, 7 success criteria |
| H3 all 7 accepted factors per segment | met | grep factor rows → 21 (3×7) |
| H4 every quantitative claim sourced or marked | met | grep score rows: 0 unmarked |
| S1 scoring shows work + sensitivity | self-reviewed | evidence/assumption line per factor; dedicated sensitivity paragraph naming the two weak scores and their rescue paths |
| S2 jobs recognizable to a real founder | deferred | judge: human (G1) — question 1 of the G1 material |

## Decisions Made by Executor
1. Scoring scale fixed at 1–5 with 5 = most attractive on every factor (incl. inverted reading for competition) — simplest scale that makes totals comparable; declared inline.
2. Ranking presented as a sequence (A → C → B), not a raw score sort, because C's channel gate is an accepted constraint (§3.6b), not a scoring input.
3. Unscored adjacent segments parked to NOT-DOING rather than half-scored — keeps H3 honest.

## Deviations & Known Limitations
Size/budget factors are assumptions by design (no sourced market counts used — §3.9); the pilot is the instrument that converts the two weakest assumptions (WTP, margin) into data.

## Handoff
Verification mode: self (draft) — this self-check is the delivery obligation; direction reviewed by the human at G1; consumed by ATOM-010/011/015 whose assembly is independently verified.
