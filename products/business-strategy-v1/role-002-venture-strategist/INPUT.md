---
atom: ROLE-002
product: Role spec venture-strategist (roles/venture-strategist.md)
parent: RPF Business Strategy v1 (ATOM-006)
formulated_by: ATOM-006 orchestrator (formulating-agent duties per LP5), 2026-07-05
verification: self
maturity_target: draft
instantiation: subagent
model_tier: M — templated role spec against ATOM-SPEC §6.3 (executed inline at session tier L; upward substitution logged)
budget: ~2k tokens
recursion_allowance: 0
---

# ROLE-002 — Input Specification

## 1. Product Identity
| Field | Value |
| :---- | :---- |
| Product | `roles/venture-strategist.md` |
| Atom ID | ROLE-002 |
| Parent product | RPF Business Strategy v1 |
| Executor role | framework-architect (exists — F2 satisfied) |
| Input product(s) | ATOM-SPEC §6.3 ROLE template; ATOM-006 INPUT §2–§3 (the domain the role must serve); `roles/framework-architect.md` as form reference |
| Consumer(s) | ATOM-008, ATOM-010–ATOM-012, ATOM-014, ATOM-015 (pending executor atoms per F2) |
| Maturity target | draft |
| Gates | none — trigger gates only |
| Instantiation | subagent |
| Verification mode | self — low criticality, reversible, internal; roles are hardened by use (F2); ROLE-001 precedent |
| Budget envelope | ~2k tokens |
| Recursion-depth allowance | 0 |

## 2. Job To Be Done
Give the strategy atoms an executor identity: a business strategist who turns accepted decisions and evidence into decision-ready strategy products — options compared, rejections recorded, no unsourced market claims.

**Consumers:** the pending strategy-execution atoms listed above; future business products of the venture.

## 3. Context — Decisions Already Made
ATOM-006 INPUT §3 (segments discipline, channels hypotheses, pricing inputs, honesty rule §3.9) defines what this role must be competent at. ≤60 lines per ATOM-006 INPUT §1.

## 4. Deliverable
`roles/venture-strategist.md` per the ATOM-SPEC §6.3 template.

## 5. Definition of Done
**Hard criteria:**
- H1. File exists at `roles/venture-strategist.md`; conforms to §6.3 (frontmatter `name`+`description`; sections Identity, Capabilities, Method Defaults, Escalation Posture, Provenance). Check: grep for the five headings + 2 frontmatter keys.
- H2. ≤60 lines total. Check: `wc -l`.
- H3. Provenance table records creation by ROLE-002, 2026-07-05. Check: grep.

**Soft criteria:**
- S1. The role bakes in the §3.9 honesty discipline (sourced / marked-assumption / human-answered) as a method default — judge: executor self-review (mode `self`).

**Maturity target:** draft. Do not gold-plate.

## 6. Method Hints (non-binding)
Mirror the register of `roles/framework-architect.md`; second person; concrete capabilities.

## 7. Escalation
E1–E7 per ATOM-SPEC §5.7. Gates: none — trigger gates only. Otherwise execute.
