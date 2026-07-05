---
atom: ATOM-012
product: Pilot design — Flow Support v0 (products/business-strategy-v1/pilot/pilot-design.md)
status: delivered
maturity_claimed: draft
cost:
  units_in: ~3k             # estimate (BC4): INPUT + §3.4/INFO-001 + pricing/channels outputs (in session context)
  units_out: ~3.5k
  unit: tokens
  wall_time: ~10m
  executor: claude-fable-5 (inline in ATOM-006 orchestrator session; tier M assigned, executed at L — upward substitution)
  sub_atoms_spawned: 0
  sub_atoms_cost: 0
---

# RESULT — ATOM-012

## Summary
Executable pilot design for Flow Support v0 with Startup Moldova: framing (observation as a service, self-hosted per §3.2/§3.4), INFO-001 exchange + four red lines embedded in the founder-facing script, six measurable success criteria each mapped to a named strategy assumption (viability floor, token model, owner-minutes, capacity, WTP, bank bridge), the full telemetry consent text (closed operational-file scope, open script, explicit revocable consent, fixed deletion date), daily cadence + one-business-day SLA, 12-week timeline, and exit conditions that re-anchor pricing and trigger or clear the channel kill trigger. ATOM-007 referenced as prerequisite owner throughout; nothing prerequisite-shaped built.

## Deliverables
| File | Purpose |
| :---- | :---- |
| `products/business-strategy-v1/pilot/pilot-design.md` | Pilot section input to ATOM-015; instrument definitions for ATOM-013; terms record for the Startup Moldova conversation |

## DoD Self-Check
| Criterion | Result | Evidence |
| :---- | :---- | :---- |
| H1 file exists | met | `ls` |
| H2 seven sections | met | grep: exactly the 7 §4 headings |
| H3 consent scope complete | met | grep: all 5 file types + no-business-content + open script + explicit consent + deletion date |
| H4 four red lines | met | grep: all four present (in Exchange section and consent text) |
| H5 SLA verbatim | met | grep ×2 |
| H6 ≥4 measured criteria | met | 6 rows, each with number + instrument + tested assumption |
| H7 ATOM-007 reference-only | met | grep ×4, all "owned by / ships at" phrasing |
| H8 markers + no platform names | met | grep 0 after excluding mandated path citation |
| S1 consent text handable as-is | self-reviewed | plain-language scope, both-directions clarity (what we take / never take), revocation path; human sees at G2 |

## Decisions Made by Executor
1. Deletion date set as formula (pilot end + 30 days, fixed in writing at signing) rather than a calendar date — §3.4 requires "date fixed", which signing satisfies; declared.
2. Red lines placed inside the consent text as "what this pilot is not" — one document a founder actually reads beats two.
3. Timeline anchored to one cohort rhythm, 12 weeks (assumption — synced at kickoff).
4. Exit asymmetry declared: technical failure + delivered intros still yields the bank bridge; partner-relationship failure is E3 regardless.

## Deviations & Known Limitations
Consent text is the English master; RO/RU founder-facing versions are an ATOM-007 setup deliverable (HP2 canon respected). Startup Moldova's cohort calendar is unknown — timeline is a template.

## Handoff
Verification mode: self (draft) — this self-check is the delivery obligation; consumed by ATOM-013/015; human sees the consent text at G2.
