---
atom: ATOM-017-VERIFY
product: VERDICT.md on ATOM-017 (rebrand text swap)
parent: Recursive Product Framework v1
formulated_by: formulating agent (launch session), 2026-07-07
verification: self
maturity_target: draft
instantiation: session
model_tier: L (maturity of target ≥ reviewed — MT3/MT4)
budget: ~120k tokens (blind package ~70 KB → ~23k read ×3.5 + 40k)
recursion_allowance: 0
---

# ATOM-017-VERIFY — Input Specification (blind package per VP2)

You are a blind Verify atom under `framework/FEV-PROTOCOL.md` §2. You receive ONLY this package. You MUST NOT read the target atom's `workspace/`, run log, `RESULT.md`, launch files other than the one listed, decision records other than the one listed, or any executor reasoning. Round: **1**. Returns used so far: **0**.

## 1. Product Identity
| Field | Value |
| :---- | :---- |
| Product | `VERDICT.md` at `products/framework-v1/017-rebrand-swap-verify/` |
| Atom ID | ATOM-017-VERIFY |
| Executor role | framework-architect (`roles/framework-architect.md`) |
| Verification mode | self |
| Budget envelope | ~120k tokens |
| Recursion-depth allowance | 0 |

## 2. Job To Be Done
Accept/return verdict on ATOM-017's product per FEV-PROTOCOL §2: re-run every hard criterion (VP3), judge S1–S2 with per-criterion findings or specific justifications (VP10), defer S3 (VP9), write `VERDICT.md` per §5.1.

## 3. Blind package (the only files you may read)
1. **Target DoD** — §4 below, verbatim from the target's `INPUT.md` §5, with the boundary context of §5 below.
2. **Deliverables under verification (the living set):** `MANIFEST.md`; `README.md`; `TASKS.md`; `ATOM-007-LAUNCH.md`; `products/business-strategy-v1/STRATEGY.md`, `segments/segment-map.md`, `pilot/pilot-design.md`, `pricing/pricing-ladder.md`, `metrics/metrics-system.md`, `channels/channel-comparison.md`.
3. **Reference standards:** `framework/FEV-PROTOCOL.md` (§5.1 verdict template); `decisions/GATE-012-rebrand-now-and-chain-order.md` (the accepted boundary frame).
4. **Instruments:** you MAY run non-content commands over the repository (`grep -r`, `git status --porcelain`, `git remote get-url origin`, `head -1`) to execute the hard checks — including grepping frozen paths to confirm they were NOT modified — without reading their contents beyond match counts.

## 4. Definition of Done of the TARGET atom (verbatim — verify against this)
**Hard criteria:**
- H1. `grep -c "RPF"` = 0 in every living file except: TASKS historical lines («Закрыто недавно» quoting past product names) and STRATEGY §Naming's verbatim «"RPF"→Qroky» swap-history mention if retained as history. Check: grep per file. *(Formulator note for round 1: ATOM-007-LAUNCH §3.7 carries the same swap-history phrase «Rebrand «RPF» → Qroky executed per GATE-012» — judge whether it falls under the same history exemption; if you find it does not, that is a finding.)*
- H2. MANIFEST contains neither the footnote line «brand name is pending» nor a dangling ¹ anchor. Check: grep.
- H3. `git status` shows changes ONLY in living files + the ATOM-017 atom folder + `status.yaml` + the GATE-012 record. Frozen set (decisions/ others, knowledge/, atom metadata under products/*/, closed launch files, naming-verdict.md, framework/) untouched. Check: `git status --porcelain` capture.
- H4. Titles of MANIFEST and README = «# Qroky — Recursive Product Framework». Check: head -1.
- H5. `git remote get-url origin` = `https://github.com/qroky/framework.git`.
**Soft criteria:**
- S1. The boundary is applied consistently: every remaining spelled-out «Recursive Product Framework» sits in a methodology-name position; no brand position still reads RPF — judge: Verify agent.
- S2. The public face reads coherently post-swap (no sentence broken by the substitution; consent text natural) — judge: Verify agent.
- S3. «Имя на витрине — моё» — judge: human (deferred, VP9).

## 5. Boundary context (accepted, GATE-012)
Qroky = brand/product; spelled-out «Recursive Product Framework» permitted as the methodology name in titles/subtitles/definitions; history frozen (append-only discipline).

## 6. Escalation
Triggers E1–E7. Otherwise execute. Write your own `STATUS.md`, `RESULT.md`, `workspace/run.log` per ATOM-SPEC obligations.
