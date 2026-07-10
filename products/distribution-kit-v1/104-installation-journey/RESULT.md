---
atom: ATOM-104
product: kit v0.2 — installation journey (fix of the CEO's live G2 RETURN, GATE-027; go GATE-028)
status: delivered (awaiting targeted blind verify + the CEO's live G2 re-run)
maturity_claimed: self-checked (harness 14/14 full re-run green; maturity_target "reviewed" needs the verify + the CEO's second Mac)
cost:
  units_in: ~100k          # estimate (BC4): GATE-027/028 + INPUT + full kit re-read (install.sh 1011L, dry-run 863L, 3 locales, 3 READMEs), vendored skill, head install/lib/listener/digest/plists, 103/RESULT
  units_out: ~32k          # estimate (BC4): install.sh v0.2 (+~350 lines), 3 locales, 3 READMEs, skill I3 amendment, harness (+2 scenarios, stub extension), records; one network interruption mid-run, no rework lost
  unit: tokens
  wall_time: ~80m
  executor: pilot-toolsmith (warm; built the installer AND the telegram head)
  sub_atoms_spawned: 0
  sub_atoms_cost: 0
---

# RESULT — ATOM-104 (kit v0.2, installation journey)

> Version chain: v0.1.0/v0.1.1 in `../101-distribution-installer/RESULT.md`,
> v0.1.2 in `../103-gesture-fix/RESULT.md`. The acceptance bar for THIS
> record is the CEO's verbatim sentences from GATE-027: «дал ключ — бот
> пнул» and «понятно, что делать и в каком порядке».

## What changed

1. **«Дал ключ → бот пнул» — question 5 closes its own loop (GATE-027
   finding 1).** Skip is stated FIRST and costs one Enter. On yes: BotFather
   walkthrough → live getMe → token stored (H4 discipline unchanged) → «now
   open your bot and press Start» → the installer polls getUpdates (honest
   ~60 s timeout) → the owner's chat_id is captured and written to the
   head's own `state/chat_id` — this IS the head's H4 binding, done
   non-interactively — → the bot IMMEDIATELY replies («Я на связи. Завтра
   утром пришлю ваш первый дайджест.», localized ×3) → the r3-accepted head
   is deployed: `profile.conf` rendered at `<workdir>/.qroky/telegram/`
   (token path = the kit's stored file, digest 09:05, quiet 23:00–08:00),
   one listener pass health-checked, both launchd jobs installed. Offset
   handoff (consumed update_id → `state/offset`) guarantees the Start press
   is never processed twice; today's digest marker is pre-written so the
   FIRST digest genuinely arrives next morning — what the hello promises.
   Timeout / no Start / no token → honest line, install continues, ONE
   command finishes everything later: `bash install.sh --enable-telegram`
   (new; reuses a stored token without re-asking).
2. **Journey map + numbered road (finding 3).** A fresh install opens with
   one paragraph — 9 questions, ~3 minutes, two lines at the end; every
   question header says «N из 9». Declared interpretation: the map prints
   right after the language question so it arrives in the human's own
   language (a map the reader cannot read is not a map); question 1 itself
   is announced as «1 из 9». Reruns are not journeys — no map.
3. **Finale = ready copy-paste block (finding 2).** `cd <real workdir> &&
   claude` (actual path substituted, asserted in the harness), then
   «скажите: qroky start»; the VS Code line; one honest line that claude's
   FIRST launch asks its own questions (theme, login); a pointer to the
   README's «Первые 5 минут».
4. **Question 9 — machine-wide gesture (GATE-028 «да, спрашивать при
   установке»).** Opt-in, recommended in text, honest line «запишем два
   файла в ~/.claude». A typed yes is required — Enter deliberately means
   «no, working folder only» (explicit means explicit). Yes writes EXACTLY
   two files: `~/.claude/skills/qroky/SKILL.md` (copy of the vendored
   skill, `cmp`-guarded) and a marker-guarded trigger block in
   `~/.claude/CLAUDE.md` (created if absent). Idempotent; removal = those
   same two paths, named to the human at install and in the READMEs.
   A wiring failure leaves the step pending so a re-run re-asks it.
5. **Rule I3 amended in the VENDORED skill**
   (`runtime/claude/skill/qroky/SKILL.md`): recorded exception with
   provenance GATE-028 — the kit installer may write exactly those two
   files on explicit opt-in; nothing else under `~`, ever; the exception
   extends to no other installer. Provenance table row added. The
   author-machine copy is the orchestrator's, untouched here.
6. **Inventory = exactly NINE everywhere:** installer header, hardened
   count assert (point 9 present, max 9, «never 10+»), README lists en/ro/ru,
   journey map.
7. **«Первые 5 минут» ×3 locales** — one screen in each README: what to say
   first (qroky start → the system surveys read-only, asks the two whys,
   proposes a one-screen plan → you say «го» or correct it), what success
   looks like, where `qroky/mission.md` and `NARRATIVE.md` appear. Finale
   points at it.

## Head wiring — declared design (INPUT §6: prefer zero edits)

The reviewed head got **zero edits**. Its state home is pointed OUTSIDE the
read-only vendored checkout — `<workdir>/.qroky/telegram/` — via
`QROKY_TG_HOME`/`QROKY_TG_ROOT`, the overrides the head already reads; two
wrapper scripts own those two env lines and `exec` the head's own
`listener.sh`/`digest.sh` byte-identical. Both plists ARE installed, but
they are **kit-rendered** (pointing at the wrappers) rather than the head's
templates, and the head's own `install.sh` is not called (its `--bind` is
interactive and its plists would home state inside `framework/`, raising
phantom «local changes» on every self-update — the F3 lesson). The kit
installer speaks the Bot API directly with curl (`getMe`/`getUpdates`/
`sendMessage`) instead of sourcing the head's `lib.sh` — both files define
`log()`, a source would silently shadow one; chat_id is parsed with
sed/grep over the Bot API's compact JSON to keep the kit's
bash+POSIX+curl+git-only contract (H1).

## Harness status

`distribution/dry-run.sh`: **14/14 green on the full re-run** (12 scenarios
+ question inventory + journey checks). New coverage per INPUT §5, all
against the stubbed Bot API (extended kit stub reuses the head-harness
modelling: token check, offset-gated /start delivery, verbatim sent-log):

- **Scenario 11 (a+b):** (a) token + Start → chat_id 424242 bound in the
  head's state, offset 111 handed off, hello ACTUALLY asserted in the
  stub's sent-log (exactly ONE send in the whole run — armed against
  double-processing by the offset guard), profile.conf/wrappers/2 plists/
  bootstraps, one healthy listener pass of the GENUINE head (the fixture
  ships the real `runtime/claude/telegram/**`), digest pre-marked;
  (b) Start never pressed → honest timeout line, token kept, head NOT
  deployed, install finishes green with the real-path finale — then
  `--enable-telegram` completes bind+hello+deploy end-to-end reusing the
  stored token without re-asking.
- **Scenario 12 (c+d):** per-branch dedicated fake HOMEs; yes → EXACTLY two
  files under `~/.claude` (exhaustive listing in the transcript), one
  marker after the re-run, skill copy byte-identical to the vendored source
  and carrying the GATE-028 exception; no (Enter) → fake HOME untouched —
  non-vacuous because the yes branch just proved the machinery writes.
- Scenario 1 gained the journey asserts (map, «N of 9» with zero «of 8»
  leftovers, `cd <real path> && claude`, VS Code, first-run honesty);
  scenario 3 asserts NO map on reruns; scenario 6's negative token grep now
  also sweeps the deployed head's home (8 files, non-vacuous); all feeds
  updated to nine answers.

**Falsifiability proven live:** run 1 scored 12/14 — scenario 11 failed
against a framework fixture without the head (install.sh degraded honestly
via its HEAD_MISSING branch, exactly as designed) and the finale assert
failed on a line-wrapped grep. Both fixes were fixture/assert-level;
production code needed no change. Spot probes: a doubled marker counts 2, a
third file under `~/.claude` counts 3 — both would fail their asserts.

## Deviations (declared, none silent)

- D-1. Journey map prints after the language question, not before it
  (readable-language reasoning above) — the «first screen» requirement is
  read as «the road is visible before any real question»; question 1's own
  header carries «1 из 9».
- D-2. Start-wait timeout does NOT deploy the head (stricter S6 reading of
  INPUT §1: a listener bound to nobody polling every 30 s is a half-alive
  state the founder cannot see); `--enable-telegram` completes everything.
- D-3. Kit-rendered plists + wrappers instead of the head's own installer
  (see «Head wiring» — zero-edit preference honored at script level).
- D-4. Question 9 requires a typed yes (Enter = no) — «explicit opt-in» read
  strictly for a write into `~`; the recommendation lives in the text.
- D-5. New sandbox-only hook `QROKY_TEST_START_WAIT` (documented in the
  installer header; unset in production = 60 s).
- D-6. One network interruption mid-build — logged in run.log, no loss.

## HUMAN-TASK (unchanged, Rowan)

A real BotFather registration needs a human Telegram account: the CEO's
live G2 re-run on the second Mac is the first real-token pass of this
journey (token → Start → «я на связи» on a real phone).
