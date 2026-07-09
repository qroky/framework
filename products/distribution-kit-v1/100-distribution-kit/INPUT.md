---
atom: ATOM-100
product: Distribution Kit v1 — self-service installer with interview (`distribution/`)
parent: — (top-level business atom; strategy INFO-017; G1 = GATE-024)
role: orchestrator (launch session); executor role: pilot-toolsmith (reuse)
formulated_by: launch session from CEO mandate INFO-017 (verbatim), 2026-07-09
verification: blind (ATOM-101-VERIFY, L) + human dry run (G2, release criterion)
maturity_target: reviewed (validated — after first stranger-install in the field)
budget: ~800k tokens subtree envelope (executor(s) ~380k incl. 071-kit reads + INFO-022 state machine + three-scenario harness + INFO-023 heartbeat consent and self-update channel; verify ~180k per ×3.5+40k; parent orchestration + narrative ≤5%; ~50k fixed per subagent). Default-envelope practice per GATE-022/INFO-019: E4 only on breach. Raised ~600k→650k→800k by CEO-authored pre-launch amendments INFO-022/INFO-023.
recursion_allowance: 2
---

# ATOM-100 — Input Specification

## 1. Product Identity
| Field | Value |
| :---- | :---- |
| Product | `distribution/install.sh` + `distribution/README.{ro,ru,en}.md` (LA4 — deliverable outside the atom folder, public face of the repo) |
| Atom ID | ATOM-100 (children: 101 installer, 101-verify) |
| Parent product | Qroky — self-service distribution (INFO-017, priority №1) |
| Executor role | pilot-toolsmith (exists — F2 satisfied; founder-facing setup scripts are its identity) |
| Input product(s) | `decisions/INFO-017` (mandate, verbatim); `products/pilot-prerequisites-v1/071-setup-kit/setup/` (base to expand: bootstrap.sh, QUICKSTART ro/ru, dry-run harness); `products/pilot-prerequisites-v1/072-*/` (telemetry consent pattern: filtered-only, show-what-leaves); `~/.claude/skills/qroky/SKILL.md` (the `qroky start` contract the finale hands off to); `runtime/claude/README.md` §1 (session start); `knowledge/precedent/` (all) |
| Consumer(s) | A stranger (non-technical founder first) installing Qroky with no author contact; Tree B (ATOM-110) consumes the interview's Telegram token and its storage path |
| Maturity target | reviewed (validated after first field stranger-install) |
| Gates | G1 = GATE-024 (this launch); G2 = CEO dry run on clean machine (HUMAN-TASK) |
| Instantiation | subagent (executor), session (verify — VP4/SS6 blind) |
| Verification mode | blind independent (F3: public-face product, perimeter-crossing — secrets handling) + human dry run |
| Budget envelope | ~600k subtree |
| Recursion-depth allowance | 2 |

## 2. Job To Be Done

Qroky is a self-service product of thousands of standalone instances (INFO-017);
today nobody can install one without the author. Expand the pilot kit
(071-setup-kit — built for the accompanied pilot) into a **distribution kit**: one
public `install.sh` that interviews the user, sets everything up, and ends with
«скажи qroky start». After this atom, a clean machine plus this script equals a
working Qroky instance in ≤15 minutes with zero questions outside the interview.

## 3. Mandate — the interview (CEO, verbatim; closed list)

> install.sh с интервью установки (язык ro/ru/en; рабочая папка;
> проверка/установка Claude Code с человеческими подсказками; подписка;
> Telegram opt-in — проводит за руку через BotFather до рабочего токена;
> телеметрия opt-in с показом, что уходит) → идемпотентный, повторный запуск
> безопасен → финал «скажи qroky start». Критерий релиза: чистая машина,
> ≤15 мин, ноль вопросов вне интервью (сухой прогон — HUMAN-TASK мне остаётся).

Seventh point — added by the list's owner (CEO, INFO-023, verbatim):

> Heartbeat — согласие в интервью инсталлятора: вопрос через пользу
> («утренний дайджест в Telegram: что сделано, что ждёт тебя — да/нет,
> меняется позже»), в вопросе одной строкой — что пульс делает (read-only
> скан, никаких действий и передачи данных); «да» → launchd включён, «нет» →
> установлен выключенным + инструкция включения; рекомендация в подсказке — да.

The seven interview points are a CLOSED list — no eighth question may be added
without E1; removing one is E7.

## 4. Definition of Done

**Hard criteria (machine-checkable):**
- H1. `distribution/install.sh` exists; single entry point; bash; depends only on
  POSIX tools + curl + git (checks and says in human words what is missing).
- H2. The interview covers exactly the seven declared points, in the user's chosen
  language (ro/ru/en, chosen first): working folder; Claude Code check/install with
  human hints; subscription check; Telegram opt-in — hand-held through BotFather
  until a WORKING token (validated live via Bot API `getMe`; skippable — opt-in);
  telemetry opt-in — shows verbatim WHAT leaves before asking (072 pattern,
  filtered-only); heartbeat consent (H10). Zero questions outside the interview.
  Check: scripted transcript of a full run; question inventory equals the closed
  list.
- H3. Self-managing idempotency (INFO-022): every step is an idempotent
  «check→do» pair. A rerun replays the checks from the top and resumes EXACTLY at
  the stop point (answered interview points are never re-asked — answers live in
  the state file, H8); a rerun on a healthy install is a free health-check that
  reports «всё стоит, ничего не делал» and changes nothing. Never duplicates,
  never destroys user data. Check: scripted double-run diff + resume-from-kill
  scenario (H6).
- H4. Secrets perimeter: the bot token is stored ONLY locally (file mode 600 inside
  the user's Qroky folder), never printed to telemetry, never committed. Secret
  redaction holds in BOTH traces — install-state.json and the human-readable log.
  Check: negative grep for the token over telemetry payload, git status, state
  file, and log is EMPTY.
- H5. Finale prints, in the chosen language: how to open a Claude Code session and
  the exact words «скажи qroky start» (or `qroky start`). The handoff target is the
  machine-wide gesture contract of the qroky skill.
- H6. Sandbox dry-run harness (expanding 071 dry-run.sh) proves the clean-machine
  path end-to-end ≤15 min with zero out-of-interview questions, PLUS three
  mandatory scenarios (INFO-022, verbatim list): (a) kill the install mid-way →
  rerun completes to the end; (b) run on an already-installed system → clean
  health-check; (c) a broken dependency → a clear human instruction. Check:
  harness exit codes + timed transcripts committed to the atom's workspace.
- H7. Blind verify: accept.
- H8. `install-state.json` — machine-readable checkpoint next to the
  human-readable log: every step `done/failed/pending` + the interview answers.
  The trace is the installer's control organ, not a report (same principle as the
  framework's file bus). Tree B (ATOM-110) will read this file as the instance's
  ground state. Check: state file present and consistent after every scenario of
  H6.
- H9. Failure ladder (INFO-022): on a step failure — self-diagnosis (cause named
  from the step's own check) → ONE auto-attempt from known remedies (network
  retry, lock wait, permissions hint) → if not cured, a CONCRETE human action:
  «сделайте Y, запустите снова — продолжу отсюда» — never «пришлите файл» (the
  file is the last line for hopeless cases only). Max 2 auto-attempts per step;
  the third failure of a step ALWAYS goes to the human. Check: fault-injection in
  the H6(c) scenario exercises the ladder end-to-end.
- H10. Heartbeat consent (INFO-023): interview point 7 asks through the benefit
  («утренний дайджест: что сделано, что ждёт тебя — да/нет, меняется позже»)
  with ONE honest line on what the pulse does (read-only scan, no actions, no
  data transfer); recommendation hint = yes. «Да» → launchd agent installed AND
  enabled; «нет» → installed DISABLED plus a one-command enable instruction.
  Check: both branches exercised in the H6 harness; disabled branch leaves no
  running agent.
- H11. Self-update channel (INFO-023): the heartbeat pulse runs `git fetch` on
  the vendored framework — read-only, RELEASE TAGS ONLY, never main. On a new
  version: a digest line with a 3-line human changelog («что улучшится у тебя»)
  and the choice да/позже/подробнее (buttons are Tree-B UI; in v1 the digest
  names the exact command/words). APPLYING is only on an explicit «да», executed
  as a mini-atom recorded in the USER's own `decisions/`, preceded by
  reconciliation of the user's local edits — conflicts SHOWN, never silently
  overwritten. Health-check and update mechanics share the ONE state/trace
  (`install-state.json`, H8). Check: sandbox scenario — instance on tag N, tag
  N+1 published with local user edit present → digest line appears, apply waits
  for «да», reconciliation surfaces the conflict, decisions record written.
  (Signed tags — touch candidate 17, trigger «100+ инстансов»; not in v1.)

**Soft criteria (judgment — judge named per criterion):**
- S1. Every user-facing line passes the non-technical-founder bar: no method jargon
  (atom, verify, FEV), failures loud and specific with a human next step — judge:
  Verify agent (founder-ux lens inside the blind package).
- S2. The BotFather walkthrough is genuinely hand-holding: a person who has never
  heard the word «бот» reaches a working token without leaving the script's
  instructions — judge: Verify agent; final judge: CEO dry run (G2).
- S3. Release criterion (CEO, verbatim): clean machine, ≤15 min, zero questions
  outside the interview — judge: CEO dry run (HUMAN-TASK; the atom does not close
  `reviewed` without it).

**Maturity target:** reviewed. Do not gold-plate; Tree B consumes the token — do
not build any Telegram behavior beyond obtaining and storing the token (that is
ATOM-110's mandate, dependency declared in INFO-017).

## 5. Method Hints (non-binding)

- Expand, don't rewrite: 071's bootstrap.sh + dry-run.sh are the proven base; the
  telemetry show-what-leaves screen exists in the 072 consent pattern.
- Interview language file per locale (ro/ru/en) rather than inline triplication;
  README per language points at the one-liner (`curl … | bash` or clone+run).
- BotFather walkthrough: numbered steps with exact taps («открой Telegram → найди
  @BotFather → …»), then the script asks for the token and validates via `getMe`
  live, looping with a human hint on failure.
- Idempotency via a state marker in the user's Qroky folder, not via guessing.
- The subscription point is a CHECK with human hints (is Claude Code logged in /
  plan active — `claude --version` + login probe), not a purchase flow.

## 6. Escalation

Triggers E1–E8 per ATOM-SPEC §5.7 / SYNTHESIS-PROTOCOL. Rowan discipline
(INFO-012/013): recon before any E1; every E1 rowan-classified at closure. The
interview list is closed (§3): a needed seventh question is E1 to the CEO, never a
silent addition. Gates: G1 = GATE-024 (go on this file); G2 = CEO dry run.

---
*End of launch file. Formulated 2026-07-09 from INFO-017 (CEO mandate, verbatim).
Tree B (ATOM-110, Telegram head v1) is reserved and will be formulated after this
atom delivers: its input — the interview's token and storage path.*
