---
plan_for: RPF Business Strategy v1 (products/business-strategy-v1/)
formulated_by: ATOM-006 orchestrator session (venture-strategist duties assumed per LP5), 2026-07-05
parent_envelope: ~200k tokens (ATOM-006 INPUT frontmatter)
date: 2026-07-05
---

# DECOMPOSITION PLAN — RPF Business Strategy v1

## Product tree
| Atom | Product (deliverable path) | Role | Tier | Budget | Verification | Gates | Instantiation | Depends on |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| ROLE-002 | `roles/venture-strategist.md` | framework-architect | M | ~2k | self | none | subagent (inline) | — |
| ROLE-003 | `roles/market-analyst.md` | framework-architect | M | ~2k | self | none | subagent (inline) | — |
| ATOM-008 | `products/business-strategy-v1/naming/naming-verdict.md` | venture-strategist | L | ~10k | independent + human | sign-off at G1 | subagent (inline) | ROLE-002 |
| ATOM-008-VERIFY | `products/business-strategy-v1/008-naming-verify/VERDICT.md` | (Verify atom) | L | ~50k | — | — | session (clean-context spawn) | ATOM-008 |
| ATOM-009 | `products/business-strategy-v1/segments/segment-map.md` | market-analyst | M | ~6k | self | G1 direction check | subagent (inline) | ROLE-003 |
| ATOM-010 | `products/business-strategy-v1/channels/channel-comparison.md` | venture-strategist | M | ~5k | self | none | subagent (inline) | ATOM-009, G1 |
| ATOM-011 | `products/business-strategy-v1/pricing/pricing-ladder.md` | venture-strategist | M | ~6k | self | none | subagent (inline) | ATOM-010 |
| ATOM-012 | `products/business-strategy-v1/pilot/pilot-design.md` | venture-strategist | M | ~5k | self | none | subagent (inline) | ATOM-009, INFO (pilot terms, G1) |
| ATOM-013 | `products/business-strategy-v1/metrics/metrics-system.md` | market-analyst | M | ~4k | self | none | subagent (inline) | — (repo data only) |
| ATOM-014 | `products/business-strategy-v1/NOT-DOING.md` | venture-strategist | M | ~2k | self | none | subagent (inline) | ATOM-008..013 |
| ATOM-015 | `products/business-strategy-v1/STRATEGY.md` | venture-strategist | L | ~5k | independent + human | G2 | subagent (inline) | ATOM-008..014 |
| ATOM-015-VERIFY | `products/business-strategy-v1/015-strategy-verify/VERDICT.md` | (Verify atom) | L | ~54k | — | — | session (clean-context spawn) | ATOM-015 |

Atom metadata folders (NC2): `role-002-venture-strategist/`, `role-003-market-analyst/`, `008-naming/`, `008-naming-verify/`, `009-segments/`, `010-channels/`, `011-pricing/`, `012-pilot/`, `013-metrics/`, `014-not-doing/`, `015-strategy/`, `015-strategy-verify/` — all under `products/business-strategy-v1/`. Deliverables live at the exact INPUT §4 tree paths, named explicitly in each child `INPUT.md` (LA2/LA4). ATOM-007 is reserved for the pilot-prerequisites product named in the parent INPUT §3.4; it is not part of this tree.

## Tier justifications (MT1 — one line per atom)
- ROLE-002 / ROLE-003: templated role specs against ATOM-SPEC §6.3 — standard structured production; M sufficient (executed inline at the session's L executor — upward substitution, logged).
- ATOM-008: brand go/no-go judgment incl. trademark-confusion assessment — doubt between M and L resolved upward per MT6 → L.
- ATOM-008-VERIFY / ATOM-015-VERIFY: Verify of maturity-target ≥ reviewed products → L mandatory (MT3/MT4).
- ATOM-009–ATOM-013: standard structured analysis against a clear spec (§3.5–§3.7 give the checklists) → M.
- ATOM-014: register compilation with judgment on revisit-triggers → M.
- ATOM-015: cross-analysis synthesis, the decision document for human + investors → L (MT6).

## Budget arithmetic (OD4)
All numbers `~`-estimates per BC4 (no live counter for main-session work — binding §5); verify envelopes per the ×3.5 + 40k formula of `knowledge/precedent/verify-envelope-calibration.md`.

- Parent own consumption: reads to date ~43k (constitution + binding + precedents + prior-atom conventions, ~128 KB ÷ 3) + plan/inputs/status/gate-briefs/records/closure writes ~12k = **~55k**
- Children (inline execute): 2+2+10+6+5+6+5+4+2+5 = **~47k** → trimmed working target **~40k** (drafts, not tomes)
- ATOM-008-VERIFY: blind package ~3k read → 3.5× + 40k ≈ **~50k**
- ATOM-015-VERIFY: blind package ~4k read → 3.5× + 40k ≈ **~54k**

Sum of child envelopes: ~144k. Parent's own remaining consumption: ~55k. Parent envelope: ~200k. Fits (O6.1): **yes — at ~199k, zero margin**.

## Sequencing (OD5)
ROLE-002 ∥ ROLE-003 → ATOM-008 ∥ ATOM-009 → ATOM-008-VERIFY → **G1** (direction check + naming sign-off + consolidated E1: pilot terms) → ATOM-010 → ATOM-011 ∥ ATOM-012 ∥ ATOM-013 → ATOM-014 → ATOM-015 → ATOM-015-VERIFY → **G2** (final acceptance) → close per L7/RB6. "Parallel" inline branches are sequential in wall time; the marker means no dependency, order free.

## Open risks
- **Zero budget margin.** Any Verify return or rework projects past the envelope → immediate E4 hard stop and gate (O6.2); atoms wait, per the parent INPUT.
- Verify real consumption may deviate from the formula (4 precedents, small-package regime less measured); real counters recorded at closure (EC6).
- Naming trademark screen depends on live web sources; unverifiable claims become marked assumptions or E1 questions (INPUT §3.9), not invented facts.
