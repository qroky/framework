---
atom: ATOM-102
product: kit v0.1.1 — backup interview point + disclaimer layer (amendment to the delivered distribution kit)
parent: ATOM-100 (runs in the REMAINING tree envelope: ~150k executor + ~50k targeted verify; subtree spent so far ~577k of ~800k — project a breach → stop and report, honest E4)
role: pilot-toolsmith (same role, warm context — this is a mandated amendment, not a new build)
formulated_by: ATOM-100 orchestrator from INFO-030 (CEO package, verbatim), 2026-07-10
verification: targeted blind re-check (same verifier, round scope = the delta)
maturity_target: reviewed (G2 CEO dry run happens AFTER this amendment — the interview changes)
model_tier: M
budget: ~150k this round
recursion_allowance: 0
---

# ATOM-102 — Kit v0.1.1 (executor input)

Mandate source (read): `decisions/INFO-030-platform-community-support.md` п.3
and п.4. The interview's closed list is extended BY ITS OWNER (CEO) to EIGHT
points.

## 1. Interview point 8 — backup opt-in (INFO-030 п.3, CEO verbatim: «включить резервную копию в ваш приватный GitHub? [рекомендуем]»)

- Benefit-framed question in all three locales; recommendation hint = yes;
  one honest line: the backup goes to the USER'S OWN private GitHub account,
  nobody else's.
- «Да» must work for a person who does not know the word GitHub: hand-held
  `gh` flow (the BotFather pattern) — check gh presence (install hint if
  missing), `gh auth login` walk-through with numbered human steps, create a
  PRIVATE repo, initial push of the user's Qroky workdir.
- **Secrets never enter the backup**: the token file (mode 600) and any
  secret path are excluded (gitignore in the user workdir + negative grep in
  the harness over the pushed tree). This extends H4.
- Restore = `git clone` — one documented command in the READMEs.
- Opt-out branch: recorded in install-state.json, no nagging, enable-later
  command documented.
- State machine: new check→do step pair, same idempotency and failure-ladder
  rules (≤2 auto-attempts; gh/network failures degrade with a concrete human
  action, install continues without backup rather than dying).

## 2. Disclaimer layer in kit texts (INFO-030 п.4)

Add to all three distribution READMEs (and the finale screen one-liner):
«Система производит черновики и анализ; юридические, финансовые и
медицинские решения и подписи — только человек. Not professional advice.»
(localized properly, not machine-glued). FAQ line in READMEs: «бэкап уходит
в ВАШ аккаунт».

## 3. Harness

- New scenario: backup opt-in with a stubbed `gh` (auth, repo create, push) —
  assert state step done, secrets negative grep over the "pushed" payload
  EMPTY, restore command printed.
- New scenario or branch: backup opt-out — state records the choice, nothing
  else happens.
- Re-run the FULL harness (now 10+ scenarios) — all green, non-vacuous.
- Question inventory check updated: exactly EIGHT points, still zero
  questions outside the interview.

## 4. Records

- RESULT.md: append «v0.1.1 amendment» section (what changed, transcripts,
  added cost). run.log: the story + budget checkpoint. README question lists
  updated to eight.
- Same write perimeter: `distribution/**` + your atom folders (101 workspace
  stays untouched except RESULT append; new transcripts go to
  `products/distribution-kit-v1/102-kit-amendment/workspace/`). No git.
