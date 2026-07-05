---
atom: ATOM-003
product: Repository Structure & Knowledge Layer (framework/REPO-STRUCTURE.md)
status: delivered
maturity_claimed: reviewed
cost:
  units_in: ~30000            # estimate per BC4 — no runtime counter exposed to executor; input package ~73 KB ≈ ~25k tokens + re-reads
  units_out: ~13000           # estimate — product + seeds + metadata ≈ ~28 KB written
  unit: tokens
  wall_time: ~25m
  executor: claude-fable-5
  sub_atoms_spawned: 0
  sub_atoms_cost: 0
---

# RESULT — ATOM-003

## Summary
Produced `framework/REPO-STRUCTURE.md` (251 lines), the third constitutional document: repository layout (LA), naming (NC), knowledge layer with the profile mechanism and the `regulatory` example (KL), human-participant profiles with language routing (HP), the remote bus segment — commit+push at closure, commit-message convention, `.gitignore` baseline (RB), the shared status machine (SM), and the budget-calibration convention (BC). All five seed files are real instances of their own templates, not examples. Consumers: every atom (paths), ATOM-004 orchestration (SM + RB), the human (navigation).

## Deliverables
| File | Purpose |
| :---- | :---- |
| `framework/REPO-STRUCTURE.md` | The normative document (LA/NC/KL/HP/RB/SM/BC; 3 fenced templates) |
| `roles/humans/ghenadie.md` | First human-participant profile (HP1, HP5 template) |
| `knowledge/precedent/remote-bus-push-required.md` | Precedent seed (a): remote-bus lesson of 2026-07-04 |
| `knowledge/precedent/verify-envelope-calibration.md` | Precedent seed (b): verify-envelope lesson of 2026-07-05 |
| `products/framework-v1/status.yaml` | First real status machine, backfilled for ROLE-001, ATOM-001, ATOM-002, ATOM-002-VERIFY, ATOM-003 |
| `.gitignore` | RB4 baseline at repository root |

## DoD Self-Check
| Criterion | Result | Evidence |
| :---- | :---- | :---- |
| H1 file exists, 250–700 lines | met | `wc -l` = 251 (initial draft was 217; expanded with informative layout mapping, RB6 closure sequence, BC worked example) |
| H2 seven areas by headings | met | `grep '^## '`: Layout / Naming / Knowledge Layer & Profiles / Human-Participant Profiles / Remote Bus / Status Machine / Budget Calibration |
| H3 exactly 3 fenced templates | met | `grep -c '^\`\`\`'` = 6 fence lines = 3 blocks (knowledge `markdown`, human profile `markdown`, status.yaml `yaml`), each with frontmatter/schema header |
| H4 zero platform names | met | grep of the six banned strings = 0 matches |
| H5 seeds exist and conform | met | all 5 files exist; status.yaml parses as valid YAML with exactly {id,state,timestamp,note} per atom; both knowledge files carry source/date/type/tags; ghenadie.md carries name/languages/preferred_for_decisions + Identity + Decision-input preferences |
| H6 no contradictions; cited ids resolve | met | 37 distinct cited rule ids extracted by grep; each verified present in ATOM-SPEC / FEV-PROTOCOL; tightenings are explicit (RB1 tightens L7; SM1 tightens O10.2; LA5 extends O1.2; BC2 extends F5) and none relax |
| H7 RESULT + cost block; STATUS delivered | met | this file; STATUS.md last line `delivered` |
| S1 fresh atom places every file | self-reviewed | LA1 closed table + LA2-LA4 + NC1-NC7 cover every artifact class the constitution names; informative current-tree mapping doubles as the test |
| S2 testable statements, no aspiration | self-reviewed | every rule phrased against file presence, path patterns, field presence, order, or grep-able content |
| S3 tightens, never relaxes | self-reviewed | §0 precedence rule restates R0.3/P0.3; each tightening labeled at the rule |
| S4 seeds immediately usable | deferred | judge: human (VP9) |
| S5 core ≤ 10 min | self-reviewed | core (excl. fenced blocks) = 2694 words ≈ 10–11 min at 250 wpm — borderline; ~500 of those words are informative tables that read faster than prose. Flagged for Verify. |

## Decisions Made by Executor
1. **Knowledge naming** (INPUT §3.6 left the choice): `knowledge/<type>/<slug>.md` over flat-with-frontmatter — type is a closed 4-value vocabulary; the path filters by directory listing alone; redundancy closed by NC4 (path type MUST equal frontmatter type). Reversible: files movable without frontmatter changes.
2. **Rule prefixes** LA/NC/KL/HP/RB/SM/BC — the INPUT §6 hint suggested `RS`, which collides with ATOM-SPEC RS1–RS3 (Research phase); replaced with LA/NC per the same hint's own "avoid collisions" instruction.
3. **`runtime/` not materialized** — git does not track empty directories; LA1 defines it as reserved, materialized by the first atom that delivers a binding.
4. **status.yaml notes mirror STATUS.md strictly** — ATOM-001's entry carries its last STATUS.md note (redelivery), not the later acceptance recorded only in git history; SM4 makes STATUS.md the single rebuild source, so the index must not know more than its source.
5. **RB6 closure sequence** — the ordered L7 checklist (run-log → workspace → STATUS → status.yaml → commit → push) is not demanded verbatim by §3.4 but is the minimal operational glue between RB and SM that ATOM-004 (orchestration) would otherwise have to invent.

## Deviations & Known Limitations
- S5 is borderline (see self-check row). If Verify reads at 200 wpm, core is ~13 min.
- The document's nested tables inside list items trip a common markdown-lint rule (MD032); the prior constitutional documents use the same construction, so consistency won over lint.
- No validator scripts shipped (Appendix A declares them future products) — conformance is checkable by the greps recorded here.

## Cleanup command for the human (INPUT §3.4)
The root `.DS_Store` is tracked from before `.gitignore` existed (RB5). Run:
`git rm --cached .DS_Store` — then include it in the next closure commit. (The `.DS_Store` files under `products/` were never tracked and are now ignored.)

## Handoff
Verification mode: independent + human. Verify receives: DoD (INPUT.md §5) + deliverable files + the two reference standards the DoD cites (ATOM-SPEC, FEV-PROTOCOL). Envelope calibration per BC2/BC3: blind package ≈ 92 KB ≈ ~31k input tokens → envelope ~70k tokens, charged to parent per VP5.
