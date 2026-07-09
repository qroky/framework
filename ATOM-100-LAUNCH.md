# LAUNCH — ATOM-100 (Tree A: Distribution Kit — self-service installer)

> Runtime instruction for this session. Execute **1 parent atom + its plan** per the
> framework documents (`framework/ATOM-SPEC.md`, `framework/FEV-PROTOCOL.md`,
> `framework/REPO-STRUCTURE.md`, `framework/ORCHESTRATION.md`,
> `framework/SYNTHESIS-PROTOCOL.md` — read them first) and the binding
> (`runtime/claude/README.md`).
> Step 0 — materialize the INPUT specification below per LP3:
> `products/distribution-kit-v1/100-distribution-kit/INPUT.md` verbatim; `STATUS.md`
> at `formulated`; `products/distribution-kit-v1/status.yaml` per SM3; open
> `NARRATIVE.md` next to STATUS.md (INFO-015) and **immediately hand the human its
> clickable path**. Narrative at the reader's profile detail level; level 3 renders
> only mandatory records (INFO-016).
> Plan: one executor child ATOM-101 (distribution installer, role pilot-toolsmith —
> reuse, F2 satisfied; tier M) + blind ATOM-101-VERIFY (tier L, fresh context,
> envelope per EC2/×3.5+40k precedent). Rowan discipline (INFO-012): recon before
> any E1; rowan-classification of every E1 at closure (INFO-013).
> G1 = CEO «го» on this launch file (GATE-024). G2 = CEO dry run on a clean machine
> (HUMAN-TASK — release criterion, stays open until performed).
> Close per L7/RB6, push included. Update status.yaml at every transition.
> Spawn justification (formulator, O5.1): INFO-017 fixes distribution as priority
> №1; the existing 071-setup-kit serves the accompanied pilot, not self-service —
> no artifact today lets a stranger install Qroky without the author.

---
---
atom: ATOM-100
product: Distribution Kit v1 — self-service installer with interview (`distribution/`)
parent: — (top-level business atom; strategy INFO-017; G1 = GATE-024)
role: orchestrator (launch session); executor role: pilot-toolsmith (reuse)
formulated_by: launch session from CEO mandate INFO-017 (verbatim), 2026-07-09
verification: blind (ATOM-101-VERIFY, L) + human dry run (G2, release criterion)
maturity_target: reviewed (validated — after first stranger-install in the field)
budget: ~600k tokens subtree envelope (executor ~250k incl. 071-kit reads; verify ~150k per ×3.5+40k; parent orchestration + narrative ≤5%; ~50k fixed per subagent). Default-envelope practice per GATE-022 interpretation: E4 only on breach.
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

The six interview points are a CLOSED list — no seventh question may be added
without E1; removing one is E7.

## 4. Definition of Done

**Hard criteria (machine-checkable):**
- H1. `distribution/install.sh` exists; single entry point; bash; depends only on
  POSIX tools + curl + git (checks and says in human words what is missing).
- H2. The interview covers exactly the six declared points, in the user's chosen
  language (ro/ru/en, chosen first): working folder; Claude Code check/install with
  human hints; subscription check; Telegram opt-in — hand-held through BotFather
  until a WORKING token (validated live via Bot API `getMe`; skippable — opt-in);
  telemetry opt-in — shows verbatim WHAT leaves before asking (072 pattern,
  filtered-only). Zero questions outside the interview. Check: scripted transcript
  of a full run; question inventory equals the closed list.
- H3. Idempotent: a second run on an already-configured machine detects existing
  state, offers repair/update, never duplicates and never destroys user data.
  Check: scripted double-run in sandbox; diff of state after runs 2 vs 1.
- H4. Secrets perimeter: the bot token is stored ONLY locally (file mode 600 inside
  the user's Qroky folder), never printed to telemetry, never committed. Check:
  negative test greps telemetry payload and git status for the token.
- H5. Finale prints, in the chosen language: how to open a Claude Code session and
  the exact words «скажи qroky start» (or `qroky start`). The handoff target is the
  machine-wide gesture contract of the qroky skill.
- H6. Sandbox dry-run harness (expanding 071 dry-run.sh) proves the clean-machine
  path end-to-end ≤15 min with zero out-of-interview questions. Check: harness exit
  code + timed transcript committed to the atom's workspace.
- H7. Blind verify: accept.

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
