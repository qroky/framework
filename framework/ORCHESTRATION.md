# ORCHESTRATION — Orchestration Protocol

| Field | Value |
| :---- | :---- |
| Product | Orchestration Protocol v1 |
| Parent product | Recursive Product Framework v1 |
| Produced by | ATOM-004 (executor role: Framework Architect) |
| Maturity | `reviewed` (target) |
| Date | 2026-07-05 |

This document defines how atoms compose into running products: decomposition planning, executor-class assignment, budget calibration, gate-brief placement, the launch-file format, spawn mechanics, and status synchronization. ATOM-SPEC is the contract, FEV-PROTOCOL the checking, REPO-STRUCTURE the ground; this is the assembly. After it, a formulating agent takes a product from idea to a tree of running atoms without inventing any mechanics — and a runtime author knows exactly what a binding must implement.

---

## 0. How to Read This Document

- Rule language (MUST / MUST NOT / SHOULD / MAY) carries the meanings of ATOM-SPEC R0.1. Numbered rules and tables are normative; passages marked *(informative)* bind nobody (R0.2).
- Rule prefixes in this document: **OD** (decomposition & planning), **MT** (model tiers), **EC** (envelope calibration), **GB** (gate briefs), **LP** (launch protocol), **SS** (spawn & status sync), **RC** (runtime-binding contract). None collide with the prefixes of ATOM-SPEC, FEV-PROTOCOL, or REPO-STRUCTURE (the P0.2 discipline); rules of all four documents are citable side by side.
- Precedence: per R0.3 and P0.3, this document tightens obligations of the earlier three documents and never relaxes them. A statement here that appears to relax one is defective: the earlier document prevails, and the conflict MUST be reported — as a finding if discovered at verification, as trigger E7 if discovered at execution.
- **Id-space disambiguation.** Finding ids (`F1..Fn` per VP11) share their letter with ATOM-SPEC's Formulate rules (F1–F6). Where a citation could be read as either, it MUST name its space: "ATOM-SPEC F1" for the rule, "finding F1 of `<atom-id>-VERIFY`" for the finding.

*(informative)* Orchestration at a glance — the duties this document assigns, in lifecycle order:

| When | Duty | Rule |
| :---- | :---- | :---- |
| Product needs > 1 atom | Author the decomposition plan | OD1–OD7 |
| Formulating each atom | Assign `model_tier` with one-line justification | MT1–MT3, MT6 |
| Formulating each atom | Calibrate the envelope from the read estimate | EC1–EC3 |
| While an executor works | Budget checkpoints at phase exits; hard stop on projected overrun | EC4–EC6 |
| After a 2nd Verify return | Rework one tier higher, automatically | MT5 |
| Handing work to a fresh session | Author the launch file; session materializes step 0 | LP1–LP6 |
| Spawning any sub-atom | Log justification + tier + envelope, then spawn | SS1 |
| While atoms run | Observe `STATUS.md`, sync `status.yaml` per transition | SS3–SS4 |
| A gate or human decision point | Author `GATE-BRIEF-<gate-id>.md` in the gated atom's folder | GB1–GB5 |
| Verification of each atom | Tier floor, envelope, isolation for the Verify atom | MT4–MT5, EC2, SS6 |
| Porting to a platform | Document the six contract items | RC1–RC5 |

---

## 1. Decomposition & Planning

- OD1 — **Planning threshold.** When a product requires more than one atom (A4), the formulating agent MUST author a decomposition plan per the §8.2 template before formulating the first sub-atom. A single-atom product needs no separate plan: its `INPUT.md` is the plan.
- OD2 — **Plan contents.** The plan lists every planned atom with:
  1. id (NC1) and output product with deliverable path;
  2. executor role (F2) and model tier (MT1);
  3. budget envelope (EC1–EC2);
  4. verification mode (FP8) and placed gates (FP11);
  5. instantiation mode (L2);
  6. dependencies — the input products it consumes, named by producing atom id.
- OD3 — **Plan location.** The plan is a product (A2). Default path: `PLAN.md` in the formulating atom's own folder (the product-file row of LA3). A launch file MAY embed the plan in its preamble instead (LP6); a plan at any other path MUST be named in the formulating atom's `INPUT.md` (LA2).
- OD4 — **Budget arithmetic.** The plan MUST show that the sum of the children's envelopes plus the parent's own remaining consumption fits the parent's envelope (O6.1). A plan without this arithmetic is incomplete and MUST NOT drive instantiation.
- OD5 — **Dependencies and sequencing.** An atom MUST NOT be instantiated before every input product it names is delivered; where its `INPUT.md` requires a maturity level, the input product must have achieved it (M4). Atoms with no dependency between them MAY run in parallel; dependent atoms run in dependency order.
- OD6 — **Depth.** The plan MUST respect the recursion-depth rule (F6, default total depth 3). A tree that needs more depth is escalated (E6) at planning time — before instantiation, not after a child discovers it.
- OD7 — **Replanning.** When an escalation outcome (E5, E6, or a gate `pivot`) changes the tree, the plan is superseded whole — prior file renamed with a `-superseded-<k>` suffix, kept unmodified; the new plan states what changed and why (the VP17 discipline). Plans are never silently edited.

*(informative)* Worked example — a 3-atom documentation product, planned with only the four framework documents in hand:

| Atom | Product | Tier | Budget | Verification | Depends on |
| :---- | :---- | :---- | :---- | :---- | :---- |
| ATOM-101 | Outline + source map | M | reads ~8k ×2 = ~16k tokens | `independent` (feeds 2 atoms) | — |
| ATOM-102 | Full text | M | reads ~15k ×2 = ~30k tokens | `independent` (maturity `reviewed`) | ATOM-101 |
| ATOM-103 | Published copy (perimeter) | S | reads ~6k ×2 = ~12k tokens | `independent + human` (crosses perimeter) | ATOM-102 |

Each Verify atom: tier L (MT3), envelope = blind-package read estimate ×3–4 (EC2), charged to the parent (VP5). One placed gate before ATOM-103 crosses the perimeter (F4), brief per GB1. Sequence strict per OD5.

---

## 2. Model Tiers

- MT1 — **Mandatory field.** Every atom's `INPUT.md` frontmatter MUST carry `model_tier: S | M | L`, assigned at Formulate time:
  1. this extends the mandatory field set of ATOM-SPEC §1.3 (a tightening per R0.3) for every atom formulated after this document's acceptance; earlier `INPUT.md` files are historical record, not amended;
  2. the assignment MUST be justified in one logged line — in the formulating agent's run log or in the field's own value — naming what makes this tier sufficient (the O5.1 discipline applied to tiering).
- MT2 — **Tier definitions.** Tiers are executor capability classes:

| Tier | Work it is sufficient for |
| :---- | :---- |
| `S` | Mechanical work: extraction, reformatting, script-checkable transforms, hard-criteria verification runs |
| `M` | Standard structured production against a clear spec |
| `L` | Architecture, normative writing, judgment-heavy verification, decomposition planning |

- MT3 — **Where quality is bought.** Formulate work and Verify work for any atom with maturity target ≥ `reviewed` MUST run at tier `L`. Economy is taken on Execute, never on Formulate or Verify.
- MT4 — **Verify tier floor.** A Verify atom's tier MUST be at least the tier of the executor that produced the product (VP5 restated in tier terms), and at least `L` when MT3 applies. Hard-criteria re-runs within a verification MAY be delegated to tier `S` sub-checks; the judgment and the verdict remain at the Verify atom's tier.
- MT5 — **Tier escalator.** When a verification issues its second return (`returns_used: 2` per VP15), the rework that answers it MUST run one tier higher than the previous execution — automatic, no gate, logged in the parent's run log. At tier `L` there is no higher tier: the rework stays at `L`; the E5 path after a third failure stands unchanged.
- MT6 — **Asymmetry.** When a tier assignment is in doubt between two tiers, the formulating agent MUST assign the higher one.
- MT7 — **Abstraction boundary.** Tier names are abstract classes. The mapping of tiers to concrete executors is a runtime-binding duty (RC2 item 3); no `framework/` document names a concrete executor (RC3).

*(informative)* The rationale this section formalizes: a weak formulator poisons the whole subtree; a weak verifier is a rubber stamp; a weak executor under a strong verifier is a sound construction. And the hidden cost of confident junk — a full verify cycle, returns, re-execution — exceeds the visible cost of overpaying for one atom.

---

## 3. Budget Calibration

Builds on BC1–BC4 of REPO-STRUCTURE: reads count; read estimate ≈ bytes ÷ 3; Verify calibrated over its blind package, charged to the parent; metering binds to the runtime.

- EC1 — **Executor floor.** An executor atom's envelope MUST be at least 2× its read estimate (BC2). The margin covers working re-reads and the writes themselves.
- EC2 — **Verify margin.** A Verify atom's envelope MUST be 3–4× the read estimate of its blind package (VP2, BC3). Verification is read-dominated: the margin covers re-reading the product per criterion, running every hard check, and writing the verdict.
- EC3 — **Defective envelopes.** An envelope below its read estimate is a Formulate defect (BC2). The executor that receives one MUST raise E7 before starting work — not discover E4 mid-flight.
- EC4 — **Checkpoints.** The executor SHOULD log a budget checkpoint (O3.2) at each phase exit of the cycle (ATOM-SPEC §2.1), comparing consumption to date against the envelope. Projected overrun at any checkpoint triggers the E4 hard stop (O6.2) immediately.
- EC5 — **Counters.** Cost blocks (O4.1) and checkpoints use real counters wherever the runtime exposes them; every number produced without a counter is prefixed `~` (BC4).
- EC6 — **Closure metering.** Where the executor had no counter over its own consumption, the closing actor MUST record the runtime-measured total in the parent's run log at closure, when the runtime exposes one (RC2 item 5) — so calibration precedents keep accumulating.

*(informative)* The measured basis for EC2: a verification with a ~35k-token read estimate consumed 123.8k real tokens — 3.5× — against an envelope set at 2×. Three envelope precedents to date are recorded in `knowledge/precedent/verify-envelope-calibration.md`.

---

## 4. Gate Briefs

- GB1 — **Placement.** A gate brief (O8.2, FEV-PROTOCOL §5.3 template) is written to `GATE-BRIEF-<gate-id>.md` in the product folder of the atom being gated. This applies to:
  1. placed gates (E3, FP13);
  2. E4/E5 briefs routed to the human.
  *(This rule closes finding F1 of ATOM-002-VERIFY.)*
- GB2 — **Timing.** The brief file is created when the brief is delivered — the moment its `GATE-NNN` id is assigned (DR3). Earlier drafts are workspace material and do not survive closure (O10.1).
- GB3 — **Reference, not duplication.** The decision record (DR1) references the brief by relative path from the repository root in its *Question / Brief* section; the brief's content is not duplicated into the record.
- GB4 — **Authorship and language.** The brief is authored by the formulating agent, never by the executor whose work is gated (O8.2, FP13), in the deciding human's `preferred_for_decisions` language (HP2).
- GB5 — **Naming forward reference.** `GATE-BRIEF-<gate-id>.md` joins the reserved filenames of REPO-STRUCTURE §2 (NC7) at that document's next touch, per the migration discipline HP4 established. Until then, GB1 binds as written here; this document does not modify REPO-STRUCTURE.

---

## 5. Launch Protocol

- LP1 — **Product type.** A launch file is a formal product type: the artifact a human or an orchestrator hands to a fresh runtime session to start execution. Naming and location per NC6, named for the first atom in declared execution order:
  1. `<ATOM-ID>-LAUNCH.md` at the repository root;
  2. its normative content is the `INPUT.md` specification(s) it materializes; on divergence, the materialized `INPUT.md` prevails (NC6).
- LP2 — **Structure.** A launch file consists of exactly two parts, per the §8.1 template:
  1. a **runtime preamble** — the execution sequence, the step-0 materialization instruction, the per-atom verify-and-close obligations, and the status-sync duty;
  2. one or more **complete INPUT specifications**, each conforming to the ATOM-SPEC §6.1 template plus MT1, in execution order.
- LP3 — **Step 0.** Before executing anything, the receiving session MUST materialize each embedded INPUT specification into its atom folder (F1, LA3): `INPUT.md` verbatim, `STATUS.md` opened in state `formulated`, and the product's `status.yaml` entry written (SM3). Only then does execution of the first atom begin.
- LP4 — **Sequence.** Atoms execute in declared order. A later atom MUST NOT begin before the earlier atom's closure — L7 complete through the full RB6 sequence, push included — unless the preamble carries an explicit parallel marker naming the atoms that may overlap (OD5 still binds).
- LP5 — **Assumed duties.** By accepting a launch file, the receiving session assumes the formulating-agent duties the preamble assigns for the atoms it contains:
  1. formulating and instantiating the blind Verify atom for every verification mode ≥ `independent` (VP1–VP2);
  2. authoring gate briefs (GB4) and routing human sign-off (VP18);
  3. syncing status (SS3);
  4. closing per RB6.
- LP6 — **Launch-scale justification.** When a launch splits work into multiple atoms, the preamble SHOULD carry the formulator's one-line spawn justification (the O5.1 discipline at launch scale) and MAY embed the decomposition plan (OD3) when one exists.

---

## 6. Spawn & Status Sync

- SS1 — **Spawn preconditions.** Every spawn, in every instantiation mode, is preceded by three logged items:
  1. the O5.1 justification line;
  2. the MT1 tier assignment;
  3. an EC-calibrated envelope.
  No spawn happens with any of the three missing.
- SS2 — **File bus only.** Results cross atom boundaries only as files (L9): the parent reads the child's product from the paths the child's `INPUT.md` names. An in-memory return value, a conversational reply, or shared session state is not delivery (O1.1).
- SS3 — **Sync duty.** Each atom owns its `STATUS.md` (O2.1). The session-level orchestrator — the parent that instantiated the atoms — MUST sync every state transition it observes into the product's `status.yaml` (SM3) at the moment of observation, not in a batch at the end of the session.
- SS4 — **Observation discipline.** The orchestrator observes state by reading `STATUS.md` files (O2.3), never by trusting an executor's in-context report:
  1. report vs. file — the file wins;
  2. `status.yaml` vs. `STATUS.md` — `STATUS.md` wins and the index is regenerated (SM4).
- SS5 — **Instantiation mapping.** The choice among `session`, `subagent`, and `auto` follows L2: `session` for heavy, human-inspectable sub-products; `subagent` for light branches; `auto` where the runtime decides. What each mode concretely is on a platform is the binding's duty (RC2 item 4).
- SS6 — **Verify isolation.** A Verify atom's fresh isolated context (VP4) means: instantiated through the binding's `session` semantics, sharing no context with the executor or the parent. A shared-context verification is void and is redone without consuming a return (VP4).

---

## 7. Runtime-Binding Contract

- RC1 — **Binding as product.** A runtime binding is a product under `runtime/<platform>/` (LA1), delivered by an atom like any other product, with its own DoD, verification mode, and maturity. Its core deliverable is a document that satisfies RC2.
- RC2 — **The contract.** Every binding MUST document, at minimum:

| # | Item | What the binding must state |
| :- | :---- | :---- |
| 1 | Session start | How a fresh session is started from a launch file (LP1–LP4): working directory, how the file is handed over, what the operator says or invokes |
| 2 | Human interface | How question sets, briefs, and sign-off requests (E1–E3, VP18) are surfaced to the human, and how answers are captured **verbatim** into decision records (DR5, HP2–HP3) |
| 3 | Tier mapping | Which concrete executor each MT2 tier resolves to, including the MT3 reservation of tier `L` for Formulate and Verify; the mapping MUST be dated and reviewed at every touch of the binding |
| 4 | Instantiation mapping | What `session`, `subagent`, and `auto` (L2) concretely are on the platform, including how `session` provides the VP4 isolation |
| 5 | Cost counters | Which real consumption counters the runtime exposes and how they enter cost blocks (O4.1) and closure records (EC5); estimates `~` only where no counter exists (BC4) |
| 6 | Headless invocation | How non-interactive execution is invoked, and its behavior at human-required points: set `STATUS.md` to `blocked`, write the pending decision record, and surface it (EP3, EP5) — never skip the point, never self-answer |

- RC3 — **Neutrality boundary.** Platform and product names MUST NOT appear in any `framework/` document. They are legal only under `runtime/<platform>/` and in atom records — cost blocks, run logs, verdicts, status notes naming a concrete executor per O4.1.
- RC4 — **Checkable conformance.** The binding's core document MUST make its correspondence to the RC2 items detectable — by headings or an explicit item-to-section mapping — so verification can check coverage by inspection.
- RC5 — **Honest gaps.** What the runtime does not enforce (for example: no automatic counter behind the E4 hard stop) MUST be stated in the binding as a known limitation, not silently assumed away.

---

## 8. Templates

- LP7 — Copy the template verbatim and replace every `<angle-bracket>` placeholder (T1). Sections may be extended; mandatory parts MUST NOT be removed. These are the only two fenced blocks in this document (the T2 discipline).

### 8.1 `LAUNCH.md` — launch file (LP1–LP6)

```markdown
# LAUNCH — <ATOM-ID>[ then <ATOM-ID> ...]

> Runtime instruction for this session. Execute <n> atom(s) in <strict sequence |
> declared order with parallel markers>, per the framework documents
> (`framework/ATOM-SPEC.md`, `framework/FEV-PROTOCOL.md`, `framework/REPO-STRUCTURE.md`,
> `framework/ORCHESTRATION.md` — read them first).
> Step 0 — materialize every INPUT specification below into its atom folder per LP3:
> `INPUT.md` verbatim; `STATUS.md` opened at `formulated`; `status.yaml` entries per SM3.
> For each atom, in declared order: execute; run its blind Verify per FEV-PROTOCOL §2
> where verification ≥ independent; request human sign-off where the mode requires it;
> close per L7/RB6. A later atom starts only after the earlier atom's closure
> <, unless marked parallel: <atom-ids>>. Update status.yaml at every transition.
> Spawn justification (formulator): <one line — why this work is split as it is (LP6)>.

---
---
<complete INPUT.md frontmatter per ATOM-SPEC §6.1, plus model_tier per MT1>
---

# <ATOM-ID> — Input Specification

<complete INPUT.md body, sections §1–§7, per the ATOM-SPEC §6.1 template>

---
<for each further atom, in execution order: repeat the frontmatter-plus-body block,
opened by the same `---` / `---` delimiter pair>
---
*End of launch file. <optional one-line note from the formulator to the session.>*
```

### 8.2 Decomposition plan (OD1–OD7)

```markdown
---
plan_for: <product name>
formulated_by: <role or human, date>
parent_envelope: <amount + unit — the formulating agent's remaining envelope (O6.1)>
date: <YYYY-MM-DD>
---

# DECOMPOSITION PLAN — <product name>

## Product tree
| Atom | Product (deliverable path) | Role | Tier | Budget | Verification | Gates | Instantiation | Depends on |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| <ATOM-ID> | <path> | <role> | <S / M / L> | <amount + unit> | <self / independent / independent + human> | <list, or none> | <session / subagent / auto> | <atom ids, or —> |

## Tier justifications (MT1 — one line per atom)
- <ATOM-ID>: <what kind of work makes this tier sufficient>

## Budget arithmetic (OD4)
Sum of child envelopes: <n unit>. Parent's own remaining consumption: <n unit>.
Parent envelope: <n unit>. Fits (O6.1): <yes — required>.

## Sequencing (OD5)
<execution order; parallel groups; which closure unblocks which atom>

## Open risks
<what could force replanning (OD7) — or "none">
```

---

## Appendix A — What This Document Does Not Define *(informative)*

- **Concrete platforms** — every mapping of tiers, instantiation modes, counters, and interfaces to a real platform lives in that platform's binding under `runtime/<platform>/` (RC1–RC2).
- **Verification mechanics** — FEV-PROTOCOL's ground; this document adds only the Verify atom's tier (MT4), envelope (EC2), and isolation mapping (SS6).
- **Scheduling beyond order** — priorities, queues, and retry policies below the granularity of OD5/LP4 are runtime concerns until a future framework atom finds a portable rule worth fixing.

*End of ORCHESTRATION v1. A formulating agent holding the four framework documents can plan, tier, budget, gate, and launch any product tree; a runtime author holding §7 knows exactly what to build.*
