---
atom: ATOM-006
product: RPF Business Strategy v1 (products/business-strategy-v1/STRATEGY.md + tree)
parent: RPF (the venture itself)
formulated_by: Human (Ghenadie) + advisor agent, 2026-07-06
verification: independent + human (final strategy gate in Russian per HP2/HP3)
maturity_target: reviewed
instantiation: session (orchestrator); children per ORCHESTRATION defaults
model_tier: L for this orchestrator, for all Formulate work and all Verify atoms; M for standard Execute; S for mechanical checks — per MT rules, tier justifications logged
budget: ~200k tokens total envelope, cascaded to children per O6.1/EC rules. Hard stop per O6.2. If the weekly cap blocks progress, atoms wait in their STATUS — do not burn the owner's Monday work quota.
recursion_allowance: 2
---

# ATOM-006 — Input Specification

## 1. Product Identity
| Field | Value |
| :---- | :---- |
| Product | `products/business-strategy-v1/STRATEGY.md` + the sub-product tree below |
| Atom ID | ATOM-006 |
| Parent product | RPF venture |
| Executor role | venture-strategist — DOES NOT EXIST YET; resolve per F2 (role-creation atom first). Same applies to any child role (market-analyst, pricing-strategist, ...): create on demand, ≤60 lines each, provenance recorded |
| Input product(s) | This INPUT; MANIFEST.md; the full repo (constitution, decisions/, knowledge/); §3 below (accumulated accepted decisions) |
| Consumer(s) | The human owner (decision basis for the next quarter); the pilot design (executable plan); the naming decision (brand go/no-go); future investors/partners (readable strategy with audit trail) |
| Maturity target | reviewed |
| Gates | G1 after naming + segments delivered (direction check, before channel/pricing work); G2 final strategy acceptance. Both briefs in Russian per HP2. Trigger gates implicit |
| Verification mode | independent + human |
| Budget envelope | ~200k tokens |
| Recursion-depth allowance | 2 |

## 2. Job To Be Done
Produce a decision-ready business strategy for RPF: who we serve first, through which channel, under what name, at what price, validated by a designed pilot — with every option considered, every rejection recorded, and every human answer in the journal. The strategy must be enough to open the first three commercial conversations. This tree is also the framework's own bootstrap exam: it must run on a foreign (business) domain without constitutional improvisation.

## 3. Context — Decisions Already Made (formalize, do not reopen)

### 3.1 Positioning (accepted, in MANIFEST)
Founder-as-CEO-of-agents; the differentiator: recursive decomposition generates the questions the founder didn't know to ask. Open-core boundary per RISK-002.

### 3.2 Bootstrap plan (option C, accepted 2026-07-05 — record as decision per DR8)
006a = this public strategy tree. 006b = a private third-party product run after repo separation (client products live in separate private repos with the constitution as a dependency; pilot startups: their machine, their subscription, their private repo, our collaborator read-access as pilot condition).

### 3.3 Naming (inputs for the naming atom)
Front-runner: **Atomaro** (semantic hook "atom", clean field — no live company found, atomaro.dev/.app owned, GitHub org atomaro-hq owned, atomaro.com squatted by a dormant holder expiring 2026-11-10 with a backorder planned). Reserve: **Qroky** (fully available incl. qroky.com, zero semantics). Dead: Atomos (live London company "Atomos AI" + video-hardware trademark holder). Hard-DoD checklist earned this week, apply in order of cheapness: (1) live-company search in category BEFORE domain checks; (2) GitHub namespace via org-creation form + `<name>.png` avatar probe — 404 alone proves nothing; (3) trademark screen EUIPO/USPTO/WIPO, incl. phonetic neighbors (flag: Atomico, the London VC — assess confusion risk explicitly); (4) domain field state; (5) 5-second comprehension test for a non-technical founder; (6) pronounceability en/ro/ru/fr; (7) sed-replaceability preserved until verdict. Output: verdict with evidence per candidate + human gate.

### 3.4 Pilot (inputs for pilot-design atom)
Partner: Startup Moldova, verbal agreement — a couple of startups incl. non-technical founders. Mode: self-hosted (their machine, their Claude subscription, their private repo) + our collaborator access + selective telemetry push (operational files only: STATUS, RESULT cost blocks, run.log, status.yaml, verdicts — no business content; open script; explicit consent; deletable after pilot, date fixed). **Flow Support v0** framing: observation is a service, not a payment — daily owner review (he chose daily deliberately), sentinel atoms draft interventions, human approves/sends; SLA "reaction to blocked within one business day"; human-hours measured as future tier unit-economics. Prerequisites owned by a future ATOM-007 (setup script, execution tiers inline/micro/full) — reference, do not build here. OPEN E1 to the human (ask at G1, in Russian): what we request from Startup Moldova in return (case study? intros? rev-share on conversions?) and the red lines of what we do NOT promise founders.

### 3.5 Segments discipline (accepted 2026-07-06)
Segment by jobs-to-be-done with client success criteria — never by demographics alone (demographic cut secondary). Candidate segment #1: non-technical founder in an accelerator; its jobs are hypotheses to state explicitly (e.g. "reach demo day without a technical cofounder and without giving up 30% equity"), not facts. Attractiveness factors checklist for scoring: segment size × competition for its jobs × achievable added value × budget for the job × channel existence and capacity × target unit margin × switching readiness.

### 3.6 Channels (hypotheses to compare, not decisions)
(a) Accelerator B2B2C — cohort license + graduate discount; equity with founders — frozen; possible success-fee with the program itself. First conversation already open (Startup Moldova). (b) Bank as GTM partner — AFTER pilot proof; paid pilot only; co-branding mandatory; exclusivity short and expensive if at all; the risk-acceptance journal is the liability answer for bank compliance. (c) Self-serve on open core — brand/funnel, slow. Sequence hypothesis: accelerator → paid bank pilot → second bank as leverage. Compare with unit economics; recommendation + rejected options into NOT-DOING.

### 3.7 Pricing (inputs)
Ladder hypothesis: self-hosted free (open core) → Flow Support (observation + interventions + monthly report) → managed. Unit-economics atom must use REAL cost data from this repo's cost blocks (a full atom cycle ≈ 90–120k tokens; verify ≈ read×3.5+constant) to compute what an active founder-month costs in tokens at current API/subscription prices; solo-founder willingness-to-pay ceiling assumption: $50–200/mo — test at pilot exit, not now.

### 3.8 Strategy hygiene (accepted 2026-07-06)
STRATEGY.md carries a **quarterly re-validation gate** (strategy is a product whose maturity decays; re-touch = diff + human gate, not a meeting). A **NOT-DOING.md** register is a first-class deliverable: every rejected segment/channel/initiative, one line why, revisit-when trigger. Known rejections to backfill: equity-for-tooling with founders; bank GTM before pilot; robotics until sim-gate; Atomos name; broad TLD shopping.

### 3.9 Honesty
No market claims that are not sourced; market numbers the agents cannot verify are E1 questions to the human or explicitly-marked assumptions. The strategy is decision-ready when the human can open three commercial conversations from it — not an investment memorandum. Do not gold-plate.

## 4. Deliverable (the tree — decomposition plan per ORCHESTRATION; parent may adjust with logged justification)
```
products/business-strategy-v1/
  STRATEGY.md            ← assembly: segments→channel→pricing→pilot→name, with re-validation gate
  NOT-DOING.md           ← rejection register
  naming/                ← Atomaro due diligence + verdict (human gate)
  segments/              ← jobs-based segment map, scored by §3.5 checklist
  channels/              ← 3-option comparison with unit economics + recommendation
  pricing/               ← ladder + founder-month token economics from repo cost data
  pilot/                 ← pilot design: success criteria, telemetry consent text, SLA, timeline
  metrics/               ← RPF success metrics system (escalation rate, verify returns, cost per product type, founder-hours per gate)
```
Each sub-product: own atom(s), own INPUT/STATUS/RESULT, verification per F3 risk mapping (strategy assembly and naming verdict: independent + human; internal analyses: independent or self per risk).

## 5. Definition of Done (parent)
**Hard:** H1 all §4 files exist. H2 STRATEGY.md ≤1500 words excl. headings, contains sections Segments/Channel/Pricing/Pilot/Name/Re-validation (headings detectable). H3 NOT-DOING.md has ≥5 entries each with why + revisit-trigger. H4 naming verdict contains per-candidate evidence for all 7 checklist points. H5 pricing shows founder-month token cost computed from ≥3 real cost blocks of this repo (cited by path). H6 every child atom closed per L7 with STATUS delivered and cost aggregated per O4.2; status.yaml complete. H7 ≥2 new role specs in /roles/ with provenance. H8 decision records exist for: option-C backfill, G1, G2, naming verdict, pilot terms (E1 answer). H9 zero contradictions with constitution; platform names only where REPO-STRUCTURE permits.
**Soft:** S1 the human can open three commercial conversations using only STRATEGY.md — judge: human (G2). S2 every strategic claim is sourced, assumed-and-marked, or human-answered — judge: Verify. S3 the tree ran without constitutional improvisation; any gap found is logged as a framework finding for the next constitutional touch — judge: Verify. S4 gate briefs and human-addressed products were delivered in Russian per HP2 — judge: human.

**Maturity target:** reviewed. On acceptance, record the bootstrap condition of framework-v1 as met (M3 note in RESULT).

## 6. Method Hints (non-binding)
Sequence children by dependency: naming ∥ segments → G1 → channels → pricing ∥ pilot ∥ metrics → NOT-DOING → STRATEGY assembly → G2. Parallel branches only where the runtime makes it cheap; sequential is fine. Steal the attractiveness checklist wording from §3.5 rather than inventing scales.

## 7. Escalation
E1–E7 per constitution. Expected E1s to the human (consolidate, Russian): Startup Moldova terms + red lines (§3.4); any market number agents cannot source; segment-job hypotheses needing his customer knowledge. Gates G1/G2 as placed. Budget hard stop per O6.2 — atoms wait, never self-waive. Otherwise: do not ask for permission on the normal path. Execute.
