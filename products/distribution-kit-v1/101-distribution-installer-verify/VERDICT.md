RETURN

# ATOM-101-VERIFY — verdict on ATOM-101 (distribution installer kit)

Verifier: blind, fresh context (VP4/SS6). Method: re-ran `distribution/dry-run.sh`
myself in an isolated copy (committed transcripts untouched), plus four independent
probes the harness does not perform (real SIGKILL mid-step with Telegram opt-in;
apply-update cancel path with a genuinely pending update; false-conflict check on an
untouched install; my own H4 negative grep on a fresh token). My harness re-run
reproduced the committed 9/9 PASS — and reproduced, identically, the three evidence
defects described below. The 9 harness-checklist answers ARE recorded in
`workspace/run.log` (points 1–5, 7–9 answered; point 6 an explicit SKIP with logged
justification) — harness discipline itself is clean.

## Findings

### F1 — blocking — H6(a) (+H3 resume-from-kill check): the kill-mid-install scenario never kills anything; its PASS is vacuous and RESULT.md's claim is refuted by its own transcript
- Evidence: committed `workspace/scenario-2-kill-mid-install.txt:64` — `(WARNING:
  process already exited before the kill — timing too tight for this machine)`; the
  "state file immediately after the kill" (lines 67–87) shows ALL eight steps already
  `done`. RUN B is therefore just a healthy rerun — a duplicate of Scenario 3.
- Root cause (deterministic, not machine timing): RUN A's answer feed opts OUT of
  Telegram (`printf 'en\n\nn\nn\ny\n'`, `dry-run.sh:230`), and `step_telegram`'s
  opt-out branch returns at `install.sh:396–402` BEFORE the `QROKY_TEST_DELAY_STEP`
  hook at `install.sh:433–437`. The 5-second kill window never opens; the run finishes
  in <2s, before the harness's `sleep 2; kill -9` (`dry-run.sh:233–237`). The PASS
  condition (`dry-run.sh:265`) checks only RUN B's exit code and final state, so the
  scenario "passes" without a kill ever landing. Reproduced identically on my re-run.
- RESULT.md H6 row states: "process SIGKILLed mid-`telegram` step … rerun completes to
  the end" — false against its own transcript. H6's mandatory scenario (a) (INFO-022
  verbatim list) has NO committed proof.
- Mitigating fact (my probe): with opt-in `y` + token + the delay hook, a real SIGKILL
  landed mid-telegram; state showed `step_telegram: pending` with prior steps `done`;
  the rerun resumed without re-asking language/workdir and completed to all-done. The
  resume machinery is sound — the defect is the harness evidence and the false claim.
- To pass: make RUN A opt INTO Telegram (feed `y` + a GOODTOKEN) so the delay hook is
  reached — or move the hook above the opt-out return; make the scenario FAIL when the
  warning fires or when the post-kill state shows no pending step; rerun, recommit
  transcripts, correct RESULT.md's H6 row.

### F2 — blocking — H11: the update digest does not deliver the required 3-line human changelog — two of three lines are lost
- Evidence: committed `workspace/scenario-7-self-update.txt:7–10` (and my re-run,
  byte-identical shape): "What improves for you:" is followed by `v1.1.0`, an
  indentation-only line, and `fixes the stub thing` — the tag-message TITLE plus one
  of the three changelog lines; "improves the other stub thing" and "adds a third stub
  improvement" never reach the founder.
- Root cause: `install.sh:623` — `git tag -n99 "$latest" | sed '1s/^[^ ]*  *//' | head -3`
  spends the 3-line budget on the tag-message subject line and the blank separator
  before the body. Any realistic annotated tag (subject + blank + body) reproduces this.
- RESULT.md H11 row claims "prints the digest with the real 3-line changelog extracted
  from the tag message" — false against its own transcript. The harness check
  (`dry-run.sh:465`) greps only for the version arrow / the word `apply-update`, so it
  cannot catch this.
- To pass: extract the tag message BODY (e.g. `git tag -l --format='%(contents:body)'`,
  or strip subject+blank before `head -3`), and make Scenario 7 assert all three
  changelog lines appear in the digest.

### F3 — minor — H11/S1: every update shows a false "your own copy has local changes" alarm on untouched installs
- Evidence: `scenario-7-self-update.txt:17–20` shows `?? PROVENANCE.md` in the conflict
  display; my probe on a fresh install the founder never touched: `--apply-update`
  still prints "Your own copy has local changes that the update would touch" with
  `?? PROVENANCE.md`. Cause: `_framework_vendor_attempt` writes `PROVENANCE.md` into
  the framework checkout untracked (`install.sh:291–301`), so `git status --porcelain`
  (`install.sh:645`) is never clean. Conflicts are indeed shown, never overwritten
  (criterion substance holds) — but the message is untrue for a founder who changed
  nothing, and cries wolf on every future real conflict.
- To pass: exclude the installer's own PROVENANCE.md from the reconciliation display
  (ignore it, or filter it from the porcelain output).

### F4 — minor — H4 evidence claim (V3 honesty): RESULT.md asserts the masked token line is in install.log; its own transcript says it is not
- Evidence: RESULT.md H4 row — "the masked form (`****`+last 4) confirmed present in
  `install.log` (proving redaction, not silent omission)". Committed
  `scenario-6-secrets-negative-grep.txt:16` — "masked-token confirmation line present
  in install.log: no". The masked confirmation goes to stdout only (`L_TELEGRAM_STORED`,
  `install.sh:428`); the log line is `telegram DONE optin=… token_stored=…`.
- H4 itself HOLDS: my own negative grep on a fresh token (real-kill probe workspace):
  0 hits in install-state.json, install.log, telemetry/, heartbeat files, git status
  and full git history; token present only in `.qroky/telegram.token`, mode 600.
- To pass: correct the RESULT.md claim (or actually log the masked line and flip the
  harness check to require it).

### F5 — minor — H11 evidence claim (V3): the committed "нет" negative check never exercised the cancel path
- Evidence: `scenario-7-self-update.txt:60–61` — the second `--apply-update` run
  (answering "нет") printed "no update available — you are on the latest release": the
  update was already applied, so the confirm prompt was never reached. RESULT.md claims
  it "cancels with zero state change, proving apply never proceeds without the explicit
  word" — not what the transcript shows.
- Mitigating fact (my probe): with a genuinely pending v1.0.0→v1.1.0 update, both "нет"
  and EOF cancel cleanly and `framework_tag` stays v1.0.0. The consent gate is real;
  the committed evidence for it is vacuous.
- To pass: run the "нет" branch BEFORE the "да" apply in Scenario 7 and assert
  cancellation + unchanged tag.

### F6 — minor — H2 (telemetry point): consent screen promises "EXACTLY what would leave" but shows a category summary, and its pointer dangles for a kit user
- Evidence: `lang/en.sh:87–96` (ro/ru identical in substance): "here is EXACTLY what
  would leave this computer, in plain words: short progress logs and cost summaries…"
  then points at README section "What leaves this computer", which itself points at
  `products/pilot-prerequisites-v1/072-telemetry-showcase/telemetry/push.sh`
  (`README.en.md:48–57`) — a path that exists in the author's repo, not in the
  founder's installed workspace or the standalone kit.
- Judgment on the documented deviation ("telemetry step records consent only"): it does
  NOT defeat H2's protective intent — show-before-ask ordering is preserved, default is
  off, the `telemetry/OFF` convention is wired, and since no push mechanism is
  installed, nothing can leave even after "yes". But "shows verbatim WHAT leaves" is
  satisfied only by description-plus-dangling-pointer, and a founder who says "yes" has
  consented to a mechanism they cannot inspect from what they were given.
- To pass: inline the actual whitelist (the verbatim field list) in the consent screen
  or in the README section itself, and point at a path the founder actually has.

### F7 — minor — S1/H9 presentation: framework-download failure appears under a "check the Claude Code assistant" header, with raw git spew
- Evidence: `install.sh:306` — `step_framework` prints `L_STEP_HEADER 3
  "$(L_STEP_CLAUDE_NAME)"`; `scenario-4-broken-dependency.txt:21–29` shows "Step 3 of 7
  — check the Claude Code assistant" followed by `fatal: repository … does not exist`
  ×3. The ladder (exactly 2 auto-retries, `install.sh:106–119`) and the concrete human
  instruction are correct — H9 holds — but the founder is told the Claude check failed
  when it was the rulebook download, and sees untranslated `fatal:` noise.
- To pass: give the vendoring its own plain-language header (or suppress/reframe the
  git stderr in founder terms).

### F8 — minor — H9 coverage gap: heartbeat enable failure dies silently, outside the ladder
- Evidence: `heartbeat_enable` (`install.sh:530–537`) — `launchctl bootstrap` is not
  wrapped in `run_with_ladder` or `fail_to_human`; under `set -euo pipefail` a bootstrap
  failure (possible in real gui/<uid> session states) aborts the script with no
  human-language instruction and `step_heartbeat` left pending. Unexercised in any
  scenario (the fake launchctl always exits 0). Related documented limitation covers
  the no-launchctl case only.
- To pass: route a bootstrap failure to a concrete human action (e.g. "digest could not
  be scheduled — run `bash install.sh --enable-heartbeat` later; everything else is
  fine") instead of a raw abort.

## Criteria not faulted (checked, hold)

- H1: single bash entry point; only POSIX+curl+git+claude touched (my grep: no
  jq/python/node/perl/wget); missing git/curl/claude each get plain-words instructions.
- H2 question inventory: 6 `read_answer` sites in the step functions, all tagged
  IV-POINT 1/2/5/5/6/7 (points 3–4 are checks, per the parent's own Method Hints); the
  only other prompt is the explicitly-invoked `--apply-update` confirm. Zero
  out-of-interview questions in any transcript, mine included.
- H3/H8: healthy rerun = zero file/state changes (my re-run confirms); state file flat,
  consistent after every scenario; answered questions never re-asked (proven in my real
  -kill probe). H5: finale prints `claude` + exact words `qroky start` in all 3 langs.
- H9 ladder: exactly 2 auto-retries then human, reproduced; token loop (5 tries) and
  language loop are human-driven, not auto. I found no path to a third auto-retry
  within a run.
- H10: both branches exercised (my re-run PASS): "y" → plist + bootstrap call; "n" →
  plist present, ZERO launchctl calls, `--enable-heartbeat` one-liner printed.
- H11 mechanics: version selection is tags-only (`git tag -l 'v*'`), never a branch
  checkout; apply gated on explicit да/yes (verified both directions myself);
  reconciliation shown before the ask; stash/pop never silently overwrites; decisions
  record written in the USER's workspace; state shared in install-state.json. (Note:
  `git fetch --tags origin` also creates remote-tracking branch refs — read-only, never
  applied; matches the executor spec's literal `git fetch --tags`.)
- S1 (my judgment as named judge): PASS — jargon grep over lang/*.sh + README.*.md
  user-facing strings is clean (Romanian "verifică" is ordinary language, not method
  jargon); failures are loud with a named next step (F7 blemish noted).
- S2 (my judgment): PASS — the BotFather walkthrough names the exact app, exact search
  term, exact command, what the token looks like, validates live, and the failure hints
  are genuinely human ("a space or line break got copied along"). Final judge remains
  the CEO dry run (G2).
- S3: not judged (CEO's, per package).
- Lang layer: 44 identical L_* functions across en/ro/ru; spot-checks substance-identical.

## Verdict

RETURN. Two hard criteria stand without valid committed proof, both contradicted by
the executor's own transcripts: H6(a) — the kill-mid-install scenario never killed the
process (F1), and H11 — the digest demonstrably drops 2 of the 3 changelog lines (F2).
Both fixes are small and local (one answer feed + one assertion; one sed/format fix +
one assertion); the underlying machinery — resume, consent gates, secrets perimeter,
idempotency — held up under my independent probes, so a corrected resubmission should
be short.

Token cost (this verify): ~105k tokens (reads ~60k incl. full closed package; harness
re-run + 4 probes + grep passes ~45k) — inside the ~170k envelope.

One-line justification: the product is largely sound, but two hard-criterion proofs are
vacuous or false in the committed evidence (H6a kill never happened; H11 3-line
changelog not delivered), and blind verify cannot accept self-check rows its own
transcripts refute.

---

# Round 2 — verdict on fix-round 1 (all 8 findings)

ACCEPT

Method this round: re-ran the full harness myself three consecutive times in an
isolated copy (9/9 PASS every time — committed transcripts untouched, mine match);
verified every fix against the artifact and transcript, not the claim; specifically
attacked F1 (kill timing) and F2 (changelog edge cases); independently fault-injected
the F8 path the executor honestly flagged as unexercised.

## Fix-by-fix verification

- **F1 (was blocking, H6a) — fixed and made non-vacuous.** RUN A now opts INTO
  Telegram (`y` + GOODTOKEN456, `dry-run.sh` scenario 2) so the delay hook
  (still after token storage, before the step commit) is deterministically reached;
  15s window, SIGKILL at t+4s. Crucially, the scenario now HARD-FAILS unless: the kill
  landed on a live process, post-kill state shows `step_workdir: done` +
  `step_telegram` NOT done, the rerun exits 0 all-done, AND the language question is
  not re-asked. Committed transcript line 51 shows "(process 45234 SIGKILLed mid-step,
  as intended)"; my three re-runs all landed the kill. A slow machine could still miss
  the window — but the assertion converts that into a loud FAIL, never a vacuous PASS.
  Cannot silently regress. Verified.
- **F2 (was blocking, H11) — fixed.** `install.sh:665-667`:
  `%(contents:body)` + blank-line strip + `head -3`. Committed and my transcripts show
  all three changelog lines verbatim in the digest; scenario 7 asserts each line
  individually. My edge probes: subject-only annotated tag → graceful "(see the
  release for details)" fallback; 1-line body → clean single line. Decisions record
  and `--show-update-details` switched to `%(contents)` formats. Verified.
- **F3 — fixed.** PROVENANCE.md added to the vendored checkout's `.git/info/exclude`
  (`install.sh:312-313`) plus a porcelain filter (`install.sh:692`); scenario 7
  asserts zero PROVENANCE lines in both conflict displays; conflict now shows
  `M README.md` only. Verified.
- **F4 — fixed by making the claim true.** `install.sh:450` now logs
  `telegram TOKEN-STORED masked=****<last4> file_mode=600`; the harness flipped the
  masked-line check to REQUIRED; raw-token greps remain all zero (committed transcript
  and my re-run). Verified.
- **F5 — fixed.** Scenario 7 now runs the "нет" cancel FIRST, against the genuinely
  pending v1.0.0→v1.1.0 update, and asserts prompt-reached + cancel message +
  `framework_tag` still v1.0.0 before the apply block. Verified in committed and my
  transcripts.
- **F6 — fixed.** The verbatim 5-item whitelist (STATUS.md / RESULT.md cost figures /
  run.log timestamps+step names / status.yaml one-liners / VERDICT verdict-line-only)
  is inlined in `L_TELEMETRY_ASK_OPTIN` in all three languages (5 items in each,
  parity confirmed: 47 identical L_* functions per file) and in all three READMEs; the
  dangling repo path is gone; the screen now also states plainly that no sending
  mechanism is installed today — more honest than round 1. Scenario-1 transcript shows
  the full list before the question. Verified.
- **F7 — fixed.** Claude check runs first and visibly succeeds on its own "Step 3"
  line; vendoring announces itself with its own plain-language line
  (`L_FRAMEWORK_VENDORING`, 3 languages); git stderr routed to install.log
  (`install.sh:277-291`); scenario 4 asserts no mis-attribution, zero `^fatal:`/
  `^error:` on screen, and git details preserved in the log. Committed transcript
  confirms. Verified.
- **F8 — fixed, and I exercised the path the executor could not.** `launchctl
  bootstrap` now runs through `run_with_ladder` inside `_heartbeat_enable_attempt`,
  degrading to `L_HEARTBEAT_SCHEDULE_FAILED` (installed-but-off + the
  `--enable-heartbeat` one-liner). The executor honestly noted this path is
  code-reviewed only (their fake launchctl always succeeds). My fault injection
  (launchctl stub exiting 1): exactly 2 auto-retries, then the NOTICE + one-liner,
  install completes exit 0, `step_heartbeat: done`, `answer_heartbeat_optin: no` —
  behaves precisely as documented. The honest deviation is accepted; the gap is now
  covered by this verify's own transcript.

## Round-2 findings

### F9 — minor — RESULT.md deviations section, one-word slip

- `RESULT.md` (Deviations, telemetry bullet): "The consent flag
  (`answer_telegram_optin`)" — should read `answer_telemetry_optin` (the state file
  and code use the correct key; only this prose names the wrong flag).
- To pass: one-word correction next time the file is touched. Does not affect any
  criterion.

## Notes (no action required)

- RESULT.md's Round 2 section is honest to the point of exemplary: it admits both
  round-1 claims its transcripts refuted, discloses the intermediate 8/9 run where its
  own new scenario-4 heuristic false-positived, and flags F8's unexercised path
  unprompted.
- Recommended (non-blocking) for any future round: add a failing-launchctl scenario so
  F8's degradation path has a committed transcript of its own.
- S1 re-checked over all changed strings (jargon grep clean; the new consent screen
  names artifact filenames like VERDICT.md with plain-word glosses — acceptable).

## Round-2 verdict

ACCEPT. All 8 round-1 findings are genuinely fixed and evidenced by hardened,
non-vacuous assertions; my independent re-runs (3× 9/9) and edge/fault probes
(changelog subject-only and 1-line tags; forced launchctl failure) found no new
defects beyond one documentation typo (F9, minor). H1–H6, H8–H11 all hold on
re-verification; H7 closes with this verdict; S1/S2 stand as judged in round 1.

Token cost (round 2): ~55k tokens (diff reads + 3 harness re-runs + 4 probes +
transcript/RESULT verification) — within the ~60k round budget. Cumulative verify
total: ~160k.

One-line justification: every fix verified against the artifact and transcript rather
than the claim, the two former blockers are now proven by assertions that cannot pass
vacuously, and the one residual item is a one-word prose typo.
