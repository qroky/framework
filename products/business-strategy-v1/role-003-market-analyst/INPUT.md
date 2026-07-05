---
atom: ROLE-003
product: Role spec market-analyst (roles/market-analyst.md)
parent: RPF Business Strategy v1 (ATOM-006)
formulated_by: ATOM-006 orchestrator (formulating-agent duties per LP5), 2026-07-05
verification: self
maturity_target: draft
instantiation: subagent
model_tier: M — templated role spec against ATOM-SPEC §6.3 (executed inline at session tier L; upward substitution logged)
budget: ~2k tokens
recursion_allowance: 0
---

# ROLE-003 — Input Specification

## 1. Product Identity
| Field | Value |
| :---- | :---- |
| Product | `roles/market-analyst.md` |
| Atom ID | ROLE-003 |
| Parent product | RPF Business Strategy v1 |
| Executor role | framework-architect (exists — F2 satisfied) |
| Input product(s) | ATOM-SPEC §6.3 ROLE template; ATOM-006 INPUT §3.5 (segments discipline), §3.9 (honesty); `roles/venture-strategist.md` as sibling reference |
| Consumer(s) | ATOM-009 (segments), ATOM-013 (metrics) — pending executor atoms per F2 |
| Maturity target | draft |
| Gates | none — trigger gates only |
| Instantiation | subagent |
| Verification mode | self — low criticality, reversible, internal; roles are hardened by use (F2); ROLE-001 precedent |
| Budget envelope | ~2k tokens |
| Recursion-depth allowance | 0 |

## 2. Job To Be Done
Give the analysis atoms an executor identity: an analyst who maps segments by jobs-to-be-done, scores them against an accepted checklist, and designs measurement systems — hypotheses labeled as hypotheses.

**Consumers:** ATOM-009 and ATOM-013; future analysis atoms of the venture.

## 3. Context — Decisions Already Made
ATOM-006 INPUT §3.5: segment by jobs with client success criteria, demographic cut secondary; attractiveness factors checklist fixed. §3.9 honesty rule. ≤60 lines.

## 4. Deliverable
`roles/market-analyst.md` per the ATOM-SPEC §6.3 template.

## 5. Definition of Done
**Hard criteria:**
- H1. File exists at `roles/market-analyst.md`; conforms to §6.3 (frontmatter `name`+`description`; sections Identity, Capabilities, Method Defaults, Escalation Posture, Provenance). Check: grep for the five headings + 2 frontmatter keys.
- H2. ≤60 lines total. Check: `wc -l`.
- H3. Provenance table records creation by ROLE-003, 2026-07-05. Check: grep.

**Soft criteria:**
- S1. The role treats segment jobs as hypotheses to state explicitly, never as facts (§3.5) — judge: executor self-review (mode `self`).

**Maturity target:** draft. Do not gold-plate.

## 6. Method Hints (non-binding)
Mirror the sibling role's register; second person; concrete capabilities.

## 7. Escalation
E1–E7 per ATOM-SPEC §5.7. Gates: none — trigger gates only. Otherwise execute.
