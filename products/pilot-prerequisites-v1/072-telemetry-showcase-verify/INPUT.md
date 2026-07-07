---
atom: ATOM-072-VERIFY
product: VERDICT.md on ATOM-072 (telemetry + consent RO/RU + work showcase)
parent: Pilot Prerequisites v1 (ATOM-007)
formulated_by: formulating agent (launch session), 2026-07-07
verification: self
maturity_target: draft
instantiation: subagent (fresh context — VP4)
model_tier: L (MT3/MT4; INFO-008 rule 3 — Verify never below L)
budget: ~90k tokens (slim package ~14k read ×3.5 + 40k, ≥25% margin per VP20)
recursion_allowance: 0
---

# ATOM-072-VERIFY — Input Specification (slim blind package, VP20)

You are a blind Verify atom. This package is SELF-CONTAINED: do NOT read any
framework document. You MUST NOT read the target atom's `INPUT.md`, `STATUS.md`,
`workspace/` or run.log. From the target's `RESULT.md` read ONLY the DoD check
table and the H3 consent point-by-point table. Round: **1**. Returns used: **0**.

## 1. Job
Re-run every hard criterion with the literal check; judge each soft criterion
with a per-criterion finding or specific justification; write `VERDICT.md`
(accept / return-with-fix-list) into
`products/pilot-prerequisites-v1/072-telemetry-showcase-verify/`.

## 2. The files you may read (complete list — nothing else)
1. `products/pilot-prerequisites-v1/072-telemetry-showcase/telemetry/push.sh`
2. `.../telemetry/negative-test.sh`
3. `.../telemetry/negative-test-output.txt`
4. `.../consent/CONSENT.ro.md`
5. `.../consent/CONSENT.ru.md`
6. `.../showcase/cost-line-spec.md`
7. `.../showcase/team-summary-spec.md`
8. `.../showcase/render.sh`
9. `.../showcase/example-cost-line.txt`
10. `.../showcase/example-team-summary.md`
11. `products/pilot-prerequisites-v1/072-telemetry-showcase/RESULT.md` — ONLY
    the DoD check table + H3 consent table.
12. **Reference (the law the product must match):**
    `products/business-strategy-v1/pilot/pilot-design.md` — the closed
    telemetry list («Scope (accepted §3.4, closed list)» passage) and the
    consent master text section. Read those sections only.
Instruments: `ls`, `wc`, `grep`, `diff`, `bash -n`; re-running
`negative-test.sh` and `render.sh` in a sandbox under /private/tmp is allowed
and encouraged (no network, no real git push).

## 3. Definition of Done of the TARGET (verbatim — verify against this)
**Hard criteria:**
- H1. All deliverable files exist: telemetry/push.sh, negative-test.sh,
  negative-test-output.txt; consent/CONSENT.ro.md + CONSENT.ru.md;
  showcase/cost-line-spec.md, team-summary-spec.md, render.sh (or render.py),
  example-cost-line.txt, example-team-summary.md. Check: ls.
- H2. `push.sh` whitelist == pilot-design closed list, literally (STATUS.md,
  RESULT.md cost blocks, run.log, status.yaml, verify verdicts — no business
  content); negative-test output shows planted non-whitelisted files rejected.
  Check: compare against the pilot-design passage + output file; re-run the
  test if in doubt.
- H3. Consent RO and RU each contain: the 4 red lines (no turnkey production
  code, no investment guarantees, no exclusivity, no team hiring), the deletion
  clause with a fill-in date field (not prose), the open-script clause. Check:
  target's H3 table + grep the consent files yourself.
- H4. cost-line-spec maps all 5 elements (N/M/D/R/$X) to named source fields;
  team-summary-spec maps all 4 sections (roles+contributions, lens map,
  conflicts with outcomes, verify returns) to named record fields. Check: tables.
- H5. The worked examples were produced by the render script from real repo
  data. Check: re-run `render.sh` against this repo and compare output shape
  to the committed examples.
- H6. Scripts pass `bash -n`; the OFF-switch behavior (telemetry/OFF file →
  push.sh exits 0 doing nothing, saying so) is implemented. Check: read + syntax.
**Soft criteria (you judge):**
- S1. A founder reading push.sh top-to-bottom understands what leaves their
  machine — name any opaque passage.
- S2. The example TEAM summary would let a CEO see who worked, in which
  perspectives, where they argued (the INFO-007 need) — name any blind spot.
- S3. The cost line is honest — no flattering rounding; governance overhead
  visible — name any gloss.

## 4. Verdict discipline
- `accept` only if every H passes under your own re-run AND no blocking soft
  failure. Otherwise `return` with a CLOSED fix list (file, line, what, why).
- Findings taxonomy: blocking / minor; minors listed, not blocking.
- Write `VERDICT.md`, `STATUS.md`, `RESULT.md`, `workspace/run.log` in YOUR
  folder (`072-telemetry-showcase-verify/`). Do NOT touch status.yaml.
- Your chat reply is a signal only; the files are the product.
