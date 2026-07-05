# Segment Map — who RPF serves first

| Field | Value |
| :---- | :---- |
| Product | Jobs-based segment map, RPF Business Strategy v1 |
| Produced by | ATOM-009 (executor role: market-analyst) |
| Maturity | `draft` — human direction check at G1 |
| Date | 2026-07-05 |

Discipline per parent INPUT §3.5: segments defined by the jobs they would hire RPF for; every job is a stated **hypothesis** with a client success criterion, not a fact. Scoring: the accepted 7-factor attractiveness checklist, each factor 1–5 where **5 = most attractive** (for "competition for its jobs": 5 = weak competition). Every quantitative claim is sourced or marked `assumption`.

## Segment A — Non-technical founder in an accelerator *(candidate #1 per input)*

**Job hypotheses:**
- A-J1 (Hypothesis): "Reach demo day without a technical cofounder and without giving up 30% equity." Success criterion: founder presents at demo day with an investor-credible product tree (strategy, PRD, MVP scope, working demo path) and has surrendered no equity for tooling or technical guardianship.
- A-J2 (Hypothesis): "Surface what I don't know to ask — before it's expensive." Success criterion: the founder's key risks and decisions appear in the decision journal *before* they become urgent; no "wish I'd known in month 1" surprise at cohort exit.
- A-J3 (Hypothesis): "Produce artifacts that survive mentor and investor scrutiny, with an audit trail of why." Success criterion: mentor review cycles shorten; investors accept the artifacts as diligence-grade.

**Scores:**
| Factor | Score | Evidence / assumption |
| :---- | :- | :---- |
| Segment size | 3 | Accelerator cohorts are a structured, enumerable population; reachable slice today = one national ecosystem (assumption: Startup Moldova cohorts ≈ tens of founders/yr; global expansion via accelerator playbook later) |
| Competition for its jobs | 3 | For *artifact production* strong competition (no-code builders, AI app generators, dev agencies); for *governed production + questions-you-didn't-ask* no direct incumbent found (assumption from category scan; see NOT-DOING for rejected framings) |
| Achievable added value | 5 | From zero structure to a governed product tree with verification and audit trail — the MANIFEST differentiator lands hardest on the least-structured founder (source: MANIFEST.md) |
| Budget for the job | 2 | Solo-founder WTP ceiling assumed $50–200/mo, untested until pilot exit (source: parent INPUT §3.7 — assumption by design) |
| Channel existence & capacity | 4 | Live channel: Startup Moldova verbal agreement incl. non-technical founders (source: parent INPUT §3.4); capacity small (one program) |
| Target unit margin | 2 | Flow Support v0 is human-hours-heavy at start; margin depends on tokens + founder-hours vs low WTP (assumption; measured at pilot per §3.4) |
| Switching readiness | 4 | No incumbent governance tool to switch away from; barrier is habit-building, not migration (assumption) |
| **Total** | **23/35** | |

## Segment B — Technical solo builder / indie hacker (self-serve open core)

**Job hypotheses:**
- B-J1 (Hypothesis): "Run an agent workforce without babysitting it — trust verification instead of re-reading everything." Success criterion: builder reviews only gates and escalations; verified-work error-escape rate stays below their own review bar.
- B-J2 (Hypothesis): "Keep a defensible record of what was decided and why." Success criterion: any past decision reconstructable from the journal in minutes.

**Scores:**
| Factor | Score | Evidence / assumption |
| :---- | :- | :---- |
| Segment size | 4 | Large global population of agent-tooling early adopters (assumption; no sourced count) |
| Competition for its jobs | 2 | Crowded: many open orchestration/agent frameworks compete for "run my agents"; governance/verification angle is rarer but the audience overlaps heavily (assumption from category familiarity) |
| Achievable added value | 3 | They can improvise harnesses themselves; value concentrates in the verification discipline and audit trail (assumption) |
| Budget for the job | 2 | OSS-first audience, low willingness to pay; monetizes only via later conversion (assumption) |
| Channel existence & capacity | 2 | Self-serve on open core requires brand/funnel — explicitly "slow" (source: parent INPUT §3.6c) |
| Target unit margin | 3 | Self-hosted free tier costs us ~0; margin exists only on conversions (source: pricing ladder §3.7) |
| Switching readiness | 2 | Already invested in their own stacks and habits (assumption) |
| **Total** | **18/35** | |

## Segment C — Regulated organization (bank) innovation / digital unit

**Job hypotheses:**
- C-J1 (Hypothesis): "Adopt agent production inside compliance constraints — maker-checker, blind verification, recorded risk acceptance." Success criterion: internal audit and compliance sign off on a pilot use case running under the framework.
- C-J2 (Hypothesis): "Show the board and regulator a controlled-AI story that is architecture, not slideware." Success criterion: the control framework passes an internal (or supervisory) review with the decision journal as evidence.

**Scores:**
| Factor | Score | Evidence / assumption |
| :---- | :- | :---- |
| Segment size | 3 | Few organizations, high value each; founder's fintech network reaches MD/RO-region banks directly (source: MANIFEST "regulated organizations, deliberately"; network reach = assumption pending E1) |
| Competition for its jobs | 4 | Governance-as-architecture for agent production has no visible direct incumbent; big-vendor "AI compliance" tooling addresses models, not agent work production (assumption from category scan) |
| Achievable added value | 5 | Segregation of duties, blind verification, append-only journal are native here — banking maker-checker isomorphism (source: MANIFEST.md) |
| Budget for the job | 5 | Banks budget for governance and compliance tooling (assumption, high confidence) |
| Channel existence & capacity | 2 | Gated: bank GTM only AFTER pilot proof, paid pilot only (source: parent INPUT §3.6b — accepted constraint) |
| Target unit margin | 4 | Paid pilots and enterprise terms; co-branding mandatory (source: §3.6b) |
| Switching readiness | 2 | Conservative procurement, long cycles (assumption, high confidence) |
| **Total** | **25/35** | |

## Ranking and sensitivity

**Sequence (not a pure score sort):** **A → C → B.** C scores highest (25) but its channel is constitutionally gated on pilot proof (§3.6b), and the pilot happens in A. A (23) has the only live channel today. B (18) runs in the background as the open-core funnel, not a first target. This reproduces the accepted sequence hypothesis (accelerator → paid bank pilot → second bank as leverage) from evidence, not by decree.

**Sensitivity:** A's rank rests on two weak scores that are assumptions by design — budget (2) and margin (2). If pilot-exit WTP comes in under the $50–200/mo floor, the segment survives only if the **program**, not the founder, pays (B2B2C cohort license — channels atom must price this). C's rank collapses to "later" if the pilot produces no bank-legible evidence — the pilot design must therefore capture compliance-relevant telemetry. B is insensitive: nothing rides on it this quarter.

## Open questions for the human (G1 material)
1. Does segment A's job list match what accelerator founders actually say they need (his customer knowledge)? Anything missing or overstated?
2. Which 2–3 banks in his network would take a post-pilot meeting — does C's channel assumption hold?

*Segments not scored: fractional-CxO consultancies, dev agencies, corporate venture studios — parked to NOT-DOING with revisit triggers.*
