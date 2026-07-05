# REPO-STRUCTURE — Repository Structure & Knowledge Layer

| Field | Value |
| :---- | :---- |
| Product | Repository Structure & Knowledge Layer v1 |
| Parent product | Recursive Product Framework v1 |
| Produced by | ATOM-003 (executor role: Framework Architect) |
| Maturity | `reviewed` (target) |
| Date | 2026-07-05 |

This document fixes the repository as the framework's physical reality: where every file lives, what it is named, what frontmatter it carries, when it reaches remote consumers, and how overall progress is read from one place. ATOM-SPEC defines the atom's contract; FEV-PROTOCOL defines checking and escalating; this document defines the ground both stand on. After this document, no atom invents a path, a filename, or a frontmatter schema.

---

## 0. How to Read This Document

- Rule language (MUST / MUST NOT / SHOULD / MAY) carries the meanings of ATOM-SPEC R0.1. Numbered rules and tables are normative; passages marked *(informative)* bind nobody (R0.2).
- Rule prefixes in this document: **LA** (layout), **NC** (naming), **KL** (knowledge layer), **HP** (human profiles), **RB** (remote bus), **SM** (status machine), **BC** (budget calibration). None collide with the prefixes of ATOM-SPEC or FEV-PROTOCOL (the P0.2 discipline); rules of all three documents are citable side by side.
- Precedence: per R0.3 and P0.3, this document tightens obligations of ATOM-SPEC and FEV-PROTOCOL and never relaxes them. A statement here that appears to relax one is defective: the earlier document prevails, and the conflict MUST be reported — as a finding if discovered at verification, as trigger E7 if discovered at execution.

---

## 1. Repository Layout

- LA1 — The repository consists of exactly these top-level paths:

| Path | Holds | Normative reference |
| :---- | :---- | :---- |
| `framework/` | Constitutional documents, binding on every atom | this document; ATOM-SPEC; FEV-PROTOCOL |
| `roles/` | Role specs, one file per role | ATOM-SPEC §6.3; NC5 |
| `roles/humans/` | Human-participant profiles | §4 |
| `products/<product-slug>/` | One folder per product that owns atoms | NC2 |
| `products/<product-slug>/<atom-folder>/` | One folder per atom | LA3 |
| `products/<product-slug>/status.yaml` | Shared status machine of the product | §6 |
| `decisions/` | Decision records | FEV-PROTOCOL §4 (DR1) |
| `knowledge/<type>/` | Knowledge layer | §3 |
| `runtime/<platform>/` | Runtime bindings — reserved; materialized by the first atom that delivers a binding | ATOM-SPEC Appendix A |
| repository root | Launch files (NC6) and `.gitignore` (RB4) only | — |

- LA2 — The LA1 table is closed. A file MUST NOT be created at a path that neither matches an LA1 row nor is named explicitly as a deliverable path in the writing atom's `INPUT.md`. New top-level directories require a framework atom that amends this document first.
- LA3 — Every atom folder contains:

| File | Mandatory | Content |
| :---- | :---- | :---- |
| `INPUT.md` | at instantiation (F1, A6) | The atom's specification, per the ATOM-SPEC §6.1 template |
| `STATUS.md` | from creation (O2.1) | Append-only state lines |
| `RESULT.md` | at delivery (V5) | Self-check + cost block, per the ATOM-SPEC §6.2 template |
| `workspace/` with `run.log` | during execution (O3.1) | Working materials; only `run.log` survives closure (O10.1) |
| `VERDICT.md` (+ `VERDICT-round-<k>.md`) | Verify atoms only | At the folder root, per VP6 and VP17 |
| product file(s) | only when `INPUT.md` names the atom folder as the delivery path | The product itself |

- LA4 — A deliverable MAY live outside its atom's folder (e.g. under `framework/` or `knowledge/`) when `INPUT.md` names the exact path (K1). The LA3 metadata set always stays in the atom folder; it is the atom's permanent record (O10.1).
- LA5 — Files are the source of truth for the entire repository. Any database, cache, or index built over them MUST be rebuildable from the files alone and is never authoritative. (Extends O1.2 from atom scope to repository scope; §6 applies it to `status.yaml`.)

*(informative)* The vendored conventions accepted in GATE-001 — append-only logs (O3.1), workspace-per-run (O10.1), self-describing packaged folders — remain exactly as ATOM-SPEC fixes them. This document adds paths and schemas, not new mechanics.

*(informative)* The repository as it stands on the day this document is delivered, mapped to the LA1 rows — a navigation aid, not a norm:

| Existing path | LA1 row it instantiates |
| :---- | :---- |
| `framework/ATOM-SPEC.md`, `framework/FEV-PROTOCOL.md`, `framework/REPO-STRUCTURE.md` | `framework/` — the constitution trio |
| `roles/framework-architect.md` | `roles/` |
| `roles/humans/ghenadie.md` | `roles/humans/` |
| `products/framework-v1/001-atom-spec/` | atom folder of ATOM-001 |
| `products/framework-v1/002-fev-protocol/` + `002-fev-protocol-verify/` | atom folder + its Verify sibling (NC2) |
| `products/framework-v1/003-repo-structure/` | atom folder of ATOM-003 (this document's producer) |
| `products/framework-v1/role-001-framework-architect/` | role-creation atom folder (NC2) |
| `products/framework-v1/status.yaml` | status machine of the product (§6) |
| `decisions/GATE-001…`, `GATE-002…`, `GATE-003…`, `RISK-001…` | `decisions/` per DR1 |
| `knowledge/precedent/remote-bus-push-required.md`, `…/verify-envelope-calibration.md` | `knowledge/<type>/` (§3) |
| `ATOM-003-LAUNCH.md`, `.gitignore` | repository root (NC6, RB4) |

---

## 2. Naming Conventions

- NC1 — Identifiers:

| Thing | Pattern | Notes |
| :---- | :---- | :---- |
| Atom | `ATOM-NNN` | `NNN` zero-padded, three digits |
| Role-creation atom | `ROLE-NNN` | Same numbering discipline, own sequence |
| Verify atom | `<target-atom-id>-VERIFY` | Fixed by VP6 |
| Placed gate / decision record | `GATE-NNN`, `INFO-NNN`, `RISK-NNN` | Fixed by DR1–DR3 |

  Numbers are sequential per prefix across the repository and are never reused, including for `failed` or abandoned atoms.
- NC2 — Product and atom folder slugs: lowercase kebab-case. An atom folder is `<nnn>-<slug>` where `<nnn>` is the atom's number and `<slug>` names its product (e.g. `003-repo-structure`); role-creation atoms use `role-<nnn>-<slug>`; a Verify atom's folder is its target's folder slug suffixed `-verify` (VP6).
- NC3 — Decision record filenames: DR1 of FEV-PROTOCOL, unchanged.
- NC4 — Knowledge files: `knowledge/<type>/<slug>.md`, where `<type>` is one of the KL2 vocabulary and `<slug>` is kebab-case. The path's `<type>` segment MUST equal the file's frontmatter `type`.
- NC5 — Role files: `roles/<role-slug>.md`, kebab-case (e.g. `framework-architect.md`). Human profiles: `roles/humans/<given-name>.md`, lowercase (e.g. `ghenadie.md`).
- NC6 — Launch files: `<ATOM-ID>-LAUNCH.md` at the repository root. A launch file is a runtime convenience for starting a session; its normative content is the `INPUT.md` it materializes. On any divergence, `INPUT.md` prevails.
- NC7 — Everything else defaults to lowercase kebab-case. Reserved filenames keep their fixed casing: `INPUT.md`, `STATUS.md`, `RESULT.md`, `VERDICT.md`, `GATE-BRIEF.md`, `run.log`, `status.yaml`, `.gitignore`.

---

## 3. Knowledge Layer & Profiles

- KL1 — Every file under `knowledge/` MUST carry YAML frontmatter with these mandatory fields:

| Field | Content |
| :---- | :---- |
| `source` | Where the knowledge comes from: atom id, document path, or external reference — precise enough to re-verify |
| `date` | `YYYY-MM-DD` — when the knowledge was established or last confirmed |
| `type` | Exactly one of the KL2 vocabulary |
| `tags` | List, at least one entry |

- KL2 — Type vocabulary (closed; extending it requires amending this document):

| `type` | Holds |
| :---- | :---- |
| `domain` | Facts about the subject matter a product operates in |
| `organizational` | Facts about the organization: people, structures, systems, accounts |
| `procedural` | How to perform something: methods, checklists, conventions |
| `precedent` | What happened, and the lesson — case history atoms can cite |

- KL3 — Consumption and write-back. An executor satisfies the knowledge part of RS1 by consulting the `knowledge/<type>/` directories relevant to its product and logging what it read. Feedback duties (O8.3, EP7) that target knowledge land here as new files or edits, recorded in the decision record's *Fed back to* section (DR6).
- KL4 — **Profiles.** A domain MAY impose a profile: a named extension declaring extra mandatory frontmatter fields for knowledge files of that domain. The mechanism:
  1. A profile is declared by adding a row to the KL5 registry via a framework atom amending this document.
  2. A knowledge file opts in by carrying `profile: <name>` in its frontmatter, and MUST then carry every field the profile declares.
  3. A file without a `profile` field carries only the KL1 core.
  4. Profile conformance is field presence — checkable by script, no implementation implied.
- KL5 — Profile registry:

| Profile | Extra mandatory fields | Purpose |
| :---- | :---- | :---- |
| `regulatory` | `authority_level` (issuing authority rank: law / regulator / supervisor guidance / internal policy), `jurisdiction`, `valid_from`, `valid_to` (date or `open`), `source_link` | Regulatory and compliance knowledge whose usability depends on who issued it, where it applies, and its validity window |

- KL6 — Any index over the knowledge layer (search database, embedding store, graph) is rebuildable and never authoritative (LA5).
- KL7 — Knowledge file template (T1 discipline: copy verbatim, replace every `<angle-bracket>` placeholder):

```markdown
---
source: <atom id | document path | external reference>
date: <YYYY-MM-DD>
type: <domain | organizational | procedural | precedent>
tags: [<tag>, <tag>]
# profile: <name>            # only when a KL5 profile applies —
# <profile-field>: <value>   # then every field of that profile is mandatory
---

# <Title — one line naming the knowledge>

<The knowledge itself. For `precedent`: what happened, then the lesson,
each stated so a future atom can act on it without reading anything else.>
```

---

## 4. Human-Participant Profiles

- HP1 — Every human who answers escalations, gates, or sign-offs MUST have a profile at `roles/humans/<given-name>.md` (NC5) before their first recorded decision. Mandatory frontmatter: `name`, `languages` (ordered list), `preferred_for_decisions` (exactly one language code). Mandatory sections: *Identity*, *Decision-input preferences*.
- HP2 — **Language canon.** Artifacts addressed to agents and executors are written in English. Products addressed to a human — E1 question sets, E2 risk-acceptance requests, E3 gate briefs, and sign-off requests per VP18 — are written in that human's `preferred_for_decisions` language.
- HP3 — Decision records keep the *Answer (verbatim)* section in the answerer's original words and language (DR5), followed immediately by a one-paragraph English summary, so agent consumers need no translation step.
- HP4 — *Forward reference:* the routing rules HP2–HP3 will migrate to FEV-PROTOCOL (their normative home, next touch of that document). Until that migration they bind as written here; this atom does not modify FEV-PROTOCOL.
*(informative)* The founding instance is `roles/humans/ghenadie.md`: the human risk-taker of Framework v1, answerer of GATE-001–GATE-003 and RISK-001. Question sets and briefs addressed to him are routed per HP2 using that profile.

- HP5 — Human profile template:

```markdown
---
name: <given-name>
languages: [<code>, <code>]          # ordered by fluency
preferred_for_decisions: <code>      # exactly one; HP2 routing key
---

# Human: <Name>

## Identity
<1–3 sentences: who this person is in the framework — which products they
own, which risks they accept, which gates they answer.>

## Decision-input preferences
<How this human wants decision inputs shaped: format, depth, what must
never be omitted. Written for the agent authoring a question set or brief.>

## Provenance
| Event | Atom | Date |
| :---- | :---- | :---- |
| Created | <ATOM-ID> | <date> |
```

---

## 5. Remote Bus

- RB1 — When the repository has a configured git remote, atom closure (L7) includes **commit and push**. A product is delivered on the bus for remote consumers only after the push succeeds; until then, delivery per O1.1 has happened locally only, and no remote consumer may be assumed to see it. (Tightens L7.)
- RB2 — Always committed at closure: the product file(s), `INPUT.md`, `STATUS.md`, `RESULT.md`, `run.log`, `VERDICT.md` with any superseded rounds, decision records, knowledge files, and `status.yaml`. Never committed: workspace scratch (deleted at L7 anyway) and everything matched by `.gitignore`. A path listed in this rule MUST NOT appear in `.gitignore`.
- RB3 — Commit messages: the first line MUST begin with the atom id(s) whose lifecycle event the commit records, followed by a colon and a one-line summary naming the event (`delivered`, `accepted`, `returned`, `blocked`, `closed`, …). Every atom id whose files are in the commit appears in the message. One commit MAY close a chain of atoms accepted together (e.g. an atom and its Verify atom). The first line SHOULD stay within 72 characters.
- RB4 — `.gitignore` baseline at the repository root, committed, containing at minimum: OS artifacts `.DS_Store`, `._*`, `Thumbs.db`, `desktop.ini`; editor swap files `*.swp`, `*.swo`, `*~`. Products MAY append entries below the baseline; no entry may contradict RB2.
- RB5 — An ignore rule does not untrack files already committed. Files newly matched by `.gitignore` but still tracked MUST be untracked in a cleanup commit — executed by the human, or by an atom whose `INPUT.md` authorizes it.
- RB6 — **Closure sequence.** At L7, the closing actor performs, in this order:

| # | Step | Rule |
| :- | :---- | :---- |
| 1 | Record acceptance in the parent's run log | L7 |
| 2 | Clean the atom's `workspace/`, keeping `run.log` | O10.1 |
| 3 | Append the final state line to the atom's `STATUS.md`, if the state changed | O2.2 |
| 4 | Update the atom's entry in the product's `status.yaml` | SM3 |
| 5 | Commit everything RB2 lists, with an RB3-conformant message | RB2, RB3 |
| 6 | Push, when a remote is configured | RB1 |

  A closure that stops before step 6 with a remote configured is incomplete: the atom's consumers on the remote still see the previous state.

*(informative)* This section exists because of a recorded lesson: a remote consumer could not reach a delivered product because closure had committed but not pushed — see `knowledge/precedent/remote-bus-push-required.md`.

---

## 6. Status Machine

- SM1 — Every multi-atom product (two or more atom folders under its `products/<product-slug>/`) MUST maintain `products/<product-slug>/status.yaml`. (Tightens O10.2 from SHOULD to MUST.)
- SM2 — `status.yaml` holds the product name, its last update timestamp, and exactly one entry per atom with the fields `id`, `state`, `timestamp`, `note`. The `state` vocabulary is identical to O2.1: `formulated | running | delivered | blocked | failed`. `timestamp` is the UTC time of that atom's latest state transition; `note` mirrors the note of the latest `STATUS.md` line (it MAY be shortened, never contradicted).
- SM3 — Update duty: the actor that appends a state line to an atom's `STATUS.md` (O2.2) MUST update that atom's entry in `status.yaml` in the same step. Entries are overwritten in place — one entry per atom, current state only. History lives in `STATUS.md`, never here.
- SM4 — `status.yaml` is an index, not truth (LA5): it MUST be rebuildable from the `STATUS.md` files of its product. On any divergence, `STATUS.md` wins and `status.yaml` MUST be regenerated to match.
- SM5 — Schema (the file is valid YAML; comments annotate the schema):

```yaml
# status.yaml — shared status machine of one multi-atom product (SM1-SM4)
# One file per products/<product-slug>/; one entry per atom; current state only.
product: <product-slug>
updated: <YYYY-MM-DDTHH:MM:SSZ>      # timestamp of the last write to this file
atoms:
  - id: <ATOM-ID>                    # NC1 identifier
    state: <formulated | running | delivered | blocked | failed>   # O2.1 vocabulary
    timestamp: <YYYY-MM-DDTHH:MM:SSZ> # this atom's latest state transition
    note: <one line, mirrors the latest STATUS.md note>
```

*(informative)* The first real instance is `products/framework-v1/status.yaml`, seeded by ATOM-003 with entries backfilled from the `STATUS.md` files of ROLE-001, ATOM-001, ATOM-002, and ATOM-002-VERIFY — the SM4 rebuild rule exercised at birth.

---

## 7. Budget Calibration

- BC1 — Reading the input package counts toward the executor's envelope. An envelope covers reads, working, and writes — not writes alone.
- BC2 — At Formulate time (F5), the envelope MUST be calibrated from the size of the input package: estimated input tokens ≈ total input bytes ÷ 3, plus a working margin for the work itself. An envelope smaller than the read estimate alone is a Formulate defect and MUST be corrected before instantiation.
- BC3 — Verify atoms are calibrated the same way over their blind package (VP2). Verify cost remains a governance cost of the formulating agent (VP5), reported as its own line per O4.2.
- BC4 — Exact metering is a runtime concern; the binding of counters to a platform belongs to the orchestration product *(forward reference)*. Cost blocks (O4.1) and budget checkpoints (K3) use real counters wherever the runtime exposes them; where it does not, they use estimates, and every estimated number is prefixed with `~`.

*(informative)* This section exists because of a recorded lesson: a Verify atom consumed roughly eight times its envelope because the envelope was estimated from expected output while the blind-package reads dominated — see `knowledge/precedent/verify-envelope-calibration.md`.

*(informative)* Worked example. A Verify atom's blind package totals ~80 KB of files: ~80,000 ÷ 3 ≈ ~27k input tokens. With a working margin for re-running checks and writing the verdict (roughly one to two times the read estimate for verification-style work), a defensible envelope is ~55–80k tokens — not the ~15k a verdict-sized output estimate would suggest.

---

## Appendix A — What This Document Does Not Define *(informative)*

- **Orchestration and runtime bindings** — how atoms are physically instantiated, scheduled, and metered on a platform. That is the orchestration product; its bindings will live under `runtime/<platform>/` (LA1).
- **The final normative home of language routing** — HP2–HP3 migrate to FEV-PROTOCOL at its next touch (HP4).
- **Tooling** — validators for KL profiles, `status.yaml` regeneration, or ignore-rule cleanup. Rules here are phrased so a script can check them; the scripts themselves are products of future atoms.

*End of REPO-STRUCTURE v1. An atom holding the constitution trio — ATOM-SPEC, FEV-PROTOCOL, and this document — can place every file it produces without asking.*
