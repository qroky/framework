# LAUNCH — ATOM-003

> Runtime instruction for this session. Execute **one atom**, per `framework/ATOM-SPEC.md` and `framework/FEV-PROTOCOL.md` (read both first — they are your contract and your governance).
> Step 0 — materialize Formulate outputs: create `products/framework-v1/003-repo-structure/` with `INPUT.md` (copy from below), `STATUS.md` in state `formulated`, and `workspace/`. Then execute.
> After self-verify and delivery, the parent (this session) MUST formulate and run a blind Verify atom per FEV-PROTOCOL §2 (as done for ATOM-002), then request human sign-off, then close per L7 and commit+push.

---
---
atom: ATOM-003
product: Repository Structure & Knowledge Layer (framework/REPO-STRUCTURE.md)
parent: Recursive Product Framework v1
formulated_by: Human (Ghenadie) + advisor agent, 2026-07-05
verification: independent + human
maturity_target: reviewed
instantiation: session
budget: ~55k tokens for Execute (reading input products counts toward the envelope — see §3.9; Verify gets its own envelope, calibrated per §3.9, charged to parent per VP5)
recursion_allowance: 1
---

# ATOM-003 — Input Specification

## 1. Product Identity
| Field | Value |
| :---- | :---- |
| Product | `framework/REPO-STRUCTURE.md` + the real seed files of §4 |
| Atom ID | ATOM-003 |
| Parent product | Recursive Product Framework v1 |
| Executor role | framework-architect (`/roles/framework-architect.md` — exists, F2 satisfied) |
| Input product(s) | `framework/ATOM-SPEC.md`; `framework/FEV-PROTOCOL.md`; this INPUT; existing repo tree as observed |
| Consumer(s) | Every atom (resolves paths & conventions); orchestration (ATOM-004 reads the status-machine & remote-bus rules); knowledge-consuming atoms; the human (navigates the repo); future domain packs (regulatory profile) |
| Maturity target | reviewed |
| Gates | none — trigger gates only |
| Instantiation | session |
| Verification mode | independent + human (constitutional document) |
| Budget envelope | ~55k tokens, hard stop per O6.2 |
| Recursion-depth allowance | 1 |

## 2. Job To Be Done
Fix the repository as the framework's physical reality: the full directory layout, naming conventions, the knowledge layer with its profile mechanism, human-participant profiles, the remote segment of the file bus, and the shared status machine. After this product, no atom should ever invent a path, a filename, or a frontmatter schema.

## 3. Context — Decisions Already Made (formalize, do not reopen)

### 3.1 Layout baseline (already in use — legalize and complete)
`framework/` (constitution), `roles/` (+ new `roles/humans/` for human-participant profiles), `products/<product>/<atom-id>/` (INPUT, STATUS, RESULT, workspace/run.log), `decisions/`, `knowledge/`, `runtime/<platform>/` (reserved, empty now). Root may also hold launch files and `.gitignore`.

### 3.2 Knowledge layer: minimal core + profiles
Every knowledge file carries minimal mandatory frontmatter: `source`, `date`, `type` (one of: domain | organizational | procedural | precedent), `tags`. Domains MAY impose **profiles** — named extensions with extra mandatory fields. Specify the mechanism plus ONE example profile, `regulatory` (fields: authority_level, jurisdiction, valid_from, valid_to, source_link), described in ≤ half a page, no implementation. Files are the source of truth; any database/index over them is rebuildable and never authoritative.

### 3.3 Human-participant profiles (accepted by human 2026-07-05)
`roles/humans/<name>.md`: identity, `languages`, `preferred_for_decisions`, decision-input preferences. Canon for agent-addressed artifacts is English; human-addressed products (escalations E1–E3, gate briefs, sign-off verdicts) use the human's preferred language; `/decisions/` records keep the verbatim original answer plus an English summary. The routing rule's normative home is FEV-PROTOCOL (next touch — note it in the profile spec as a forward reference, do not modify FEV-PROTOCOL in this atom).

### 3.4 Remote bus segment (lesson: consumer could not reach the bus, 2026-07-04)
When a git remote is configured, atom closure (L7) includes commit + push; a product is not "on the bus" for remote consumers until pushed. Define: what is always committed (product, INPUT, STATUS, RESULT, run log, decisions, knowledge), commit-message convention referencing atom IDs, and `.gitignore` baseline (OS junk: `.DS_Store` etc. — the repo currently contains `.DS_Store` files; add `.gitignore` and note the cleanup command in RESULT for the human to run).

### 3.5 Status machine (O10.2)
Fix the schema of the shared machine-readable status file for multi-atom products: path (`products/<product>/status.yaml`), one entry per atom: `id, state, timestamp, note`. Same state vocabulary as STATUS.md. Generated/updated at each atom's state transitions; rebuildable from STATUS.md files (index, not truth).

### 3.6 Naming conventions
Atom IDs (`ATOM-NNN`, `ROLE-NNN`, `<ATOM>-VERIFY`), product folder slugs, decision files (keep DR1 of FEV-PROTOCOL), knowledge files (`knowledge/<type>/<slug>.md` or flat with type in frontmatter — choose the simplest that scales, log the choice), role files.

### 3.7 Embodiment & platform stance
Same as ATOM-SPEC R0.4 / §3.11 of ATOM-001 INPUT: zero platform names in normative text; nothing assumes a chat-LLM executor.

### 3.8 Vendored conventions (GATE-001)
Append-only logs, workspace-per-run, SKILL-style packaging stay as fixed by ATOM-SPEC; do not rename or re-invent.

### 3.9 Budget semantics (lesson: ATOM-002-VERIFY consumed ~60k against a ~15k envelope with no E4, 2026-07-05)
For this atom and as a documented convention in REPO-STRUCTURE's atom-folder section: reading the input package counts toward the envelope; envelopes MUST be calibrated from package size (estimate: total input bytes / 3 ≈ input tokens, plus working margin). Note in the document that exact metering is a runtime concern (forward reference to the orchestration product), and cost blocks use real counters when the runtime exposes them, estimates marked `~` otherwise.

## 4. Deliverable
1. `framework/REPO-STRUCTURE.md` — the normative document covering §3.1–3.9.
2. Real seed files (they are part of the product, not examples):
   - `roles/humans/ghenadie.md` — languages: ro, ru, en, fr; preferred_for_decisions: ru; decision-input preference: balanced pros/cons with explicit risks (especially non-obvious ones) before or alongside recommendations.
   - `knowledge/` — exactly 2 precedent-type knowledge files, sourced from the repo's own history: (a) the remote-bus lesson (§3.4), (b) the verify-envelope calibration lesson (§3.9). Each conforming to §3.2 frontmatter.
   - `products/framework-v1/status.yaml` — first real status-machine file, backfilled for ROLE-001, ATOM-001, ATOM-002, ATOM-002-VERIFY, ATOM-003.
   - `.gitignore` at repo root.
3. Exactly three fenced templates inside REPO-STRUCTURE.md: knowledge file, human profile, `status.yaml` schema.

## 5. Definition of Done
**Hard criteria:**
- H1. `framework/REPO-STRUCTURE.md` exists; 250–700 lines including templates.
- H2. Sections covering: Layout / Naming / Knowledge layer & profiles / Human profiles / Remote bus / Status machine / Budget-calibration convention (detectable by headings).
- H3. Exactly three fenced templates (knowledge, human profile, status.yaml), each with frontmatter or schema header.
- H4. Zero platform/product names in normative text (grep: "Claude Code", "MCP", "Codex", "OpenClaw", "Hermes", "BMAD").
- H5. All seed files of §4.2 exist and conform to their own templates (ghenadie.md, 2 knowledge files, status.yaml, .gitignore).
- H6. Zero contradictions with ATOM-SPEC and FEV-PROTOCOL; every cited rule id resolves.
- H7. `RESULT.md` with cost block; `STATUS.md` last state `delivered`.

**Soft criteria (judge: Verify agent unless noted):**
- S1. A fresh atom, given only the constitution trio (ATOM-SPEC, FEV-PROTOCOL, REPO-STRUCTURE), can place every file it produces without asking.
- S2. Every normative statement testable; no aspirational language.
- S3. Tightens but never relaxes the two prior constitutional documents.
- S4. The human profile and the two knowledge seeds read as immediately usable — judge: human.
- S5. Core (excluding templates) readable in ≤ 10 minutes.

**Maturity target:** reviewed. Do not gold-plate.

## 6. Method Hints (non-binding)
Continue the rule-numbering ethos (new prefix, e.g. RS/N/KL/HP/RB/SM/BC — avoid collisions, mind FEV-PROTOCOL F2-finding about id spaces). Tables over prose. Where §3 is silent, simplest reversible choice, logged per O9.1.

## 7. Escalation
Triggers E1–E7 of ATOM-SPEC §5.7. Gates: none — trigger gates only. Budget: hard stop per O6.2 — stop-and-escalate, never finish-then-report. Otherwise: do not ask for permission on the normal path. Execute.

---
*End of launch file. One atom, then its blind Verify, then the human.*
