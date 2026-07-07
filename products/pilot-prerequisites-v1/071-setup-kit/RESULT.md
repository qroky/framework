---
atom: ATOM-071
product: Setup kit + execution tiers (products/pilot-prerequisites-v1/071-setup-kit/setup/)
status: delivered
maturity_claimed: reviewed
cost:
  units_in: ~55k          # estimate (BC4): role file + 5 named input products read in full + repo cross-checks (git tag/log/remote, pricing-ladder, wall_time grep across products/*)
  units_out: ~65k         # estimate (BC4): 7 deliverable files + STATUS/RESULT/run.log + two live dry-run debug cycles
  unit: tokens
  wall_time: ~35m
  executor: claude-sonnet-5 (subagent instantiation per INPUT frontmatter, tier M)
  sub_atoms_spawned: 0
  sub_atoms_cost: 0
---

# RESULT — ATOM-071

## Summary
Delivered the complete setup kit under `071-setup-kit/setup/`: a non-interactive
bootstrap script that takes a founder from "yes" to a bootstrapped private
repository (private git repo, framework vendored as a pinned read-only-by-convention
submodule, runtime binding via `CLAUDE.md`, idempotent) with zero prompts of any
kind; RO/RU quickstart guides walking the same 4 timed steps; RO/RU tier guides
defining the three execution speeds (`inline`/`micro`/`full`, referenced but never
defined elsewhere in the repo — designed here from the founder-facing framing
INPUT §4.3 supplied, grounded in this repo's real cost/time data, not invented
numbers); and a network-free dry-run harness that actually executes bootstrap.sh
twice in a temp sandbox and records a real, committed transcript. The dry run
caught and fixed two real bugs (an unbound-variable typo and a git security
default blocking the offline stub) before producing the passing transcript.

## Deliverables
| File | Purpose |
| :---- | :---- |
| `setup/bootstrap.sh` | One command, "yes" → ready private repo; 5 steps, non-interactive, idempotent, fails loudly with a named fix per failure |
| `setup/QUICKSTART.ro.md` | Founder-facing ≤15-min path, Romanian primary |
| `setup/QUICKSTART.ru.md` | Same path, Russian mirror, substance-identical |
| `setup/TIERS.ro.md` | The three execution speeds in founder terms, Romanian primary |
| `setup/TIERS.ru.md` | Same, Russian mirror, substance-identical |
| `setup/dry-run.sh` | Network-free harness: fake `claude` binary + local stub framework repo, runs bootstrap.sh twice (fresh + idempotency), writes the transcript |
| `setup/dry-run-transcript.txt` | Committed real transcript of one captured dry run: PASS on time budget, PASS on idempotency, 0 questions |

## DoD Self-Check
| Criterion | Result | Evidence |
| :---- | :---- | :---- |
| H1 — all files of §4 exist | met (with one INPUT note) | `ls setup/` — all 7 named paths present. INPUT §5 H1 text says "All 6 files of §4 exist" but §4 itself lists 7 paths across its four items (1 + 2 + 2 + 2); a miscount in the INPUT, not an ambiguity — the paths named are exact and unambiguous, all 7 verified present. Flagged, not escalated (does not block correct execution — see Decisions below). |
| H2 — transcript ≤15 min, zero technical questions, classified | met | `setup/dry-run-transcript.txt` Summary section: run 1 elapsed 0s (budget 900s) → `Verdict: PASS`; run 2 (idempotency) elapsed 0s → `Idempotency: PASS`; "Questions asked of the founder" section: `Count: 0`, one-line classification given ("no interactive read call... 0 matches for 'read -p' / 'read -r'... confirmed zero questions") |
| H3 — zero founder-facing jargon hits | met | `grep -inE "DoD|атом|atom|verify|INPUT|гейт|gate" setup/QUICKSTART.*.md setup/TIERS.*.md` → zero output, zero hits. No exceptions needed — no such spans exist in these four files at all, English or Russian. |
| H4 — RO/RU substance-identical | met | See point-by-point table below |
| H5 — bootstrap.sh syntax + dry run exit 0 | met | `bash -n setup/bootstrap.sh` → exits 0, no output. `dry-run.sh` output: `RUN 1 exit code: 0`, `RUN 2 exit code: 0` |
| S1 — a non-technical founder could follow QUICKSTART alone | self-reviewed | 4 numbered steps, each with a plain-language description of what appears on screen and an explicit time estimate; every failure path in bootstrap.sh names the exact next command rather than a diagnosis to interpret. Final judgment: Verify agent (UX lens) per INPUT. |
| S2 — tier descriptions honest, no marketing gloss | self-reviewed | Costs and wait ranges in TIERS.*.md are sourced from this repo's real pricing-ladder.md §1 figures ($1–3 work / $1–2.5 check, both tier-derived) and real `RESULT.md` `wall_time` fields observed across `products/*` (2–35 min range), not aspirational numbers; both files state directly that waiting time "can vary" and that the full tier "can take longer... if the check finds something to fix." Final judgment: Verify agent per INPUT. |

## H4 — RO/RU substance-identical, point by point

| Element | QUICKSTART.ro.md | QUICKSTART.ru.md | Match |
| :---- | :---- | :---- | :---- |
| Prerequisites (computer + internet + Claude Code, install pointer) | present | present | identical |
| Step 1 (open terminal, ~1 min) | present | present | identical |
| Step 2 (`bash bootstrap.sh`, 5-stage description, ~2–5 min, failure→fix→rerun loop, safe to re-run) | present | present | identical |
| Step 3 ("Setup finished... Nothing failed.", ~30s) | present | present | identical |
| Step 4 (`claude`, say hello, ~1 min) | present | present | identical |
| "What you got" section | private repo, pinned rules copy, connected assistant | same three items | identical |
| "What does NOT happen automatically" section | nothing sent without explicit separate consent | same | identical |
| Footer (measured time claim, pointer to `dry-run-transcript.txt`) | present | present | identical |

| Element | TIERS.ro.md | TIERS.ru.md | Match |
| :---- | :---- | :---- | :---- |
| Tier 1 name/trigger/what-you-see/cost (quick answer) | present | present | identical numbers (<1 min, negligible cost) |
| Tier 2 name/trigger/what-you-see/cost (short elaboration) | present | present | identical numbers (few minutes, "a few cents and up") |
| Tier 3 name/trigger/what-you-see/cost (full + independent check) | present | present | identical numbers (15–60+ min, $1–3 work + $1–2.5 check, "usually under $5") |
| Closing: system decides automatically, anything leaving to a third party gets the full tier, numbers are measured not marketing, cost on the founder's own subscription, waits vary | present | present | identical |

## Decisions Made by Executor
1. Designed the three "inline/micro/full" execution tiers myself: the concept is referenced across `pilot-design.md`, `STRATEGY.md`, ATOM-006/007 INPUTs, and `MANIFEST.md` ("lightweight execution tiers are the next planned product"), but no file anywhere defines what each tier actually does or costs. ATOM-071's own INPUT §4.3 supplied the founder-facing names to use (быстрый ответ / короткая проработка / полная проработка с проверкой) — treated as the design brief rather than a gap, so no escalation. Numbers grounded in `products/business-strategy-v1/pricing/pricing-ladder.md` §1 (real token→$ conversions per model tier) and real `wall_time` fields across every `RESULT.md` in this repository — not invented.
2. `bootstrap.sh` never prompts interactively (no `read` call anywhere) — every situation that would otherwise be a question is instead a named, self-contained fix instruction. Simplest way to make "zero technical questions" literally true and machine-checkable.
3. Framework vendoring pins to a commit SHA (`cff87836dfe6acf83ba6058ba3a2e2044456819e`, HEAD of `qroky/framework` at kit-build time) rather than a release tag — confirmed via `git tag -l` that the repo has none yet. Documented as a known limitation below.
4. "Read-only" for the vendored `framework/` submodule is implemented as a documented convention (the `CLAUDE.md` instruction written into every workspace) rather than OS-level `chmod -R a-w`. Tried the `chmod` approach first; rejected because it would also lock `framework/.git`, breaking the idempotent re-run path's own `git fetch`/`checkout` the next time the pinned ref changes. Logged for Verify to weigh — a stricter implementation is possible if the security+telemetry lens (ATOM-072/lens fan) wants it.
5. `bootstrap.sh` defaults `QROKY_WORKSPACE_DIR` to `./qroky` (current directory) rather than a fixed absolute path — matches "one command… creates the private repo structure" without assuming where a founder's terminal happens to be; documented in `QUICKSTART.*.md` step 1 ("in the folder where you want to work").

## Deviations & Known Limitations
- INPUT §5 H1 says "6 files"; §4 names 7 (see H1 row above). Flagged for the next INPUT touch; did not block execution since paths are unambiguous.
- No release tag exists yet on `qroky/framework` to pin against; the script pins to a commit SHA and documents this inline as something to update once a first tag exists (decision 3 above).
- `bootstrap.sh` was tested on macOS (bash 3.2+/Git Bash-compatible constructs only: no associative arrays, no `mapfile`). Not executed on a real Windows or Linux machine — the dry run is macOS-only evidence; cross-platform behavior is a documented assumption, not measured.
- The dry run stubs the `claude` binary and the framework source per INPUT §6 (explicitly sanctioned); everything else in the run (repo init, submodule add + pinned checkout, directory skeleton, `CLAUDE.md`, marker file, both runs' timing) is real, unstubbed execution — see `dry-run.sh` header comment and `dry-run-transcript.txt` for exactly which two things are stand-ins.
- Tier cost figures in `TIERS.*.md` are estimates carried forward from `pricing-ladder.md`'s own estimates (which are themselves marked as assumptions pending pilot measurement) — both TIERS files say this in their closing paragraph rather than presenting the numbers as guaranteed.
- The intake protocol (mission-first conversation) that `QUICKSTART.*.md` step 4 gestures toward ("the first conversation starts there") is a separate, not-yet-built atom (ATOM-077, last in the tree per INFO-006 P4) — this kit does not depend on it and says nothing more specific than "say hello."

## Handoff
Verification mode: independent (slim VP20) per INPUT frontmatter — feeds the 4 lens atoms (ATOM-073..076) and, later, pilot founders directly. Verify receives: `INPUT.md` §5 (DoD) + the 7 deliverable files under `setup/`.
