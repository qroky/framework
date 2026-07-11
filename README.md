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
3. Watch a real cycle: any atom folder in the public factory, [qroky/lab](https://github.com/qroky/lab), shows the full record — `INPUT.md` → product → blind `VERDICT.md` → human acceptance in its `decisions/`.

**Repository map:**

| Path | What lives there |
| :---- | :---- |
| [MANIFEST.md](MANIFEST.md) | The manifesto — why Qroky exists, who it is for, what is open |
| [framework/](framework/) | The constitution: four normative documents binding every atom |
| [knowledge/](knowledge/) | The knowledge layer: domain, organizational, procedural, precedent |
| [runtime/](runtime/) | Runtime bindings — how atoms run on a concrete platform |
| [distribution/](distribution/) | The installer kit: `install.sh`, the dist-manifest, the freeze check |
| [qroky.sh](qroky.sh) | The one-command entry — installed as the `qroky` command on PATH: `qroky install \| update \| uninstall` |
| [LICENSE](LICENSE) | Apache License 2.0 — the open boundary is recorded in the decision journal (RISK-002, in the lab) |

This repository is the PRODUCT — what every instance receives, whole
(see [distribution/dist-manifest](distribution/dist-manifest) and
[docs/separation.md](docs/separation.md)). The full self-construction
journal — every product folder, every decision, every gate, verbatim —
lives in the public factory: **[qroky/lab](https://github.com/qroky/lab)**.

Licensed under [Apache-2.0](LICENSE). **Qroky** is the product's brand name; the methodology it implements is the **Recursive Product Framework**.
