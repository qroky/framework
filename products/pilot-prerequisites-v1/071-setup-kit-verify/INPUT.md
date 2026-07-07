---
atom: ATOM-071-VERIFY
product: VERDICT.md on ATOM-071 (setup kit + execution tiers)
parent: Pilot Prerequisites v1 (ATOM-007)
formulated_by: formulating agent (launch session), 2026-07-07
verification: self
maturity_target: draft
instantiation: subagent (fresh context — VP4)
model_tier: L (MT3/MT4; INFO-008 rule 3 — Verify never below L)
budget: ~80k tokens (slim package ~10k read ×3.5 + 40k, ≥25% margin per VP20)
recursion_allowance: 0
---

# ATOM-071-VERIFY — Input Specification (slim blind package, VP20)

You are a blind Verify atom per `framework/FEV-PROTOCOL.md` §2 — but this
package is SELF-CONTAINED: do NOT read FEV-PROTOCOL or any framework document;
everything you need is here. You MUST NOT read the target atom's `INPUT.md`,
`STATUS.md`, `workspace/` or run.log. From the target's `RESULT.md` read ONLY
the DoD check table and the H4 substance-identity table. Round: **1**.
Returns used so far: **0**.

## 1. Job
Re-run every hard criterion with the literal check command; judge each soft
criterion with a per-criterion finding or specific justification; write
`VERDICT.md` (accept / return-with-fix-list) into
`products/pilot-prerequisites-v1/071-setup-kit-verify/`.

## 2. The files you may read (complete list — nothing else)
1. `products/pilot-prerequisites-v1/071-setup-kit/setup/bootstrap.sh`
2. `products/pilot-prerequisites-v1/071-setup-kit/setup/QUICKSTART.ro.md`
3. `products/pilot-prerequisites-v1/071-setup-kit/setup/QUICKSTART.ru.md`
4. `products/pilot-prerequisites-v1/071-setup-kit/setup/TIERS.ro.md`
5. `products/pilot-prerequisites-v1/071-setup-kit/setup/TIERS.ru.md`
6. `products/pilot-prerequisites-v1/071-setup-kit/setup/dry-run.sh`
7. `products/pilot-prerequisites-v1/071-setup-kit/setup/dry-run-transcript.txt`
8. `products/pilot-prerequisites-v1/071-setup-kit/RESULT.md` — ONLY the DoD
   check table and the H4 RO/RU substance table.
Instruments: non-content commands over these files (`ls`, `wc`, `grep`,
`bash -n`) and re-executing `dry-run.sh` in a temp dir under /private/tmp
(network-free) if you judge the transcript needs reproduction.

## 3. Definition of Done of the TARGET (verbatim — verify against this)
**Hard criteria:**
- H1. All 6 files of the deliverable list exist under `071-setup-kit/setup/`:
  bootstrap.sh, QUICKSTART.ro.md, QUICKSTART.ru.md, TIERS.ro.md, TIERS.ru.md,
  dry-run.sh + dry-run-transcript.txt. Check: ls.
- H2. `dry-run-transcript.txt` shows elapsed ≤ 15 min and zero questions
  requiring technical knowledge (any question in the transcript is listed at
  its end with a one-line classification). Check: transcript.
- H3. `grep -iE "DoD|атом|atom|verify|INPUT|гейт|gate" QUICKSTART.*.md TIERS.*.md`
  returns zero founder-facing hits (English machinery words inside file paths /
  code spans excepted — the target's RESULT lists any such spans). Check: grep.
- H4. RO and RU renders are substance-identical (same steps, same numbers, same
  promises) — the target's RESULT carries a point-by-point table; spot-check it
  against the actual files. Check: table + files.
- H5. `bootstrap.sh` passes `bash -n`; the dry run exits 0. Check: run it.
**Soft criteria (you judge):**
- S1. A non-technical founder could follow QUICKSTART alone, unaided — judge
  from the founder's chair; name the exact line of any failure.
- S2. Tier descriptions are honest about waiting time and cost — no marketing
  gloss; name any glossed claim.

## 4. Verdict discipline
- `accept` only if every H passes under your own re-run AND no soft-criterion
  failure is blocking. Otherwise `return` with a CLOSED fix list (each item:
  file, line, what, why — nothing outside the list may be demanded later).
- Findings taxonomy: blocking / minor. Minor findings do not block accept but
  MUST be listed.
- Write `VERDICT.md` (verdict, per-criterion table, findings, your real token
  estimate), `STATUS.md`, `RESULT.md` (product = the verdict), `workspace/run.log`
  in YOUR folder (`071-setup-kit-verify/`). Do NOT touch status.yaml.
- Your chat reply is a signal only; the files are the product.
