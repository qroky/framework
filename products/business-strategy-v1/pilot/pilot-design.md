# Pilot Design — Flow Support v0 with Startup Moldova

**Atom:** ATOM-012 · **Role:** venture-strategist · **Date:** 2026-07-05 · **Maturity:** draft
**Inputs:** ATOM-006 INPUT §3.4/§3.2/§3.9; `decisions/INFO-001-pilot-terms-startup-moldova.md`; `pricing/pricing-ladder.md`; `channels/channel-comparison.md`.
Prerequisites (setup script, execution tiers) are owned by future **ATOM-007** — referenced throughout, built nowhere in this document.

---

## Framing

**Observation is a service, not a payment** (accepted §3.4). Pilot founders — a couple of startups from Startup Moldova, including non-technical founders (source: §3.4, verbal agreement) — run RPF **self-hosted**: their machine, their own runtime subscription (tiers per `runtime/claude/README.md`), their private repo with the constitution as a dependency (repo separation per accepted §3.2). We provide **Flow Support v0**: daily owner review of their atom flows, sentinel atoms draft interventions, a human approves and sends every intervention. Daily cadence is deliberate (accepted §3.4). The pilot is simultaneously the test instrument for the strategy's marked assumptions (see Success criteria) and — per `channels/channel-comparison.md` — the acquisition mechanism for the bank channel.

## Exchange & red lines

**What Startup Moldova provides** (source: `decisions/INFO-001-pilot-terms-startup-moldova.md`, human-decided): a public case study + 2–3 introductions to banks / funds / follow-on accelerators. Equity with founders is frozen (accepted §3.6a).

**Red lines — what we do NOT promise founders** (INFO-001, verbatim scope):
1. No turnkey production code.
2. No investment guarantees.
3. No exclusivity.
4. No team hiring.

These four lines appear in the founder-facing expectations script (below) — stated up front, not discovered later.

## Success criteria

Each criterion converts a named, marked assumption from the strategy into measured data (sources: `pricing/pricing-ladder.md` §3, `channels/channel-comparison.md`).

| # | Criterion (target) | Tests which assumption | Instrument |
| :- | :---- | :---- | :---- |
| 1 | ≥2 founders complete ≥4 weeks of active use each | pilot viability floor (assumption) | telemetry: status.yaml activity |
| 2 | Real cycles/founder-month measured; model range 90–120k tokens/cycle, ~10 cycles/mo (assumption per §3.7) confirmed or re-anchored | founder-month token model | telemetry: run.log + status.yaml counters |
| 3 | Owner-review time ≤30 min/day/founder averaged over the pilot (assumption: 15–30 min) | Rung-2 margin's binding COGS | measured human-hours log (accepted §3.4: "human-hours measured as future tier unit-economics") |
| 4 | Operator holds ≥2 concurrent founders without SLA breach; extrapolation to ≥6 stated with evidence | channel capacity kill trigger (`channels/channel-comparison.md`) | SLA log + hours log |
| 5 | Pilot-exit pricing conversation: WTP signal inside $50–200/mo band (assumption per §3.7 — **this is the designated test**) or B2B2C rescue triggered | WTP ceiling; payer identity | structured exit interview per founder + program |
| 6 | ≥1 case study publishable + ≥2 of the 3 promised intros delivered | channel (b) bridge (INFO-001) | exchange checklist with Startup Moldova |

Escalation rate, verify returns, and cost per product type are pilot metrics too — defined in `metrics/metrics-system.md` (ATOM-013), not duplicated here.

## Telemetry & consent

**Scope (accepted §3.4, closed list):** the telemetry push copies **operational files only** — `STATUS.md`, `RESULT.md` cost blocks, `run.log`, `status.yaml`, verify verdicts. **No business content**: no INPUT bodies, no deliverables, no decision-record texts, no code. The push script is **open** — the founder can read every line of what leaves their machine. Delivery of the script itself is an ATOM-007 prerequisite.

**Consent text (founder-facing; ships RO/RU at ATOM-007 setup — English master per HP2):**

> **Telemetry consent — RPF pilot (Flow Support v0)**
> You run RPF on your own machine, your own subscription, and your own private repository. To support you and to measure what the framework really costs, we ask your consent to receive copies of **operational files only**: atom STATUS files, the cost blocks of RESULT files, run logs, status.yaml, and verification verdicts.
> **We never receive**: your product content, specifications, code, decisions, or anything describing what your startup is building. The script that sends these files is open — you can read exactly what it sends before you agree.
> Your data is used for two purposes only: (1) daily review of your flows so we can help when something is blocked (reaction within one business day), and (2) aggregate cost/usage statistics for the framework.
> **Deletion:** all telemetry from your repos is deleted on **[pilot end date + 30 days — fixed in writing at signing]**, or earlier on your request at any time, no reason needed.
> **What this pilot is not** (so expectations are honest): we do not deliver turnkey production code, we do not guarantee investment, we do not ask for exclusivity, and we do not hire or replace your team.
> Consent is explicit, opt-in, and revocable: reply "I agree" / sign below. Revoking stops the push and triggers deletion.

## Operating cadence & SLA

- **Daily** owner review of each founder's flows (deliberately daily — accepted §3.4).
- Sentinel atoms draft interventions; **a human approves/sends every intervention** — nothing reaches a founder unreviewed.
- **SLA: reaction to any `blocked` state within one business day** (accepted §3.4 verbatim).
- Every intervention and its minutes logged — the human-hours ledger is a first-class pilot output (feeds Rung-2 pricing).

## Timeline

One accelerator-cohort rhythm (assumption — synchronized with Startup Moldova's calendar at kickoff): **weeks 0–1** onboarding (ATOM-007 setup script, consent signing, private repo creation per §3.2); **weeks 2–9** active Flow Support (8 weeks measured operation); **weeks 10–11** exit: pricing conversations, case-study drafting, intros scheduled; **+30 days** telemetry deletion per consent. Total ≈ 12 weeks (assumption).

## Exit

The pilot ends with: (1) the six criteria scored against targets; (2) pricing re-anchored — criteria 2/3/5 replace the three widest assumptions in `pricing/pricing-ladder.md`; (3) capacity verdict against the channel kill trigger — if <6-founder extrapolation fails, escalate to the quarterly re-validation gate before any second channel (`channels/channel-comparison.md`); (4) case study + intros delivered per INFO-001 — opening the bank channel; (5) telemetry deletion executed on the fixed date. Failure on criteria 1–4 with success on 6 still yields the channel bridge; failure on 6 is a partner-relationship escalation (E3) regardless of technical success.
