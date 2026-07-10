# LAUNCH — ATOM-110 (telegram-head-v1: the phone-side voice of the instance)

> Runtime instruction. Starts on CEO «го» (G1). Accelerated per INFO-032:
> does NOT wait for tree A closure — builds on a TEST bot token; the only
> dependency on A is the production token registration step (kit interview
> question 5, already delivered in v0.1.1). Needed for the second-Mac test.
> Execute per the five framework documents and `runtime/claude/README.md`.
> Step 0 — materialize per LP3 into `products/telegram-head-v1/110-telegram-head/`
> (INPUT.md verbatim, STATUS.md `formulated`, status.yaml per SM3, NARRATIVE.md
> opened with its clickable path handed to the human immediately — INFO-015/016).
> Rowan (INFO-012/013) and spawn proportionality (INFO-018: `mission_value` +
> `why_not_lower` on every O5.1) apply to every spawn.
> Spawn justification (formulator, O5.1): decision parity away from the desk is
> the hard gap — today every gate waits for the CEO to sit at the Mac;
> mission_value: unblocks the second-Mac test and is the INFO-017 parity
> milestone (Telegram sufficient for the full cycle); why_not_lower: a listener
> daemon + bot protocol + parity records + harness is a build with a hard DoD
> scenario, not an inline edit or a lens.
> Budget (proportionality + precedents, INFO-019 flagged practice per GATE-022):
> subtree ~600k — executor ~350k (M, pilot-toolsmith warm: closest precedent is
> ATOM-101 installer, 325k spent of ~410k), blind verify ~180k (L, code+harness
> like 101-verify at 202k, delta-scoped tighter), parent orchestration +
> narrative ≤5%, ~50k fixed per subagent. E4 only on breach.
> G-gates: G1 (CEO go on this plan); G2 (CEO presses a REAL gate from his phone
> — live round-trip during the second-Mac test window).

---
---
atom: ATOM-110
product: Telegram head v1 — gates/E1 as buttons with decision parity, NARRATIVE feed, morning digest, /status, free-input router, «кроки» from the bot
parent: — (top-level; INFO-017 tree B, accelerated by INFO-032)
role: pilot-toolsmith (warm, maturity runs=2; scripts + launchd + file bus is its home ground)
formulated_by: session from CEO decision INFO-032 (verbatim), 2026-07-10
verification: independent blind (L) — code + harness, mandatory DoD scenario exercised, not code-read
maturity_target: reviewed (validated — after the CEO answers a real gate from his phone in the second-Mac test)
model_tier: M (executor), L (verify)
budget: ~600k subtree (see header; INFO-019 flagged practice, referenced explicitly)
recursion_allowance: 1
---

# ATOM-110 — Input Specification

## 1. Product Identity
| Field | Value |
| :---- | :---- |
| Product | `runtime/claude/telegram/` — launchd polling listener + outbound send helper + inbox conventions + digest/feed renderers + bot-side «кроки» routing; harness `telegram/dry-run.sh` |
| Atom ID | ATOM-110 (child: 110-verify) |
| Parent product | Qroky runtime binding (INFO-017 channel parity; INFO-032 acceleration) |
| Input product(s) | `decisions/INFO-032` (mandate, verbatim); `decisions/INFO-017` (parity = hard); kit v0.1.1 token storage path (question 5); `runtime/claude/heartbeat/` (digest source); `framework/` DR5/O8.1 (what a decision record must contain); `knowledge/reference/harness-checklist.md` (INFO-025, mandatory run); profile levels 1/2/3 (INFO-009/016) |
| Consumer(s) | CEO on his phone (only bound chat_id); the session/heartbeat that picks up inbox records; second-Mac test |
| Maturity target | reviewed (validated after first real phone-answered gate) |
| Gates | G1 = CEO «го» on this plan; G2 = live round-trip from the phone |
| Instantiation | one executor subagent (pilot-toolsmith) + blind verify session |
| Verification mode | independent blind (L); the closed-session DoD scenario must be EXERCISED by harness |
| Budget envelope | ~600k subtree |
| Recursion-depth allowance | 1 |

## 2. Job To Be Done

The CEO is away from the Mac. A gate fires in a running tree. His phone buzzes:
one message, plain language, buttons. He presses one. That press becomes a
decision record in `decisions/` with the same force as a verbatim answer typed
into the session — and the tree moves. In the morning the same chat brings the
heartbeat digest; during the day it streams the meaning-feed of live trees at
his chosen detail level; «что в работе» answers from status.yaml; a free-text
thought becomes a formulated task after ONE clarifying re-ask; and «кроки»
works from the bot exactly as from a chat window.

## 3. Mandate (closed decisions — formalize, do not reopen; full text INFO-032)

1. **Composition v1 (closed list):** (a) gates/E1 as inline-button messages
   with DECISION PARITY — press = record in `decisions/` (hard criterion);
   (b) NARRATIVE.md feed by profile level; (c) morning digest via heartbeat
   + the self-update 3-line changelog (INFO-023); (d) «что в работе» from
   `products/*/status.yaml`; (e) free input → router-formulator with ONE
   clarifying re-ask before accepting a task; (f) «кроки» gesture works from
   the bot (message starting with кроки/qroky → skill protocol).
2. **Delivery physics:** local launchd listener, POLLING only (getUpdates)
   — no inbound ports, no webhooks, no resident agent daemons. Incoming
   answers land as files in `decisions/inbox/`; a live session or the next
   heartbeat picks them up. The asynchrony is honest: nothing pretends to
   listen continuously.
3. **Security v1 (instead of 2FA):** chat_id binding — only the owner's
   chat_id is honored; any other chat_id is ignored AND flagged.
   Risk-level HUMAN-TASK confirmations require an EXPLICIT TYPED WORD — no
   button is offered for them. (S3–S5 unchanged: token never logged, never
   printed, never backed up — the kit's gitignore block already covers
   `*.token`; nothing goes outward by agent hands except bot messages to
   the bound chat, which are the product itself.)
4. **NOT in v1 (не золотить — tree-level NOT-DOING):** 2FA, groups, inline
   editing, media. Do not build hooks «for later».
5. **Mandatory DoD scenario (verbatim):** «гейт нажат при закрытой сессии →
   ответ не потерян → подхвачен при пробуждении» — proven by harness, not
   by code reading.
6. **Token:** build and test on a TEST bot token (executor registers its
   own via BotFather flow or takes one from the CEO if provided — E1 only
   if truly blocked, Rowan first). Production token path = the one the kit
   interview stores; the code reads THAT path, никакой второй регистрации.

## 4. Definition of Done

**Hard (machine-checkable):**
- H1. **Parity round-trip:** harness proves button press → file in
  `decisions/inbox/` → pickup renders a decision record in `decisions/`
  carrying: gate id, the FULL question text as sent, the button label as
  pressed (verbatim, DR5), timestamp, channel=telegram. A session-typed
  answer to the same gate produces a record of identical force — diff shows
  channel field only.
- H2. **Closed-session scenario (the mandated one):** listener receives a
  press while NO session runs → inbox file persists → next pickup
  (simulated session or heartbeat run) consumes it exactly once (no loss,
  no double-execution on re-run). Kill-mid-write also leaves either a
  complete file or none (atomic write via tmp+rename).
- H3. **Listener physics:** launchd plist, polling interval sane (≥30s),
  `lsof` in harness shows NO listening ports; offset/state file survives
  restarts (no replayed old presses); listener is a plain script, not an
  LLM agent.
- H4. **chat_id binding:** foreign chat_id message → no action, one flag
  line in the listener log + inbox quarantine entry; harness exercises it.
- H5. **Risk-word rule:** messages that would confirm a risk-level
  HUMAN-TASK carry NO buttons; the prompt says the explicit word required;
  a button-press-style reply to such an item is rejected and re-asked.
- H6. **Morning digest:** heartbeat output (incl. «За сутки» and the
  3-line changelog when a new release tag exists) is delivered as ONE
  message to the bound chat; heartbeat absent/disabled → no crash, listener
  unaffected.
- H7. **NARRATIVE feed:** new appended beats of live trees are sent
  respecting the profile detail level (level from the human profile file;
  level 1 = gates only, 2 = beats, 3 = full reasoning beats); no re-send of
  old beats (offset per file).
- H8. **/status (or «что в работе»):** renders running/delivered atoms
  from `products/*/status.yaml` in plain language, ≤1 message.
- H9. **Free input router:** a non-command text produces exactly ONE
  clarifying re-ask, then a formulated task file in `decisions/inbox/`
  (kind=task-proposal) for the session to pick up — the bot does NOT
  execute anything itself; «кроки»-prefixed messages route to the skill
  protocol instead.
- H10. **Secrets:** test and production token read from file path only;
  negative grep over logs, inbox, harness transcripts and any committed
  file = zero token occurrences.
- H11. **Harness:** `dry-run.sh` with a stubbed Bot API (local fake
  getUpdates/sendMessage), all scenarios above non-vacuous (the r1-F1
  lesson: assertions must be able to fail); HARNESS-CHECKLIST (INFO-025)
  answered in run.log; full run green.
- H12. Blind verify: accept. Records per LP: RESULT.md with TEAM summary,
  run.log with breath lines (INFO-029) and budget checkpoints, NARRATIVE.md
  live from step 0.

**Soft (judge — CEO at G2):**
- S1. The CEO answers a REAL gate from his phone during the second-Mac test
  and the tree moves without him touching the Mac.
- S2. Digest and feed read as plain human language on a phone screen (no
  atom/verify jargon without a gloss).
- S3. The re-ask of the router feels like one smart question, not a form.

**Maturity target:** reviewed; validated on the first real phone-answered gate.

## 5. Method Hints (non-binding)

- Reuse the heartbeat launchd pattern (`runtime/claude/heartbeat/`) for the
  listener plist; same honesty rule in all rendered texts.
- Inbox record format: small YAML/MD files, one per event, tmp+rename;
  consumed = moved to `decisions/inbox/done/` (mirrors the CEO-orders
  ledger pattern the human already lives with).
- Outbound send helper should be callable BY the session and BY heartbeat
  (one script, two callers) — that is the «execution picked up by session
  or heartbeat» physics.
- Profile level source: the human profile file the kit installs; default 2.
- Keep the whole thing in `runtime/claude/telegram/` + atom folders; no
  edits to framework/, no edits to the kit in this tree (the kit already
  stores the token).

## 6. Escalation

E1–E8 per constitution; Rowan discipline on every E1 (test-token
registration: exhaust BotFather self-service first). The closed list §3 may
not be reopened — friction with it is E7 against INFO-032. NOT-DOING items
proposed anyway = defect. Gates: G1 CEO «го» on this plan; G2 live phone
round-trip. Envelope breach → honest E4.

---
*End of launch file. Formulated 2026-07-10 from INFO-032 (verbatim; tree B
accelerated ahead of A closure — production-token step is the only A
dependency and is already delivered in kit v0.1.1).*
