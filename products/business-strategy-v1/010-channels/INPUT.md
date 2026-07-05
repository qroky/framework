---
atom: ATOM-010
product: Channel comparison + recommendation (products/business-strategy-v1/channels/channel-comparison.md)
parent: RPF Business Strategy v1 (ATOM-006)
formulated_by: ATOM-006 orchestrator (formulating-agent duties per LP5), 2026-07-05
verification: self
maturity_target: draft
instantiation: subagent
model_tier: M — structured comparison against accepted §3.6 hypotheses (executed inline at session tier L; upward substitution logged)
budget: ~7k tokens
recursion_allowance: 0
---

# ATOM-010 — Input Specification

## 1. Product Identity
| Field | Value |
| :---- | :---- |
| Product | `products/business-strategy-v1/channels/channel-comparison.md` |
| Atom ID | ATOM-010 |
| Parent product | RPF Business Strategy v1 |
| Executor role | venture-strategist (roles/venture-strategist.md — F2 satisfied) |
| Input product(s) | ATOM-006 INPUT §3.6 (three channel hypotheses + sequence hypothesis), §3.9; `segments/segment-map.md` (G1-confirmed A→C→B); `pricing/pricing-ladder.md` (founder-month economics — resequencing dependency); `decisions/INFO-001-pilot-terms-startup-moldova.md` (pilot terms = channel-a entry + channel-b bridge) |
| Consumer(s) | ATOM-012 (pilot design), ATOM-014 (rejected options), ATOM-015 (Channel section) |
| Maturity target | draft |
| Gates | none (G2 covers final assembly) |
| Instantiation | subagent |
| Verification mode | self — internal analysis per parent INPUT §4 authorization; risk low: draft consumed inside the tree, assembly independently verified, human at G2 |
| Budget envelope | ~7k tokens |
| Recursion-depth allowance | 0 |

## 2. Job To Be Done
Compare the three accepted channel hypotheses with unit economics grounded in the pricing atom's founder-month numbers, produce exactly one recommendation consistent with the G1-confirmed segment sequence, price the B2B2C rescue option the segment map flagged, and hand rejected options to NOT-DOING.

## 3. Context — Decisions Already Made (formalize, do not reopen)
§3.6 verbatim: (a) Accelerator B2B2C — cohort license + graduate discount; equity with founders frozen; possible success-fee with the program; first conversation open (Startup Moldova). (b) Bank as GTM partner — AFTER pilot proof; paid pilot only; co-branding mandatory; exclusivity short and expensive if at all; risk-acceptance journal is the liability answer for bank compliance. (c) Self-serve on open core — brand/funnel, slow. Sequence hypothesis: accelerator → paid bank pilot → second bank as leverage. Compare with unit economics; recommendation + rejected options into NOT-DOING.
G1 (GATE-008): segment sequence A→C→B confirmed. INFO-001: pilot exchange = case study + 2–3 bank/fund intros — the bank intros are channel (b)'s entry mechanism. §3.9: bank-side numbers not derivable from repo data are marked assumptions or named as conversation-gated, not invented.

## 4. Deliverable
`products/business-strategy-v1/channels/channel-comparison.md` — three options, each with a unit-economics block (acquisition cost, capacity constraint, revenue basis, margin) consuming `pricing/pricing-ladder.md` numbers; B2B2C per-cohort price; exactly one recommendation with the sequence; rejected variants handed to NOT-DOING.

## 5. Definition of Done
**Hard criteria:**
- H1. File exists at the path above. Check: `ls`.
- H2. Three option sections, each with acquisition, capacity, revenue, margin rows. Check: grep option headings (3) + the four row labels ×3.
- H3. Exactly one `## Recommendation` section stating the sequence. Check: grep count = 1.
- H4. ≥2 rejected variants explicitly handed to NOT-DOING (marker `→ NOT-DOING`). Check: grep ≥ 2.
- H5. Every quantitative claim carries `(source: ...)` or `assumption` marker. Check: grep.
- H6. Consumes pricing and INFO-001 by path. Check: grep `pricing/pricing-ladder.md` ≥1 and `INFO-001` ≥1.

**Soft criteria:**
- S1. A reader can see why the recommended sequence wins on the numbers shown, not by assertion — judge: executor self-review, re-checked at G2.

**Maturity target:** draft. Do not gold-plate.

## 6. Method Hints (non-binding)
The capacity constraint is human owner-review hours (pricing atom's material finding) — channel throughput is bounded by attention, not tokens. Bank ACV is not computable from repo data: state it as conversation-gated with an assumption range, honestly marked.

## 7. Escalation
E1–E7 per ATOM-SPEC §5.7. Unsourceable numbers → marked assumptions, not stops. Otherwise execute.
