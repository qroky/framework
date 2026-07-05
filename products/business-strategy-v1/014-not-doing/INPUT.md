---
atom: ATOM-014
product: NOT-DOING register (products/business-strategy-v1/NOT-DOING.md)
parent: RPF Business Strategy v1 (ATOM-006)
formulated_by: ATOM-006 orchestrator (formulating-agent duties per LP5), 2026-07-05
verification: self
maturity_target: draft
instantiation: subagent
model_tier: M — consolidation of already-made rejections (executed inline at session tier L; upward substitution logged)
budget: ~4k tokens
recursion_allowance: 0
---

# ATOM-014 — Input Specification

## 1. Product Identity
| Field | Value |
| :---- | :---- |
| Product | `products/business-strategy-v1/NOT-DOING.md` (product root per §4 tree) |
| Atom ID | ATOM-014 |
| Parent product | RPF Business Strategy v1 |
| Executor role | venture-strategist (roles/venture-strategist.md — F2 satisfied) |
| Input product(s) | ATOM-006 INPUT §3.8 (register mandate + known backfills: equity-for-tooling, bank GTM before pilot, robotics until sim-gate, Atomos name, broad TLD shopping); `naming/naming-verdict.md` + GATE-009 (Atomaro/Atomos kills); `segments/segment-map.md` (parked segments); `channels/channel-comparison.md` (4 rejected variants) |
| Consumer(s) | ATOM-015 (referenced); quarterly re-validation gate (revisit triggers) |
| Maturity target | draft |
| Gates | none |
| Instantiation | subagent |
| Verification mode | self — consolidation of decisions already made; risk minimal |
| Budget envelope | ~4k tokens |
| Recursion-depth allowance | 0 |

## 2. Job To Be Done
Consolidate every rejection this strategy has produced or inherited into one first-class register: one line why, one revisit trigger each — so future sessions and the quarterly gate stop re-litigating closed questions.

## 3. Context — Decisions Already Made (formalize, do not reopen)
§3.8: NOT-DOING.md is a first-class deliverable; every rejected segment/channel/initiative gets: one line why + revisit-when trigger. Known backfills named in §3.8 verbatim (five above). GATE-009 added Atomaro + Atomos with revisit triggers. ATOM-009 parked unscored adjacent segments. ATOM-010 handed four channel variants.

## 4. Deliverable
`products/business-strategy-v1/NOT-DOING.md` — table register: entry, why (one line), revisit trigger, source (decision/atom path). Parent H3 requires ≥5 entries; expected ≈ 12.

## 5. Definition of Done
**Hard criteria:**
- H1. File exists at the path above. Check: `ls`.
- H2. ≥5 entries each with why + revisit trigger. Check: grep table rows ≥5, no empty cells.
- H3. All five §3.8 named backfills present. Check: grep each.
- H4. Every entry cites a source (decision record, atom, or accepted §). Check: grep source column.
- H5. Zero bare platform names. Check: grep.

**Soft criteria:**
- S1. Entries are decisions, not intentions — each is something actually rejected somewhere citable — judge: executor self-review.

**Maturity target:** draft. Do not gold-plate.

## 6. Method Hints (non-binding)
One table beats prose. Group by kind (name/segment/channel/initiative) only if it stays one screen.

## 7. Escalation
E1–E7 per ATOM-SPEC §5.7. Otherwise execute.
