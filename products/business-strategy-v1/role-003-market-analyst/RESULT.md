---
atom: ROLE-003
product: Role spec market-analyst (roles/market-analyst.md)
status: delivered
maturity_claimed: draft
cost:
  units_in: ~1k             # estimate (BC4)
  units_out: ~1k
  unit: tokens
  wall_time: ~3m
  executor: claude-fable-5 (inline in ATOM-006 orchestrator session; tier M assigned, executed at L — upward substitution)
  sub_atoms_spawned: 0
  sub_atoms_cost: 0
---

# RESULT — ROLE-003

## Summary
Role spec `market-analyst` created per ATOM-SPEC §6.3: jobs-to-be-done segment mapping with hypothesis discipline ("we believe X, we would know by Y") and metrics design where every metric must name the decision it informs.

## Deliverables
| File | Purpose |
| :---- | :---- |
| `roles/market-analyst.md` | Executor role for ATOM-009 (segments), ATOM-013 (metrics) |

## DoD Self-Check
| Criterion | Result | Evidence |
| :---- | :---- | :---- |
| H1 template conformance | met | grep: 5/5 section headings, 2/2 frontmatter keys |
| H2 ≤60 lines | met | `wc -l` → 38 |
| H3 provenance row | met | grep: `Created \| ROLE-003 \| 2026-07-05` |
| S1 jobs as explicit hypotheses | self-reviewed | Identity + Method Defaults state the hypothesis discipline; facts/hypotheses separation explicit |

## Decisions Made by Executor
"A metric without a consumer decision attached is cut" adopted as a method default — the A3 consumer rule applied to metrics; simplest reversible reading of INPUT §4 (metrics deliverable).

## Deviations & Known Limitations
None.

## Handoff
Verification mode: self (draft) — this self-check is the acceptance.
