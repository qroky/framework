# Runtime Binding — Claude Code

| Field | Value |
| :---- | :---- |
| Product | First runtime binding: Claude Code |
| Parent product | Recursive Product Framework v1 |
| Produced by | ATOM-004H (executor role: Framework Architect) |
| Contract implemented | `framework/ORCHESTRATION.md` §7 (RC1–RC5) |
| Maturity | `reviewed` (target) |
| Date | 2026-07-05 |

This document binds the abstract runtime contract to **Claude Code** (Anthropic's agentic coding tool: CLI, desktop app, and IDE extension). Platform names are legal here and only here (RC3). Primary reader: the human operator. A person — or a headless caller — reading only this file can launch any launch file of this repository correctly.

**Contract coverage map (RC4):**

| RC2 item | Section here |
| :- | :---- |
| 1 — Session start | §1 |
| 2 — Human interface | §2 |
| 3 — Tier mapping | §3 |
| 4 — Instantiation mapping | §4 |
| 5 — Cost counters | §5 |
| 6 — Headless invocation | §6 |

Plus §7 operational pitfalls and §8 known limitations (RC5).

## 1. Session start

1. Open a terminal (or the IDE with the Claude Code extension) **in the repository root** — every path in launch files and framework documents is relative to it.
2. Start a fresh session: `claude` in the CLI, or a new chat in the IDE/desktop app.
3. Hand over the launch file: open `<ATOM-ID>-LAUNCH.md` in the editor (it attaches as context) or reference it by path, and say: **"Execute this launch file"**.
4. The session then reads the four framework documents, performs step 0 (LP3: materialize `INPUT.md` verbatim, open `STATUS.md` at `formulated`, write `status.yaml` entries), and executes the atoms in declared order (LP4).

## 2. Human interface

- Question sets, gate briefs, and sign-off requests (E1–E3, VP18) are surfaced through the session's **interactive question interface**: the operator sees the brief and clickable options (with a marked recommendation) directly in the session.
- Briefs addressed to the human are written in that human's `preferred_for_decisions` language (HP2 — currently Russian for `roles/humans/ghenadie.md`).
- The chosen answer is recorded **verbatim** into the decision record under `decisions/` (DR5), followed by a one-paragraph English summary (HP3). The session — not the human — writes the record; the human only answers.
- Practice: GATE-002 through GATE-005 were all captured this way.

## 3. Tier mapping (dated 2026-07-05 — review at every touch of this file)

| Tier (MT2) | Concrete model | Used for |
| :---- | :---- | :---- |
| `S` | Claude Haiku 4.5 | Mechanical checks, extraction, script-checkable transforms |
| `M` | Claude Sonnet 5 | Standard structured production against a clear spec |
| `L` | Claude Fable 5 (fallback: Claude Opus 4.8) | Formulate, Verify, normative writing, decomposition planning (MT3 reservation) |

Operational note: flagship-tier quota (Fable/Opus) is limited on current plans. If quota forces a substitution, log it in the run log; prefer postponing a tier-L Verify over running it below tier L (MT3/MT4 — a weak verifier is a rubber stamp).

## 4. Instantiation mapping

| Mode (L2) | On this platform | VP4 isolation |
| :---- | :---- | :---- |
| `session` | A fresh Claude Code session, **or** an Agent-tool subagent spawned with a clean context (it receives only its prompt and the files it reads) | Yes — no executor or parent context is shared |
| `subagent` | An Agent-tool spawn inside the parent session | Not isolated from the parent's instructions; fine for light branches |
| `auto` | Left to the session's judgment (Agent tool by default) | Per choice made |

Practice: every Verify atom to date (ATOM-002/003/004-VERIFY) ran as a fresh-context Agent-tool spawn with a blind-package `INPUT.md` — the `session` semantics of SS6. Regardless of mode, deliverables travel only on the file bus (SS2, L9): the subagent's chat reply is a signal, never the product.

## 5. Cost counters

- **Subagent runs:** the runtime reports a real total (`subagent_tokens`) in the Agent-tool result. The closing actor copies it into the run log and cost aggregation (EC6). Practice: 123,814 real tokens for ATOM-003-VERIFY; 139,394 for ATOM-004-VERIFY — both recorded from this counter.
- **Main-session executors:** no live counter is exposed *to the executor* mid-flight, so cost blocks use `~`-prefixed estimates (BC4) calibrated per BC2 (bytes ÷ 3). The operator can see session totals via `/cost` (CLI) or the status line and may record them at closure.
- Consequence: the E4 hard stop for main-session work currently rests on the executor's own estimates, not on metering — see §8.

## 6. Headless invocation

- From the repository root: `claude -p "Execute the launch file <ATOM-ID>-LAUNCH.md"` (non-interactive "print" mode; add `--permission-mode acceptEdits` or a configured allowlist so file writes do not stall).
- At human-required points (E1–E3 questions, VP18 sign-off) the interactive question interface is **unavailable**. Per RC2 item 6 the session MUST then: set the atom's `STATUS.md` to `blocked`, write the decision record in `status: pending` with the full question set or brief (EP3), commit and push if a remote is configured (so the human sees it on the bus), and stop. It MUST NOT skip the point or answer for the human. Resumption per EP5: a later session records the answer and continues.
- Status: this is the designed behavior; it has not yet been exercised end-to-end — see §8.

## 7. Operational pitfalls (observed this week)

1. **Launch from the repository root only.** Sessions started elsewhere resolve relative paths wrong.
2. **One launch-file version.** Keep exactly one copy of the launch file open in the editor; close stale duplicates.
3. **Save before send.** An unsaved editor buffer attaches the stale on-disk version. Save, then say "Execute this launch file".

## 8. Known limitations (RC5 — what this runtime does not yet enforce)

- **No automatic E4 metering for main-session executors.** Overrun protection is calibration + self-reporting until real counters are surfaced to executors (three verify-envelope precedents in `knowledge/precedent/verify-envelope-calibration.md`).
- **Headless human-gate path untested.** §6 documents designed behavior, not verified practice.
- **VP4 isolation is a platform property, not an enforcement.** Clean-context spawns depend on Claude Code's subagent semantics; nothing here can prove the verifier read nothing else beyond its logged blind-package list.
- **Tier substitutions under quota pressure are logged, not prevented.** The run log is the audit trail.

*End of the Claude Code binding. Contract: ORCHESTRATION §7. This file names the platform; the framework never does.*
