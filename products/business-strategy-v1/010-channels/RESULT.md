---
atom: ATOM-010
product: Channel comparison + recommendation (products/business-strategy-v1/channels/channel-comparison.md)
status: delivered
maturity_claimed: draft
cost:
  units_in: ~3k             # estimate (BC4): INPUT + §3.6 context + pricing/segments/INFO-001 (in session context)
  units_out: ~3k
  unit: tokens
  wall_time: ~8m
  executor: claude-fable-5 (inline in ATOM-006 orchestrator session; tier M assigned, executed at L — upward substitution)
  sub_atoms_spawned: 0
  sub_atoms_cost: 0
---

# RESULT — ATOM-010

## Summary
Three accepted channel hypotheses compared on unit economics grounded in the pricing atom's numbers. Recommendation: **accelerator → paid bank pilot → second bank as leverage** — the §3.6 sequence hypothesis confirmed by economics: (a) costs ~$0 to enter, matches one operator's capacity (6–10 founders), and via INFO-001 terms is the acquisition mechanism for (b); (b) holds the margin ceiling but is pilot-gated; (c) is a zero-cost passive funnel. B2B2C rescue priced: $1,000–1,500/cohort-month for ~10 founders (payer flips founder→program if WTP fails). Bank pilot ticket explicitly conversation-gated, no number invented (§3.9). Kill trigger defined: capacity failure (<6 founders in attention budget) escalates before any second channel. Four rejected variants handed to NOT-DOING.

## Deliverables
| File | Purpose |
| :---- | :---- |
| `products/business-strategy-v1/channels/channel-comparison.md` | Channel decision input to ATOM-012 (pilot), ATOM-014 (rejections), ATOM-015 (Channel section) |

## DoD Self-Check
| Criterion | Result | Evidence |
| :---- | :---- | :---- |
| H1 file exists | met | `ls` |
| H2 three options × four economics rows | met | grep: 3 option headings; 3×Acquisition/Capacity/Revenue basis/Margin |
| H3 exactly one Recommendation with sequence | met | grep count = 1; sequence stated verbatim |
| H4 ≥2 rejected variants → NOT-DOING | met | grep: 5 markers (4 entries + heading) |
| H5 quantitative claims sourced or marked | met | grep; residual hits are $0 structural facts of the free rung and the recommendation prose referencing numbers sourced above |
| H6 consumes pricing + INFO-001 by path | met | grep: 6 + 5 |
| S1 sequence wins on shown numbers | self-reviewed | each leg of the recommendation cites the economics row it rests on |

## Decisions Made by Executor
1. B2B2C cohort price set consistent with the ladder anchor ($100–150/founder-month) rather than independently derived — one pricing spine across the strategy; declared assumption.
2. Bank pilot ticket left unpriced (conversation-gated) — §3.9 forbids inventing it; the managed-rung multiple is the only stated basis.
3. Added a kill trigger (capacity, not demand) — the pricing atom's finding that attention is the binding constraint implies the channel's failure mode; declared as executor addition within §3.6 scope.
4. Graduate discount fixed at 50%/3 months as a testable placeholder (assumption).

## Deviations & Known Limitations
Operator capacity (6–10 founders) generalizes the pricing atom's hours assumption — the single most consequential unmeasured number in the channel plan; ATOM-013 must carry the corresponding metric. Executed after ATOM-011 per parent resequencing (run.log 14:40Z).

## Handoff
Verification mode: self (draft) — this self-check is the delivery obligation; consumed by ATOM-012/014/015 whose assembly is independently verified; human sees channels at G2.
