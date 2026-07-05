---
atom: ATOM-004H-VERIFY
product: Verdict on ATOM-004H (VERDICT.md)
parent: Recursive Product Framework v1
formulated_by: formulating agent (launch session, L5/VP1), 2026-07-05
verification: self
maturity_target: draft
instantiation: session
model_tier: L (verify of maturity-reviewed target — MT3/MT4)
budget: ~46k tokens (calibrated per BC2/BC3 and ORCHESTRATION EC2 — blind package ~40 KB ≈ ~13k read tokens × 3.5; charged to parent per VP5)
recursion_allowance: 0
---

# ATOM-004H-VERIFY — Input Specification (blind package per VP2)

## 1. Product Identity
| Field | Value |
| :---- | :---- |
| Product | `products/framework-v1/004h-claude-binding-verify/VERDICT.md` |
| Atom ID | ATOM-004H-VERIFY |
| Parent product | Recursive Product Framework v1 |
| Executor role | Verify agent (operating manual: `framework/FEV-PROTOCOL.md` §2) |
| Input product(s) | exactly the blind package of §3 below — nothing else |
| Consumer(s) | Formulating agent (acceptance decision, L6) |
| Maturity target | draft |
| Gates | none — trigger gates only |
| Instantiation | session (fresh isolated context, VP4) |
| Verification mode | self |
| Budget envelope | ~46k tokens (charged to parent per VP5; hard stop per O6.2) |
| Recursion-depth allowance | 0 |

## 2. Job To Be Done
Blind-verify ATOM-004H's product against its DoD (§4 below). Verdict: `accept` or `return` with findings, per FEV-PROTOCOL VP7–VP14. Round 1; returns used: 0.

## 3. Blind package — the ONLY files you may read
1. This INPUT.md.
2. Product under verification: `runtime/claude/README.md`.
3. Reference standard cited by H2/S2: `framework/ORCHESTRATION.md` (its §7 Runtime-Binding Contract is the checklist).
4. Operating manual: `framework/FEV-PROTOCOL.md` §2.
5. Product metadata cited by H4: `products/framework-v1/004h-claude-binding/RESULT.md`, `products/framework-v1/004h-claude-binding/STATUS.md`, `products/framework-v1/status.yaml`. Per VP3: self-check claims therein are claims, not evidence — re-run everything yourself.

Prohibited (VP2): the target atom's `workspace/`, its `INPUT.md` sections other than the DoD quoted below, any other atom's folder, launch files, git history (except `git status --porcelain framework/` needed to check H3), and any executor reasoning beyond the RESULT.md admitted above.

Note: `products/framework-v1/status.yaml` contains an entry for ATOM-004H-VERIFY (this atom), written by the formulating agent per SM3 — not part of the product under verification; for H4 judge only that ATOM-004H's entry is present and current.

## 4. The DoD you verify against (ATOM-004H INPUT §5, verbatim)
**Hard:** H1 file exists ≤200 lines. H2 covers every item of the ORCHESTRATION runtime-binding contract (checklist correspondence detectable). H3 does not modify any file under `framework/`. H4 `RESULT.md` + `STATUS.md` delivered; status.yaml updated.
**Soft (judge: Verify):** S1 a newcomer with this runtime installed can execute a launch file end-to-end using only this README. S2 no contradiction with ORCHESTRATION; the tier mapping is concrete and current. S3 honest about limitations (what the runtime does not yet enforce).
**Maturity target:** reviewed.

## 5. Definition of Done (for this Verify atom)
**Hard:** V-H1. `VERDICT.md` exists at this folder's root, conforming to the FEV-PROTOCOL §5.1 template. V-H2. Every hard criterion H1–H4 has an evidence row with the actual check run and raw output. V-H3. Every soft criterion S1–S3 has a finding or a criterion-specific "no findings" justification (VP10).
**Soft (judge: self):** V-S1. Findings, if any, conform to VP11.

## 6. Method Hints (non-binding)
For H2, extract the six RC2 items from ORCHESTRATION §7 and check each is covered in the README with detectable correspondence. For H3, `git status --porcelain framework/` (empty = pass) — since delivery happened without an intervening commit, uncommitted framework/ changes would show. Be adversarial on S2: check the README's rule citations against ORCHESTRATION; check the tier mapping names concrete models and a date. For S1, walk both paths (interactive §1, headless §6) as a newcomer would.

## 7. Escalation
Triggers E1–E7 of ATOM-SPEC §5.7. Gates: none. Otherwise: do not ask for permission. Execute, then write your own STATUS.md, workspace/run.log, and RESULT.md per ATOM-SPEC obligations (L10).
