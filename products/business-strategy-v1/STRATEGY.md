# Qroky Business Strategy v1

**Assembled by ATOM-015 (venture-strategist) · 2026-07-05 · maturity target: reviewed · G2 gate: GATE-010**

Qroky sells one thing: a founder operating as **CEO of agents** — a constitutional framework whose recursive decomposition generates the questions the founder didn't know to ask (positioning per accepted §3.1; open-core boundary per RISK-002). This document is the strategy in ≤1500 words; every number traces to an analysis file by path. It is built to open three commercial conversations: with **Startup Moldova** (pilot kickoff), with a **first bank** (via pilot intros), and with a **follow-on accelerator or fund** (via the case study).

## Segments

We serve jobs, not demographics (`segments/segment-map.md`, G1-confirmed by `decisions/GATE-008-atom-006-g1-direction.md`). Three segments scored on the accepted 7-factor checklist:

- **A — non-technical founder in an accelerator (23/35):** jobs like "reach demo day without a technical cofounder and without giving up 30% equity". Our only live channel today. **First.**
- **C — regulated organization / bank innovation unit (25/35):** highest raw score, but the channel is gated on pilot proof by accepted decision. **Second.**
- **B — technical solo builder (18/35):** background self-serve funnel. **Third.**

Sequence **A → C → B**. Known sensitivity: A's rank rests on unverified willingness-to-pay and margin — both are pilot instruments, and the B2B2C rescue below covers the downside.

## Channel

Three options compared on unit economics (`channels/channel-comparison.md`): accelerator B2B2C, bank-as-GTM-partner, self-serve open core. Recommendation — the accepted sequence, now confirmed by numbers rather than assumed:

**Accelerator → paid bank pilot → second bank as leverage.** The accelerator costs ~$0 to enter (warm relationship, pilot paid in kind per `decisions/INFO-001-pilot-terms-startup-moldova.md`), matches one operator's capacity, and its exchange terms — case study + 2–3 bank/fund intros — make it the acquisition mechanism for the bank channel. Banks are paid-pilot-only, co-branded, with the risk-acceptance journal as the compliance answer; exclusivity short and expensive if at all. Open core runs passively underneath at zero marginal cost.

**Rescue option, priced:** if founder-level WTP fails at pilot exit, the payer flips to the program — cohort license $1,000–1,500/cohort-month for ~10 founders (assumption, `channels/channel-comparison.md`). **Kill trigger:** if the operator cannot hold 6+ founders inside the attention budget, capacity — not demand — is the failure; no second channel until that's resolved.

## Pricing

Ladder (`pricing/pricing-ladder.md`): **self-hosted free (open core) → Flow Support ($150/founder-month anchor, assumption tested at pilot exit) → managed (3–5× Flow Support, priced after the first bank conversation).**

The unit economics are computed from this repository's real cost blocks (verify runs 105–139k tokens each, real counters in `knowledge/precedent/verify-envelope-calibration.md` and both product `status.yaml` files): an active founder-month ≈ 1.0–1.6M tokens ≈ **$15–32/month raw compute** at current per-tier API prices (tiers per `runtime/claude/README.md`). The strategic consequence: **token COGS is negligible against the $50–200/month WTP band (assumption, pilot-tested) — the binding cost is human owner-review attention (8–15 h/founder-month, assumption).** Margin survives a ×3 error in token estimates; it does not survive mispricing human hours. Pricing therefore scales by attention tier, not token volume — and the framework's own promise (less human attention per product) is literally the margin engine.

## Pilot

**Flow Support v0 with Startup Moldova** (`pilot/pilot-design.md`): a couple of startups incl. non-technical founders, self-hosted — their machine, their subscription, their private repo — with our collaborator access and consented telemetry limited to operational files only (no business content, open script, deletable, fixed date; consent text ready in the pilot design). Service: daily owner review, sentinel-drafted interventions human-approved, **SLA: reaction to blocked within one business day**. Exchange (human-decided, `decisions/INFO-001-pilot-terms-startup-moldova.md`): public case study + 2–3 bank/fund intros. Red lines stated up front: no turnkey production code, no investment guarantees, no exclusivity, no team hiring.

Six measured success criteria convert the strategy's widest assumptions into data — cycles/month, owner-minutes/day, concurrent capacity, WTP at exit, case study + intros delivered. ~12 weeks, one cohort rhythm. Metrics and their instruments: `metrics/metrics-system.md` (escalation rate, verify returns, cost per product type, founder-hours per gate — all grep-able from files the constitution already obliges). Prerequisites (setup script, execution tiers) belong to a future ATOM-007.

## Name

Verdict (`naming/naming-verdict.md`, human-accepted via GATE-009; evidence updated per `decisions/INFO-002` and `decisions/INFO-003`): **Atomaro is dead** — a live commercial product of a major telecom occupies the name in our market's language space; backorder cancelled. **Qroky is cleared for public use**: qroky.com and the GitHub org secured (human-acquired), and the formal register screen (TMview across EUIPO/WIPO/USPTO/AGEPI, 05.07.2026) came back clean — zero exact hits, no live near-string mark in classes 9/42. The "RPF"→Qroky swap was executed per GATE-012 (ATOM-017, 2026-07-07). Method lesson recorded: live-company search in the market's languages first — it killed in one check what domain research missed. Rejected names and all other closed questions live in `NOT-DOING.md` (14 entries, each with a revisit trigger).

## Re-validation

Strategy is a product whose maturity decays (accepted §3.8). **Quarterly re-validation gate:** a re-touch is a diff against this file plus a human gate — not a meeting. The gate reads current numbers from `metrics/metrics-system.md` and the revisit triggers in `NOT-DOING.md`; the pilot exit (criteria above) forces the first re-anchor of pricing and segments regardless of calendar. Anything here proven wrong gets changed by diff, logged by decision record — same discipline as everything else in this repository.
