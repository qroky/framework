---
atom: ATOM-008-VERIFY
product: VERDICT.md on ATOM-008 (products/business-strategy-v1/008-naming-verify/VERDICT.md)
parent: RPF Business Strategy v1 (ATOM-006)
formulated_by: ATOM-006 orchestrator (formulating agent of the verified atom, VP1), 2026-07-05
verification: self
maturity_target: draft
instantiation: session
model_tier: L — judgment-heavy verification of a maturity-target `reviewed` product (MT3/MT4)
budget: ~50k tokens (blind package ~3k read ×3.5 + 40k constant per knowledge/precedent/verify-envelope-calibration.md)
recursion_allowance: 0
---

# ATOM-008-VERIFY — Input Specification (blind package, VP2)

## 1. Verification round
round: 1; returns_used: 0 (VP15).

## 2. Target DoD (verbatim from ATOM-008 INPUT §5)
**Hard criteria:**
- H1. File exists at `products/business-strategy-v1/naming/naming-verdict.md`. Check: `ls`.
- H2. For each of Atomaro and Qroky: all 7 checklist points present as numbered evidence rows. Check: grep for point numbering per candidate section (2 × 7 rows).
- H3. Atomico confusion risk explicitly assessed (the flag §3.3 requires). Check: `grep -c Atomico` ≥ 1 in an assessment sentence.
- H4. Every evidence row carries a source (input §3.3, URL, or repo path, with date) or the explicit marker `assumption` / `not verifiable`. Check: grep each row for `(source:` or `assumption` or `not verifiable`.
- H5. A Verdict section with per-candidate go/hold/kill and exactly one recommendation. Check: grep `## Verdict`, `Recommendation`.

**Soft criteria:**
- S1. No invented facts: web-derived claims match the cited sources; unverifiable register states are declared, not guessed — judge: Verify agent.
- S2. The verdict is decision-ready for a non-technical founder (5-second comprehension of the recommendation) — judge: human (G1) — **deferred per VP9, do not judge**.

**Maturity target:** reviewed.

## 3. Product path(s)
- `products/business-strategy-v1/naming/naming-verdict.md` (the product)
- `products/business-strategy-v1/008-naming/RESULT.md`, `products/business-strategy-v1/008-naming/STATUS.md` (self-check claims — claims, not evidence, VP3)

## 4. Reference standards (required to run the checks)
- `framework/FEV-PROTOCOL.md` (Verify protocol §2, VERDICT.md template §5.1, finding rules VP8–VP15)
- `framework/ATOM-SPEC.md` (cycle obligations; STATUS/RESULT obligations O2, O3, O4)

## 5. Deliverable
`products/business-strategy-v1/008-naming-verify/VERDICT.md` per FEV-PROTOCOL §5.1, plus this atom's own `STATUS.md`, `RESULT.md`, and `workspace/run.log` in `products/business-strategy-v1/008-naming-verify/`.

## 6. Escalation
Verdict is exactly `accept` or `return` (VP12). S1 web spot-checks MAY use live fetches of the URLs cited in the product; if the web is unavailable, judge S1 on internal consistency and say so. Nothing else may be read beyond the files listed here (VP2).
