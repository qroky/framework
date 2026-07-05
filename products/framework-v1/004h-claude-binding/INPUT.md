---
atom: ATOM-004H
product: First runtime binding (runtime/claude/README.md)
parent: Recursive Product Framework v1
formulated_by: Human (Ghenadie) + advisor agent, 2026-07-05
verification: independent
maturity_target: reviewed
instantiation: session
model_tier: M (documentation of observed practice against a fixed contract)
budget: ~45k tokens for Execute (read estimate ≈ 18k; ×2.5). Verify envelope: read estimate ×3.5. Hard stop per O6.2.
recursion_allowance: 0
---

# ATOM-004H — Input Specification

## 1. Product Identity
| Field | Value |
| :---- | :---- |
| Product | `runtime/claude/README.md` (+ optional `runtime/claude/scripts/` helpers) |
| Atom ID | ATOM-004H |
| Parent product | Recursive Product Framework v1 |
| Executor role | framework-architect |
| Input product(s) | `framework/ORCHESTRATION.md` (as accepted — its §Runtime-binding contract is your checklist); repo run.logs as observed practice; this INPUT |
| Consumer(s) | The human operating this runtime today; future runtime authors (the worked example); ATOM-005/006 |
| Maturity target | reviewed |
| Gates | none |
| Instantiation | session |
| Verification mode | independent (documentation; reversible; single-runtime blast radius) |
| Budget envelope | ~45k tokens |
| Recursion-depth allowance | 0 |

## 2. Job To Be Done
Bind the abstract contract to this runtime: a person (or headless caller) reading only this README can launch any launch-file correctly. Platform names are legal HERE and only here.

## 3. Context — Decisions Already Made
Document faithfully what practice has proven this week: session started in repo root; launch file attached with "Execute this launch file"; model selection per tier (map S/M/L to the concrete models available in this runtime, with the tier-L reservation for Formulate/Verify and the current flagship-quota caveat as a operational note); human questions surfaced via the session's question interface and recorded verbatim per HP3/DR rules; commit+push at closure per RB6; token counters: use the runtime's real counters where exposed (runtime-measured totals have appeared in run.logs), estimates `~` otherwise; headless invocation documented with its human-gate blocking behavior per the contract. Include the known operational pitfalls log: launch from repo root only; one launch file version in editor; save before send.

## 4. Deliverable
`runtime/claude/README.md`, ≤200 lines. Optional: minimal helper script(s) under `runtime/claude/scripts/` (e.g., hard-criteria grep/wc runner) — MAY, not MUST; do not build a framework.

## 5. Definition of Done
**Hard:** H1 file exists ≤200 lines. H2 covers every item of the ORCHESTRATION runtime-binding contract (checklist correspondence detectable). H3 does not modify any file under `framework/`. H4 `RESULT.md` + `STATUS.md` delivered; status.yaml updated.
**Soft (judge: Verify):** S1 a newcomer with this runtime installed can execute a launch file end-to-end using only this README. S2 no contradiction with ORCHESTRATION; the tier mapping is concrete and current. S3 honest about limitations (what the runtime does not yet enforce).
**Maturity target:** reviewed.

## 6. Method Hints (non-binding)
Write for the person, not the agent: this is the one document in the repo whose primary reader is a human operator.

## 7. Escalation
E1–E7. Gates: none. Budget hard stop per O6.2. Otherwise execute.
