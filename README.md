# Qroky — Recursive Product Framework

Qroky is an operating system for building products with a workforce of agents. Every piece of work is a **product** with a consumer, acceptance criteria, and a maturity level, produced by a single universal unit — the **atom** — that recurses from company strategy down to a paragraph. Work is specified, executed, and **blind-verified** under segregation of duties; the human supplies only intent, missing information, and risk acceptance, and every decision is recorded. The whole system is markdown files and git — no platform lock-in, no database of record. Start with [MANIFEST.md](MANIFEST.md) (5 minutes); it explains why this exists and what is free.

**Who it is for:**

- **Solo founders** — one person plus Qroky operates like a company: intent in, governed and verified production out.
- **Small teams** — run a portfolio of products with explicit ownership of risk, acceptance, and budget.
- **Regulated organizations** — maker-checker, blind verification, audit trail, and recorded risk acceptance as architecture, not add-ons.
- **Contributors** — a methodology that builds and verifies itself in the open; the repository is the working example.

**Quickstart:**

1. Read the constitution, in order: [ATOM-SPEC](framework/ATOM-SPEC.md) → [FEV-PROTOCOL](framework/FEV-PROTOCOL.md) → [REPO-STRUCTURE](framework/REPO-STRUCTURE.md) → [ORCHESTRATION](framework/ORCHESTRATION.md).
2. To run atoms on the reference runtime, follow [runtime/claude/README.md](runtime/claude/README.md) — session start, tier mapping, human sign-off, headless mode.
3. Watch a real cycle: any atom folder under [products/framework-v1/](products/framework-v1/) shows the full record — `INPUT.md` → product → blind `VERDICT.md` → human acceptance in [decisions/](decisions/).

**Repository map:**

| Path | What lives there |
| :---- | :---- |
| [MANIFEST.md](MANIFEST.md) | The manifesto — why Qroky exists, who it is for, what is open |
| [framework/](framework/) | The constitution: four normative documents binding every atom |
| [roles/](roles/) | Executor role specs; human-participant profiles in `roles/humans/` |
| [products/](products/) | One folder per product; one folder per atom — the permanent work record |
| [decisions/](decisions/) | The decision journal: gates, risk acceptances, information, verbatim |
| [knowledge/](knowledge/) | The knowledge layer: domain, organizational, procedural, precedent |
| [runtime/](runtime/) | Runtime bindings — how atoms run on a concrete platform |
| [LICENSE](LICENSE) | Apache License 2.0 — the open boundary is recorded in [decisions/RISK-002](decisions/RISK-002-open-core-boundary.md) |

Licensed under [Apache-2.0](LICENSE). **Qroky** is the product's brand name; the methodology it implements is the **Recursive Product Framework**.
