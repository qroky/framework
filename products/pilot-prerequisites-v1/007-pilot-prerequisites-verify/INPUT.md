---
atom: ATOM-007-VERIFY
product: VERDICT.md on ATOM-007 (parent — the whole Pilot Prerequisites tree)
parent: Pilot Prerequisites v1
formulated_by: formulating agent (launch session), 2026-07-07
verification: self
maturity_target: draft
instantiation: subagent (fresh context — VP4)
model_tier: L (MT3/MT4; INFO-008 rule 3)
budget: ~120k tokens (slim package ~22k read ×3.5 + 40k, ≥25% margin per VP20)
recursion_allowance: 0
---

# ATOM-007-VERIFY — Input Specification (slim blind package, VP20)

You are the blind Verify atom of the PARENT: you judge whether the tree as a
whole meets the parent's DoD — not re-verifying the children (each already
carries an accept-r1 blind verdict) but checking the parent's own claims:
completeness, the RESULT's aggregation arithmetic, the fold-back evidence, and
the soft criteria S1–S4. Self-contained: do NOT read framework documents or
any child's INPUT/STATUS/workspace. Round: **1**. Returns: **0**.

## 1. Job
Re-run the parent's hard criteria H1–H6; recompute the RESULT frontmatter
arithmetic; judge S1–S4 (S5 is the human's, defer); write `VERDICT.md`
(accept / return-with-closed-fix-list) into
`products/pilot-prerequisites-v1/007-pilot-prerequisites-verify/`.

## 2. Files you may read (complete list)
1. `products/pilot-prerequisites-v1/007-pilot-prerequisites/RESULT.md` (the judged delivery)
2. `products/pilot-prerequisites-v1/007-pilot-prerequisites/PLAN.md` (map + OD4 + addenda)
3. `products/pilot-prerequisites-v1/007-pilot-prerequisites/INPUT.md` §4–§5 (the DoD — the law)
4. Deliverable presence + spot-reads: everything under `071-setup-kit/setup/`, `072-telemetry-showcase/{telemetry,consent,showcase}/`, `077-intake-protocol/intake/`
5. `007-synth/SYNTHESIS.md` (H6: §6.2 shape, SY9 coverage, X-classification)
6. The four child VERDICTs (verdict lines + findings sections only): `071-setup-kit-verify/VERDICT.md`, `072-telemetry-showcase-verify/VERDICT.md`, `077-intake-protocol-verify/VERDICT.md`, `078-fix-round-verify/VERDICT.md`
7. `products/pilot-prerequisites-v1/status.yaml` (the EC6 counters the RESULT aggregates)
8. The four lens `LENS-VERDICT.md` files (answer lines + SY9 sections only — for S4)
Instruments: ls, wc, grep, diff, arithmetic. No sandbox runs needed — the
child verifies already re-ran the scripts; your job is the parent layer.

## 3. Criteria (verbatim from the parent DoD; adapt evidence to the parent layer)
**Hard:**
- H1. Every §4 deliverable exists at the paths the plan names; the plan carries
  the perspective map with the four lenses and the OD4 arithmetic. Check: ls + read.
- H2. The timed dry-run transcript exists and shows ≤15 min / zero technical
  questions (evidence: transcript file + 071/078 verdicts). Check: file + verdicts.
- H3. Telemetry whitelist enforcement + negative test evidenced (072/078
  verdicts + files). Check: read.
- H4. Consent RO/RU exist, substance-identical to master, deletion fill-in
  field (072/078 verdicts + files). Check: read.
- H5. Cost-line, TEAM-summary AND narrative specs derive from named fields;
  worked examples exist, generated from real repo data. Check: files.
- H6. SYNTHESIS.md per §6.2 with SY9 per-lens coverage and every
  X-contradiction classified; the parent RESULT carries FB4 fold-back evidence
  and the D7 subtree fields (`total_descendants`, `max_depth_reached`,
  `subtree_cost` + four-type breakdown). **Recompute the frontmatter numbers
  from status.yaml's EC6 counters** — descendant count, breakdown sums, tier
  shares; a wrong number is a blocking finding. Check: arithmetic.
**Soft (you judge; S5 deferred to human at G2):**
- S1. Machinery fully hidden across founder-facing artifacts (child S-verdicts
  + your own jargon spot-grep on the RO/RU files).
- S2. The intake guide genuinely derives goals from values (077 verdict + your
  own read of derivation.md).
- S3. The cost line is honest — checkstop on the placeholder rate actually in
  the render code; governance overhead visible in the RESULT breakdown.
- S4. The four lenses produced at least one named contradiction each or a
  specific SY9 concurrence — no smoothed consensus (read the four SY9 sections).

## 4. Verdict discipline
`accept` only if every H passes (arithmetic included) and no blocking soft
failure; otherwise `return` with a CLOSED fix list. Findings: blocking / minor.
Write `VERDICT.md`, `STATUS.md`, `RESULT.md`, `workspace/run.log` in YOUR
folder. Do NOT touch status.yaml. Chat reply is a signal; files are the product.
