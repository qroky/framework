# ATOM-SPEC — The Atom Specification

| Field | Value |
| :---- | :---- |
| Product | Atom Specification v1 |
| Parent product | Recursive Product Framework v1 |
| Produced by | ATOM-001 (executor role: Framework Architect) |
| Maturity | `reviewed` (target) — to be `validated` by the bootstrap run (ATOM-006) |
| Date | 2026-07-05 |

This document defines the **Atom** — the single universal unit of work from which every product of the framework is recursively built. Every executor MUST read this document before starting an atom. It is written for four kinds of executor at once: a language model, a script, a human, and a physical system whose output is checked by sensors. Nothing in the normative text assumes any one of them.

---

## 0. How to Read This Document

- R0.1 — **MUST** means an absolute obligation; violating it makes the atom's product unacceptable. **MUST NOT** is an absolute prohibition. **SHOULD** means the obligation applies unless a reason to deviate is logged in the run log. **MAY** means genuinely optional.
- R0.2 — All numbered rules and all tables are **normative**. Passages marked *(informative)* explain or illustrate and bind nobody.
- R0.3 — Precedence: an atom's `INPUT.md` MAY tighten any obligation in this document (smaller budget, stricter verification, extra criteria). It MUST NOT relax one. If an `INPUT.md` appears to contradict this specification, that is escalation trigger E7 (§5.7).
- R0.4 — **Executor neutrality.** "Executor" means whatever performs the atom: a language model, a program, a human, or a machine acting in the physical world. Every obligation in this document is phrased against files and observable artifacts — "write to the file bus", never "reply in chat". Test: a competent human MUST be able to execute an atom by reading this document and the atom's `INPUT.md` alone.
- R0.5 — This document defines the atom's contract. The detailed Formulate/Execute/Verify protocol, the repository layout beyond what atoms themselves touch, and runtime bindings are separate framework products; this document references only the interfaces it needs (Appendix A).

---

## 1. Atom Definition

### 1.1 The formula

> **(Role)** executes **(Cycle: understand → research → clarify → create → verify)** over **(Input product)** and delivers **(Output product)** to **(Consumer)** against **(DoD + maturity level)**.

Every element of the formula is mandatory. An atom with no named consumer, no DoD, or no resolved role is not an atom and MUST NOT be executed.

### 1.2 Everything is a product

- A1 — The framework recognizes exactly one unit of work: the **atom**. There are no "tasks", "steps" or "phases" at any scale.
- A2 — A **product** is any unit of work output: a document, a design, a decision, a question to a human together with its recorded answer, a piece of research, code, or the outcome of a physical action verified by instrument or sensor.
- A3 — Every product MUST have: (a) a consumer, (b) a job-to-be-done, (c) a Definition of Done, (d) a maturity level.
- A4 — If a product is too large for one atom, it MUST be decomposed into sub-products. Each sub-product is processed by the same atom structure, recursively, under the budget-cascade and depth rules of §5.5 and §5.6.
- A5 — **Scale invariance.** A company strategy and a paragraph of text differ in scale, not in structure. No rule in this document has scale-dependent special cases.

*(informative)* Three atoms at very different scales, same structure:

| Field | Atom "write a paragraph" | Atom "launch a product line" | Atom "move an object" |
| :---- | :---- | :---- | :---- |
| Role | Copywriter | Venture Lead | Warehouse manipulator operator |
| Input product | Section brief | Approved strategy + budget | Pick order |
| Output product | Paragraph in file | Product line live (tree of sub-products) | Object at target coordinates |
| Consumer | Document assembly atom | The business owner | Packing atom |
| DoD hard | Word count, terminology present | Revenue system reports first sale | Sensor reads position within tolerance |
| DoD soft | Reads in the document's voice | Positioning matches strategy | — |
| Verification | `self` | `independent + human` | `self` (sensor is the check) |

### 1.3 Mandatory fields of an atom specification

An atom is specified by its `INPUT.md` (template in §6.1). The following fields are mandatory:

| # | Field | Content |
| :- | :---- | :---- |
| 1 | Atom ID | Unique identifier within the parent product |
| 2 | Parent product | The product this atom serves |
| 3 | Product | Name of the output product and the exact file(s) to deliver |
| 4 | Executor role | A role that exists as a spec in `/roles/` at instantiation time (§2.0, F2) |
| 5 | Input product(s) | Files the executor receives; nothing else is promised |
| 6 | Consumer(s) | Who reads the output product, and for what |
| 7 | Job To Be Done | What the product must accomplish for the consumer |
| 8 | DoD — hard criteria | Machine/instrument-checkable: structure, presence, counts, tests, sensor readings |
| 9 | DoD — soft criteria | Judgment criteria, each assigned to a judge (Verify agent or human) |
| 10 | Maturity target | One of the levels in §3 |
| 11 | Verification mode | `self` \| `independent` \| `independent + human` (§1.4) |
| 12 | Instantiation mode | `session` \| `subagent` \| `auto` (§4, L2) |
| 13 | Budget envelope | Amount + unit meaningful to the executor (tokens, hours, currency, energy), allocated from the parent's envelope |
| 14 | Gates | Human intent-confirmation points placed at Formulate time (§5.8), or "none" |
| 15 | Recursion-depth allowance | How many further decomposition levels this atom may open (default total depth: 3) |

- A6 — An atom MUST NOT be instantiated while any mandatory field is absent from its `INPUT.md`.
- A7 — Every hard criterion MUST be checkable by a script or instrument at near-zero cost. Every soft criterion MUST name its judge. A criterion that is neither is not a DoD criterion and MUST be rewritten or removed at Formulate time.

### 1.4 Verification modes

| Mode | Who checks | What they receive |
| :---- | :---- | :---- |
| `self` | The executor, in the verify phase of its own cycle | Own product + DoD |
| `independent` | A separate Verify atom with a clean context | **Only** the DoD and the product — no executor reasoning, no parent history (blind acceptance) |
| `independent + human` | Blind Verify atom, then the human risk-taker | As above; the human additionally receives the Verify findings and signs off |

- A8 — The verification mode is assigned at Formulate time from the risk mapping in §2.0 (F3). The executor MUST NOT change it.
- A9 — For maturity ≥ `reviewed`, the executor MUST NOT verify its own product for acceptance. Its self-check (§2.6) is a delivery obligation, not an acceptance.

---

## 2. The Execution Cycle

### 2.0 Formulate-time obligations *(performed by the formulating agent — the parent — before the cycle starts)*

- F1 — The formulating agent MUST write the atom's `INPUT.md` with all fields of §1.3, create the atom's product folder with `STATUS.md` in state `formulated`, and log a spawn justification (§5.5).
- F2 — **Role resolution.** The formulating agent MUST check whether the required role spec exists in `/roles/`. If it does not, a role-creation atom MUST be formulated and executed first (consumer: the pending executor atom; DoD: role spec complete per the ROLE template of §6.3). Roles are created on demand and hardened by use; there is no pre-built persona library.
- F3 — **Verification-depth assignment.** The formulating agent MUST assign the verification mode from this default risk mapping. Any override MUST be logged with justification in the `INPUT.md`.

| Risk profile of the product | Verification mode |
| :---- | :---- |
| Low criticality, reversible, internal (drafts, research notes, intermediate artifacts) | `self` |
| Medium criticality, OR feeds ≥ 2 downstream atoms, OR maturity target ≥ `reviewed` | `independent` |
| High criticality, OR irreversible, OR crosses the perimeter (external communication, publication, production, physical action), OR regulatory relevance | `independent + human` |

- F4 — **Gate placement.** The formulating agent MUST place human gates (§5.8) at: (a) after idea elaboration, before decomposition; (b) before expensive execution phases; (c) before anything leaves the perimeter — where those points exist for the product. Trigger gates (budget breach, 2× Verify returns) exist implicitly on every atom.
- F5 — **Budget allocation.** The child's envelope MUST be allocated from the formulating agent's own remaining envelope, with the unit named (§5.6).
- F6 — The formulating agent MUST set the recursion-depth allowance so that total decomposition depth does not exceed 3; a need for deeper decomposition is an escalation, not a default.

### 2.1 Cycle overview *(executor side)*

| Phase | Purpose | Entry condition | Exit condition |
| :---- | :---- | :---- | :---- |
| 1. Understand | Own the contract | `INPUT.md` read in full | JTBD, consumer, DoD restated in run log; ambiguities listed; no blocking ambiguity — or E1/E7 raised |
| 2. Research | Gather what exists | Understand exited | Sources logged; information sufficient to plan the product — or a named information gap |
| 3. Clarify | Close information gaps | A blocking gap named | Gap closed via escalation E1, answer recorded — or phase skipped because no gap exists |
| 4. Create | Produce the product | No open blocking gaps | All deliverable files written to the file bus per `INPUT.md` |
| 5. Verify (self) | Check own work before handoff | Product files complete | Every DoD criterion self-checked; `RESULT.md` written; `STATUS.md` = `delivered` |

- C1 — Phases MUST be entered in order. Returning to an earlier phase is permitted and MUST be logged in the run log.
- C2 — The cycle operates only on files: the executor's context at start is its `INPUT.md` and the files it references — nothing else is guaranteed to exist.

### 2.2 Phase 1 — Understand

- U1 — The executor MUST read the entire `INPUT.md` before producing anything.
- U2 — The executor MUST restate in the run log: the JTBD, the consumer(s), and each DoD criterion, in its own words.
- U3 — If any accepted decision in the input appears contradictory or unimplementable, the executor MUST raise E7 (§5.7) and MUST NOT "interpret around" it.
- U4 — Exit: an explicit run-log entry that no blocking ambiguity remains, or an escalation.

### 2.3 Phase 2 — Research

- RS1 — The executor MUST consult the input products and, where the repository's knowledge layer exists, knowledge relevant to the product (domain / organizational / procedural / precedent types), and MUST log in the run log what was consulted.
- RS2 — The executor MUST NOT invent facts to fill a gap that research did not close. An unclosed gap that blocks the DoD becomes a Clarify-phase question.
- RS3 — Exit: a run-log entry naming either "information sufficient" or the specific gap(s) carried into Clarify.

### 2.4 Phase 3 — Clarify

- CL1 — This phase runs only if a blocking information gap exists; otherwise it MUST be skipped with a one-line run-log note.
- CL2 — A clarification MUST be formulated as a precise question set: context, options considered, and what exactly is blocked. Vague questions ("any thoughts?") are prohibited.
- CL3 — The question is routed per escalation E1 (§5.7). The answer MUST be recorded under `/decisions/` and referenced from the run log before work resumes.
- CL4 — Questions that do not block the DoD MUST NOT interrupt the atom; the executor decides per §5.9 (executor decisions) and logs the decision.

### 2.5 Phase 4 — Create

- K1 — The executor MUST write the product as file(s) at the location named in `INPUT.md`. The file bus is the only delivery channel (§5.1).
- K2 — The executor MUST keep `STATUS.md` current (§5.2) and append run-log entries at material steps (§5.3) throughout this phase.
- K3 — The executor MUST monitor budget consumption. Projected overrun triggers the hard stop E4 (§5.6) — immediately, not after finishing.
- K4 — If the product proves too large for this atom, the executor MUST decompose per A4: formulate sub-atoms (thereby taking the formulating-agent obligations of §2.0 for them), within its recursion-depth allowance and budget cascade.
- K5 — Exit: every deliverable file named in `INPUT.md` exists at its final path.

### 2.6 Phase 5 — Verify (self)

- V1 — The executor MUST check its product against **every** DoD criterion: hard criteria by actually running the check where the executor can (script, count, measurement), soft criteria by explicit review.
- V2 — The self-check results MUST be recorded in `RESULT.md` as a per-criterion table: met / not met / deviation, with evidence for hard criteria.
- V3 — A knowingly unmet criterion MUST NOT be silently shipped: the executor either fixes it within budget, or records the deviation in `RESULT.md` and, if the deviation defeats the JTBD, raises the appropriate escalation instead of delivering.
- V4 — Self-verification never substitutes for the assigned verification mode (A9). For `independent` and above, acceptance happens outside this atom (§4, L5).
- V5 — Exit: `RESULT.md` written with cost block (§5.4); `STATUS.md` last state is `delivered`.

---

## 3. Maturity Levels

| Level | Meaning | Minimum verification | Human involvement |
| :---- | :---- | :---- | :---- |
| `draft` | Product exists, internally consistent, self-checked against DoD | `self` | None |
| `reviewed` | Passed blind independent verification against DoD | `independent` | None required |
| `validated` | Reviewed, **and** proven in use: successfully consumed by at least one downstream atom, or passed an empirical/bootstrap test named in the DoD | `independent` + recorded consumption/test evidence | None required |
| `production` | Validated, **and** cleared to cross the perimeter or bear irreversible consequences | `independent + human` | Mandatory recorded risk acceptance (§5.8) |

- M1 — The verification mode assigned at Formulate MUST be at least the minimum required by the maturity target, and assigning a mode above that minimum requires the logged override justification of F3.
- M2 — The maturity target is set at Formulate time. The executor MUST NOT spend budget pushing a product beyond its target ("do not gold-plate").
- M3 — The achieved maturity is recorded in `RESULT.md` frontmatter by the executor as claimed, and confirmed (or corrected) by the acceptance step (§4, L5–L6). A product's maturity can rise later without re-executing the atom — e.g. `reviewed` → `validated` when a downstream atom consumes it successfully and records that fact.
- M4 — A product MUST NOT be consumed by an atom whose `INPUT.md` requires a higher maturity than the product has achieved.

---

## 4. Atom Lifecycle

| Step | Actor | Obligations | `STATUS.md` state after step |
| :- | :---- | :---- | :---- |
| L1. Formulate | Formulating agent (parent) | §2.0 F1–F6 complete; product folder + `INPUT.md` + `STATUS.md` created; spawn justified | `formulated` |
| L2. Instantiate | Parent / runtime | Choose per `INPUT.md`: `session` (fresh isolated context — human-inspectable, for heavy sub-products), `subagent` (same-context spawn — cheap, for light recursive branches), or `auto` (runtime decides). Executor receives only `INPUT.md` + referenced files | `formulated` |
| L3. Execute | Executor | Run the cycle (§2.1–2.6); maintain `STATUS.md` and run log throughout; write product files to the file bus | `running` |
| L4. Deliver | Executor | Final product at the product folder root (or the path `INPUT.md` names); `RESULT.md` with cost block; workspace holds only working materials + run log | `delivered` |
| L5. Verify | Verify atom (for mode ≥ `independent`) | Receives **only** DoD + product (blind). Verdict: accept, or return with findings. For hard criteria: run the checks. For soft criteria: raise findings or explicitly justify "no findings" | (verify atom has its own STATUS) |
| L6. Accept / Return / Escalate | Verify atom → parent → (human) | Accept → L7. Return → executor reworks (back to L3), maximum 2 returns. A 3rd failed verification MUST escalate to the human (E5). For `independent + human`: human sign-off after Verify acceptance | `running` again if returned |
| L7. Close | Parent (or executor on `self` mode) | Record acceptance in the parent's run log; clean the atom's `workspace/` keeping the run log; product + `INPUT.md` + `RESULT.md` + `STATUS.md` + run log remain as the permanent record | `delivered` (final) |

- L8 — **Failure paths.** An atom that cannot proceed sets `STATUS.md` to `blocked` (waiting on an escalation answer) or `failed` (will not deliver; parent must reformulate or abandon), each with a one-line reason. A `blocked` atom resumes to `running` when unblocked.
- L9 — A sub-agent does not "return an answer". It writes a product; the parent reads it from the file bus. This holds for every instantiation mode, including `subagent`.
- L10 — The Verify atom is itself an atom: it has an `INPUT.md` (containing the DoD and the product path — nothing else), its own status, and its own result. Its detailed protocol is a separate framework product (Appendix A); this specification only fixes the interface: blind input, accept/return verdict, 2-return limit.

---

## 5. Obligations

These obligations bind every atom regardless of scale, domain, executor kind, or instantiation mode.

### 5.1 File bus

- O1.1 — Every atom MUST write its product to the repository as file(s). Files are the only communication bus between atoms; no other channel (conversation, shared memory, verbal report) is authoritative.
- O1.2 — Working materials live in the atom's `workspace/`; final products at the paths `INPUT.md` names. Files are the source of truth; any database over them is a rebuildable index.

### 5.2 Status signaling

- O2.1 — Every atom MUST maintain a `STATUS.md` in its product folder with states: `formulated → running → delivered | blocked | failed`.
- O2.2 — Each state transition MUST append one line: timestamp, state, one-line note. Existing lines are never edited; the last line is the current state.
- O2.3 — Purpose test: any consumer — human or agent — MUST be able to distinguish "still working" from "silently dead" by reading `STATUS.md` alone, without inspecting the executor's context.

### 5.3 Append-only run log

- O3.1 — Every atom MUST keep an append-only run log in its `workspace/` (default name `run.log`). Entries are written atomically, never edited, never rewritten. It is the atom's canonical memory and audit trail and survives workspace cleanup (L7).
- O3.2 — Minimum events to log: cycle start; phase entries/exits (including skips); understanding restatement (U2); sources consulted (RS1); every executor decision (§5.9); every escalation raised and its resolution; every sub-atom spawned (with justification, O5.1); budget checkpoints; delivery.
- O3.3 — One line per event: timestamp, event tag, note. The log is for reconstruction, not narrative — write what happened, not why it was hard.

### 5.4 Cost block

- O4.1 — Every atom's `RESULT.md` MUST carry a cost block in its frontmatter with: units consumed in/out (tokens for language-model executors; the nearest meaningful resource unit — hours, currency, energy — otherwise, with the unit named), wall time, executor identity (model / person / system), and number of sub-atoms spawned.
- O4.2 — Reported cost covers the atom itself plus, as a separate line, the aggregated cost of its sub-atoms.

### 5.5 Spawn justification

- O5.1 — Before spawning a sub-atom, the formulating agent MUST log one line in its run log: expected value, estimated cost, and why the work is not done inline.

### 5.6 Budget cascade and hard stop

- O6.1 — Budgets cascade: a child's envelope is allocated from the parent's remaining envelope. The sum of children's envelopes plus the parent's own consumption MUST NOT be planned to exceed the parent's envelope.
- O6.2 — **Hard stop.** The moment an executor projects that total consumption will exceed its envelope, it MUST stop work, set `STATUS.md` to `blocked`, and escalate (E4) with a gate brief. Finishing first and reporting the overrun afterwards is prohibited. Self-waiving the envelope is prohibited.

### 5.7 Escalation triggers

| # | Trigger | Required response |
| :- | :---- | :---- |
| E1 | Information gap blocks the DoD | Formulate precise question set (CL2); route to the party that owns the answer — the human when only the human knows; record answer in `/decisions/` |
| E2 | Risk threshold: irreversibility × impact exceeds what the atom is authorized to accept | Stop before the irreversible step; request recorded risk acceptance from the human (§5.8) |
| E3 | A gate placed at Formulate time is reached | Deliver a gate brief; wait for go / no-go / pivot |
| E4 | Projected budget-envelope breach | Hard stop per O6.2 |
| E5 | Verification failed 3 times (2 returns exhausted) | Escalate to human with both the product and the Verify findings |
| E6 | Needed decomposition exceeds recursion-depth allowance | Stop; escalate to parent for reformulation |
| E7 | Input contradiction: an accepted decision in `INPUT.md` is contradictory or unimplementable as stated | Stop; one consolidated question set to the formulating agent / human; MUST NOT reinterpret accepted decisions unilaterally |

- O7.1 — Escalations are consolidated: one precise question set per stop, not a drip of single questions.
- O7.2 — On the normal path — no trigger fired — the executor MUST NOT ask for permission. Execute.

### 5.8 Human products and gates

- O8.1 — Humans supply exactly three products to the framework: **missing information** (E1), **risk acceptance** (E2 — a recorded acceptance of a named risk), and **intent confirmation** at gates (E3 — go / no-go / pivot).
- O8.2 — A gate's input product is a **gate brief**: current status, spent so far, cost ahead, 2–3 options with trade-offs, and a recommendation. It is prepared by the formulating agent — never by the executor whose work is being gated.
- O8.3 — Every human answer MUST be recorded under `/decisions/` and fed back into role specs and knowledge, so that the escalation rate per question type falls over time.

### 5.9 Executor decisions

- O9.1 — When the executor faces a design choice not covered by its input or by accepted decisions, it MUST make the simplest choice that does not close doors, log it in the run log, and list it in `RESULT.md` under "Decisions made by executor" for review at verification.
- O9.2 — If no reversible option exists, that is E2 or E7 — not a judgment call.

### 5.10 Workspace hygiene

- O10.1 — Each run gets its own `workspace/`. On closure (L7) the workspace is cleaned: scratch materials deleted, run log kept. The permanent record of an atom is: product file(s), `INPUT.md`, `RESULT.md`, `STATUS.md`, run log.
- O10.2 — Multi-atom products SHOULD maintain a shared machine-readable status file (one entry per atom: id, state, timestamp) so orchestration can read overall progress from one place; its schema is fixed by the repository-structure product (Appendix A).

---

## 6. Templates

- T1 — To formulate an atom, copy the template verbatim and replace every `<angle-bracket>` placeholder. Sections may be extended; mandatory fields and sections MUST NOT be removed.
- T2 — These are the only three fenced blocks in this specification: `INPUT.md`, `RESULT.md`, `ROLE.md`.

### 6.1 Atom `INPUT.md` template

```markdown
---
atom: <ATOM-ID>
product: <output product name>
parent: <parent product>
formulated_by: <role or human, date>
verification: <self | independent | independent + human>
maturity_target: <draft | reviewed | validated | production>
instantiation: <session | subagent | auto>
budget: <amount + unit>
recursion_allowance: <0..3>
---

# <ATOM-ID> — Input Specification

## 1. Product Identity
| Field | Value |
| :---- | :---- |
| Product | <name and exact deliverable file path(s)> |
| Atom ID | <ATOM-ID> |
| Parent product | <parent> |
| Executor role | <role name — MUST exist in /roles/ before instantiation> |
| Input product(s) | <files the executor receives; nothing else is promised> |
| Consumer(s) | <who reads the output, and for what — detailed in §2> |
| Maturity target | <draft | reviewed | validated | production> |
| Gates | <list, or "none — trigger gates only"; restated in §7> |
| Instantiation | <session | subagent | auto> |
| Verification mode | <per risk mapping; if overridden, justify here> |
| Budget envelope | <amount + unit; hard stop-and-escalate on projected overrun> |
| Recursion-depth allowance | <n> |

## 2. Job To Be Done
<What this product must accomplish, for whom.>

**Consumers:**
1. <consumer — what they do with the product>

## 3. Context — Decisions Already Made
<Accepted decisions the executor MUST formalize, not reopen. Reference /decisions/ entries where they exist.>

## 4. Deliverable
<Exact files to produce and where. Repository paths, not descriptions.>

## 5. Definition of Done
**Hard criteria (machine/instrument-checkable):**
- H1. <structure / presence / count / test / sensor reading>

**Soft criteria (judgment — judge named per criterion):**
- S1. <criterion> — judge: <Verify agent | human>

**Maturity target:** <level>. Do not gold-plate.

## 6. Method Hints (non-binding)
<Optional guidance. The executor may deviate.>

## 7. Escalation
Stop and escalate (one consolidated question set) on triggers E1–E7 of ATOM-SPEC §5.7.
Gates placed for this atom: <list, or "none — trigger gates only">.
Otherwise: do not ask for permission on the normal path. Execute.
```

### 6.2 Atom `RESULT.md` template

```markdown
---
atom: <ATOM-ID>
product: <output product name>
status: delivered
maturity_claimed: <draft | reviewed | validated | production>
cost:
  units_in: <n>            # tokens for LM executors; else name the unit
  units_out: <n>
  unit: <tokens | hours | currency | energy>
  wall_time: <e.g. 1h20m>
  executor: <model id | person | system id>
  sub_atoms_spawned: <n>
  sub_atoms_cost: <aggregate, same unit>
---

# RESULT — <ATOM-ID>

## Summary
<3–6 lines: what was produced, for whom, anything the consumer must know first.>

## Deliverables
| File | Purpose |
| :---- | :---- |
| <path> | <what it is> |

## DoD Self-Check
| Criterion | Result | Evidence |
| :---- | :---- | :---- |
| H1 | met / not met | <command output, count, reading> |
| S1 | self-reviewed | <one line> |

## Decisions Made by Executor
<Choices not covered by the input; each with the simplest-reversible rationale. "None" if none.>

## Deviations & Known Limitations
<Unmet criteria, shortcuts, anything Verify should probe. "None" if none.>

## Handoff
Verification mode: <mode>. Verify receives: DoD (INPUT.md §5) + deliverable files only.
```

### 6.3 `ROLE.md` template

```markdown
---
name: <role-slug>
description: <one line: who this role is and when an atom needs it>
---

# Role: <Role Name>

## Identity
<2–4 sentences: who this role is, what they optimize for, who they write/build for.
Written in second person: "You are...">

## Capabilities
- <what this role is competent at — concrete, testable>
- <...>

## Method Defaults
- <how this role works by default: order of operations, preferred forms of output,
  quality bars it applies without being asked>

## Escalation Posture
- <what this role escalates vs. decides alone, beyond the universal triggers E1–E7>
- <question style: e.g. "always presents 2–3 options with a recommendation">

## Provenance
| Event | Atom | Date |
| :---- | :---- | :---- |
| Created | <ATOM-ID> | <date> |
| Hardened | <ATOM-ID that used it and fed back changes> | <date> |
```

---

## Appendix A — Interfaces to Sibling Products *(non-normative)*

This specification is the first product of Framework v1. It deliberately does not define:

- **The Formulate/Execute/Verify protocol in detail** — how Verify atoms are formulated, how findings are structured, how returns are worded. A sibling product defines it; this document fixes only the interface: blind input (DoD + product), accept/return verdict, 2-return limit, third failure escalates (L10, E5).
- **Repository structure and the knowledge layer** — full folder layout, knowledge frontmatter profiles (e.g. regulatory profiles with authority level, jurisdiction, validity dates), and the shared status-machine schema of O10.2. This document fixes only what every atom touches: its product folder (`INPUT.md`, `STATUS.md`, `RESULT.md`, `workspace/` with run log), `/roles/`, `/decisions/`.
- **Orchestration and runtime bindings** — how atoms are physically instantiated on a given platform. Runtime-specific bindings live under `/runtime/<platform>/`. Nothing in the normative text above depends on any of them: this specification contains zero platform-specific instructions, by design.

*End of ATOM-SPEC v1. An atom that follows this document needs nothing else to know its contract.*
