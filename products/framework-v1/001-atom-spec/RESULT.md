---
atom: ATOM-001
product: Atom Specification v1 (framework/ATOM-SPEC.md)
status: delivered
maturity_claimed: draft (target reviewed — pending independent Verify + human sign-off)
cost:
  units_in: ~35000        # estimated; includes input spec + harness context
  units_out: ~13000       # estimated; product + metadata files
  unit: tokens
  wall_time: ~6m
  executor: claude-fable-5 (fresh session, sole context = INPUT.md)
  sub_atoms_spawned: 0
  sub_atoms_cost: 0
---

# RESULT — ATOM-001

## Summary
Produced `framework/ATOM-SPEC.md` — the normative definition of the Atom: formula, 15 mandatory spec fields, the five-phase execution cycle with Formulate-time obligations (role resolution, risk-based verification depth), a four-level maturity scale, the full lifecycle including the blind-Verify interface, ten obligation families (file bus, status, run log, cost, spawn justification, budget hard stop, escalation triggers E1–E7, human products/gates, executor decisions, workspace hygiene), and three ready-to-copy templates. Repository skeleton created per INPUT §4. Well under budget envelope (~48k of 60k total projected, incl. input context).

## Deliverables
| File | Purpose |
| :---- | :---- |
| framework/ATOM-SPEC.md | The product — Atom Specification v1 |
| products/framework-v1/001-atom-spec/INPUT.md | Copy of the input specification |
| products/framework-v1/001-atom-spec/STATUS.md | Live status (last state: delivered) |
| products/framework-v1/001-atom-spec/workspace/run.log | Append-only run log |
| decisions/, roles/, knowledge/ | Empty skeleton directories per INPUT §4 |

## DoD Self-Check
| Criterion | Result | Evidence |
| :---- | :---- | :---- |
| H1 file exists, 400–1200 lines | met | `wc -l` = 417 (after return-1 rework) |
| H2 all six §4 sections by headings | met | grep '^## ': Atom Definition / The Execution Cycle / Maturity Levels / Atom Lifecycle / Obligations / Templates |
| H3 exactly three fenced templates, YAML frontmatter | met | `grep -c '^```'` = 6 (3 open + 3 close); each template opens with `---` YAML block |
| H4 zero platform/product names | met | grep -c -E 'Claude Code\|MCP\|Codex\|OpenClaw\|Hermes\|BMAD' = 0 (in the entire file, incl. appendix) |
| H5 RESULT.md with cost block; STATUS last state delivered | met | this file; STATUS.md final line = delivered |
| S1 fresh agent could execute from spec + INPUT alone | self-reviewed | normal path covered end-to-end: cycle entry/exit rules, lifecycle table, O7.2 "do not ask on normal path" |
| S2 every normative statement testable | self-reviewed | MUST/SHOULD/MAY throughout; no "as appropriate"/"strive to"; SHOULD requires logged deviation (R0.1) |
| S3 no §3 decision contradicted or reopened | self-reviewed | §3.1–3.11 mapped 1:1 into §§1–5; §3.12 touched only in Appendix A + RS1 as permitted |
| S4 core readable ≤ 15 min | self-reviewed | ~290 lines excluding templates, mostly tables |
| S5 scale invariance, no special cases | self-reviewed | A5 rule + informative 3-scale example table (paragraph / product line / sensor-verified physical action) |

## Decisions Made by Executor
1. **Maturity semantics** (input gave only example names): `draft`=self-checked, `reviewed`=blind-verified, `validated`=reviewed+proven in consumption, `production`=validated+human risk acceptance. Maturity can rise without re-execution (M3) — keeps the scale cheap and reversible.
2. **STATUS.md format**: append-only lines `timestamp state — note`; last line = current state. Makes H5-style checks trivial and matches the append-only ethos.
3. **Run log default name** `workspace/run.log`, minimum event list in O3.2; repository-structure product may rename/extend.
4. **Cost block units**: generalized `units_in/out + unit` field so non-LM executors (human, machine) fit without schema change; tokens remain the LM default.
5. **Verify-atom interface only** (L10): blind input, accept/return, 2-return limit — detailed protocol left to the FEV product per Method Hints.
6. **M4 added** (consumer may not consume below required maturity) — implied by maturity levels having consequences; simplest closing rule, reversible.
7. **Rule numbering scheme** (R/A/F/C/U/RS/CL/K/V/M/L/O/E/T) for citability by future atoms and Verify findings.

## Verify Return 1 — Fixes Applied (05.07.2026)

1. §6.1 INPUT template: added rows for Input product(s), Consumer(s), Maturity target, Gates to the Product Identity table — all 15 mandatory fields of §1.3 now have a designated slot.
2. M1 reworded to one unambiguous sentence: mode MUST be ≥ the maturity minimum; above the minimum requires the F3 override justification.

Hard criteria re-checked after rework: H1=417 lines, H3=3 fenced templates, H4=0 banned strings — all pass. Nothing else changed.

## Deviations & Known Limitations
- Cost figures are estimates: the executor has no exact token meter on this runtime; flagged as `~`. Verify may treat exact-count absence as a finding — a runtime-binding concern, not a spec concern.
- `maturity_claimed` is `draft` by definition (M3): `reviewed` can only be conferred by the independent Verify atom, which does not exist yet (ATOM-002 defines its protocol; a Verify atom for this product must be formulated by the parent).

## Handoff
Verification mode: `independent + human`. Verify receives: INPUT.md §5 (DoD) + `framework/ATOM-SPEC.md` only. Human accepts final.
