---
atom: ATOM-017
product: Rebrand text swap «RPF» → Qroky (living artifacts)
status: delivered
maturity_claimed: reviewed
cost:
  units_in: ~10k
  units_out: ~4k
  unit: tokens
  wall_time: ~8m
  executor: claude-fable-5 (session, inline; tier-S work at L — MT6 upward substitution)
  sub_atoms_spawned: 0
  sub_atoms_cost: 0
total_descendants: 0
max_depth_reached: 0
subtree_cost:
  execute: ~14k tokens
  verify: (governance cost of the formulating agent — reported at closure per EC6)
  role-creation: 0
  synthesis: 0
---

# RESULT — ATOM-017

## Summary
Text half of the rebrand executed under the GATE-012 boundary: 10 living files
edited, brand positions read **Qroky**, the methodology keeps its spelled-out
name «Recursive Product Framework», the «brand name pending» footnote and its ¹
anchor removed from MANIFEST, history frozen. GitHub transfer to
`qroky/framework` was done by the human; origin updated and fetch-verified.

## Deliverables
| File | Change |
| :---- | :---- |
| `MANIFEST.md` | title, 5 brand positions, footnote + anchor removed |
| `README.md` | title, 3 brand positions, license line restates brand vs methodology |
| `TASKS.md` | forward rows (2.1/2.2 closed per GATE-012; swap row → executing) |
| `ATOM-007-LAUNCH.md` | parent fields + §3.7 refreshed with change note (decision B5) |
| `products/business-strategy-v1/STRATEGY.md` | title, positioning line, swap-status sentence |
| `…/segments/segment-map.md`, `…/pilot/pilot-design.md` (incl. consent), `…/pricing/pricing-ladder.md`, `…/metrics/metrics-system.md`, `…/channels/channel-comparison.md` | brand positions |

## DoD Self-Check
| Criterion | Result | Evidence |
| :---- | :---- | :---- |
| H1 | met | grep -c "RPF" = 0 across living set; two retained mentions are swap-history phrases explicitly allowed by H1 (ATOM-007-LAUNCH §3.7, STRATEGY §Naming); TASKS line 45 historical per B3 |
| H2 | met | grep "brand name is pending\|¹" MANIFEST.md → 0 |
| H3 | met | git status --porcelain: 10 living files + atom folder + GATE-012 record only; frozen set untouched |
| H4 | met | head -1 both = «# Qroky — Recursive Product Framework» |
| H5 | met | git remote get-url origin = https://github.com/qroky/framework.git (fetch tested) |
| S1 | self-reviewed | boundary B1–B5 applied per file; framework/ grep-clean of both names |
| S2 | self-reviewed | edited sentences re-read in context |
| S3 | deferred | human judge at GATE-013 |

## Decisions Made by Executor
B1 brand positions → Qroky; B2 spelled-out methodology name retained, title
pattern «Qroky — Recursive Product Framework», README license line restated;
B3 frozen history (decisions/, knowledge/, atom metadata, closed launches,
naming-verdict.md, TASKS historical lines); B4 STRATEGY swap-status sentence
updated as fact, not history rewrite; B5 ATOM-007-LAUNCH §3.7 refreshed with
change note (launch not yet materialized). All logged in run.log.

## Deviations & Known Limitations
None. `Handover1.md` remains untracked at root (pre-existing, outside this atom's scope).

## Handoff
Verification mode: independent + human. Verify receives: DoD (INPUT §5) + the 10
living files + instruments (grep/git status). Human gate: GATE-013.
