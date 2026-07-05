---
atom: ATOM-005
product: Manifest & public face (MANIFEST.md, README.md, LICENSE, decisions/RISK-002)
parent: Recursive Product Framework v1
formulated_by: Human (Ghenadie) + advisor agent, 2026-07-06
verification: independent + human
maturity_target: reviewed
instantiation: session
model_tier: L (public-facing, positioning-critical)
budget: ~55k tokens for Execute (read estimate ≈ 25k; ×2 + margin). Hard stop per O6.2.
recursion_allowance: 0
---

# ATOM-005 — Input Specification

## 1. Product Identity
| Field | Value |
| :---- | :---- |
| Product | Root `MANIFEST.md` + root `README.md` + root `LICENSE` + `decisions/RISK-002-open-core-boundary.md` |
| Atom ID | ATOM-005 |
| Parent product | Recursive Product Framework v1 |
| Executor role | framework-architect (exists, F2 satisfied) |
| Input product(s) | the four framework documents; `runtime/claude/README.md`; `decisions/` (all); `knowledge/precedent/` (both); this INPUT |
| Consumer(s) | PRIMARY: a non-technical founder seeing the repo for the first time (10 minutes to "I understand what this is and why I'd want it"). SECONDARY: accelerator program managers deciding to offer this to a cohort; investors/partners; future contributors; banks evaluating the governance story |
| Maturity target | reviewed |
| Gates | none — trigger gates only |
| Instantiation | session |
| Verification mode | independent + human |
| Budget envelope | ~55k tokens |
| Recursion-depth allowance | 0 |

## 2. Job To Be Done
Give the framework its public face: a two-page manifesto a newcomer reads before anything else, a landing README that routes readers in under a minute, the legal foundation (LICENSE), and the recorded decision that draws the open/commercial boundary. After this product, a stranger arriving at the repository understands what this is, who it is for, what is free, and how to start — without reading a single normative document.

## 3. Context — Decisions Already Made (formalize, do not reopen)

### 3.1 Naming (placeholder discipline)
The methodology name is **RPF — Recursive Product Framework**. A commercial brand name is pending a naming atom (trademark/collision due diligence in progress; candidates exist). The manifest MUST use only the exact string "RPF" as the name everywhere (one token, sed-replaceable), MUST NOT coin any other name, and MAY carry one footnote: brand name pending.

### 3.2 Positioning (accepted by human 2026-07-05)
Core narrative: **the founder as CEO of agents — one person plus RPF is a company.** The founder supplies exactly three things the system cannot produce: intent (go/no-go/pivot at gates), missing information, and risk acceptance — everything else is produced by agents in isolated atoms under blind verification. Key differentiator vs. assistants: RPF's recursive decomposition *generates the questions* the founder didn't know to ask (unknown unknowns become a product tree with acceptance criteria). Not an assistant that answers — an operating system that asks, produces, verifies, and records.

### 3.3 The five load-bearing principles (compress, don't rewrite)
(1) Everything is a product — consumer, JTBD, Definition of Done, maturity; no tasks, no phases. (2) One atom, infinite recursion — same structure at every scale. (3) Humans supply three exclusive products — information, risk acceptance, intent; involvement is designed to fall over time (escalation rate is a metric, answers feed back into roles/knowledge). (4) Formulate / Execute / Verify — segregation of duties with blind verification; isomorphic to banking maker-checker; every decision leaves an audit trail in `/decisions/`. (5) Files are the whole system — platform-neutral markdown + git; any model, any runtime; databases are rebuildable indexes.

### 3.4 Open-core boundary (RISK-002 — accepted by human 2026-07-05, record it)
OPEN (Apache License 2.0): the constitution (four framework documents), templates, base roles, the reference runtime binding, this repository. COMMERCIAL (closed, separate): the enforcement harness (isolated verification service, tamper-evident logs, real budget stops, metrics dashboards), domain verticals (regulated-industry knowledge profiles and role packs), managed/hosted offering. One-line rationale for the record: *the standard is free; proven trust in execution is the product.* Accepted risk: the methodology can be copied — traded for standardization, brand, and distribution. Record as `decisions/RISK-002-open-core-boundary.md` per DR rules (kind: risk-acceptance; answered_by: Ghenadie; trigger: backfill per DR8; verbatim answer sourced from this INPUT).

### 3.5 Honesty section — known limitations of v1 (mandatory in MANIFEST)
State plainly: single-human governance model (no multi-approver delegation yet); full atom ceremony is heavy for micro-tasks (lightweight execution tiers are the next planned product); sequential execution (no concurrent-write protocol yet); budget metering partially estimate-based pending runtime counters. Framing: known scope decisions with planned successors, not oversights.

### 3.6 Proof, not promises
The manifest MAY cite only facts present in this repository: the framework wrote and blind-verified its own constitution (bootstrap); N atoms executed with recorded verdicts, returns, and human sign-offs; verify-envelope calibration improved across three measured precedents; the decision journal is real and public. No market claims, no adoption claims, no benchmarks that do not exist.

### 3.7 LICENSE mechanics
`LICENSE` at repo root = the verbatim Apache License 2.0 text (standard full text, copyright line: "Copyright 2026 Ghenadie Cernei"). README and MANIFEST reference it in one line each.

## 4. Deliverable
1. `MANIFEST.md` (root) — the manifesto per §3.2–3.6. Structure suggestion (non-binding): why now → what RPF is (five principles, compressed) → who it is for (founder first; teams; regulated organizations) → what the human does (three products, gates) → what is open and what is commercial → limitations → what exists today → start here.
2. `README.md` (root) — landing page ≤60 lines: one-paragraph what-this-is, 4-bullet who-it's-for, quickstart pointer (constitution reading order + `runtime/claude/README.md`), links to MANIFEST/LICENSE, repo map in one table.
3. `LICENSE` — per §3.7.
4. `decisions/RISK-002-open-core-boundary.md` — per §3.4.

## 5. Definition of Done
**Hard criteria:**
- H1. All four files exist at the exact paths above.
- H2. `MANIFEST.md` ≤ 1,100 words excluding headings (two pages); `README.md` ≤ 60 lines.
- H3. `LICENSE` contains the Apache License 2.0 canonical text (detectable: "Apache License" + "Version 2.0" + §4 redistribution clause present).
- H4. Zero platform/product names in MANIFEST and README (grep: "Claude", "Claude Code", "MCP", "Codex", "OpenClaw", "Hermes", "BMAD") — runtime specifics live behind the quickstart pointer, not on the public face. The name used is exactly "RPF" (H4b: no other coined name appears).
- H5. `decisions/RISK-002-open-core-boundary.md` conforms to the decision-record template (frontmatter keys + 4 sections).
- H6. Zero contradictions with the four framework documents; every factual claim in MANIFEST is verifiable inside the repo (S-checked, but hard-checkable subset: every number cited matches repo state).
- H7. `RESULT.md` with cost block; `STATUS.md` last state `delivered`; status.yaml updated.

**Soft criteria:**
- S1. A non-technical founder reading only MANIFEST.md for 10 minutes can answer: what is this, what would I do with it, what do I keep doing myself, what is free — judge: human.
- S2. No hype vocabulary ("revolutionary", "game-changing", "10x"); confidence through specifics — judge: Verify.
- S3. The limitations section reads as engineering honesty, not disclaimer boilerplate — judge: Verify.
- S4. README routes a reader to the right next document in under a minute — judge: Verify.

**Maturity target:** reviewed. Do not gold-plate.

## 6. Method Hints (non-binding)
Write the manifesto as an argument, not a feature list. Steal the strongest phrasings from the constitution rather than inventing parallel vocabulary. The five principles compress to one line each — the normative documents carry the detail.

## 7. Escalation
E1–E7 per ATOM-SPEC §5.7. Gates: none. Budget hard stop per O6.2. Otherwise: do not ask for permission on the normal path. Execute.
