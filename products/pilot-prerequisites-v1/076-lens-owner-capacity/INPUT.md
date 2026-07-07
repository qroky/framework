---
atom: ATOM-076
product: Lens verdict — owner-capacity (the fan of ATOM-007, SYNTHESIS-PROTOCOL LF1-LF7)
parent: Pilot Prerequisites v1 (ATOM-007; plan: 007-pilot-prerequisites/PLAN.md)
formulated_by: formulating agent (launch session), 2026-07-07
verification: self (feeds 1 consumer - the synthesis act ATOM-007-SYNTH)
maturity_target: draft
instantiation: subagent
model_tier: S
budget: ~75k tokens (GATE-017 calibration incl. ~50k fixed subagent term)
recursion_allowance: 0
---

# ATOM-076 — Input Specification (lens atom)

## 1. Identity
| Field | Value |
| :---- | :---- |
| Lens | **owner-capacity** |
| Executor role | ops-capacity-reviewer (`roles/ops-capacity-reviewer.md` — read it first, it IS you) |
| Atom ID | ATOM-076 |
| Consumer | ATOM-007-SYNTH (the synthesis act) — your verdict is one of four |
| Verification mode | self |
| Budget envelope | ~75k tokens |

## 2. The shared question (LF2 — same for all four lenses)
**«Дают ли эти пререквизиты пилоту стартовать и быть измеренным безопасно?»**
(Do these prerequisites let the pilot start and be measured safely?)
You answer it strictly through your lens. The other three lenses examine the
same products through theirs; you do not know their answers.

## 3. The products under examination (read ALL of these; nothing else except §1's role file)
1. `products/pilot-prerequisites-v1/071-setup-kit/setup/` — all 7 files (bootstrap, quickstarts RO/RU, tiers RO/RU, dry-run + transcript)
2. `products/pilot-prerequisites-v1/072-telemetry-showcase/` — telemetry/ (3 files), consent/ (2), showcase/ (5)
3. `products/pilot-prerequisites-v1/007-pilot-prerequisites/PLAN.md` — the tree you are part of
4. `products/pilot-prerequisites-v1/007-pilot-prerequisites/INPUT.md` — §2, §3 and §4 only (the intake protocol is NOT built yet — deliberately last; judge its SPEC in §3.1/§3.4 at design level)
Do NOT read: verify verdicts, other lens folders, run.logs — your independence is the fan's value.

## 4. Lens emphasis (your DoD)
Workload arithmetic for the one-human pilot owner: from these prerequisites, hours/week at 2 concurrent founders (daily review per Flow Support v0, intervention approvals, verify returns, telemetry review); SLA 'reaction to blocked within one business day' - feasible against the owner's calendar as evidenced by the PLAN's own gate cadence (5 human stops in one day on this very tree); breaking point in founders count; what in setup/tiers/telemetry design ADDS owner load that could be automated or batched. Numbers with units, not reassurance.

## 5. Deliverable
`076-lens-owner-capacity/LENS-VERDICT.md`:
1. **Answer** to the shared question: yes / yes-with-conditions / no — one line, then the case.
2. **Findings** — each: artifact, exact location, what, severity (blocking-for-pilot / significant / minor), and WHAT YOU WOULD CHANGE. Specific, never vibes.
3. **Named contradiction or concurrence (SY9)** — at least one place where your lens PUSHES AGAINST what another optic would likely want (e.g. hiding vs showing mechanics, rigor vs cost, safety vs friction), stated as «моя линза требует X, даже если это ухудшает Y». If after honest search you have none — write the specific reason, not a smoothed «всё совместимо».
4. **Cost of your own look** — your token estimate.
Plain, direct language. Russian or English — your choice; founder-facing quotes stay as-is.

## 6. Obligations
Write `STATUS.md`, `RESULT.md` (product path + self-check), `workspace/run.log` in YOUR folder. Do NOT touch status.yaml. No escalations expected: if an input file is missing, record it as a finding, not an E1 — the fan must not stall.
