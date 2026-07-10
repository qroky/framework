# RESULT — ATOM-110 (Telegram head v1)

## TEAM summary

Executor: pilot-toolsmith (warm, maturity run 3 — installer kit r1/r2 and
v0.1.1 precede this). Mandate: INFO-032 verbatim, amended by INFO-033
(two-contour channel model, lex posterior). G1 = GATE-026. One executor, no
child spawns (the build is one coherent script family — spawn proportionality
per INFO-018: nothing here decomposes below one toolsmith without inventing
seams). Blind verify (L) is the next consumer; G2 (live phone round-trip) is
the CEO's, in the second-Mac test window.

## Deliverables (all under `runtime/claude/telegram/`)

| File | What it is |
| :---- | :---- |
| `lib.sh` | shared plumbing: profile defaults+overrides, token-from-file, `tg_api` (curl, ≤2 retries), atomic tmp+rename writes, quiet-hours clock, signaled registry, `/status` renderer |
| `listener.sh` | ONE polling pass (launchd StartInterval=30s): getUpdates → per update: chat_id check, instant ack SENT BY THE LISTENER, durable inbox file, handler wake; narrative sweep; quiet-queue flush; offset survives restarts; lock against overlap |
| `handler.sh` | the only LLM home: «кроки» → skill protocol, free-input router (exactly ONE re-ask → `task-proposal` inbox file), promise open/keep/resume; honest no-LLM degradation |
| `pickup.sh` | mechanical inbox consumption: gate answers → decision records; render-then-move idempotency = exactly-once effect |
| `send-event.sh` | THE shared outbound helper (session AND heartbeat callers): gate/e1/result/overdue/beat/info, inline buttons, risk-word rule, quiet-hours queue (blockers first at flush), signaled registry |
| `record-decision.sh` | THE decision-record renderer for BOTH channels — parity by construction |
| `digest.sh` | digest contour: «сделано / в работе / ждёт тебя сегодня / расход» + 3-line changelog on a new release tag; signaled events as status lines; once-a-day marker |
| `install.sh` / `uninstall.sh` | launchd install (both jobs), `--bind` chat_id walkthrough, `--status` health check, `--render-plists-only` harness hook |
| `launchd/*.plist` | listener (StartInterval 30) + digest (StartCalendarInterval from profile `DIGEST_TIME`, daily) |
| `profile.conf.example` | the two contours configured independently: digest time, quiet hours, detail level, risk word, token path |
| `README.md` | operator documentation incl. production setup (5 steps) |
| `dry-run.sh` | sandboxed harness: 11 scenarios, stubbed Bot API (PATH-shadowed curl — production code path untouched), stub LLM, fixture repo root; transcripts → this atom's `workspace/` |

Inbox conventions (consumed by session/heartbeat): `decisions/inbox/` one
event per file, atomic; `done/` = consumed ledger; `quarantine/` = foreign
material. Kinds: `gate-answer`, `user-message`, `kroky`, `task-proposal`,
`promise`.

## DoD self-check (INPUT §4)

| Criterion | Status | Evidence (workspace/) |
| :---- | :---- | :---- |
| H1 parity round-trip; session diff = channel only | met | scenario-1: record carries gate id + full question as sent + verbatim label + ts + channel; diff vs session record = exactly 2 lines, both `channel:` (asserted non-empty) |
| H2 closed-session press → persisted → consumed exactly once; kill-mid-write complete-or-nothing | met | scenario-2: press with no session persisted; two wakes → 1 record, second wake no-op; SIGKILL proven inside tmp→rename window (tmp remnant asserted), 0 partial files, offset not advanced, re-delivered next pass |
| H3 polling only, no ports, offset survives, plain script, ack cadence | met | scenario-3: `lsof` empty on a LIVE pass (liveness asserted), restart resends nothing, offset == last update id, plist StartInterval=30 |
| H4 chat_id binding | met | scenario-4: foreign message AND foreign press → 0 replies, 0 events, 2 flag lines, 2 quarantine records |
| H5 risk-word rule | met | scenario-5: risk item sent with NO buttons + word named; button-style reply rejected & re-asked (0 records); typed word recorded verbatim |
| H6 digest: profile time ±5, 4 sections, no duplicate alarms, changelog | met | scenario-6 (content, planted already-signaled gate → status line, 3-line changelog on new tag, once/day) + scenario-3 (plist Hour:Minute == profile, daily); ±5 rides launchd StartCalendarInterval as H6 explicitly allows |
| H7 events at the moment they occur, one shared helper, beats per level | met | scenario-7: heartbeat-side calls to `send-event.sh` sent instantly (no session, no listener); levels 1/2/3 all exercised; no re-sends (per-file offset) |
| H13 ≤1 min ack; «принял, результат к N»; promise survives kill | met | scenario-8: ack in the same pass (pass <25s + 30s cadence ⇒ worst case <60s); promise file written BEFORE work; kill -9 proven against live handler pre-result; after wake result delivered, promise closed |
| H14 quiet hours: queue, blockers first, user still acked | met | scenario-9: night events 0 sent / 2 queued; night user message acked; morning flush blocker FIRST (order asserted) |
| H8 /status ≤1 message | met | scenario-10: `/status` and «что в работе» rendered from status.yaml, one message each |
| H9 router: ONE re-ask → task-proposal; «кроки» routes to the skill | met | scenario-10 (one clarify, zero second re-asks, task file valid, bot executed nothing) + scenario-8 (кроки routed to handler/skill path) |
| H10 secrets | met | scenario-11: token proven to flow (stub marker + non-empty payload), zero occurrences in log/state/records/sent/committed/transcripts |
| H11 harness, checklist in run.log, full run green | met | 11/11 PASS (SUMMARY.txt); INFO-025 answers in run.log before build |
| H12 blind verify accept | pending | next step — not self-closable |
| S1–S3 (CEO judgment at G2) | pending | phone screen reading and live round-trip are the human's judgment by design |

## Decisions made by executor (O9.1 — full list D1–D13 in run.log)

Highlights: single-pass listener under launchd StartInterval=30s (cadence
holds ≤1 min with margin, no daemon pretense); parity by construction (one
renderer, channel is an argument); render-then-move idempotent pickup
(deterministic timestamps make re-render byte-identical → exactly-once
effect without locks); quiet queue flushed by the listener pass with blocker
prefix ordering; python3 as JSON parser only (dependency with loud
degradation); deny-by-default before chat binding; risk classification
belongs to the CALLER of send-event (session/heartbeat), the head only
enforces word-not-button.

## Deviations & known limitations (V3 — none silent)

- **No-LLM degradation branches of handler.sh are code-read-only** (the stub
  LLM always answers; the claude-CLI-missing paths — honest chat notices +
  event kept in inbox — follow the F8-precedent evidence class).
- **tg_api network-failure ladder (retry ≤2 → queue) is not exercised in the
  committed green run** — the stub never fails. It WAS exercised de facto by
  the broken first runs (see run.log bug trail), but that is anecdote, not a
  committed scenario.
- **`install.sh --bind` and the real launchctl bootstrap are not
  scenario-exercised** (interactive stdin / real LaunchAgents); plist
  rendering IS asserted (scenario-3). Same class as the kit's F8 note.
- **Digest ±5 min rests on launchd StartCalendarInterval precision** —
  explicitly allowed by H6's wording; no simulated-clock daily soak was run.
- **Orphan-promise branch** (promise present, its work file lost) is
  code-read-only — scenarios always keep the work file, as the design
  intends.
- **Level-2 beat filter is a heuristic** (bold-opening lines of NARRATIVE
  paragraphs); level 3 sends full new content. Documented in README.
- **Sandbox git fixtures**: the harness creates a throwaway git repo inside
  its own mktemp sandbox for the changelog scenario (the ATOM-101/102
  accepted precedent); no git operation touched the real repository.
- **Production `claude -p` handler path untested end-to-end** — the LLM is
  stubbed per the token reality; the first live exercise is G2's smoke.

## HUMAN-TASK (one line, per the token reality — not a blocker)

Create a test bot via @BotFather on your phone, put the token into a file
(e.g. `~/qroky/.qroky/telegram.token`, mode 600), point `profile.conf`
`TOKEN_FILE` at it, then run: `bash runtime/claude/telegram/install.sh &&
bash runtime/claude/telegram/install.sh --bind` and send the bot «что в
работе» — an answer within a minute is the smoke pass (part of G2, second-Mac
test window).

## Cost

~140k tokens estimated (M-tier executor, BC4 estimate: inputs ~35k, build
~55k, four harness iterations ~40k, records ~10k) of the ~350k envelope. No
E1 (Rowan held: token registration converted to the HUMAN-TASK line above),
no E4.

## Handoff

Blind verify (L) receives: this RESULT.md, `runtime/claude/telegram/**`, this
atom's `workspace/` transcripts, INPUT.md. The mandated DoD scenario is
harness-exercised (scenario-2), not code-read. After verify: G2 live
round-trip from the CEO's phone closes S1 and flips maturity toward
validated on the first real phone-answered gate.

## Fix round — verify ACCEPT r1, 6 minor findings (VERDICT.md), all fixed

| Finding | Fix | New evidence (workspace/) |
| :---- | :---- | :---- |
| M1 — callback_data truncated to 64 chars, not bytes; a long-label gate would be rejected by the real API and loop in the retry queue | callback_data = `<id>\|<button-index>` (byte-checked at build; an oversized ID fails LOUDLY and is never queued); labels persisted as `buttonN:` lines in `state/pending-gates/`; the listener resolves the verbatim label from the registry at press time — DR5-verbatim exact by construction at any length; a press with no matching registry entry gets a polite reply and no record | scenario-12: old scheme proven to need >64 bytes (111-byte class, asserted); the stub now models the REAL API cap and its rejection was proven live on an oversized payload; gate sent, max callback_data ≤64 bytes, full label intact as button TEXT; press by index → recorded answer = full label verbatim; decision record carries it |
| M2 — SIGKILL'd pass left the lock: ack-blind window up to ~5.5 min | the lock carries the holder PID; a dead holder is stolen IMMEDIATELY (`kill -0`); pid-less young locks fall back to a 2-min mtime bound — crash blind window is now one 30s cadence | scenario-2 extended: the crashed pass's lock is deliberately LEFT (lock-left asserted =1 so the check cannot pass vacuously); the next pass logs «stale lock removed (holder … dead)» and re-delivers the press |
| M3 — orphan-promise detector globbed ANY work file | checks THE promise's own `work:` file (`$INBOX/<work>.md`) — unrelated inbox traffic can no longer hide an orphan | code fix in handler.sh; the branch stays code-read-only as declared, but the logic gap the verifier found inside that declared branch is closed |
| M4 — failed or missed digest fire = silently lost day | digest safety net in the listener pass: sent-marker absent AND now past `DIGEST_TIME` → re-fire digest.sh (idempotent via its own marker); also covers a Mac asleep at fire time | scenario-13: a pass BEFORE digest time fires nothing; a pass after it delivers the missed digest, marker restored, safety-net log line asserted |
| M5 — run.log claimed masked-URL logging that did not exist; curl stderr (which can carry the token URL) flowed raw into telegram.log | curl stderr captured per attempt and the token masked to `bot****<last4>` BEFORE anything is logged — the checklist claim is now true in code; the record discrepancy is corrected in run.log (the original claim described intent, not code — the verifier was right) | scenario-14: 3 forced curl failures with the token-bearing URL in stderr → ≥3 masked lines in the log, ZERO raw-token occurrences in the log and across all committed transcripts; the ladder queued the event and the next pass delivered it — this also closes the previously undemonstrated tg_api failure-ladder deviation |
| M6 — «Ждёт тебя сегодня» could show waiting items AND «решений не ждём» together | one combined waiting list; the «решений не ждём» line appears only when BOTH waiting atoms and pending gates are empty | scenario-13 asserts a digest with a waiting atom present and zero «решений не ждём» occurrences |

Harness after the fix round: **14/14 PASS** — scenarios 1–11 unchanged in
intent (callback fixtures moved to the new index format; digest-time fixture
moved to 21:00 so the M4 safety net stays inert until deliberately exercised,
documented in the harness), scenarios 12–14 new. First run after the fixes
was green. All committed transcripts are from the final run. Fix-round cost
~45k (inside the ~50k round budget); cumulative executor total ~185k of
~350k. Same perimeter, no git operations. Ready for G2.
