---
atom: ATOM-009
product: Jobs-based segment map (products/business-strategy-v1/segments/segment-map.md)
parent: RPF Business Strategy v1 (ATOM-006)
formulated_by: ATOM-006 orchestrator (formulating-agent duties per LP5), 2026-07-05
verification: self
maturity_target: draft
instantiation: subagent
model_tier: M — standard structured analysis against the accepted §3.5 checklist (executed inline at session tier L; upward substitution logged)
budget: ~6k tokens
recursion_allowance: 0
---

# ATOM-009 — Input Specification

## 1. Product Identity
| Field | Value |
| :---- | :---- |
| Product | `products/business-strategy-v1/segments/segment-map.md` |
| Atom ID | ATOM-009 |
| Parent product | RPF Business Strategy v1 |
| Executor role | market-analyst (roles/market-analyst.md — F2 satisfied) |
| Input product(s) | ATOM-006 INPUT §3.5 (segments discipline + attractiveness checklist), §3.4 (pilot partner context), §3.6 (channel hypotheses), §3.9 (honesty); MANIFEST.md (who RPF is for) |
| Consumer(s) | The human (G1 direction check); ATOM-010 (channels); ATOM-011 (pricing); ATOM-015 (Segments section) |
| Maturity target | draft |
| Gates | G1 direction check (human reviews the map before channel/pricing work builds on it) |
| Instantiation | subagent |
| Verification mode | self — internal analysis per parent INPUT §4 ("independent or self per risk"); risk low: draft consumed inside the tree, human direction-check at G1, final assembly independently verified |
| Budget envelope | ~6k tokens |
| Recursion-depth allowance | 0 |

## 2. Job To Be Done
Map who RPF serves first: candidate segments defined by the jobs they would hire RPF for (explicit hypotheses with client success criteria), scored against the accepted attractiveness checklist, ranked, with the ranking's sensitivity stated — so the human can confirm or redirect direction at G1.

**Consumers:** human (direction), channels atom (segment→channel fit), pricing atom (budget-for-the-job), strategy assembly.

## 3. Context — Decisions Already Made (formalize, do not reopen)
§3.5 verbatim: segment by jobs-to-be-done with client success criteria — never by demographics alone. Candidate segment #1: non-technical founder in an accelerator; its jobs are hypotheses to state explicitly (e.g. "reach demo day without a technical cofounder and without giving up 30% equity"), not facts. Attractiveness factors (the closed scoring checklist): segment size × competition for its jobs × achievable added value × budget for the job × channel existence and capacity × target unit margin × switching readiness. §3.9: no unsourced market claims — sizes and budgets the executor cannot source are marked assumptions or E1 questions collected for G1.

## 4. Deliverable
`products/business-strategy-v1/segments/segment-map.md` — ≥3 candidate segments, each: job hypotheses (client-perspective, success criterion per job), 7-factor score with the evidence/assumption behind each factor, ranking + sensitivity, open questions for the human (G1 material).

## 5. Definition of Done
**Hard criteria:**
- H1. File exists at the path above. Check: `ls`.
- H2. ≥3 segments, each with ≥2 job hypotheses labeled as hypotheses and a client success criterion per job. Check: grep section count + `Hypothesis` labels.
- H3. Every segment scored on all 7 accepted factors (7 rows per segment, factor wording from §3.5). Check: grep factor rows.
- H4. Every quantitative claim carries `(source: ...)` or `assumption` marker. Check: grep.

**Soft criteria:**
- S1. Scoring shows its work and states ranking sensitivity — judge: executor self-review (mode `self`), re-checked by the human at G1.
- S2. Segment #1's jobs would be recognizable to a real accelerator founder — judge: human (G1).

**Maturity target:** draft. Do not gold-plate.

## 6. Method Hints (non-binding)
Steal the §3.5 checklist wording. Scores 1–5 with one evidence line each beat false precision. Candidate segments beyond #1: draw from MANIFEST audiences (small teams running product portfolios; regulated organizations) — but score them honestly against channel existence today.

## 7. Escalation
E1–E7 per ATOM-SPEC §5.7. Gate: G1 (direction). Unsourceable numbers → marked assumptions + G1 question list, not stops. Otherwise execute.
