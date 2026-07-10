# VERDICT — ATOM-110 (Telegram head v1), independent blind verify (L)

- **Verdict: ACCEPT** (0 blocking, 6 minor findings)
- **Verifier:** blind L-tier session, 2026-07-10; no prior contact with the build
- **Method:** contract (INPUT.md + INFO-032/033) and artifacts read FIRST; own full
  harness run; adversarial probes (7) in an independent sandbox; executor's
  RESULT.md / run.log / transcripts read ONLY afterwards and cross-checked.
- **Blindness note:** the executor's committed transcripts were backed up before my
  harness run and restored byte-identical afterwards (cmp-verified); no git
  operations performed.

## Own harness run (independent)

`bash runtime/claude/telegram/dry-run.sh` — **11/11 PASS, exit 0**
(my run 2026-07-10T14:19:30Z vs executor's committed 13:53:22Z: PASS lines
identical scenario-for-scenario). My transcripts kept off-repo in the verify
scratchpad; the committed `workspace/` files remain the executor's originals.

## Hard criteria H1–H14 — all confirmed by my own evidence

| Crit | Independent evidence |
| :---- | :---- |
| H1 | My run scenario-1: record carries gate id + FULL question as sent + verbatim label + ts + channel; **diff telegram-vs-session = exactly the `- channel:` line** (2 diff lines, both channel, diff non-empty). Divergence attempts: `\|` inside a label survives (`${CB_DATA#*\|}`); the only divergence path found is the long-label truncation — finding M1. |
| H2 | My run scenario-2: press with NO session persisted; two pickup wakes → 1 record, second wake `consumed=0`; SIGKILL landed inside the tmp→rename window (tmp remnant asserted =1), 0 partial files, offset NOT advanced, press re-delivered. **Non-vacuity independently proven:** re-running the kill sequence WITHOUT the delay hook, the window is unobservable (KILLED=0) → the harness assertion is capable of failing. Extra attack: two CONCURRENT pickups over two pending answers → 2 records, 0 residue, 2 in done/, no duplication (one racer exits rc=1 on the mv race — benign, see M3 note). |
| H3 | `lsof -iTCP -sTCP:LISTEN` on the LIVE listener (liveness asserted =1) → empty. Polling only (`getUpdates`, offset=N+1); offset survives restart (no re-sends); plist StartInterval=30 (< 60s ack budget, pass wall-time <25s asserted). **Listener is non-LLM:** grep over all scripts — `CLAUDE_BIN`/`run_llm` exist ONLY in handler.sh (lines 28–37); python in listener is a JSON parser writing shlex-quoted spool files. |
| H4 | Foreign message AND foreign button press: 0 replies to the foreign chat, 0 inbox events, 2 flag lines, 2 quarantine records (update_id in name — no same-second collision). Pre-bind = everything quarantined (deny-by-default), listener.sh:178. |
| H5 | Risk item sent with NO buttons even though `--buttons` was passed (refused + logged), text names the word; button-style callback to the risk item **rejected and re-asked**, 0 records. My extra probe: typed word with TWO risk gates pending → disambiguation re-ask («Уточни: ПОДТВЕРЖДАЮ <id>»), 0 records; explicit `ПОДТВЕРЖДАЮ GATE-R2` → exactly that gate recorded, verbatim. |
| H6 | Digest: all four sections, running atom + pending gate listed; planted already-signaled gate rendered as «уже приходило событием сегодня, без повторной тревоги» — no duplicate alarm; 3-line changelog on new tag v2.0.0; second same-day run sends nothing. ±5 min via the launchd StartCalendarInterval assertion (plist Hour/Minute == profile, no Weekday key = daily) — the option H6's wording explicitly allows. Digest is heartbeat-independent by construction (reads files directly); missing spend ledger → honest «данных нет». |
| H7 | Events born with no session and no listener (direct `send-event.sh` calls, the heartbeat path) sent instantly; blocker never held back at daytime; NARRATIVE beats per level: 2 = headline only (body suppressed), 3 = full reasoning, 1 = nothing; per-file offset → no re-sends. |
| H13 | Ack sent by the listener itself in the same pass (<25s + 30s cadence ⇒ worst case <60s); «принял, результат к N» sent AND promise file durable in inbox BEFORE work; `kill -9` between promise and result (kill rc=0 asserted, result NOT yet sent asserted) → promise survives, next wake delivers the result, promise closed, kroky consumed. |
| H14 | Night (pinned clock 02:xx): 2 events queued, 0 sent; user message still acked at night; morning flush delivers the BLOCKER first (line-order asserted). My boundary probe: 23:00 queues (inclusive start), 08:00 sends (exclusive end) — «delivered when quiet hours end» holds at the minute edge. |
| H8 | `/status` and «что в работе» rendered mechanically (no LLM) from `products/*/status.yaml`, one message each, 3800-char cap with honest truncation note. |
| H9 | Free text → exactly ONE clarifying question, zero second re-asks, then `kind: task-proposal` inbox file for the session; the bot executes nothing. «кроки» routes to the handler/skill path; handler's LLM call is `--allowedTools Read Glob Grep` — read-only, consistent with the qroky no-actions-before-«го» protocol. |
| H10 | Token demonstrably FLOWS (stub validates it on every call — auth-ok marker asserted; sent.jsonl non-empty) yet zero occurrences in log/state/records/sent payloads/committed files/transcripts. My probes: (a) planted a deliberate leak line → the same grep catches it (detector live, not vacuous); (b) my own sandbox with a fresh lookalike token — zero real traces after all probes; (c) no `.token`/`profile.conf` committed under `runtime/claude/telegram/`. |
| H11 | Harness green 11/11; assertions falsifiable (proven above); INFO-025 checklist answered 1–9 in run.log before build (verified present). |
| H12 | This verdict: **accept**. |

**NOT-DOING check:** grep sweep over all scripts/plists for
2FA/TOTP/groups/editMessage/media/webhooks — clean (only regex `.group()`
Python hits). No hooks «for later» found.

**Repo hygiene:** my harness run left nothing in the real repo (sandboxed via
`QROKY_TG_HOME`/`QROKY_TG_ROOT`); the sandbox git fixture never touched the
real repository.

## Findings (all minor; ranked)

- **M1 (minor, should fix before G2 gates with long labels).**
  `send-event.sh:57` truncates `callback_data` to 64 **characters**
  (`[:64]`) — Telegram's limit is 64 **bytes**. My probe: a realistic Russian
  label («Вернуть на доработку с подробным комментарием…») produced
  callback_data of 64 chars = **111 bytes** — the real Bot API rejects such a
  sendMessage (BUTTON_DATA_INVALID), the stub does not model this. Consequence
  chain in production: gate send fails → 3 tg_api attempts → queued → re-tried
  by every listener pass forever (permanently invalid payload contradicts the
  «never an infinite retry» comment, send-event.sh:24), and the gate never
  reaches the phone. Secondary effect: for labels that DO fit, chars-slicing
  can silently truncate the recorded «verbatim» label vs what the button
  displayed (weakens H1's DR5 verbatim for long labels). Typical short labels
  («Да, принять»/«Вернуть») are unaffected — hence minor, not blocking.
  Suggested fix: callback_data = `<gate-id>|<button-index>`, resolve the label
  from `state/pending-gates/` at press time (also makes verbatim exact by
  construction).
- **M2 (minor).** Crash-stale lock blind window: a SIGKILL'd listener pass
  leaves `state/listener.lock`; subsequent passes exit «pass skipped» until
  the lock is >5 min old (listener.sh:26–36). My probe: kill -9 mid-pass →
  next pass sends nothing, log «pass skipped: another pass is running» → up to
  ~5.5 min without ack after an abnormal listener death (crash-window breach
  of the ≤1 min ack; steady state is fine and harness-proven). Suggested fix:
  write the PID into the lock and steal on `kill -0` failure, or lower the
  stale threshold to ~90–120s.
- **M3 (minor).** Orphan-promise detector is imprecise (handler.sh:139–146):
  it checks whether ANY kroky/user-message file exists in the inbox, not the
  one belonging to THIS promise — an orphaned promise coexisting with
  unrelated inbox traffic is never detected, never closed, and the owner is
  never told (silent for that edge, against the «no loss, no silence»
  intent). The branch is declared code-read-only in RESULT.md (declaration
  accurate), but the declared branch also carries this logic gap. Related
  benign observation: a concurrent pickup racer can exit rc=1 on the mv race
  (set -e), aborting a handler pass early — events stay in inbox and the next
  wake completes them (no loss, verified).
- **M4 (minor).** Digest single-shot per day: marker is written only on
  success and StartCalendarInterval fires once daily (digest.sh:19–23,
  110–116) — a network failure at fire time (after tg_api's 3 attempts) means
  NO digest that day; the log is loud but the phone is silent, so «daily
  ±5 мин» silently misses a day under a transient outage. Suggested fix: let
  a listener pass retry while the marker is absent and now > DIGEST_TIME.
- **M5 (minor, record discrepancy).** run.log INFO-025 answer 4 claims «curl
  URL never logged raw (log line shows bot<masked>)» — no masked-URL log line
  exists in the code; URLs are simply never logged, and curl's **stderr is
  appended to telegram.log** (lib.sh:65). Actual behavior satisfies H10 (my
  greps prove zero token traces), but the checklist claim does not match the
  code, and piping curl stderr into the log is a (low) theoretical leak
  surface worth scrubbing.
- **M6 (cosmetic).** Digest section «Ждёт тебя сегодня» renders
  `${WAIT_LINES}${PENDING_LINES:-• решений не ждём}` (digest.sh:96): with
  waiting atoms present but no pending gates, the section shows blocked items
  AND «решений не ждём» — contradictory on a phone screen (touches S2, CEO's
  judgment at G2).

## Executor claims vs my evidence (post-blind cross-check)

RESULT.md's DoD table matches my independent run and code reading point for
point; the bug trail (4 self-caught bugs) is consistent with the code as
committed («${label}» fix present at listener.sh:107, update_id in quarantine
names at listener.sh:182, executable bits present). All deviations required to
be declared ARE declared and accurate: no-LLM degradation branches, tg_api
failure ladder, install/--bind/launchctl, ±5-on-launchd, orphan-promise
branch, level-2 heuristic, stubbed `claude -p`. The single record/code
discrepancy found is M5. Cost claim (~140k of ~350k) is plausible against the
artifact volume; not independently measurable from here.

## Bottom line

The mandated DoD scenario («гейт нажат при закрытой сессии → ответ не потерян
→ подхвачен при пробуждении») is genuinely harness-EXERCISED, kill-proven and
non-vacuous — I reproduced it and independently falsified its kill assertion.
Parity is real and by construction; physics honest (no ports, non-LLM
listener, polling that holds the ack budget); security v1 (chat_id binding,
risk word, token hygiene) held under adversarial probing. Six minors, none
touching a hard criterion under realistic v1 usage; M1 is the one to fix
before long-label gates meet the real Bot API.

**ACCEPT.** Next: G2 — live phone round-trip (S1–S3 are the CEO's judgment).

*Verifier spend estimate: ~90k tokens of the ~180k envelope (contract+code
~45k, own harness run + 7 probes ~30k, cross-check + verdict ~15k).*
