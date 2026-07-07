---
atom: ATOM-078-VERIFY
product: VERDICT.md on ATOM-078 (fix-round over 071/072 artifacts)
parent: Pilot Prerequisites v1 (ATOM-007)
formulated_by: formulating agent (launch session), 2026-07-07
verification: self
maturity_target: draft
instantiation: subagent (fresh context — VP4)
model_tier: L (MT3/MT4; INFO-008 rule 3)
budget: ~110k tokens (slim package ~20k read ×3.5 + 40k, ≥25% margin per VP20)
recursion_allowance: 0
---

# ATOM-078-VERIFY — Input Specification (slim blind package, VP20)

You are a blind Verify atom. Self-contained: do NOT read framework documents,
the target's `INPUT.md`, `STATUS.md`, `workspace/` or run.log. From the
target's `RESULT.md` read ONLY the H1 coverage table. Round: **1**. Returns: **0**.

## 1. Job
The target was a fix-round: it edited the ATOM-071/072 artifacts per a
22-row register, wired two answered value gates, and added a narrative spec.
Re-run its hard criteria, check REGRESSION (the previously-accepted criteria
of 071/072 must still hold), judge soft criteria, write `VERDICT.md`
(accept / return-with-closed-fix-list) into
`products/pilot-prerequisites-v1/078-fix-round-verify/`.

## 2. Files you may read (complete list)
1. All files under `products/pilot-prerequisites-v1/071-setup-kit/setup/` (7 files)
2. All files under `products/pilot-prerequisites-v1/072-telemetry-showcase/telemetry/`, `.../consent/`, `.../showcase/`
3. `products/pilot-prerequisites-v1/078-fix-round/RESULT.md` — ONLY the H1 coverage table
4. `products/pilot-prerequisites-v1/078-fix-round/workspace/pilot-design-amendment-proposal.md` (existence + read)
5. **References (the law):** `products/pilot-prerequisites-v1/007-synth/SYNTHESIS.md` — ONLY the «Fix-priority register» section (22 rows); `decisions/GATE-018-atom-007-synthesis-e8-gate.md` (E8-1/E8-2 verbatim); `decisions/INFO-009-field-test-lesson-5-run-transparency.md` (narrative spec law)
Instruments: ls, wc, grep, diff, `bash -n`; re-running the negative test,
OFF-switch test, dry-run and render scripts in a /private/tmp sandbox is
allowed and encouraged (no network, no real pushes).

## 3. Criteria (verbatim from the target's DoD + regression)
**Hard:**
- H1. Every register row marked «исполнитель» maps to a real change (spot-check
  at least rows №1, №2, №4, №5, №6, №20 against the artifacts); CEO-choice rows
  (№3, №5-runbook, №9) present as labeled «вариант A / вариант B» — nothing
  chosen for the human. Check: coverage table + artifacts.
- H2. `bash -n` green on every script; negative-test + OFF-switch re-run green;
  scheduler install (bootstrap) idempotent and dry-runnable. Check: run them.
- H3. Founder-facing jargon grep (`grep -iE "DoD|атом|atom|verify|INPUT|гейт|gate"`)
  zero-hit on all RO/RU founder files (QUICKSTART, TIERS, CONSENT; path/code
  spans excepted). Check: grep.
- H4. E8 wiring quotes GATE-018 semantics exactly: consent opt-in item «одну
  простую фразу о построенном…»; primary-duty + 2-of-5-days breach protocol;
  TEAM summary local-only by default, content line gated on the opt-in flag;
  no INPUT.md reads in the perimeter-crossing render path. Check: grep + read
  the render code path.
- H5. `showcase/narrative-spec.md` exists (spawn-brief + debrief sections
  mapped to named record fields; ≤5% subtree_cost budget rule; levels 1/2/3
  with piercing events); render produces a debrief worked example from this
  repo's real records. Check: file + re-run render.
- H6 (regression). ATOM-071's dry run still exits 0 with elapsed ≤15 min;
  ATOM-072's whitelist still equals the closed list (STATUS.md, RESULT.md cost
  blocks, run.log, status.yaml, verify verdicts). Check: re-run + read.
**Soft (you judge):**
- S1. Edits are minimal — no drive-by rewording beyond the register; name any
  unexplained diff you notice against the register's scope.
- S2. The debrief worked example reads like a story a founder would actually
  read — name any mechanics leak.

## 4. Verdict discipline
`accept` only if every H passes your own re-run and no blocking soft failure;
otherwise `return` with a CLOSED fix list (file, line, what, why). Findings:
blocking / minor. Write `VERDICT.md`, `STATUS.md`, `RESULT.md`,
`workspace/run.log` in YOUR folder. Do NOT touch status.yaml. Chat reply is a
signal; files are the product.
