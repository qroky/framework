---
atom: ATOM-008
product: Naming due diligence + verdict (products/business-strategy-v1/naming/naming-verdict.md)
parent: RPF Business Strategy v1 (ATOM-006)
formulated_by: ATOM-006 orchestrator (formulating-agent duties per LP5), 2026-07-05
verification: independent + human
maturity_target: reviewed
instantiation: subagent
model_tier: L — brand go/no-go judgment incl. trademark-confusion assessment; doubt between M and L resolved upward per MT6
budget: ~10k tokens (read estimate ~3k: §3.3 inputs + web results; ×2 + web margin)
recursion_allowance: 0
---

# ATOM-008 — Input Specification

## 1. Product Identity
| Field | Value |
| :---- | :---- |
| Product | `products/business-strategy-v1/naming/naming-verdict.md` |
| Atom ID | ATOM-008 |
| Parent product | RPF Business Strategy v1 |
| Executor role | venture-strategist (roles/venture-strategist.md — F2 satisfied) |
| Input product(s) | ATOM-006 INPUT §3.3 (candidates + hard-DoD checklist + evidence earned to date); live web sources for the trademark screen; the repository (for checklist point 7) |
| Consumer(s) | The human owner (brand go/no-go at G1); ATOM-015 (Name section of STRATEGY.md); future incorporation/trademark filings |
| Maturity target | reviewed |
| Gates | human sign-off of the verdict at G1 (VP18) |
| Instantiation | subagent |
| Verification mode | independent + human — fixed by parent INPUT §4 (naming verdict) |
| Budget envelope | ~10k tokens |
| Recursion-depth allowance | 0 |

## 2. Job To Be Done
Deliver a naming verdict the human can sign at G1: for each live candidate (front-runner **Atomaro**, reserve **Qroky**), evidence against all 7 checklist points of §3.3, applied in order of cheapness; the dead candidate (Atomos) recorded with its kill reason; one recommendation with the risk picture.

**Consumers:** the human (go/no-go), STRATEGY.md Name section, NOT-DOING register (dead candidates).

## 3. Context — Decisions Already Made (formalize, do not reopen)
Parent INPUT §3.3 verbatim: Atomaro front-runner (clean live-company field; atomaro.dev/.app owned; GitHub org atomaro-hq owned; atomaro.com squatted by dormant holder expiring 2026-11-10, backorder planned). Qroky reserve (fully available incl. qroky.com; zero semantics). Atomos dead (live London company "Atomos AI" + video-hardware trademark holder). The 7-point checklist and its order are accepted method — do not redesign it. Honesty rule §3.9: every claim sourced (with date) or explicitly marked as assumption; the trademark screen depends on live sources — where a register cannot be queried, say so; do not simulate a search result.

## 4. Deliverable
`products/business-strategy-v1/naming/naming-verdict.md` — per-candidate evidence table (7 checklist points × {Atomaro, Qroky}), Atomos kill record, Atomico phonetic-neighbor confusion assessment, verdict + recommendation for the human gate.

## 5. Definition of Done
**Hard criteria:**
- H1. File exists at the path above. Check: `ls`.
- H2. For each of Atomaro and Qroky: all 7 checklist points present as numbered evidence rows. Check: grep for point numbering per candidate section (2 × 7 rows).
- H3. Atomico confusion risk explicitly assessed (the flag §3.3 requires). Check: `grep -c Atomico` ≥ 1 in an assessment sentence.
- H4. Every evidence row carries a source (input §3.3, URL, or repo path, with date) or the explicit marker `assumption` / `not verifiable`. Check: grep each row for `(source:` or `assumption` or `not verifiable`.
- H5. A Verdict section with per-candidate go/hold/kill and exactly one recommendation. Check: grep `## Verdict`, `Recommendation`.

**Soft criteria:**
- S1. No invented facts: web-derived claims match the cited sources; unverifiable register states are declared, not guessed — judge: Verify agent.
- S2. The verdict is decision-ready for a non-technical founder (5-second comprehension of the recommendation) — judge: human (G1).

**Maturity target:** reviewed. Do not gold-plate.

## 6. Method Hints (non-binding)
Checklist in order of cheapness (§3.3). Points 1, 2, 4 already carry this week's evidence — cite it as `(source: parent INPUT §3.3, 2026-07-05)` and only re-verify where a single cheap query does it. The new work is point 3 (trademark screen EUIPO/USPTO/WIPO incl. phonetic neighbors) and the judgment points 5–6.

## 7. Escalation
E1–E7 per ATOM-SPEC §5.7. Gate: human sign-off at G1 (brief authored by the formulating agent, in Russian per HP2). Otherwise execute.
