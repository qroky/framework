---
atom: ATOM-017
product: Rebrand text swap «RPF» → Qroky (living artifacts)
parent: Recursive Product Framework v1 (brand: Qroky per GATE-012, INFO-002/003)
formulated_by: Human (GATE-012) + formulating agent (launch session), 2026-07-07
verification: independent + human
maturity_target: reviewed
instantiation: subagent (inline — executed by the session at tier L; tier-S mechanical work, upward substitution logged)
model_tier: S — mechanical text swap with a stated boundary; executed at session tier L (MT6 upward substitution, logged)
budget: ~25k tokens (reads of the living set ~8k ×3 for careful per-file edits)
recursion_allowance: 0
---

# ATOM-017 — Input Specification

## Perspective map — ATOM-017 (PM1–PM4)

**Question under examination:** does the brand swap apply the GATE-012 boundary correctly?
**Fan triggers (PM6):** decomposition plan = no; maturity ≥ reviewed = yes; crosses perimeter = yes (public face).
**Fan decision:** opt-out per PM4.

Opt-out: single lens — narrow question — mechanical text substitution under an
explicitly accepted boundary (GATE-012); no professional optic beyond
brand-consistency exists for this product; the perimeter risk is carried by the
`independent + human` verification mode, not by a fan.

## 1. Product Identity
| Field | Value |
| :---- | :---- |
| Product | Brand swap across the living artifact set (paths in §4) |
| Atom ID | ATOM-017 |
| Parent product | Recursive Product Framework v1 |
| Executor role | framework-architect (exists) |
| Input product(s) | `decisions/GATE-012-rebrand-now-and-chain-order.md`; `decisions/INFO-002`, `INFO-003` (name cleared); grep scope of «RPF» occurrences |
| Consumer(s) | Public repo readers (MANIFEST/README); ATOM-007 tree (founder-facing name); pilot artifacts |
| Maturity target | reviewed |
| Gates | GATE-013 — human acceptance after Verify (perimeter, F4 c) |
| Instantiation | subagent (inline) |
| Verification mode | independent + human — crosses the perimeter (public face) |
| Budget envelope | ~25k tokens |
| Recursion-depth allowance | 0 |

## 2. Job To Be Done
Complete the rebrand's text half (the GitHub transfer to `qroky/framework` is done
by the human): every brand position in living artifacts reads **Qroky**; the
methodology keeps its spelled-out name; history stays frozen; the «brand name
pending» footnote disappears from the public face.

## 3. Context — Decisions Already Made (GATE-012 — formalize, do not reopen)
- Rebrand now (decision 2.1, re-confirmed). Chain: swap → touch → ATOM-007.
- Usage boundary (frame from GATE-012, exact rule = executor decision, logged):
  **Qroky** = brand/product; **«Recursive Product Framework»** spelled out is
  permitted as the methodology name in titles/subtitles/definitions.
- Remove the MANIFEST footnote «brand name is pending» (and its ¹ anchor).
- Remote origin already points to `https://github.com/qroky/framework.git`.

## 4. Deliverable (the living set — closed list)
`MANIFEST.md`; `README.md`; `TASKS.md` (forward-looking rows only);
`ATOM-007-LAUNCH.md` (not yet materialized — §3.7 refreshed with change note);
`products/business-strategy-v1/`: `STRATEGY.md`, `segments/segment-map.md`,
`pilot/pilot-design.md`, `pricing/pricing-ladder.md`, `metrics/metrics-system.md`,
`channels/channel-comparison.md`.
**Frozen (MUST NOT be touched):** `decisions/`, `knowledge/`, all atom metadata
under `products/*/` (INPUT/RESULT/STATUS/VERDICT/PLAN/GATE-BRIEF/run.log), closed
launch files (`ATOM-001-atom-spec-INPUT.md`, `ATOM-002..006-LAUNCH.md`,
`ATOM-016-LAUNCH.md`), `naming/naming-verdict.md` (naming evidence),
`framework/` (uses no brand name — verify by grep, do not edit).

## 5. Definition of Done
**Hard criteria:**
- H1. `grep -c "RPF"` = 0 in every §4 living file except: TASKS historical lines
  («Закрыто недавно» quoting past product names) and STRATEGY §Naming's verbatim
  «"RPF"→Qroky» swap-history mention if retained as history. Check: grep per file.
- H2. MANIFEST contains neither the footnote line «brand name is pending» nor a
  dangling ¹ anchor. Check: grep.
- H3. `git status` after the swap shows changes ONLY in §4 living files + this
  atom's folder + `status.yaml` (+ `TASKS.md`). Frozen set untouched. Check:
  `git status --porcelain` capture.
- H4. Titles of MANIFEST and README follow the pattern «Qroky — Recursive Product
  Framework» (brand first, methodology as subtitle). Check: head -1 grep.
- H5. `git remote get-url origin` = `https://github.com/qroky/framework.git`.
**Soft criteria:**
- S1. The boundary is applied consistently: every remaining spelled-out
  «Recursive Product Framework» sits in a methodology-name position; no brand
  position still reads RPF — judge: Verify agent.
- S2. The public face reads coherently post-swap (no sentence broken by the
  substitution; consent text natural) — judge: Verify agent.
- S3. «Имя на витрине — моё»: the human accepts the rebranded public face —
  judge: human (GATE-013).

**Maturity target:** reviewed. Do not gold-plate.

## 6. Method Hints (non-binding)
Per-file precise edits over blind `sed` (occurrences already mapped). Log the
exact boundary rule as an executor decision (O9.1).

## 7. Escalation
Triggers E1–E7 (+E8 n/a — no fan). Gate: GATE-013 after Verify. Otherwise execute.
