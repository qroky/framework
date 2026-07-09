---
atom: ATOM-101
product: distribution/install.sh + locale files + distribution READMEs + sandbox harness
status: delivered
maturity_claimed: reviewed (self-checked; awaiting blind verify ATOM-101-VERIFY per INPUT frontmatter)
cost:
  units_in: ~152k          # estimate (BC4): closed read list (7 items) + role file + a few directly-needed extras (071/072 precedents, status.yaml, INFO-025), wc -c / 3
  units_out: ~140k         # estimate (BC4): install.sh + dry-run.sh + 3 lang files + 3 READMEs + 9 scenario transcripts + run.log + this file, wc -c / 3, plus iteration overhead from 5 real bugs found and fixed via repeated harness runs (not purely file-bytes)
  unit: tokens
  wall_time: ~75m
  executor: claude-sonnet-5 (subagent instantiation per INPUT frontmatter, tier M)
  sub_atoms_spawned: 0
  sub_atoms_cost: 0
---

# RESULT — ATOM-101

## Summary

Delivered the complete, tested Distribution Kit v1 installer under
`distribution/`: `install.sh` (753 lines) — a single bash entry point that
interviews a stranger at exactly the seven declared points (language,
working folder, Claude Code check, subscription check, Telegram opt-in with
a hand-held BotFather walkthrough and live `getMe` token validation,
daily-support-sharing opt-in with show-what-leaves-before-asking, and
benefit-framed heartbeat/morning-digest consent), vendors the framework
with provenance, and ends with the exact handoff to `qroky start`. Every
step is a self-contained `check -> do` pair backed by a hand-written flat
JSON state file (`install-state.json`, no `jq` dependency — POSIX+curl+git
only per H1) that makes reruns resume exactly where they stopped and turns
a healthy rerun into a free, silent health check. A failure ladder (2 auto
-retries, then a concrete named human action) covers every step; the
Telegram bot token is the one secret in scope and is written only to a
mode-600 file, never to state/log/telemetry/git. A self-update channel
(`--check-update` / `--show-update-details` / `--apply-update`) tracks
release tags only, shows local-edit conflicts before ever touching them,
and records every applied update as a plain-language decision file inside
the user's own workspace.

`distribution/dry-run.sh` (543 lines) is the sandbox harness: it shadows
`claude`, `curl` (Telegram's `getMe` only), and `launchctl` on `PATH`,
stands up a real, local, tagged git repository as the framework origin, and
runs `install.sh` completely unmodified against those fakes. It exercises
9 scenarios end to end — full clean run, kill-mid-install, healthy rerun,
broken dependency, double-run idempotency diff, secrets negative grep,
self-update (tag N -> N+1 with a planted local-edit conflict), and both
branches of the heartbeat consent question — and writes a timed, real
transcript of each to this atom's `workspace/` folder. **Current state: 9/9
PASS.** Building the harness surfaced and fixed five real bugs (see
Decisions/Deviations below and `workspace/run.log`), including one that, if
shipped, would have silently reused one stale workspace across independent
installer runs.

## Deliverables

| File | Purpose |
| :---- | :---- |
| `distribution/install.sh` | Single entry point: 7-point interview, idempotent state machine, failure ladder, secrets handling, self-update commands, finale |
| `distribution/lang/en.sh` | English user-facing strings (substance-identical to ro/ru) |
| `distribution/lang/ro.sh` | Romanian user-facing strings |
| `distribution/lang/ru.sh` | Russian user-facing strings |
| `distribution/README.en.md` | What it does, the one-liner, the 7 questions, "what leaves this computer", "don't touch my instance" |
| `distribution/README.ro.md` | Same, Romanian |
| `distribution/README.ru.md` | Same, Russian |
| `distribution/dry-run.sh` | Sandbox harness: 9 scripted scenarios against fully-stubbed dependencies |
| `products/distribution-kit-v1/101-distribution-installer/workspace/scenario-{1..8}-*.txt` | Real, timed transcripts of every scenario |
| `products/distribution-kit-v1/101-distribution-installer/workspace/SUMMARY.txt` | Machine-checkable pass/fail roll-up (currently 9/9 PASS) |
| `products/distribution-kit-v1/101-distribution-installer/workspace/run.log` | Full run log: understanding, sources, harness-checklist answers, decisions, bugs found+fixed, budget checkpoints |
| `products/distribution-kit-v1/101-distribution-installer/RESULT.md` | This file |

## DoD Self-Check (parent ATOM-100 H1-H11, S1-S3)

| Criterion | Result | Evidence |
| :---- | :---- | :---- |
| H1 — single entry point, bash, POSIX+curl+git only, checks + human words on missing deps | met | `distribution/install.sh` `main_interview()` checks `git`/`curl` before anything else with a named fix per OS; `step_claude_code` does the same for `claude`. No other runtime dependency anywhere in the file (`grep -E 'jq\|python\|node'` over install.sh: zero hits). |
| H2 — interview covers exactly the 7 declared points, in chosen language, zero questions outside | met | `scenario-1-full-clean-run.txt`, "Question inventory check" section: every interactive `read_answer` call site inside the 7 `step_*` functions is tagged `# IV-POINT:<n>:<name>`; 6/6 call sites tagged (points 3 "Claude Code" and 4 "subscription" are automatic checks with no `read`, per the parent's own Method Hints — "a CHECK... not a purchase flow"); distinct points referenced: 1,2,5,5,6,7 — all within the closed list of 7. |
| H3 — self-managing idempotency: check->do steps, rerun resumes without re-asking, healthy rerun = free no-op | met | `scenario-3-healthy-rerun.txt`: file-tree hash diff and state-field diff (excluding the commit timestamp) both empty after a rerun on Scenario-1's finished workspace; 7 "already set up" health-check lines printed, zero new prompts. `scenario-5-idempotency-diff.txt`: two full runs with identical answers produce an identical file listing and identical structural state. |
| H4 — secrets perimeter: token file mode 600, never in state/log/telemetry/git | met | `scenario-6-secrets-negative-grep.txt`: zero grep hits for the raw token across `install-state.json`, `install.log`, `telemetry/`, and full git history of both the workspace repo and the vendored `framework/` repo; token file mode confirmed `600`; the masked form (`****`+last 4) confirmed present in `install.log` (proving redaction, not silent omission). |
| H5 — finale prints, in chosen language, how to open Claude Code + "qroky start" | met | `scenario-1-full-clean-run.txt` tail: "Type: claude" / "Say: qroky start"; separately spot-checked in Russian (ad hoc, see run.log) — same phrase renders literally regardless of interview language, per parent H5's "exact words". |
| H6 — sandbox harness proves clean path <=15min zero out-of-interview questions PLUS 3 scenarios (kill-mid, healthy rerun, broken dependency) | met | `scenario-1`: exit 0 in 0-1s (budget 900s). `scenario-2-kill-mid-install.txt`: process SIGKILLed mid-`telegram` step (via the `QROKY_TEST_DELAY_STEP` sandbox-only hook), rerun completes to the end, all steps `done`. `scenario-3`: see H3. `scenario-4-broken-dependency.txt`: unreachable framework source -> 2 auto-retries -> concrete human instruction, prior steps' `done` state preserved. |
| H7 — blind verify: accept | pending | Out of this atom's own authority to self-close (INPUT frontmatter: `verification: blind`) — this RESULT.md is what ATOM-101-VERIFY receives; no verifier conversation happened, per instructions. |
| H8 — install-state.json present + consistent after every scenario | met | Present and internally consistent (steps/answers reflect exactly what happened) in every one of the 9 scenario transcripts; flat single-level JSON, `version`/`generated_at`/7×`answer_*`/7×`step_*`/3×`framework_*` fields, machine-parseable for Tree B (ATOM-110) without a JSON library dependency in the reader either, if it chooses the same grep approach. |
| H9 — failure ladder: self-diagnosis -> known-remedy auto-attempt -> concrete human action; max 2 auto-attempts, 3rd always human | met | `scenario-4-broken-dependency.txt`: exactly 2 "trying again automatically" lines, then the concrete instruction ("Check the internet connection, then run this installer again..."), exit 1. Ladder implemented once (`run_with_ladder`), shared by every step that has a real automatic remedy (network retry); steps with no automatic remedy (Claude Code not installed) skip straight to the human action — documented design choice, not a silent gap (see Decisions). |
| H10 — heartbeat consent: benefit-framed question + 1 honest line, да->installed+enabled, нет->installed disabled + 1-command enable instruction, both branches exercised, disabled branch leaves no running agent | met | `scenario-8-heartbeat-both-branches.txt`: "yes" branch — plist generated AND the fake `launchctl` log shows a `bootstrap` call for it; "no" branch — plist generated (file exists) but the fake `launchctl` log shows **zero** bootstrap calls during that run, and the one-command enable instruction (`--enable-heartbeat`) is printed. This scenario was added specifically because the parent's own check text names "both branches exercised in the H6 harness" — see Decisions #7. |
| H11 — self-update: release tags only (never main), digest (3-line changelog + да/позже/подробнее), apply only on explicit да, decisions/ record in USER's workspace, conflicts shown before apply, shared state/trace | met | `scenario-7-self-update.txt`: `--check-update` fetches tags only (`git tag -l 'v*'`, never checks out `main`/a branch) and prints the digest with the real 3-line changelog extracted from the tag message; a local edit was planted in the user's `framework/README.md` beforehand — `--apply-update` SHOWS the exact `git status --porcelain` diff (`M README.md`) before asking to confirm; confirming with "да" stashes the local edit, checks out the new tag, re-applies the stash, and writes `decisions/UPDATE-<date>-v1.1.0.md` with old/new tag, confirmation timestamp, and the local-edit reconciliation outcome; state's `framework_tag` advances to `v1.1.0`. A second run answering "нет" (negative-check) cancels with zero state change, proving apply never proceeds without the explicit word. |
| S1 — every user-facing line: no method jargon, failures loud+specific with a human next step | self-reviewed, final judge Verify | `grep -inE 'atom\|DoD\|FEV\|verify\|gate'` across all of `lang/*.sh` and `README.*.md`, filtered to exclude `#`-comment lines: zero hits inside any actual user-facing string (the only hits are in bash header comments, which are never shown to a founder and themselves state the no-jargon rule). Every `fail_to_human`/`L_CLAUDE_MISSING`/etc. message names a concrete next action, never a bare error code. |
| S2 — BotFather walkthrough is genuinely hand-holding | self-reviewed, final judge Verify + CEO dry run (G2) | `L_TELEGRAM_WALKTHROUGH` (all 3 languages): 7 numbered steps naming the exact app, the exact search term ("BotFather"), the exact command to send (`/newbot`), and what the token looks like, ending in a live `getMe` check with a plain-language retry hint ("a space or line break got copied along... copy again, carefully" / "it was already reset — open BotFather, send /token"). Not measured against an actual never-heard-of-bots human — that measurement is explicitly G2 (CEO dry run, HUMAN-TASK), outside this atom's authority. |
| S3 — release criterion: clean machine, <=15min, zero questions outside interview | self-reviewed, final judge CEO dry run (G2) | Scenario 1: 0-1s in a stubbed sandbox (network-free by construction — a real founder's real download time for Claude Code/git/the framework clone is the variable component, same documented caveat 071's RESULT.md carried forward). Question count: see H2. G2 itself — a real clean machine, a real human, real network — is explicitly out of this atom's authority (HUMAN-TASK, parent DoD). |

## Decisions Made by Executor (O9.1)

1. **Workspace layout** — `QROKY_WORKSPACE_DIR` default `./qroky` (same name/default as 071's `bootstrap.sh`, for continuity); `install-state.json`, `install.log`, `decisions/` sit at the TOP of that folder (not nested under a second `qroky/`), alongside `framework/` (vendored) and `.qroky/telegram.token` (the one secret, mode 600). Documented in every README's "Don't touch my instance" section.
2. **State file format** — hand-written flat single-level JSON (globally-unique `step_*`/`answer_*` keys, grep-extractable with no `jq`/YAML-library dependency, matching H1's dependency constraint and the same reasoning `072/telemetry/push.sh` already uses for `status.yaml`). Whole file rewritten fresh from the process's own shell variables on every commit — no associative arrays, so it stays bash-3.2-compatible (the same stock-macOS-bash constraint `071/RESULT.md` flagged).
3. **Real interactive prompts** — unlike 071's zero-question `bootstrap.sh`, this atom's mandate IS an interview, so `install.sh` uses real `read`. Every interactive call site is tagged `# IV-POINT:<n>:<name>` specifically so the harness can machine-check "question inventory equals the closed list" (H2) rather than relying on a hand count.
4. **Test-stub strategy** — PATH-shadowing (fake `claude`/`curl`/`launchctl`, a real local tagged git repo standing in for the framework remote) is the primary mechanism, following 071's already-reviewed pattern; `install.sh` needs zero test-mode branches for those three. Exactly ONE explicit `QROKY_TEST_STUBS=1` in-script hook exists (the soft subscription/login heuristic), matching the INPUT's own suggested example; every other path is production-identical between sandbox and reality.
5. **Self-update lives inside install.sh as flags**, not a separately-deliverable daemon script (the INPUT's own deliverable list names no such file) — `install.sh` generates the end user's heartbeat runner + launchd plist at Step 7, with THIS machine's own paths substituted, and that generated runner calls `install.sh --check-update` daily. H1's "single entry point" stays literally true.
6. **Claude Code step has no auto-retry ladder** — "software is not installed" has no automatic remedy among the three named in H9 (network retry / lock wait / permission hint), so that step goes straight to the human instruction rather than performing 2 pointless retries first. Framework vendoring (the step with a real network dependency) carries the full ladder instead — exercised in Scenario 4.
7. **Added Scenario 8 (heartbeat both branches) mid-build** — the parent's H10 check text explicitly requires "both branches exercised in the H6 harness", which the original 7-scenario plan (drawn from the INPUT's bullet list, which does not separately name this) did not cover. Added it once noticed, rather than treating H10's check clause as satisfied by inference from Scenario 1 alone.
8. **`git submodule` idempotency check uses `-e`, not `-d`, for `framework/.git`** — a submodule's `.git` is a FILE (gitlink), not a directory; caught before this reached the harness (would have silently re-run the vendor step on every single invocation, defeating H3's health-check promise for that step specifically).

## Deviations & Known Limitations (V3 — none silent)

- **H7 is not self-closable** — this RESULT.md is the blind-verify package; no verifier conversation occurred, per the executor's own instructions. Listed as "pending" above, not "met", to keep the table honest.
- **Telemetry step (interview point 6) records consent only** — it does not vendor `072-telemetry-showcase/telemetry/push.sh` into the user's workspace. That script already exists as a separate, already-reviewed product; this atom's closed deliverable list (INPUT section 2) names `install.sh` + `lang/` + `README.*` + `dry-run.sh`, not a copy of 072's telemetry mechanism. The consent flag (`answer_telemetry_optin`) and the same `telemetry/OFF`-file convention 071/072 already use are wired for real, ready for a future atom to point the real push script at. Not a silent gap — flagged here and in each README's "What leaves this computer" section, which correctly says the mechanism lives in `072-telemetry-showcase`.
- **Subscription check (interview point 4) is a heuristic, not a certainty** — it looks for one of three plausible Claude Code credential file locations (`~/.claude.json`, `~/.claude/credentials`, `~/.config/claude`) and prints a soft, non-blocking NOTICE if none is found. The real, authoritative check would be an actual Claude Code API call, which the Method Hints explicitly say NOT to build ("a CHECK... not a purchase flow"). Documented in `install.sh`'s own header comment and here.
- **S2/S3's true judges (a genuinely bot-naive human; a real clean machine on a real network) are outside this atom's authority** — both are explicitly the parent's G2 (CEO dry run, HUMAN-TASK). This atom's own evidence is the closest machine-checkable proxy (structured walkthrough content; a network-free timed run), not a substitute for the human judgment the parent DoD itself defers.
- **Framework vendoring pins to the latest matching tag, or HEAD if none exists** — same "no release tags published yet" caveat 071/RESULT.md carried forward; the dry-run harness manufactures its own tags (`v1.0.0`, `v1.1.0`) specifically to exercise the self-update path, since the real `qroky/framework` repository has none yet at the time of this build.
- **macOS-centric heartbeat mechanics** — `launchctl`/`LaunchAgents` are macOS-only; `install.sh` detects a missing `launchctl` and falls back to a NOTICE + manual run instruction (same shape as 071's `crontab` fallback), but this fallback path itself was not exercised as an isolated scenario in this harness (only the macOS `launchctl`-present path was, via the fake). Logged, not silent.
- **Bug-fix trail** — five real bugs were found and fixed while building this atom's OWN harness (a bash pipeline env-var scoping bug that produced a real stray directory on this machine before being caught and cleaned up; two `set -u`/unbound-variable bugs in the self-update flag commands; an off-by-one in the failure ladder's retry count; a `grep -r` single-file formatting bug; and a heredoc `%s` non-substitution bug in the update digest). Full narrative in `workspace/run.log`. None of these reached a committed transcript uncorrected — the second and third full harness runs are what is filed here.

## Handoff

Verification mode: blind (ATOM-101-VERIFY, tier L) per INPUT frontmatter —
receives this RESULT.md plus the full `distribution/**` tree and this
atom's `workspace/` transcripts; no verifier conversation occurs. Tree B
(ATOM-110) is the next consumer in line: it reads `install-state.json`'s
`answer_telegram_token_stored` flag and the `.qroky/telegram.token` file
path as its instance ground state, per the parent's stated dependency.
