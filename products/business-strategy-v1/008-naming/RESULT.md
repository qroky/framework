---
atom: ATOM-008
product: Naming due diligence + verdict (products/business-strategy-v1/naming/naming-verdict.md)
status: delivered
maturity_claimed: reviewed
cost:
  units_in: ~6k             # estimate (BC4): INPUT + §3.3 context + 4 web queries/fetch results
  units_out: ~3k            # verdict + atom metadata
  unit: tokens
  wall_time: ~15m
  executor: claude-fable-5 (inline in ATOM-006 orchestrator session; tier L per INPUT)
  sub_atoms_spawned: 0
  sub_atoms_cost: 0
---

# RESULT — ATOM-008

## Summary
The naming verdict inverts the intake picture: **Atomaro is killed** — it is a live commercial design-system platform of Rostelecom (paid tiers, RU domestic-software registry, Figma community presence), found by the checklist's own cheapest check (live-company search in category), which the intake evidence had missed. **Qroky survives** everything checkable today and is recommended as front-runner, conditional on two cheap register probes (GitHub org-form, formal EUIPO/USPTO/WIPO queries) before public use. The atomaro.com backorder should be cancelled.

## Deliverables
| File | Purpose |
| :---- | :---- |
| `products/business-strategy-v1/naming/naming-verdict.md` | 7-point evidence per candidate, Atomos kill record, Atomico assessment, verdict + recommendation for G1 |

## DoD Self-Check
| Criterion | Result | Evidence |
| :---- | :---- | :---- |
| H1 file exists | met | `ls` |
| H2 7 evidence rows × 2 candidates | met | grep row count: 7 + 7 |
| H3 Atomico assessed | met | `grep -c Atomico` → 4, incl. dedicated section |
| H4 every row sourced or marked | met | grep: 0 unmarked rows |
| H5 Verdict section + one recommendation | met | grep: both present |
| S1 no invented facts | self-reviewed | web claims carry URLs + fetch date; register states declared "not performed", not guessed |
| S2 decision-ready for founder | deferred | judge: human (G1, VP9) |

## Decisions Made by Executor
1. Atomaro assessed as **kill**, not hold: identical string, same broad category, incumbent scale, and home-market (RU-language) search dominance leave no reversible path worth holding open. The human can override at G1.
2. Formal trademark-register queries declared not-performed rather than simulated from search snippets — §3.9 honesty over checklist completeness; remaining probes scoped as tier-S follow-up work.
3. "(source: executor judgment, ATOM-008)" used as the source marker for the two judgment-type checklist points (5, 6) so H4 stays script-checkable.

## Deviations & Known Limitations
Checklist points 2–3 for Qroky are open probes (GitHub org-form check; formal register queries) — explicitly marked in the verdict; closing them is a precondition of public use, not of this verdict.

## Handoff
Verification mode: independent + human. Verify receives: DoD (INPUT.md §5) + `naming/naming-verdict.md` (+ this RESULT and STATUS where criteria reference them). Human sign-off at G1.
