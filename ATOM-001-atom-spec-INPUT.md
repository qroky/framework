# ATOM-001 — Input Specification (v2, post-GATE-001)

This document is the **input product** for the first atom of the Recursive Product Framework (RPF). It is itself written in the format it asks you to formalize. The framework bootstraps itself. v2 changelog: incorporates GATE-001 decision (standalone harness, vendored conventions), STATUS signaling, budget hard-stop, risk-based verification depth, role resolution, embodiment-agnostic wording. Formulated 2026-07-05.

---

## 1\. Product Identity

| Field | Value |
| :---- | :---- |
| Product | **Atom Specification v1** (`ATOM-SPEC.md`) |
| Atom ID | ATOM-001 |
| Parent product | Recursive Product Framework v1 (root product) |
| Formulated by | Human (Ghenadie) \+ advisor agent, 2026-07-05 |
| Executor role | **Framework Architect** — a systems thinker who writes precise, minimal, executable methodology documents. Writes for two readers at once: an LLM agent that must follow the document literally, and a human who must trust it. Prefers short normative statements over prose. Ruthless about removing anything a future agent does not strictly need. |
| Instantiation | Fresh session (full context isolation). Your only context is this file. |
| Verification mode | `independent + human` (a separate Verify atom will check your output against the DoD below; the human accepts final) |
| Budget envelope | Soft limit \~60k tokens total. **Hard rule: the moment you project exceeding it, STOP and escalate (§7) — do not finish first and report later.** (Precedent: ATOM-000 overran 2× and self-waived; that waiver path is now closed.) |

## 2\. Job To Be Done

Produce the **formal definition of the Atom** — the single universal unit of work from which the entire framework is recursively built. Every future agent, on any task, in any domain, will read this document before doing anything. It is the constitution's first article.

**Consumers of your product:**

1. **Executor agents** — will read `ATOM-SPEC.md` at the start of every atom to know their contract.  
2. **Sub-products of Framework v1** — ATOM-002 (FEV & Escalation Protocol), ATOM-003 (Repository Structure & Knowledge Layer), ATOM-004 (Orchestration Protocol & Claude Harness), ATOM-005 (Manifest), ATOM-006 (Bootstrap validation run). They cannot start without your definitions.  
3. **The human owner** — must be able to read it in one sitting and trust it.

## 3\. Context — Decisions Already Made

The following decisions are **already made and accepted by the human risk-taker**. Do not reopen them. Formalize them.

### 3.1 Core paradigm: everything is a product

The framework does not know "tasks", "steps" or "phases". It knows **products**: any unit of work — a document, a design, a decision, a question to a human, a piece of research, a physical action's outcome — is a product with a consumer, a job-to-be-done, acceptance criteria (Definition of Done) and a maturity level. If a product is too large for one atom, it is decomposed into sub-products, each processed by the **same atom structure, recursively**. The framework is scale-invariant: a company strategy and a paragraph of text differ in scale, not in structure.

### 3.2 The Atom

An atom is: **(Role) executes (Cycle: understand → research → clarify → create → verify) over (Input product) and delivers (Output product) to (Consumer) against (DoD \+ maturity level).**

### 3.3 FEV — Formulate / Execute / Verify (segregation of duties)

Three stages, never combined in one context:

- **Formulate** — a parent/orchestrating agent writes the sub-product's spec, DoD, budget, gates, **assigns verification depth (§3.4) and resolves the executor role (§3.5)**.  
- **Execute** — an isolated agent produces the product. Never verifies itself for maturity ≥ independent.  
- **Verify** — a separate agent with a clean context receives **only the DoD and the product** (blind acceptance — no executor reasoning, no parent history). Max 2 returns for rework; a 3rd failure escalates to human. This is deliberately isomorphic to banking maker-checker / segregation-of-duties. DoD criteria are two-tier: **hard criteria** (machine-checkable: structure, presence, counts, tests, sensor readings — verified by script/instrument at near-zero cost) and **soft criteria** (judgment — verified by the Verify agent, who must either raise findings or explicitly justify "no findings").

### 3.4 Risk-based verification depth (assigned at Formulate)

Verification is not one-size: its depth is a Formulate-time decision driven by risk, so that checking cost is proportional to the cost of error. Default mapping (overridable with logged justification):

| Risk profile of the product | Verification mode |
| :---- | :---- |
| Low criticality, reversible, internal (drafts, research notes, intermediate artifacts) | `self` — executor's own check against DoD |
| Medium criticality OR feeds ≥2 downstream atoms OR maturity target ≥ reviewed | `independent` — blind Verify agent |
| High criticality OR irreversible OR crosses the perimeter (external communication, publication, production, physical action) OR regulatory relevance | `independent + human` — blind Verify, then human risk-taker sign-off |

### 3.5 Roles are products; lazy role resolution

A role spec is itself a product living in `/roles/`. At Formulate time the formulating agent MUST check whether the required role spec exists; if it does not, a **role-creation atom** is formulated and executed first (consumer: the pending executor atom; DoD: role spec complete per the ROLE template). Roles are created on demand and hardened by use — the framework does not ship a pre-built persona library.

### 3.6 Humans supply three exclusive products

1. **Missing information** (information-gap escalation): the agent formulates a precise question — context, options, what exactly is blocking.  
2. **Risk acceptance**: where consequences are irreversible/external, the human's product is a recorded acceptance of a named risk. Escalation rule: `information gap ∨ (irreversibility × impact > threshold)`.  
3. **Intent confirmation (strategic gates)**: go / no-go / pivot decisions at cost-curve inflection points: (a) after idea elaboration, before decomposition; (b) before expensive execution phases — direction approved on cheap skeletons; (c) before anything leaves the perimeter. Plus trigger gates: budget-envelope breach, 2× Verify returns. Gates are placed at Formulate time. The gate's input product is a **gate brief** (status, spent, cost ahead, 2–3 options with trade-offs, recommendation), prepared by the formulating agent — never by the executor. All human answers are recorded in `/decisions/` and fed back into role specs / knowledge, so the escalation rate per question type must fall over time.

### 3.7 File bus (mandatory) \+ status signaling

Every atom, regardless of how it was instantiated, **must write its product to the repository as file(s)**. Files are the only communication bus between atoms. A sub-agent does not "return an answer" — it writes a product; the parent reads it. Additionally, every atom MUST maintain a `STATUS.md` in its product folder, updated at state transitions: `formulated → running → delivered | blocked | failed` (+ timestamp \+ one-line note), so any consumer — human or agent — can distinguish "still working" from "silently dead" without inspecting the session. Working materials live in the atom's `workspace/`; final products at the product folder root; atoms clean their workspace on closure, keeping product \+ metadata. Files are the source of truth; any database is a rebuildable index.

### 3.8 Cost accountability

Every atom's result carries a **cost block** in frontmatter/RESULT: tokens in/out, wall time, model, number of spawned sub-atoms. Before spawning a sub-atom, the parent logs a one-line justification (expected value, estimated cost, why not do it inline). Budgets cascade: a child's envelope is allocated from the parent's. **Projected overrun is a mandatory stop-and-escalate, not a report-after-the-fact.**

### 3.9 Instantiation modes

`session` (fresh chat/session — full isolation, human-inspectable, for heavy sub-products) | `subagent` (same-session spawn — cheap, for light recursive branches) | `auto`. Default recursion depth limit: 3; deeper decomposition \= escalation.

### 3.10 GATE-001 decision: standalone harness, vendored skeleton

Accepted by the human 2026-07-05 after reconnaissance of the leading method-as-files framework. RPF is built as a **standalone harness**; proven conventions are adopted (not re-invented, not depended upon): (a) agent/role packaging in the open SKILL.md style (minimal name+description frontmatter, markdown body) so role specs remain conceptually convertible to the agentskills.io ecosystem; (b) an **append-only, atomically-written run log** per atom workspace as the canonical memory/audit trail (never edited, never rewritten); (c) **workspace-per-run** folders; (d) a shared **status-machine YAML** for multi-atom products. In `ATOM-SPEC.md` describe these conventions generically — do not name third-party frameworks in normative text. Rationale (context only): enforcement — blind verification, budget stops — cannot be built inside frameworks whose hooks run in the producer's own session; the harness is the moat.

### 3.11 Platform & embodiment stance

Claude-first execution, **platform-neutral and embodiment-agnostic core**: this spec must contain zero platform-specific instructions AND zero hidden assumptions that the executor is a chat LLM. An executor may be a language model, a script, a human, or a robotic system whose DoD is checked by sensors; phrase obligations so all of these fit ("write to the file bus", not "reply in chat"). Test: a competent human could execute an atom by reading the docs alone. Runtime-specific bindings live separately under `/runtime/<platform>/`.

### 3.12 Knowledge layer (context only — ATOM-003's job, not yours)

Knowledge files carry minimal mandatory frontmatter (source, date, type, tags); domains may impose **profiles** with extended fields (e.g. a regulatory profile: authority level, jurisdiction, validity dates, source link). Mention the knowledge types (domain / organizational / procedural / precedent) only where the atom touches them.

## 4\. Your Deliverable

Create the repository skeleton and the product:

rpf/

  framework/

    ATOM-SPEC.md          ← your product

  products/

    framework-v1/

      001-atom-spec/

        INPUT.md           ← copy of this file

        STATUS.md          ← your live status (§3.7)

        workspace/         ← your scratch space (incl. append-only run log)

        RESULT.md          ← short completion report \+ cost block

  decisions/

  roles/

  knowledge/

`ATOM-SPEC.md` must define, normatively and compactly:

1. **Atom definition** — the formula, all mandatory fields of an atom spec (identity, role, input, consumer, JTBD, DoD hard/soft, maturity target, instantiation, verification mode per §3.4, budget envelope, gates, recursion-depth allowance).  
2. **The execution cycle** — understand → research → clarify → create → verify(self), with entry/exit conditions per phase, including Formulate-time obligations: role resolution (§3.5) and verification-depth assignment (§3.4).  
3. **Maturity levels** — a small, named scale (e.g. draft / reviewed / validated / production) with what each level requires in verification mode and human involvement.  
4. **Atom lifecycle** — formulate → instantiate → execute → write product to file bus → maintain STATUS.md → self-report (cost block) → hand to Verify → accept/return/escalate → close (workspace cleanup, keep run log).  
5. **Obligations** — file bus, status signaling, append-only run log, cost block, spawn justification, budget cascade with hard stop-on-projected-overrun, escalation triggers (information gap, risk threshold, gate, budget breach, verify-loop limit).  
6. **Templates** — exactly three ready-to-copy fenced templates: atom `INPUT.md`, `RESULT.md` (with cost-block schema), and `ROLE.md` (role spec in SKILL.md-style packaging: minimal frontmatter \+ identity, capabilities, method defaults, escalation posture).

## 5\. Definition of Done

**Hard criteria (machine-checkable):**

- H1. File `framework/ATOM-SPEC.md` exists; length 400–1200 lines including templates.  
- H2. Contains all six sections from §4 (detectable by headings).  
- H3. Contains exactly three fenced templates (`INPUT.md`, `RESULT.md`, `ROLE.md`), each valid markdown with YAML frontmatter.  
- H4. Zero occurrences of platform/product-specific names in normative text (grep: "Claude Code", "MCP", "Codex", "OpenClaw", "Hermes", "BMAD") — platform notes, if any, confined to a clearly marked non-normative appendix.  
- H5. `RESULT.md` exists and contains a cost block (tokens in/out, time, spawns); `STATUS.md` exists and its last state is `delivered`.

**Soft criteria (judgment):**

- S1. A fresh agent given only `ATOM-SPEC.md` \+ an `INPUT.md` could execute an atom without asking "what do I do in this situation" for any normal-path situation.  
- S2. Every normative statement is testable — no aspirational language ("should strive to", "as appropriate") in obligations.  
- S3. Nothing in the document contradicts §3 decisions; nothing reopens them.  
- S4. A human can read the core (excluding templates) in ≤ 15 minutes.  
- S5. Scale-invariance holds: the spec works equally for "write a paragraph", "launch a product line", and "move an object with a sensor-verified outcome" without special cases.

**Maturity target:** `reviewed` — v1, to be validated by ATOM-006 bootstrap run. Do not gold-plate.

## 6\. Method Hints (non-binding)

- Write normatively: MUST / SHOULD / MAY.  
- Prefer tables and numbered rules over prose.  
- When you face a design choice not covered by §3, make the **simplest decision that doesn't close doors**, and log it in `RESULT.md` under "Decisions made by executor" — the Verify atom and the human will review them.  
- Do not design the repository layout beyond what §4 requires (ATOM-003's product). Do not design the FEV protocol in detail (ATOM-002) — only reference the interfaces your atom definition needs.

## 7\. Escalation

Stop and ask the human (one consolidated, precise question set — context, options, what blocks you) if:

- Any §3 decision appears contradictory or unimplementable as stated.  
- You project exceeding the budget envelope (mandatory stop — see §1).  
- A design choice materially closes doors and you cannot find a reversible option.

Otherwise: do not ask for permission on the normal path. Execute.

---

*End of input. Your consumer is waiting. Build the atom that builds everything else.*  
