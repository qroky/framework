# RPF — Recursive Product Framework

*A manifesto. Normative rules live in [`framework/`](framework/); this document tells you why they exist.*¹

## Why now

Agents can now produce most of what a company produces: research, specifications, code, contracts-in-draft, plans. What they cannot produce is the wanting of it — someone still has to decide what the company is for, accept the risks, and know whether a thing is actually done. The bottleneck has moved from producing work to governing it.

Today's tools answer this with assistance: a faster pair of hands attached to one person's attention. RPF answers it with an operating system. One person plus RPF is a company — the founder acts as chief executive of a workforce of agents, and everything below intent runs as governed, verified, recorded production.

The difference is not speed. An assistant answers the questions you ask it. RPF's recursive decomposition *generates the questions you didn't know to ask*: state an intent, and it becomes a tree of products, each with a named consumer, acceptance criteria, a budget, and a verification plan — your unknown unknowns, surfaced as a structure you can steer. Not an assistant that answers. An operating system that asks, produces, verifies, and records.

## What RPF is

Five principles carry the whole framework. One line each — the normative documents carry the detail.

1. **Everything is a product.** Every unit of work has a consumer, a job to be done, a Definition of Done, and a maturity level. There are no tasks, no phases — only products and the atoms that produce them.
2. **One atom, infinite recursion.** A single universal unit of work at every scale. A paragraph and a product line differ in scale, not in structure; whatever is too large decomposes into sub-products processed by the same atom, recursively.
3. **Humans supply three products.** Missing information, risk acceptance, and intent at gates. Everything else is produced by agents. Human involvement is designed to fall over time: the escalation rate is a metric, and every answer feeds back into roles and knowledge so the same question is not asked twice.
4. **Formulate / Execute / Verify.** Segregation of duties: whoever specifies does not execute, and whoever executes never accepts their own work. Verification is blind — the checker receives the criteria and the product, never the producer's reasoning. Bankers will recognize maker-checker. Every decision leaves an audit trail in [`decisions/`](decisions/).
5. **Files are the whole system.** Plain markdown and git, platform-neutral by constitution: any model, any runtime — the spec is written so that even a competent human could execute an atom from the files alone. Databases are rebuildable indexes, never the truth.

## Who it is for

**The founder, first.** One person with an idea and no team: RPF turns intent into a governed production tree and asks only what it genuinely cannot answer. **Teams**, next: the same structure lets a small team run a portfolio of products with explicit ownership of risk and acceptance. **Regulated organizations**, deliberately: segregation of duties, blind verification, recorded risk acceptance, and an append-only decision journal are not add-ons here — they are the architecture.

## What the founder does

Three things, and only when the system escalates. You answer questions only you can answer. You accept, in writing, the risks only you can carry. And at gates you say go, no-go, or pivot — after a brief that states status, what has been spent, what lies ahead, and the options with a recommendation. Everything you decide is recorded verbatim and fed back, so the system asks less next quarter than it did this one.

## What is open, what is commercial

**Open, under Apache-2.0:** the constitution (the four framework documents), the templates, the base roles, the reference runtime binding, this repository. **Commercial, separate:** the enforcement harness (isolated verification as a service, tamper-evident logs, real budget stops, metrics dashboards), domain verticals for regulated industries, and a managed offering. One line of rationale, recorded in [`decisions/RISK-002-open-core-boundary.md`](decisions/RISK-002-open-core-boundary.md): *the standard is free; proven trust in execution is the product.* The methodology can be copied — that risk is accepted, traded for standardization and distribution.

## Limitations of v1

Known scope decisions, each with a planned successor — not oversights.

- **Single-human governance.** One risk-taker, no multi-approver delegation yet.
- **Ceremony weight.** The full atom lifecycle is heavy for micro-tasks; lightweight execution tiers are the next planned product.
- **Sequential execution.** No concurrent-write protocol yet; atoms run in dependency order.
- **Metering.** Budget stops are partially estimate-based until runtime counters are wired in; every estimated number is marked as such.

## What exists today

No market claims. Only what this repository can show:

- The framework **wrote and blind-verified its own constitution**: all four normative documents were produced by the framework's own atoms and accepted only after independent verification.
- The discipline caught real defects: the very first document was **returned by its blind verifier** for a template defect that would have propagated to every future atom — fixed minimally, re-verified, then accepted.
- Verification budgeting **improved across three measured runs** — from 8× over the envelope, to 1.8×, to within 6% — each measurement recorded as a public precedent in [`knowledge/precedent/`](knowledge/precedent/).
- The decision journal is real: every gate, every risk acceptance, human answers verbatim, in [`decisions/`](decisions/).

## Start here

Ten more minutes: read [`framework/ATOM-SPEC.md`](framework/ATOM-SPEC.md) §1 — the atom formula is the whole idea. Then the [`README.md`](README.md) routes you: constitution reading order, the runtime quickstart, and the repository map. License: [Apache-2.0](LICENSE).

---
¹ RPF is the methodology's name; a commercial brand name is pending.
