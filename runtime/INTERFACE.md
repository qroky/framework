# Runtime INTERFACE — the neutral-core ↔ binding boundary

> Half-page map (INFO-030 п.1) for two readers: a community forker porting
> Qroky to another runtime, and anyone adding a feature — a new feature that
> crosses this boundary in the wrong direction is a defect. The framework
> never names a platform (RC3); everything platform-specific lives in a
> binding under `runtime/<name>/`.

## What the framework REQUIRES from any runtime binding

A binding is complete when it delivers these seven capabilities (the RC2
contract, ORCHESTRATION §7):

1. **Session start** — a way to hand a launch file to a fresh agent session
   that reads the five constitutional documents and executes LP3.
2. **Human interface** — question sets, gate briefs, and sign-off requests
   reach the human in their profile language; answers are recorded verbatim
   by the session (DR5), never by the human.
3. **Tier mapping** — three model tiers S/M/L mapped to concrete models.
   The SYSTEM routes by work class (MT rules); the USER never picks a model
   — a binding that surfaces model choice to the user violates the boundary.
4. **Instantiation** — `session` (clean-context spawn, VP4 isolation for
   blind verify) and `subagent` (in-session spawn) both available.
5. **Cost counters** — real token counts per spawned agent (EC6); where the
   runtime hides them, calibrated estimates marked `~` (BC4).
6. **Headless operation** — at human-required points an unattended run
   blocks, writes the pending decision record to the bus, and stops (EP3) —
   it never answers for the human.
7. **File bus** — deliverables travel as files in the repo; chat replies are
   signals, never products (SS2/L9).

## What stays in the CORE (never in a binding)

The five framework documents, roles, knowledge, decisions — no platform
names, no model names, no vendor API shapes. Rules cite tiers (S/M/L) and
capabilities (spawn, verify, counters), never products.

## What stays in the BINDING (never in the core)

Model ids and quotas, spawn syntax, permission modes, schedulers
(launchd/cron), notification channels, install mechanics. Reference
implementation: `runtime/claude/README.md` + `runtime/claude/heartbeat/`.

## Forking

Port = write a new `runtime/<yours>/README.md` delivering the seven
capabilities; the core needs zero edits. See CONTRIBUTING for the forking
policy (Apache-free code, protected name — forks rename). Regression duty:
after any model-version change inside a binding, re-run the reference atom
and compare behavior (RELEASE checklist step 7).
