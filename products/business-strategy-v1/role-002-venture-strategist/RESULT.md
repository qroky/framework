---
atom: ROLE-002
product: Role spec venture-strategist (roles/venture-strategist.md)
status: delivered
maturity_claimed: draft
cost:
  units_in: ~1k             # estimate (BC4): §6.3 template + sibling role re-read from session context
  units_out: ~1k            # role spec + atom metadata
  unit: tokens
  wall_time: ~3m
  executor: claude-fable-5 (inline in ATOM-006 orchestrator session; tier M assigned, executed at L — upward substitution)
  sub_atoms_spawned: 0
  sub_atoms_cost: 0
---

# RESULT — ROLE-002

## Summary
Role spec `venture-strategist` created per ATOM-SPEC §6.3: a business strategist optimizing for founder-actionable decisions, with the §3.9 honesty discipline (sourced / marked-assumption / human-answered) and the NOT-DOING rejection habit baked in as method defaults.

## Deliverables
| File | Purpose |
| :---- | :---- |
| `roles/venture-strategist.md` | Executor role for ATOM-008, 010–012, 014, 015 |

## DoD Self-Check
| Criterion | Result | Evidence |
| :---- | :---- | :---- |
| H1 template conformance | met | grep: 5/5 section headings, 2/2 frontmatter keys |
| H2 ≤60 lines | met | `wc -l` → 39 |
| H3 provenance row | met | grep: `Created \| ROLE-002 \| 2026-07-05` |
| S1 honesty discipline baked in | self-reviewed | Method Defaults line 2 + Escalation Posture line 2 carry §3.9 verbatim in role terms |

## Decisions Made by Executor
Risk-picture obligation from `roles/humans/ghenadie.md` (downside never hidden) written into the role's escalation posture — the feedback loop O8.3 anticipates, applied at creation.

## Deviations & Known Limitations
None.

## Handoff
Verification mode: self (draft) — this self-check is the acceptance (A9 note: maturity < reviewed).
