---
atom: ATOM-004
product: Orchestration Protocol (framework/ORCHESTRATION.md)
status: delivered
maturity_claimed: reviewed
cost:
  units_in: ~40000            # estimate per BC4 — no counter exposed to executor; trio + INPUT + precedents + prior-atom formats ≈ ~95 KB + re-reads
  units_out: ~15000           # estimate — product (~24 KB) + metadata + in-phase rework
  unit: tokens
  wall_time: ~30m
  executor: claude-fable-5
  sub_atoms_spawned: 0
  sub_atoms_cost: 0
---

# RESULT — ATOM-004

## Summary
Produced `framework/ORCHESTRATION.md` (251 lines), the fourth framework document: decomposition & planning (OD1–OD7 + plan template), model tiers (MT1–MT7: mandatory `model_tier` field, tier-L reservation for Formulate/Verify, tier escalator, asymmetry rule), budget calibration on top of BC1–BC4 (EC1–EC6: executor ×2 floor, verify ×3–4 margin, defective-envelope E7), gate-brief placement closing finding F1 of ATOM-002-VERIFY (GB1–GB5), the launch protocol legalizing current practice (LP1–LP7 + LAUNCH template), spawn & status sync (SS1–SS6), and the six-item runtime-binding contract (RC1–RC5). Consumers: formulating agents, runtimes (ATOM-004H is first), Verify atoms, the human.

## Deliverables
| File | Purpose |
| :---- | :---- |
| `framework/ORCHESTRATION.md` | The normative document (OD/MT/EC/GB/LP/SS/RC; 2 fenced templates) |

## DoD Self-Check
| Criterion | Result | Evidence |
| :---- | :---- | :---- |
| H1 file exists, 250–700 lines | met | `wc -l` = 251 (first draft 203; reworked in-phase) |
| H2 seven §4 sections by headings | met | `grep '^## '`: Decomposition & Planning / Model Tiers / Budget Calibration / Gate Briefs / Launch Protocol / Spawn & Status Sync / Runtime-Binding Contract |
| H3 exactly two fenced templates | met | `grep -c '^\`\`\`'` = 4 fence lines = 2 blocks (`LAUNCH.md`, decomposition plan) |
| H4 zero platform/product names | met | grep of the six banned strings = 0 matches |
| H5 zero trio contradictions; cited ids resolve | met | 65 distinct cited rule ids extracted by script; each resolves in ATOM-SPEC / FEV-PROTOCOL / REPO-STRUCTURE; tightenings explicit (MT1 extends §1.3 per R0.3; EC1–EC2 tighten BC2–BC3; LP4 tightens L7 sequencing; GB5/HP4-style forward reference instead of touching REPO-STRUCTURE) |
| H6 RESULT + cost block; STATUS delivered; status.yaml | met | this file; STATUS.md last line `delivered`; status.yaml synced in same step (SM3) |
| S1 four docs suffice for a 3-atom product | self-reviewed | §0 glance table maps every duty to its rule; §1 worked example plans exactly a 3-atom product with tiers, budgets, verification, gate, sequence |
| S2 every normative statement testable | self-reviewed | rules phrased against file presence, field presence, counts, order, and logged lines; rationale confined to *(informative)* passages |
| S3 tightens, never relaxes | self-reviewed | precedence bullet restates R0.3/P0.3; each tightening labeled at the rule; nothing weakens a trio obligation |
| S4 LAUNCH template reproduces the launch-file structure | self-reviewed | template mirrors ATOM-004-LAUNCH.md: title, blockquote preamble (sequence, step-0, verify-and-close, status-sync, spawn justification), `---`/`---` INPUT blocks in order, end-line — judge: Verify |
| S5 core ≤ 10 min | self-reviewed | full core (incl. informative) ~3011 words ≈ 12 min @250 wpm; normative-only ≈ ~2500 words ≈ 10 min. Flagged for Verify (same borderline class as ATOM-003's F3) |

## Decisions Made by Executor
1. **Id-space disambiguation rule** added in §0 (INPUT §6 hint): citations name their space ("ATOM-SPEC F1" vs "finding F1 of `<atom-id>-VERIFY`") — smallest rule that closes the ambiguity without renumbering anything.
2. **MT1 applies forward only** — atoms formulated after acceptance; INPUTs 001–003 are historical record. Avoids retroactive contradiction with A6.
3. **Plan location default** `PLAN.md` in the formulating atom's folder (LA3 product-file row), launch preamble MAY embed instead — simplest reversible option consistent with LA2.
4. **EC5/EC6 split** — counters vs closure metering, one obligation per rule id.
5. **Informative aids** (§0 glance table, §1 worked example) added to serve S1 directly; both marked *(informative)*.

## Deviations & Known Limitations
- S5 borderline when informative passages are counted (see self-check row). Trimmed twice; further cuts would remove the S1-serving aids.
- The LAUNCH template generalizes two observed instances (ATOM-003, ATOM-004 launches); a parallel-marker launch has never been exercised.
- No validator scripts shipped (consistent with REPO-STRUCTURE Appendix A); conformance checkable by the greps recorded in the run log.

## Handoff
Verification mode: independent + human. Verify receives: DoD (INPUT.md §5) + `framework/ORCHESTRATION.md` + RESULT.md/STATUS.md/status.yaml (H6) + reference standards the DoD cites (constitution trio; ATOM-004-LAUNCH.md for S4). Envelope per INPUT: read estimate ×3.5 — blind package ≈ ~120 KB ≈ ~40k read tokens → ~140k envelope, charged to parent per VP5.
