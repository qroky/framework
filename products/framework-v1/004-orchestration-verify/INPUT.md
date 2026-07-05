---
atom: ATOM-004-VERIFY
product: Verdict on ATOM-004 (VERDICT.md)
parent: Recursive Product Framework v1
formulated_by: formulating agent (launch session, L5/VP1), 2026-07-05
verification: self
maturity_target: draft
instantiation: session
model_tier: L (judgment-heavy verification of a constitutional document — MT3/MT4)
budget: ~132k tokens (calibrated per BC2/BC3 and ORCHESTRATION EC2 — blind package ~113 KB ≈ ~38k read tokens × 3.5; charged to parent per VP5)
recursion_allowance: 0
---

# ATOM-004-VERIFY — Input Specification (blind package per VP2)

## 1. Product Identity
| Field | Value |
| :---- | :---- |
| Product | `products/framework-v1/004-orchestration-verify/VERDICT.md` |
| Atom ID | ATOM-004-VERIFY |
| Parent product | Recursive Product Framework v1 |
| Executor role | Verify agent (operating manual: `framework/FEV-PROTOCOL.md` §2) |
| Input product(s) | exactly the blind package of §3 below — nothing else |
| Consumer(s) | Formulating agent (acceptance decision, L6); the human (sign-off, VP18) |
| Maturity target | draft |
| Gates | none — trigger gates only |
| Instantiation | session (fresh isolated context, VP4) |
| Verification mode | self |
| Budget envelope | ~132k tokens (charged to parent per VP5; hard stop per O6.2) |
| Recursion-depth allowance | 0 |

## 2. Job To Be Done
Blind-verify ATOM-004's product against its DoD (§4 below). Verdict: `accept` or `return` with findings, per FEV-PROTOCOL VP7–VP14. Round 1; returns used: 0.

## 3. Blind package — the ONLY files you may read
1. This INPUT.md.
2. Product under verification: `framework/ORCHESTRATION.md`.
3. Product metadata cited by H6: `products/framework-v1/004-orchestration/RESULT.md`, `products/framework-v1/004-orchestration/STATUS.md`, `products/framework-v1/status.yaml`. Per VP3: executor self-check claims therein are claims, not evidence — re-run everything yourself.
4. Reference standards cited by H5 and S1–S4: `framework/ATOM-SPEC.md`, `framework/FEV-PROTOCOL.md`, `framework/REPO-STRUCTURE.md`; and `ATOM-004-LAUNCH.md` (repository root) — the launch file S4 compares against.

Prohibited (VP2): the target atom's `workspace/`, its `INPUT.md` sections other than the DoD quoted below, any other atom's folder, git history, and any executor reasoning beyond the RESULT.md admitted above.

Note on the blind package's own environment: `products/framework-v1/status.yaml` contains entries for ATOM-004H and ATOM-004-VERIFY (this atom) written by the formulating agent per SM3 — they are not part of the product under verification; for H6 judge only that ATOM-004's entry is present and current.

## 4. The DoD you verify against (ATOM-004 INPUT §5, verbatim)
**Hard:** H1 file exists, 250–700 lines incl. templates. H2 all seven §4 sections detectable by headings. H3 exactly two fenced templates. H4 zero platform/product names (grep: "Claude Code", "MCP", "Codex", "OpenClaw", "Hermes", "BMAD"). H5 zero contradictions with the constitution trio; every cited rule id resolves. H6 `RESULT.md` with cost block; `STATUS.md` last state `delivered`; status.yaml updated.
**Soft (judge: Verify unless noted):** S1 a formulating agent holding only the four framework docs can plan, tier, budget, gate and launch a 3-atom product without improvising. S2 every normative statement testable. S3 tightens, never relaxes, the trio. S4 the LAUNCH template reproduces this very launch file's structure without loss — judge: Verify. S5 core readable ≤ 10 min.
**Maturity target:** reviewed. Do not gold-plate.

(The "seven §4 sections" of H2 are: Decomposition & planning / Model tiers / Budget calibration / Gate briefs / Launch protocol / Spawn & status sync / Runtime-binding contract. The "two fenced templates" of H3 are: `LAUNCH.md` and a decomposition plan.)

## 5. Definition of Done (for this Verify atom)
**Hard:** V-H1. `VERDICT.md` exists at this folder's root, conforming to the FEV-PROTOCOL §5.1 template (frontmatter + all sections). V-H2. Every hard criterion H1–H6 has an evidence row with the actual check run and raw output. V-H3. Every soft criterion S1–S5 has a finding or a criterion-specific "no findings" justification (VP10); none is deferred — all name Verify as judge.
**Soft (judge: self):** V-S1. Findings, if any, conform to VP11 (severity + citation + evidence).

## 6. Method Hints (non-binding)
Run hard checks by script (note: this platform's grep mishandles `(^|[class])` alternation groups — prefer simple patterns with trailing guards). Be adversarial on S2/S3: hunt for aspirational phrasing and for any statement that relaxes a trio obligation. For H5, extract every cited rule id and resolve each against the trio. For S4, compare the §8.1 template element by element against `ATOM-004-LAUNCH.md`: title form, preamble contents (sequence, step-0, verify-and-close, status-sync, spawn justification), INPUT delimiting, footer.

## 7. Escalation
Triggers E1–E7 of ATOM-SPEC §5.7. Gates: none. Otherwise: do not ask for permission. Execute, then write your own STATUS.md, workspace/run.log, and RESULT.md per ATOM-SPEC obligations (L10).
