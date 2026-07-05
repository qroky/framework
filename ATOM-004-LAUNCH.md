# LAUNCH — ATOM-004 then ATOM-004H

> Runtime instruction for this session. Execute **two atoms in strict sequence**, per the constitution trio (`framework/ATOM-SPEC.md`, `framework/FEV-PROTOCOL.md`, `framework/REPO-STRUCTURE.md` — read all three first).
> Step 0 — materialize Formulate outputs for both atoms per RS/SM rules. Execute ATOM-004; run its blind Verify per FEV-PROTOCOL §2; request human sign-off; close per L7/RB6. Only then execute ATOM-004H (its §3 references the accepted ORCHESTRATION.md), with its own blind Verify and closure. Update status.yaml at every transition.
> Spawn justification (formulator): the platform-neutral protocol and the platform binding have different consumers, different H4 constraints (the binding legally names the platform), and different change cadence; one atom would force one document to violate either neutrality or usefulness.

---
---
atom: ATOM-004
product: Orchestration Protocol (framework/ORCHESTRATION.md)
parent: Recursive Product Framework v1
formulated_by: Human (Ghenadie) + advisor agent, 2026-07-05
verification: independent + human
maturity_target: reviewed
instantiation: session
model_tier: L (constitutional document — see §3.2; this field is what you will formalize)
budget: ~70k tokens for Execute (read estimate per BC1: constitution trio + this INPUT ≈ 30k; margin ×2). Verify envelope: read estimate ×3.5 per §3.3. Hard stop per O6.2.
recursion_allowance: 1
---

# ATOM-004 — Input Specification

## 1. Product Identity
| Field | Value |
| :---- | :---- |
| Product | `framework/ORCHESTRATION.md` |
| Atom ID | ATOM-004 |
| Parent product | Recursive Product Framework v1 |
| Executor role | framework-architect (exists, F2 satisfied) |
| Input product(s) | constitution trio; this INPUT; open items inherited per GATE-004 (F1 gate-brief placement; verify-margin observation) |
| Consumer(s) | Formulating agents (decomposition, tiering, budgeting, gate placement); runtimes (what a binding must implement); Verify atoms (envelope + tier rules); the human (predictable involvement points) |
| Maturity target | reviewed |
| Gates | none — trigger gates only |
| Instantiation | session |
| Verification mode | independent + human (constitutional document) |
| Budget envelope | ~70k tokens |
| Recursion-depth allowance | 1 |

## 2. Job To Be Done
Define how atoms are composed into running products: decomposition planning, executor-class (model tier) assignment, budget calibration, gate-brief placement, launch-file format, spawn mechanics, and status synchronization. After this product, a formulating agent can take any product from idea to a tree of running atoms without inventing any orchestration mechanics — and a runtime author knows exactly what a binding must provide.

## 3. Context — Decisions Already Made (formalize, do not reopen)

### 3.1 Fixed by the constitution — reference, don't restate
Instantiation modes and depth (§1.3 field 12, L2, F6); budget cascade & hard stop (O6.1–O6.2, E4); FEV interface (L5–L6, VP*); file bus & status (O1, O2, SM1–SM4); remote bus (RB1–RB6); budget calibration baseline (BC1–BC4).

### 3.2 Executor class — `model_tier` (accepted by human 2026-07-05)
New mandatory INPUT field `model_tier: S | M | L` assigned at Formulate with one-line logged justification (mirror of O5.1):
- **S** — mechanical work: extraction, reformatting, script-checkable transforms, hard-criteria verification runs.
- **M** — standard structured production against a clear spec.
- **L** — architecture, normative writing, judgment-heavy verification, decomposition planning.
Rules to formalize: (a) **Formulate and Verify of maturity ≥ reviewed run at tier L; economize on Execute** — a weak formulator poisons the subtree, a weak verifier is a rubber stamp; a weak executor under a strong verifier is a sound construction. (b) **Tier escalator:** after a 2nd Verify return, re-execution happens one tier higher, automatically, logged. (c) Asymmetry rule: when in doubt, tier up — the hidden cost of confident junk (full verify cycle + returns + re-execution) exceeds the visible cost of overpaying. (d) Tier names are abstract classes; concrete model mapping is a runtime-binding concern (keeps H4 clean).

### 3.3 Envelope calibration, verify margin (three precedents, see knowledge/precedent/verify-envelope-calibration.md)
Formalize on top of BC1–BC4: Verify envelopes = read estimate × 3–4 (working margin covers re-reads and check outputs; measured 123.8k vs ~35k read estimate on ATOM-003-VERIFY). Executor envelopes = read estimate ×2 minimum. An envelope below the read estimate is a Formulate defect and grounds for E7 by the executor.

### 3.4 Gate-brief placement (closes finding F1 of ATOM-002-VERIFY)
`GATE-BRIEF-<gate-id>.md` lives in the product folder of the atom being gated; the resulting decision record in `/decisions/` references it by relative path. Naming joins §2 of REPO-STRUCTURE (note the forward reference; do not modify REPO-STRUCTURE in this atom — its next touch inherits this rule).

### 3.5 Launch protocol (legalize current practice)
The launch file — the artifact a human or orchestrator hands to a fresh runtime session — becomes a formal product type: runtime preamble (sequence, step-0 materialization, verify-and-close obligations) + one or more full INPUT specs. Multi-atom launches execute in declared order; a later atom's execution begins only after the earlier atom's closure (or explicit parallel marker). Formalize as a fenced template.

### 3.6 Spawn & status mechanics
Each atom owns its STATUS.md; the session-level orchestrator (parent) syncs `status.yaml` at every observed transition. Sub-agent spawns follow O5.1 justification + §3.2 tier assignment + BC calibration; results land on the file bus per L9, never in-memory.

### 3.7 Runtime binding contract
Define the minimal contract every `runtime/<platform>/` binding MUST document: how a session is started from a launch file; how the human is questioned and answers are captured for `/decisions/`; how model tiers map to concrete executors; how real token counters are surfaced into cost blocks (estimates `~` only where no counter exists); how headless (non-interactive) execution is invoked and how it must behave at human-required points (block and surface, never skip). Platform names MUST NOT appear here — only the contract; the binding itself (ATOM-004H) names them.

## 4. Deliverable
`framework/ORCHESTRATION.md` with sections: Decomposition & planning / Model tiers / Budget calibration / Gate briefs / Launch protocol / Spawn & status sync / Runtime-binding contract. Exactly TWO fenced templates: `LAUNCH.md` and a decomposition plan (product tree with per-atom tier, budget, verification mode, gates).

## 5. Definition of Done
**Hard:** H1 file exists, 250–700 lines incl. templates. H2 all seven §4 sections detectable by headings. H3 exactly two fenced templates. H4 zero platform/product names (grep: "Claude Code", "MCP", "Codex", "OpenClaw", "Hermes", "BMAD"). H5 zero contradictions with the constitution trio; every cited rule id resolves. H6 `RESULT.md` with cost block; `STATUS.md` last state `delivered`; status.yaml updated.
**Soft (judge: Verify unless noted):** S1 a formulating agent holding only the four framework docs can plan, tier, budget, gate and launch a 3-atom product without improvising. S2 every normative statement testable. S3 tightens, never relaxes, the trio. S4 the LAUNCH template reproduces this very launch file's structure without loss — judge: Verify. S5 core readable ≤ 10 min.
**Maturity target:** reviewed. Do not gold-plate.

## 6. Method Hints (non-binding)
New rule prefixes (e.g. OD/MT/EC/GB/LP/SS/RC), no collisions. Mind the F2 id-space finding: findings F<n> vs rule ids.

## 7. Escalation
E1–E7 per ATOM-SPEC §5.7. Gates: none. Budget hard stop per O6.2. Otherwise execute.

---
---
atom: ATOM-004H
product: First runtime binding (runtime/claude/README.md)
parent: Recursive Product Framework v1
formulated_by: Human (Ghenadie) + advisor agent, 2026-07-05
verification: independent
maturity_target: reviewed
instantiation: session
model_tier: M (documentation of observed practice against a fixed contract)
budget: ~45k tokens for Execute (read estimate ≈ 18k; ×2.5). Verify envelope: read estimate ×3.5. Hard stop per O6.2.
recursion_allowance: 0
---

# ATOM-004H — Input Specification

## 1. Product Identity
| Field | Value |
| :---- | :---- |
| Product | `runtime/claude/README.md` (+ optional `runtime/claude/scripts/` helpers) |
| Atom ID | ATOM-004H |
| Parent product | Recursive Product Framework v1 |
| Executor role | framework-architect |
| Input product(s) | `framework/ORCHESTRATION.md` (as accepted — its §Runtime-binding contract is your checklist); repo run.logs as observed practice; this INPUT |
| Consumer(s) | The human operating this runtime today; future runtime authors (the worked example); ATOM-005/006 |
| Maturity target | reviewed |
| Gates | none |
| Instantiation | session |
| Verification mode | independent (documentation; reversible; single-runtime blast radius) |
| Budget envelope | ~45k tokens |
| Recursion-depth allowance | 0 |

## 2. Job To Be Done
Bind the abstract contract to this runtime: a person (or headless caller) reading only this README can launch any launch-file correctly. Platform names are legal HERE and only here.

## 3. Context — Decisions Already Made
Document faithfully what practice has proven this week: session started in repo root; launch file attached with "Execute this launch file"; model selection per tier (map S/M/L to the concrete models available in this runtime, with the tier-L reservation for Formulate/Verify and the current flagship-quota caveat as a operational note); human questions surfaced via the session's question interface and recorded verbatim per HP3/DR rules; commit+push at closure per RB6; token counters: use the runtime's real counters where exposed (runtime-measured totals have appeared in run.logs), estimates `~` otherwise; headless invocation documented with its human-gate blocking behavior per the contract. Include the known operational pitfalls log: launch from repo root only; one launch file version in editor; save before send.

## 4. Deliverable
`runtime/claude/README.md`, ≤200 lines. Optional: minimal helper script(s) under `runtime/claude/scripts/` (e.g., hard-criteria grep/wc runner) — MAY, not MUST; do not build a framework.

## 5. Definition of Done
**Hard:** H1 file exists ≤200 lines. H2 covers every item of the ORCHESTRATION runtime-binding contract (checklist correspondence detectable). H3 does not modify any file under `framework/`. H4 `RESULT.md` + `STATUS.md` delivered; status.yaml updated.
**Soft (judge: Verify):** S1 a newcomer with this runtime installed can execute a launch file end-to-end using only this README. S2 no contradiction with ORCHESTRATION; the tier mapping is concrete and current. S3 honest about limitations (what the runtime does not yet enforce).
**Maturity target:** reviewed.

## 6. Method Hints (non-binding)
Write for the person, not the agent: this is the one document in the repo whose primary reader is a human operator.

## 7. Escalation
E1–E7. Gates: none. Budget hard stop per O6.2. Otherwise execute.

---
*End of launch file. Protocol first, binding second, human twice.*
