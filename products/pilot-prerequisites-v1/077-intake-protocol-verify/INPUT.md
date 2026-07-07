---
atom: ATOM-077-VERIFY
product: VERDICT.md on ATOM-077 (intake protocol)
parent: Pilot Prerequisites v1 (ATOM-007)
formulated_by: formulating agent (launch session), 2026-07-07
verification: self
maturity_target: draft
instantiation: subagent (fresh context — VP4)
model_tier: L (MT3/MT4; INFO-008 rule 3)
budget: ~90k tokens (slim package ~13k read ×3.5 + 40k, ≥25% margin per VP20)
recursion_allowance: 0
---

# ATOM-077-VERIFY — Input Specification (slim blind package, VP20)

You are a blind Verify atom. Self-contained package: do NOT read framework
documents, the target's `INPUT.md`, `STATUS.md`, `workspace/` or run.log.
From the target's `RESULT.md` read ONLY the DoD check table and the H3
substance table. Round: **1**. Returns used: **0**.

## 1. Job
Re-run every hard criterion; judge soft criteria with per-criterion findings;
write `VERDICT.md` (accept / return-with-closed-fix-list) into
`products/pilot-prerequisites-v1/077-intake-protocol-verify/`.

## 2. Files you may read (complete list)
1. `products/pilot-prerequisites-v1/077-intake-protocol/intake/INTAKE-GUIDE.md`
2. `.../intake/mission-template.ro.md`
3. `.../intake/mission-template.ru.md`
4. `.../intake/derivation.md`
5. `.../intake/field-test-lessons.md`
6. `products/pilot-prerequisites-v1/077-intake-protocol/RESULT.md` — DoD table + H3 table only
7. **References (the law):** `decisions/INFO-007-field-test-lesson-2-team-visibility.md` and `decisions/INFO-009-field-test-lesson-5-run-transparency.md` (verbatim lesson texts), `decisions/GATE-018-atom-007-synthesis-e8-gate.md` (the «двух достаточно» closure + E8 answers)
Instruments: ls, wc, grep, diff over these files.

## 3. Definition of Done of the TARGET (verbatim)
**Hard:**
- H1. All 5 files exist at the named paths. Check: ls.
- H2. Jargon grep zero-hit on the two mission templates (RO/RU): pattern
  `grep -iE "DoD|атом|atom|verify|INPUT|гейт|gate"` (machinery words in file
  paths/code spans excepted, listed in RESULT). Check: grep.
- H3. RO/RU templates substance-identical (same sections, same promises) —
  spot-check the target's H3 table against the files. Check: table + files.
- H4. The guide contains: the detail-level question (1/2/3, default 2), a
  cost-plan passage with a worked auto-escalation example, the as-is
  inventory branch for transformational cases, a TEAM-summary expectation
  line. Check: grep/read.
- H5. field-test-lessons.md quotes both lessons verbatim from the two INFO
  records and the GATE-018 closure. Check: diff against the references.
**Soft (you judge):**
- S1. The derivation method genuinely derives goals from values — apply its
  own disguised-task-list test to the guide's worked example; name the line
  if it fails.
- S2. A founder reading the RO/RU templates feels invited, not processed —
  name any processing-tone passage.

## 4. Verdict discipline
`accept` only if every H passes your own re-run and no blocking soft failure;
otherwise `return` with a CLOSED fix list (file, line, what, why). Findings:
blocking / minor (minors listed, non-blocking). Write `VERDICT.md`,
`STATUS.md`, `RESULT.md`, `workspace/run.log` in YOUR folder. Do NOT touch
status.yaml. Chat reply is a signal; files are the product.
