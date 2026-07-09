---
atom: ATOM-101
product: distribution/install.sh + locale files + distribution READMEs + sandbox harness (the working kit)
parent: ATOM-100 (products/distribution-kit-v1/100-distribution-kit/INPUT.md — read it first; its H1–H11 are YOUR acceptance criteria)
role: pilot-toolsmith (roles/pilot-toolsmith.md — adopt it fully, incl. Agency Doctrine and Harness Discipline sections)
formulated_by: ATOM-100 orchestrator, 2026-07-10
verification: blind (ATOM-101-VERIFY, tier L, fresh context) — you will NOT talk to the verifier; your products speak alone
maturity_target: reviewed
model_tier: M
budget: ~330k tokens. Hard stop per O6.2 — if you project a breach, stop and report, do not run through it.
recursion_allowance: 0 (no sub-spawns — build inline)
---

# ATOM-101 — Distribution Installer (executor input)

## 1. Read first (closed list)

1. `products/distribution-kit-v1/100-distribution-kit/INPUT.md` — the parent spec; H1–H11 are the DoD you deliver against.
2. `products/pilot-prerequisites-v1/071-setup-kit/setup/` — bootstrap.sh, dry-run.sh, QUICKSTART ro/ru: the PROVEN base. Expand, don't rewrite from zero.
3. `products/pilot-prerequisites-v1/072-telemetry-showcase/` — the consent pattern: show-what-leaves screen, filtered-only push, negative tests.
4. `~/.claude/skills/qroky/SKILL.md` — the `qroky start` contract your finale hands off to (§1 trigger grammar, §4 install).
5. `runtime/claude/heartbeat/` — heartbeat.sh, prompt, launchd plist, install.sh: adapt for the END USER's machine (their paths, their workdir), do not point at this repo's paths.
6. `knowledge/reference/harness-checklist.md` — you MUST walk all 9 points and record the answers in your run.log (skip only with logged justification).
7. `runtime/claude/README.md` §1 (session start wording for the finale).

## 2. Deliverables (LA4 — outside the atom folder where stated)

- `distribution/install.sh` — single entry point, bash, POSIX+curl+git only.
- `distribution/lang/{en,ro,ru}.sh` (or equivalent) — locale strings; language is interview point 1; ALL user-facing lines localized, no method jargon (atom/verify/FEV → plain words).
- `distribution/README.en.md`, `README.ro.md`, `README.ru.md` — one page each: what the installer does, the one-liner to run it, what the seven questions are, the «не трогайте мой инстанс» pointers (enable/disable heartbeat, disable update check).
- `distribution/dry-run.sh` — sandbox harness (expand 071's): full clean run (timed, ≤15 min, zero out-of-interview questions), kill-mid-install → rerun completes, healthy rerun → clean health-check («всё стоит, ничего не делал»), broken dependency → concrete human instruction, double-run idempotency diff, secrets negative grep (token absent from state/log/telemetry/git), self-update scenario (sandbox repo: tag N → publish N+1 with a local user edit → digest line appears, apply waits for explicit «да», reconciliation SHOWS the conflict, decisions record written on the user side).
- Transcripts of every harness scenario → `products/distribution-kit-v1/101-distribution-installer/workspace/`.
- `products/distribution-kit-v1/101-distribution-installer/RESULT.md` — self-check table vs H1–H11 (each: met/how checked), harness-checklist 9 answers (or pointer to run.log), decisions-made-by-executor list (O9.1), honest deviations if any (V3 — never silent), cost estimate (bytes÷3 per BC2).

## 3. Binding mechanics (from the parent's H-criteria — do not re-derive, implement)

- **Interview = exactly 7 points** (H2, closed list): language en/ro/ru first; working folder; Claude Code check/install with human hints; subscription/login check (probe, not purchase flow); Telegram opt-in — numbered BotFather walkthrough to a WORKING token validated live via `getMe`, loop with human hint on failure, skippable; telemetry opt-in — show verbatim what leaves BEFORE asking (072 pattern); heartbeat consent — benefit-framed question («утренний дайджест: что сделано, что ждёт тебя — да/нет, меняется позже») + one honest line (read-only scan, no actions, no data transfer), recommendation hint = yes; «да» → launchd installed AND enabled, «нет» → installed DISABLED + one-command enable instruction.
- **State machine** (H3/H8): `install-state.json` in the user's Qroky folder — steps done/failed/pending + interview answers; every step an idempotent «check→do» pair; rerun = checks from top, resume at stop point, answered questions never re-asked; healthy rerun = free health-check, changes nothing.
- **Failure ladder** (H9): self-diagnosis from the step's own check → ONE auto-attempt from known remedies (network retry, lock wait, permissions hint) → concrete human action «сделайте Y, запустите снова — продолжу отсюда»; max 2 auto-attempts/step, third failure ALWAYS to the human; «пришлите файл» only as the last line for hopeless cases.
- **Secrets** (H4): bot token → file mode 600 in the user's Qroky folder; NEVER in telemetry, state, log, or git; negative grep across all four is EMPTY.
- **Self-update** (H11): heartbeat pulse runs read-only `git fetch --tags` on the vendored framework, considers RELEASE TAGS ONLY (never main); new tag → digest line: 3-line human changelog + how to say да/позже/подробнее (exact command/words — buttons are a later tree); apply ONLY on explicit «да», executed as a mini-atom writing a record into the USER's `qroky/decisions/`, preceded by reconciliation of local edits — conflicts SHOWN, never silently overwritten. Health-check and update share install-state.json.
- **Finale** (H5): print, in the chosen language, how to open a Claude Code session and the exact words «скажи qroky start» / `qroky start`.
- Vendoring: install clones/copies the framework into `<workdir>/qroky/framework/` with PROVENANCE (source + commit + date) per the skill's §4 pattern.

## 4. Escalation & discipline

- Rowan (INFO-012): recon before any question — the answer to most design gaps is in the read list. A BLOCKING gap you cannot resolve = STOP and return one consolidated question set in your final message (do not guess, do not ask mid-flight).
- The 7-point interview list is CLOSED: needing an 8th question is exactly such a blocking gap.
- Do NOT touch: pilot materials (071/077/079 originals — copy patterns, never edit them), framework/, decisions/, TASKS.md, README.md at repo root. Your writes: `distribution/**` and your own atom folder only.
- No git commits, no push — the orchestrator closes the bus (lesson: no blanket adds while children write).
- Your final text message = a short report (delivered/blocked, path list, self-check verdict, cost). The products live on the file bus, not in the message.
