---
atom: ATOM-100
status: delivered (verify accepted r2; awaiting G2 — CEO dry run on a clean machine, the release criterion S3)
date: 2026-07-10
maturity: delivered → reviewed after G2; validated after first field stranger-install
total_descendants: 2 (ATOM-101 executor, ATOM-101-VERIFY)
subtree_cost: ~577,000 tokens (children real counters 527,425 + parent orchestration ~50k est per BC4)
breakdown: { execute: 324949 (M), verify: 202476 (L), roles: 0 (reused), synthesis: 0 (no fan), narrative+orchestration: ~50000 (L, est) }
tier_shares: { L: ~44%, M: ~56%, S: 0% }
envelope: ~800k — no breach (72% used)
verify_returns: 1 (r1 RETURN: 2 blocking + 6 minor → all fixed → r2 ACCEPT + 1 typo fixed by closing actor)
rowan: { e1_to_human: 0, rowan_fails: 0 }
---

# RESULT — ATOM-100 Distribution Kit v1

## What exists now

`distribution/` — a stranger with a clean Mac can run ONE script and get a
working Qroky instance in ≤15 minutes: `install.sh` (7-question interview
en/ro/ru, check→do state machine over `install-state.json`, failure ladder
≤2 auto-attempts, heartbeat consent with both branches, self-update via
release tags only — apply gated on explicit «да» with reconciliation),
localized READMEs, and `dry-run.sh` — a 9-scenario sandbox harness, all
green with non-vacuous assertions.

## TEAM summary (INFO-007)

| Participant | Tier | Contribution | Friction & resolution |
| :---- | :- | :---- | :---- |
| Orchestrator (launch session) | L | Formulation, spawn briefs, verify package, closure | — |
| pilot-toolsmith (ATOM-101, reused role) | M | The whole kit; found & fixed 5 of its own bugs while building the harness | Self-check claimed a real kill-test that was vacuous — caught by verify, honestly rebuilt in round 2 |
| Blind verifier (fresh context) | L | RETURN r1 (2 blocking + 6 minor, every one evidence-backed); ACCEPT r2 after re-breaking attempts failed; fault-injected the one path the executor honestly flagged as unexercised | Disagreed with executor's transcript claims — resolved by independent re-runs (3× 9/9), not by negotiation |

No perspective fan (mono-role product build); no value conflicts (E8: 0).

## Deviations & carry-over

- Telemetry step records consent with the verbatim 5-item whitelist; the
  actual push mechanism (072's push.sh) is NOT vendored — outside this
  atom's closed deliverable list. Carry-over decision for the CEO or a
  follow-up atom: vendor it at install time vs first-use.
- F8 degradation path (launchctl bootstrap failure → installed-but-off) is
  covered by the VERIFIER's fault-injection transcript, not the executor's
  harness (their launchctl stub always succeeds) — documented, adequate.

## Gate state

- G1 = GATE-025 («100 - go»).
- **G2 pending — HUMAN-TASK: CEO dry run on a clean machine** (≤15 min,
  zero questions outside the interview). The atom does not close
  `reviewed` without it.
