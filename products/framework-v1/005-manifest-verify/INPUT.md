---
atom: ATOM-005-VERIFY
product: VERDICT.md on ATOM-005 (Manifest & public face)
parent: Recursive Product Framework v1
formulated_by: formulating agent (launch session), 2026-07-05
verification: self
maturity_target: draft
instantiation: session
model_tier: L (judgment-heavy verification of a positioning-critical public product — MT3/MT4)
budget: ~185k tokens (blind-package read estimate ~41k ×3.5 + 40k runtime constant, per launch preamble and EC2)
recursion_allowance: 0
---

# ATOM-005-VERIFY — Input Specification (blind package per VP2)

You are a blind Verify atom under `framework/FEV-PROTOCOL.md` §2. You receive ONLY this package. You MUST NOT read the target atom's `workspace/`, run log, launch files, or any executor reasoning. Round: **1**. Returns used so far: **0**.

## 1. Product Identity
| Field | Value |
| :---- | :---- |
| Product | `VERDICT.md` at `products/framework-v1/005-manifest-verify/` |
| Atom ID | ATOM-005-VERIFY |
| Parent product | Recursive Product Framework v1 |
| Executor role | framework-architect (`roles/framework-architect.md`) |
| Input product(s) | the blind package listed in §3 |
| Consumer(s) | The formulating agent (accept/return routing per L6); the human risk-taker (sign-off per VP18) |
| Maturity target | draft |
| Gates | none — trigger gates only |
| Instantiation | session (fresh isolated context, VP4) |
| Verification mode | self (a Verify atom's own product is not re-verified) |
| Budget envelope | ~185k tokens |
| Recursion-depth allowance | 0 |

## 2. Job To Be Done
Deliver an accept/return verdict on ATOM-005's product per FEV-PROTOCOL §2: re-run every hard criterion yourself (VP3 — the executor's self-check is a claim, not evidence), judge every soft criterion assigned to the Verify agent with per-criterion findings or specific justifications (VP10), defer human-judged criteria (VP9), and write `VERDICT.md` per the FEV-PROTOCOL §5.1 template, with a closed minimal fix list if returning (VP14).

## 3. Blind package (the only files you may read)
1. **Target DoD** — §5 of this document, verbatim from the target atom's `INPUT.md`.
2. **Deliverables under verification:** `MANIFEST.md`, `README.md`, `LICENSE`, `decisions/RISK-002-open-core-boundary.md` (all repo-root-relative), plus `products/framework-v1/005-manifest/RESULT.md` and `products/framework-v1/005-manifest/STATUS.md` (H7 references them).
3. **Reference standards the criteria cite:** `framework/ATOM-SPEC.md`, `framework/FEV-PROTOCOL.md`, `framework/REPO-STRUCTURE.md`, `framework/ORCHESTRATION.md` (H6 contradiction check; FEV-PROTOCOL §5.2 for the H5 template; §5.1 for your own verdict template); `decisions/GATE-004-atom-003-acceptance.md`, `decisions/GATE-005-atom-004-acceptance.md`, `knowledge/precedent/verify-envelope-calibration.md` (H6 number verification). For H6 factual-claim checks you MAY additionally run non-content commands over the repository (`ls`, `wc`, `grep` counts) as instruments; do not read file contents beyond this list.

## 4. Deliverable
`products/framework-v1/005-manifest-verify/VERDICT.md` per FEV-PROTOCOL §5.1, plus your own `STATUS.md`, `RESULT.md`, and `workspace/run.log` per ATOM-SPEC obligations.

## 5. Definition of Done of the TARGET atom (verbatim — verify against this)
**Hard criteria:**
- H1. All four files exist at the exact paths above.
- H2. `MANIFEST.md` ≤ 1,100 words excluding headings (two pages); `README.md` ≤ 60 lines.
- H3. `LICENSE` contains the Apache License 2.0 canonical text (detectable: "Apache License" + "Version 2.0" + §4 redistribution clause present).
- H4. Zero platform/product names in MANIFEST and README (grep: "Claude", "Claude Code", "MCP", "Codex", "OpenClaw", "Hermes", "BMAD") — runtime specifics live behind the quickstart pointer, not on the public face. The name used is exactly "RPF" (H4b: no other coined name appears).
- H5. `decisions/RISK-002-open-core-boundary.md` conforms to the decision-record template (frontmatter keys + 4 sections).
- H6. Zero contradictions with the four framework documents; every factual claim in MANIFEST is verifiable inside the repo (S-checked, but hard-checkable subset: every number cited matches repo state).
- H7. `RESULT.md` with cost block; `STATUS.md` last state `delivered`; status.yaml updated.

**Soft criteria:**
- S1. A non-technical founder reading only MANIFEST.md for 10 minutes can answer: what is this, what would I do with it, what do I keep doing myself, what is free — judge: human.
- S2. No hype vocabulary ("revolutionary", "game-changing", "10x"); confidence through specifics — judge: Verify.
- S3. The limitations section reads as engineering honesty, not disclaimer boilerplate — judge: Verify.
- S4. README routes a reader to the right next document in under a minute — judge: Verify.

**Maturity target:** reviewed. Do not gold-plate.

*Note (for the "exact paths above" of H1, restated from the target INPUT §4): `MANIFEST.md` (root), `README.md` (root), `LICENSE` (root), `decisions/RISK-002-open-core-boundary.md`.*

## 6. Method Hints (non-binding)
Run hard checks as commands and quote raw output. For H6, check the MANIFEST's factual claims one by one against the listed references and repo state. S1 is human-judged: mark it deferred (VP9). Findings need all three fields (VP11): severity, citation, evidence.

## 7. Escalation
Stop and escalate (one consolidated question set) on triggers E1–E7 of ATOM-SPEC §5.7. Gates: none — trigger gates only. Otherwise: do not ask for permission on the normal path. Execute.
