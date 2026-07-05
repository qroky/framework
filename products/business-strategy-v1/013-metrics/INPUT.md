---
atom: ATOM-013
product: RPF success metrics system (products/business-strategy-v1/metrics/metrics-system.md)
parent: RPF Business Strategy v1 (ATOM-006)
formulated_by: ATOM-006 orchestrator (formulating-agent duties per LP5), 2026-07-05
verification: self
maturity_target: draft
instantiation: subagent
model_tier: M — metric definition against existing repo instrumentation (executed inline at session tier L; upward substitution logged)
budget: ~6k tokens
recursion_allowance: 0
---

# ATOM-013 — Input Specification

## 1. Product Identity
| Field | Value |
| :---- | :---- |
| Product | `products/business-strategy-v1/metrics/metrics-system.md` |
| Atom ID | ATOM-013 |
| Parent product | RPF Business Strategy v1 |
| Executor role | market-analyst (roles/market-analyst.md — F2 satisfied) |
| Input product(s) | ATOM-006 INPUT §4 (the four named metrics: escalation rate, verify returns, cost per product type, founder-hours per gate); `pilot/pilot-design.md` (instruments + telemetry scope); `pricing/pricing-ladder.md` (assumptions needing measurement); repo operational formats (STATUS/RESULT cost blocks, run.log, status.yaml, verdicts) as the data sources metrics must be computable from |
| Consumer(s) | ATOM-015 (referenced from strategy); pilot operation (ATOM-007-era dashboards); quarterly re-validation gate |
| Maturity target | draft |
| Gates | none (G2 covers final assembly) |
| Instantiation | subagent |
| Verification mode | self — internal analysis per parent INPUT §4 authorization; risk low: draft, human at G2 |
| Budget envelope | ~6k tokens |
| Recursion-depth allowance | 0 |

## 2. Job To Be Done
Define the metrics system that tells the founder whether RPF works as a business: the four §4-named framework metrics plus the pilot's commercial metrics — each with formula, data source (an existing operational file format; telemetry-scope-compatible), collection cadence, and the decision it informs. Metrics nobody will act on are excluded by design.

## 3. Context — Decisions Already Made (formalize, do not reopen)
§4 names exactly: escalation rate, verify returns, cost per product type, founder-hours per gate. Telemetry scope (accepted §3.4) bounds pilot data to operational files only — a metric requiring business content is invalid by construction. Pilot instruments already fixed in `pilot/pilot-design.md` §Success criteria — reference, don't redefine. §3.9 honesty: no target values invented where no baseline exists; state "baseline TBD at pilot" instead.

## 4. Deliverable
`products/business-strategy-v1/metrics/metrics-system.md` — metric table(s): name, formula, data source (repo file format), cadence, decision informed, target-or-baseline-TBD; the four §4 metrics present verbatim; commercial pilot metrics referencing pilot instruments; explicit exclusion note for unactionable metrics.

## 5. Definition of Done
**Hard criteria:**
- H1. File exists at the path above. Check: `ls`.
- H2. All four §4 metrics present by name. Check: grep each.
- H3. Every metric row has formula + data source + cadence + decision-informed. Check: grep table columns.
- H4. Every data source is an operational file format within telemetry scope (STATUS/RESULT cost blocks/run.log/status.yaml/verdicts) or an explicitly human-kept log. Check: grep source column values.
- H5. No invented targets: rows without a baseline carry `baseline TBD` (or a sourced/assumption-marked value). Check: grep.
- H6. Zero bare platform names (path citations excluded). Check: grep.

**Soft criteria:**
- S1. Each metric names the decision it changes — a metric with no decision is dropped, not decorated — judge: executor self-review; human at G2.

**Maturity target:** draft. Do not gold-plate.

## 6. Method Hints (non-binding)
This tree is itself the first data set: GATE count, escalations, verify returns, and real counters already exist in decisions/ and status.yaml — use them as the day-one baselines where honest.

## 7. Escalation
E1–E7 per ATOM-SPEC §5.7. Otherwise execute.
