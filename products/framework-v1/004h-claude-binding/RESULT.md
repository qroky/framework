---
atom: ATOM-004H
product: First runtime binding (runtime/claude/README.md)
status: delivered
maturity_claimed: reviewed
cost:
  units_in: ~12000            # estimate per BC4 — ORCHESTRATION §7 + observed-practice sources (run.logs, gate records) re-read
  units_out: ~8000            # estimate — README (~8 KB) + metadata
  unit: tokens
  wall_time: ~10m
  executor: claude-fable-5
  sub_atoms_spawned: 0
  sub_atoms_cost: 0
---

# RESULT — ATOM-004H

## Summary
Produced `runtime/claude/README.md` (86 lines): the first runtime binding, mapping every item of the ORCHESTRATION §7 contract (RC2 items 1–6) to Claude Code — session start from a launch file, the interactive question interface with verbatim decision capture, the dated S/M/L → Haiku 4.5 / Sonnet 5 / Fable 5 (Opus 4.8 fallback) tier mapping with the MT3 reservation and quota caveat, instantiation-mode mapping including VP4 isolation via fresh-context spawns, real counters (`subagent_tokens`) vs `~` estimates, and headless invocation with block-and-surface behavior at human gates. Includes the observed pitfalls log and an honest RC5 limitations section. Primary reader: the human operator.

## Deliverables
| File | Purpose |
| :---- | :---- |
| `runtime/claude/README.md` | The binding (RC4 coverage map + §1–§8) |

## DoD Self-Check
| Criterion | Result | Evidence |
| :---- | :---- | :---- |
| H1 file exists ≤200 lines | met | `wc -l` = 86 |
| H2 covers every RC2 item, correspondence detectable | met | coverage-map table maps items 1–6 to §1–§6; all six section headings present |
| H3 no `framework/` file modified | met | `git status --porcelain framework/` = 0 entries |
| H4 RESULT + STATUS delivered; status.yaml updated | met | this file; STATUS.md last line `delivered`; status.yaml synced same step (SM3) |
| S1 newcomer end-to-end using only this README | self-reviewed | §1 steps 1–4 (interactive) and §6 (headless) each give a complete start-to-close path; framework docs are read by the session, not required of the operator |
| S2 no contradiction with ORCHESTRATION; tier mapping concrete and current | self-reviewed | each section cites the rule it implements; tier table dated 2026-07-05 with named models per RC2 item 3 |
| S3 honest about limitations | self-reviewed | §8 lists 4 non-enforcements including the untested headless path and the unenforceable VP4 isolation |

## Decisions Made by Executor
1. **No `scripts/` helpers shipped** — INPUT §4 says MAY; M2 do-not-gold-plate. Hard-criteria checks remain documented one-liners.
2. **README in English** — HP2 routes only decision inputs to the human's preferred language; repository artifacts stay English.
3. **Quota caveat phrased as "postpone Verify rather than downgrade it"** — the operational reading of MT3/MT4 for this runtime.

## Deviations & Known Limitations
- §6 headless behavior is designed, not exercised — stated in the product itself (§8).
- Model quotas and pricing change faster than framework documents; the tier table is dated and RC2 item 3 forces review at every touch.

## Handoff
Verification mode: independent (no human). Verify receives: DoD (INPUT.md §5) + `runtime/claude/README.md` + `framework/ORCHESTRATION.md` (the contract H2/S2 cite) + RESULT.md/STATUS.md/status.yaml (H4). Blind package ≈ 40 KB ≈ ~13k read tokens → envelope ~46k (×3.5), charged to parent per VP5.
