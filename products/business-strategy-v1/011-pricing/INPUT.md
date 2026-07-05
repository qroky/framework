---
atom: ATOM-011
product: Pricing ladder + founder-month token economics (products/business-strategy-v1/pricing/pricing-ladder.md)
parent: RPF Business Strategy v1 (ATOM-006)
formulated_by: ATOM-006 orchestrator (formulating-agent duties per LP5), 2026-07-05
verification: self
maturity_target: draft
instantiation: subagent
model_tier: M — structured unit-economics analysis against accepted §3.7 inputs (executed inline at session tier L; upward substitution logged)
budget: ~7k tokens
recursion_allowance: 0
---

# ATOM-011 — Input Specification

## 1. Product Identity
| Field | Value |
| :---- | :---- |
| Product | `products/business-strategy-v1/pricing/pricing-ladder.md` |
| Atom ID | ATOM-011 |
| Parent product | RPF Business Strategy v1 |
| Executor role | venture-strategist (roles/venture-strategist.md — F2 satisfied) |
| Input product(s) | ATOM-006 INPUT §3.7 (ladder hypothesis + real-cost mandate + WTP assumption), §3.9 (honesty); segment map (`segments/segment-map.md`, budget-for-the-job + margin factors); repo cost blocks (see §3); tier price list per `runtime/claude/README.md` binding |
| Consumer(s) | ATOM-010 (channel unit economics — resequenced to consume this), ATOM-012 (pilot terms context), ATOM-015 (Pricing section) |
| Maturity target | draft |
| Gates | none (G2 covers final assembly) |
| Instantiation | subagent |
| Verification mode | self — internal analysis per parent INPUT §4 authorization; risk low: draft consumed inside the tree, assembly independently verified, human at G2 |
| Budget envelope | ~7k tokens |
| Recursion-depth allowance | 0 |

## 2. Job To Be Done
Turn the accepted ladder hypothesis (self-hosted free → Flow Support → managed) into a priced ladder whose unit economics rest on REAL cost blocks from this repository — computing what an active founder-month costs in tokens at current per-tier prices — so the channels atom can compute channel unit economics and the strategy states margin honestly.

## 3. Context — Decisions Already Made (formalize, do not reopen)
§3.7 verbatim: ladder self-hosted free (open core) → Flow Support (observation + interventions + monthly report) → managed. Unit-economics MUST use real cost data from this repo's cost blocks (full atom cycle ≈ 90–120k tokens; verify ≈ read×3.5+constant); solo-founder WTP ceiling assumption $50–200/mo — test at pilot exit, not now. §3.9: no unsourced numbers.
**Known citable real cost blocks (executor verifies, may add):** `knowledge/precedent/verify-envelope-calibration.md` (measured-runs table: 123 814 / 139 394 / 138 342 real tokens); `products/framework-v1/status.yaml` (ATOM-005-VERIFY real counter 138,342); `products/business-strategy-v1/status.yaml` (ATOM-008-VERIFY real counter 105,273); BC4 `~`-estimates in child RESULT.md cost blocks (mark as estimates).
**Parent constraint (H9 discipline):** the deliverable references the runtime binding by path (`runtime/claude/README.md`) and tier labels S/M/L only — no bare platform/vendor/model names in prose. Vendor price sourcing is logged in the atom run log where names are legal (RC3). Subscription-plan prices are NOT sourced — if the deliverable touches them, mark as unsourced and exclude from computation.

## 4. Deliverable
`products/business-strategy-v1/pricing/pricing-ladder.md` — three-rung ladder each with: what the client gets, our COGS structure, price basis; founder-month token cost computed from ≥3 real cost blocks cited by repo path; per-tier $/MTok inputs with source markers; margin implication vs the WTP assumption; what the pilot must measure.

## 5. Definition of Done
**Hard criteria:**
- H1. File exists at the path above. Check: `ls`.
- H2. Three ladder rungs present (self-hosted / Flow Support / managed), each with a COGS line and a price-basis line. Check: grep rung headings + `COGS` + `Price basis` (3 each).
- H3. Founder-month token cost computed from ≥3 real cost blocks cited by repo path. Check: grep distinct repo paths in the computation section ≥ 3.
- H4. Every quantitative claim carries `(source: ...)` or `assumption` marker. Check: grep.
- H5. WTP $50–200/mo appears explicitly marked as an assumption with a pilot-exit test note. Check: grep.
- H6. Zero bare platform/vendor/model names in the deliverable. Check: grep banned-name list → 0 matches.

**Soft criteria:**
- S1. The computation shows its work (a reader can recompute) and states sensitivity — judge: executor self-review, re-checked at G2.

**Maturity target:** draft. Do not gold-plate.

## 6. Method Hints (non-binding)
Blend input/output prices with a declared ratio assumption (verify runs are read-dominated). Distinguish real counters from BC4 `~`-estimates. The interesting strategic question is what dominates COGS — tokens or human attention; answer it with the numbers.

## 7. Escalation
E1–E7 per ATOM-SPEC §5.7. Unsourceable numbers → marked assumptions, not stops. Otherwise execute.
