---
atom: ATOM-003-VERIFY
product: Verdict on ATOM-003 (VERDICT.md)
parent: Recursive Product Framework v1
formulated_by: formulating agent (launch session, L5/VP1), 2026-07-05
verification: self
maturity_target: draft
instantiation: session
budget: ~70k tokens (calibrated per REPO-STRUCTURE BC2/BC3 — blind package ~92 KB ≈ ~31k input tokens + working margin; charged to parent per VP5)
recursion_allowance: 0
---

# ATOM-003-VERIFY — Input Specification (blind package per VP2)

## 1. Product Identity
| Field | Value |
| :---- | :---- |
| Product | `products/framework-v1/003-repo-structure-verify/VERDICT.md` |
| Atom ID | ATOM-003-VERIFY |
| Parent product | Recursive Product Framework v1 |
| Executor role | Verify agent (operating manual: `framework/FEV-PROTOCOL.md` §2) |
| Input product(s) | exactly the blind package of §3 below — nothing else |
| Consumer(s) | Formulating agent (acceptance decision, L6); the human (sign-off, VP18) |
| Maturity target | draft |
| Gates | none — trigger gates only |
| Instantiation | session (fresh isolated context, VP4) |
| Verification mode | self |
| Budget envelope | ~70k tokens (charged to parent per VP5; hard stop per O6.2) |
| Recursion-depth allowance | 0 |

## 2. Job To Be Done
Blind-verify ATOM-003's product against its DoD (§4 below). Verdict: `accept` or `return` with findings, per FEV-PROTOCOL VP7–VP14. Round 1; returns used: 0.

## 3. Blind package — the ONLY files you may read
1. This INPUT.md.
2. Product under verification: `framework/REPO-STRUCTURE.md`.
3. Product (seed files, part of the product per the DoD): `roles/humans/ghenadie.md`; `knowledge/precedent/remote-bus-push-required.md`; `knowledge/precedent/verify-envelope-calibration.md`; `products/framework-v1/status.yaml`; `.gitignore` (repository root).
4. Product metadata cited by H7: `products/framework-v1/003-repo-structure/RESULT.md`, `products/framework-v1/003-repo-structure/STATUS.md`. Per VP3: executor self-check claims therein are claims, not evidence — re-run everything yourself.
5. Reference standards cited by H6 and S3: `framework/ATOM-SPEC.md`, `framework/FEV-PROTOCOL.md`.

Prohibited (VP2): the target atom's `workspace/`, its `INPUT.md` sections other than the DoD quoted below, any other atom's folder, launch files, git history, and any executor reasoning beyond the RESULT.md admitted above.

Note on the blind package's own environment: `products/framework-v1/status.yaml` may contain an entry for ATOM-003-VERIFY (this atom) — that entry is written by the formulating agent per SM3 and is not part of the product under verification; judge the file's schema conformance and the five backfilled entries the DoD names.

## 4. The DoD you verify against (ATOM-003 INPUT §5, verbatim)
**Hard criteria:**
- H1. `framework/REPO-STRUCTURE.md` exists; 250–700 lines including templates.
- H2. Sections covering: Layout / Naming / Knowledge layer & profiles / Human profiles / Remote bus / Status machine / Budget-calibration convention (detectable by headings).
- H3. Exactly three fenced templates (knowledge, human profile, status.yaml), each with frontmatter or schema header.
- H4. Zero platform/product names in normative text (grep: "Claude Code", "MCP", "Codex", "OpenClaw", "Hermes", "BMAD").
- H5. All seed files of §4.2 exist and conform to their own templates (ghenadie.md, 2 knowledge files, status.yaml, .gitignore).
- H6. Zero contradictions with ATOM-SPEC and FEV-PROTOCOL; every cited rule id resolves.
- H7. `RESULT.md` with cost block; `STATUS.md` last state `delivered`.

**Soft criteria (judge: Verify agent unless noted):**
- S1. A fresh atom, given only the constitution trio (ATOM-SPEC, FEV-PROTOCOL, REPO-STRUCTURE), can place every file it produces without asking.
- S2. Every normative statement testable; no aspirational language.
- S3. Tightens but never relaxes the two prior constitutional documents.
- S4. The human profile and the two knowledge seeds read as immediately usable — judge: human.
- S5. Core (excluding templates) readable in ≤ 10 minutes.

**Maturity target:** reviewed. Do not gold-plate.

(The seed files of "§4.2" are: `roles/humans/ghenadie.md`; exactly 2 precedent-type knowledge files — the remote-bus lesson and the verify-envelope calibration lesson; `products/framework-v1/status.yaml` backfilled for ROLE-001, ATOM-001, ATOM-002, ATOM-002-VERIFY, ATOM-003; `.gitignore` at repo root.)

## 5. Definition of Done (for this Verify atom)
**Hard:** V-H1. `VERDICT.md` exists at this folder's root, conforming to the FEV-PROTOCOL §5.1 template (frontmatter + all sections). V-H2. Every hard criterion H1–H7 has an evidence row with the actual check run and raw output. V-H3. Every soft criterion judged by you has a finding or a criterion-specific "no findings" justification (VP10); S4 marked deferred to human (VP9).
**Soft (judge: self):** V-S1. Findings, if any, conform to VP11 (severity + citation + evidence).

## 6. Method Hints (non-binding)
Run hard checks by script. Be adversarial on S2/S3: hunt for aspirational phrasing and for any statement that relaxes an ATOM-SPEC or FEV-PROTOCOL obligation. For H5, check each seed against the template fenced inside REPO-STRUCTURE.md itself. For H6, extract every cited rule id by grep and resolve each against the two standards.

## 7. Escalation
Triggers E1–E7 of ATOM-SPEC §5.7. Gates: none. Otherwise: do not ask for permission. Execute, then write your own STATUS.md, workspace/run.log, and RESULT.md per ATOM-SPEC obligations (L10).
