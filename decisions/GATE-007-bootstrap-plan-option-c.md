---
id: GATE-007
date: 2026-07-05
kind: gate
status: answered
atom: ATOM-006
trigger: backfill
answered_by: Ghenadie (human risk-taker)
recorded_by: ATOM-006 (orchestrator session)
---

# GATE-007 — Bootstrap plan: option C (public strategy tree + private third-party product)

## Question / Brief
Which product should serve as the framework's bootstrap validation (the first non-framework product produced end-to-end by the framework)? Options considered at the time: (A) a framework-internal product only; (B) a public third-party product inside this repository; (C) a two-part bootstrap — 006a: the public RPF business-strategy tree in this repository, and 006b: a private third-party product run after repo separation.

## Answer (verbatim)
*(Reconstruction per DR5 — backfilled from the accepted decision recorded in ATOM-006-LAUNCH.md / INPUT §3.2, formulated by Human (Ghenadie) + advisor agent and accepted 2026-07-05.)*

"006a = this public strategy tree. 006b = a private third-party product run after repo separation (client products live in separate private repos with the constitution as a dependency; pilot startups: their machine, their subscription, their private repo, our collaborator read-access as pilot condition)."

*English summary (HP3): option C accepted — the bootstrap runs in two parts: the public business-strategy tree (this product), then a private client product in a separate repository consuming the constitution as a dependency, under the pilot conditions listed.*

## Consequences
ATOM-006 (this tree) proceeds as bootstrap part 006a. Client/pilot products will not live in this repository; repo separation with the constitution as a dependency becomes a prerequisite for 006b, referenced by the pilot design (ATOM-012) and reserved atom ATOM-007. On successful closure of ATOM-006, the framework-v1 documents' bootstrap condition is met (M3 note in the parent RESULT).

## Fed back to
`products/business-strategy-v1/006-business-strategy/PLAN.md` (tree scoped to 006a only); pilot design INPUT (ATOM-012) carries the self-hosted / private-repo conditions. No role-spec change: the decision is product-scoping, not method.
