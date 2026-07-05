---
atom: ATOM-015
product: RPF Business Strategy v1 (products/business-strategy-v1/STRATEGY.md)
parent: RPF Business Strategy v1 (ATOM-006)
formulated_by: ATOM-006 orchestrator (formulating-agent duties per LP5), 2026-07-05
verification: independent + human (fixed by ATOM-006 INPUT §4 — not executor discretion)
maturity_target: reviewed
instantiation: subagent
model_tier: L — synthesis whose quality determines G2 acceptance (MT6)
budget: ~8k tokens (execute); verify separately enveloped ~65k per GATE-008 slim package
recursion_allowance: 0
---

# ATOM-015 — Input Specification

## 1. Product Identity
| Field | Value |
| :---- | :---- |
| Product | `products/business-strategy-v1/STRATEGY.md` |
| Atom ID | ATOM-015 |
| Parent product | RPF Business Strategy v1 (this IS the parent's headline deliverable) |
| Executor role | venture-strategist (roles/venture-strategist.md — F2 satisfied) |
| Input product(s) | ALL six analyses: `naming/naming-verdict.md` (+GATE-009), `segments/segment-map.md` (+GATE-008 G1), `channels/channel-comparison.md`, `pricing/pricing-ladder.md`, `pilot/pilot-design.md` (+INFO-001), `metrics/metrics-system.md`, `NOT-DOING.md`; ATOM-006 INPUT §3.1 (positioning), §3.8 (re-validation gate), §3.9 (decision-ready test) |
| Consumer(s) | The human (G2; opens three commercial conversations from it — S1); every future strategy re-touch |
| Maturity target | reviewed |
| Gates | G2 (GATE-010) after independent verify |
| Instantiation | subagent (inline execution; verify is a clean-context session spawn) |
| Verification mode | independent + human (INPUT §4 fixed) — blind verify with slim package per `decisions/GATE-008-atom-006-g1-direction.md` |
| Budget envelope | ~8k tokens execute |
| Recursion-depth allowance | 0 |

## 2. Job To Be Done
Assemble the six analyses into ONE decision-ready strategy document a non-technical founder can act from: ≤1500 words excluding headings, sections Segments / Channel / Pricing / Pilot / Name / Re-validation — each section carrying the decision, the number(s) behind it, and the path to the full analysis. The test (§3.9): the human can open three commercial conversations using only this file.

## 3. Context — Decisions Already Made (formalize, do not reopen)
Positioning §3.1: founder-as-CEO-of-agents; differentiator: recursive decomposition generates the questions the founder didn't know to ask; open-core boundary per RISK-002. All section content is already decided in the six analyses and four decision records — assembly synthesizes, it does not re-analyze or introduce new claims. Every number must trace to an input product (cite by path). H9: runtime by path only.

## 4. Deliverable
`products/business-strategy-v1/STRATEGY.md` — the parent H2 object: ≤1500 words excl. headings; sections (headings detectable): Segments, Channel, Pricing, Pilot, Name, Re-validation.

## 5. Definition of Done
**Hard criteria:**
- H1. File exists at the path above. Check: `ls`.
- H2. ≤1500 words excluding heading lines. Check: `grep -v '^#' STRATEGY.md | wc -w` ≤ 1500.
- H3. All six named sections present as headings. Check: grep each of Segments/Channel/Pricing/Pilot/Name/Re-validation.
- H4. Every section cites its underlying analysis by repo path (≥6 distinct paths total). Check: grep.
- H5. Quantitative claims sourced or assumption-marked (inherited markers count when the citing path carries them). Check: grep spot-check.
- H6. Re-validation section states the quarterly gate mechanism (§3.8: re-touch = diff + human gate). Check: grep `quarterly`.
- H7. Zero bare platform names (path citations excluded). Check: grep.

**Soft criteria (judge: blind Verify, then human at G2):**
- S1. Human can open three commercial conversations from this file alone (parent S1) — judge: human.
- S2. Every strategic claim sourced, assumed-and-marked, or human-answered (parent S2) — judge: Verify.
- S3. No new analysis smuggled in — assembly only — judge: Verify.

**Maturity target:** reviewed.

## 6. Method Hints (non-binding)
Open with the positioning sentence and the three conversations the document enables (accelerator/bank/next partner). One number per decision beats three. The word budget is a feature: cite, don't repeat.

## 7. Escalation
E1–E7 per ATOM-SPEC §5.7. Contradiction between analyses discovered during assembly = E2 back to parent, not silent smoothing. Otherwise execute.
