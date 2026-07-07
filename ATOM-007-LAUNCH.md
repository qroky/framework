# LAUNCH — ATOM-007 (Pilot Prerequisites: Flow Support v0 onboarding)

> Runtime instruction for this session. Execute **one orchestrating atom** per the
> five framework documents (`framework/ATOM-SPEC.md`, `framework/FEV-PROTOCOL.md`,
> `framework/REPO-STRUCTURE.md`, `framework/ORCHESTRATION.md`,
> `framework/SYNTHESIS-PROTOCOL.md` — read them first) and the binding
> (`runtime/claude/README.md`).
> ATOM-007 is a PARENT atom — it authors the decomposition plan WITH a perspective
> map (PM1–PM6; the lens list in §3.2 below is its input, not its invention),
> formulates, launches, verifies, synthesizes and closes its own sub-atoms per
> F1–F6, the ORCHESTRATION rules, and the SYNTHESIS-PROTOCOL fan rules. All three
> PM6 fan triggers hold for this product (OD1 plan; maturity `reviewed`; crosses
> the perimeter) — the fan is mandatory: this is the framework's **first real lens
> fan**, the validation path of SYNTHESIS-PROTOCOL (`reviewed` → `validated` per M3
> on successful consumption; record it in RESULT).
> Step 0 — materialize the INPUT below into
> `products/pilot-prerequisites-v1/007-pilot-prerequisites/` per LP3 (`INPUT.md`
> verbatim; `STATUS.md` at `formulated`; `products/pilot-prerequisites-v1/status.yaml`
> per SM3).
> **Gate G1 comes before any execution:** author the decomposition plan + perspective
> map, then deliver the G1 brief to the human (Russian, plain language — see the
> GATE-011 S5 lesson: restate criteria in human terms) and WAIT for go. After go:
> execute per plan; blind Verify per FEV-PROTOCOL for every mode ≥ independent;
> synthesis act per SYNTHESIS-PROTOCOL §3; G2 before anything founder-facing is
> final; close per L7/RB6 with semantic fold-back evidence (FB4). Update status.yaml
> at every transition. Atoms of this tree SHOULD carry the INFO-005/D7 transitive
> subtree fields in RESULT frontmatter voluntarily (T1 extension; the MUST arrives
> with the constitutional touch) — the showcase cost line (§3.3) depends on them.
> Spawn justification (formulator): pilot cannot start without these prerequisites
> (TASKS 1.1 critical path); multi-deliverable product with mandatory fan (LP6).

---
---
atom: ATOM-007
product: Pilot Prerequisites v1 (products/pilot-prerequisites-v1/ tree)
parent: RPF venture (pilot critical path; strategy per products/business-strategy-v1/STRATEGY.md)
formulated_by: Human (Ghenadie — INFO-006) + formulating agent (launch session), 2026-07-07
verification: independent + human (founder-facing artifacts cross the perimeter)
maturity_target: reviewed
instantiation: session (orchestrator); children per ORCHESTRATION + SYNTHESIS-PROTOCOL defaults
model_tier: L for this orchestrator, all Formulate, all Verify, and the synthesis act (MT3, LF4); lens/execute atoms M or S per MT2 with logged justification
budget: ~350k tokens total envelope, cascaded per O6.1/EC/PM5/LF3. Executor envelopes sized ×3.5+40k for writing-heavy atoms (GATE-011 precedent), not the EC1 floor. Hard stop per O6.2.
recursion_allowance: 2
---

# ATOM-007 — Input Specification

## 1. Product Identity
| Field | Value |
| :---- | :---- |
| Product | `products/pilot-prerequisites-v1/` tree — deliverables per §4 |
| Atom ID | ATOM-007 |
| Parent product | RPF venture |
| Executor role | venture-strategist (exists — chair of the fan per SY3); lens roles created on demand per F2 |
| Input product(s) | This INPUT; `products/business-strategy-v1/pilot/pilot-design.md` (consent master text, success criteria, telemetry scope); `products/business-strategy-v1/STRATEGY.md`; `decisions/INFO-001` (exchange + red lines), `INFO-005` (subtree accounting), `INFO-006` (this atom's accepted decisions); `knowledge/precedent/` (all); `runtime/claude/README.md` |
| Consumer(s) | Pilot founders + Startup Moldova (setup, consent, telemetry — perimeter); the pilot operator (Flow Support tooling, intake protocol); pricing re-anchor at pilot exit (cost data); SYNTHESIS-PROTOCOL validation record |
| Maturity target | reviewed |
| Gates | **G1 — decomposition plan + perspective map to the human (go / no-go / pivot) BEFORE any execution** (F4 a+b; INFO-006: «План — мне на го до исполнения»); **G2 — before founder-facing artifacts are final** (perimeter, F4 c). Briefs in Russian, plain language (HP2 + GATE-011 lesson). Trigger gates implicit |
| Instantiation | session |
| Verification mode | independent + human |
| Budget envelope | ~350k tokens |
| Recursion-depth allowance | 2 |

## 2. Job To Be Done

Everything needed so that a non-technical founder who said "yes" is running their
first atom within 15 minutes, safely, with honest expectations — and so that the
pilot produces the measurements the strategy needs (pilot-design criteria 1–6).
Deliver the onboarding path (mission-first intake), the self-hosted setup, the
execution tiers, the open telemetry with consent, and the cost-line showcase —
the pilot's selling artifact.

## 3. Context — Decisions Already Made (formalize, do not reopen)

### 3.1 Mission-first intake (INFO-006 P1)
Intake starts with values and mission, not tasks. The onboarding conversation's
**first product is the founder's `mission.md`**: value-constraints («минимум
ухода», «не отдам 30% equity»), a mission without metrics, a perimeter of the
unacceptable. Goals and the first product branches are **derived** from it. The
founder sees a conversation — never the machinery: DoD, atoms, verify run inside
and are neither shown nor explained to the founder.

### 3.2 Starting lenses for the fan (INFO-006 P2 — the map receives input, it does not invent)
1. **Non-technical founder UX** — every founder-facing artifact judged as product UX;
2. **Token economics** — real cost of the founder-month, tier discipline, envelope defaults;
3. **Security + telemetry** — whitelist boundary, consent integrity, open script;
4. **Owner operational capacity** — Flow Support at ≥2 concurrent founders within the SLA (pilot-design criteria 3–4).

The perspective map (PM1–PM6) is built over these four; adding or merging lenses
requires the PM5/O5.1 logged justification. Same question for the fan: *"do these
prerequisites let the pilot start and be measured safely?"* — each lens answers it
over the same deliverables.

### 3.3 Cost-line showcase (INFO-006 P3)
From day one, every founder-facing reply and the telemetry stream carry the
summary line: **«⚙ N агентов · M ролей · глубина D · возвратов verify R · $X»**,
sourced from the INFO-005/D7 transitive subtree accounting (total_descendants,
max_depth_reached, subtree_cost with execute/verify/role-creation/synthesis
breakdown). The cost line is a **selling artifact** — Startup Moldova must see it
from day one. Deliverable: the line's spec + its generation wired into the
telemetry script and the founder-reply convention.

### 3.4 Intake atom last + field-test reservation (INFO-006 P4)
The intake-protocol atom is **last in dependency order**. Its `INPUT.md` reserves
a section **«Уроки полевого теста»**: a live garden-test of the copilot pattern
(fuzzy request → expected result first → elaboration) is running; the CEO verdict
with findings lands within 1–2 days of 2026-07-07. One finding is already
accepted: **as-is inventory is mandatory for transformational tasks** — an
inventory of the existing plus an explicit preserve/change/remove list BEFORE
designing the to-be. If the verdict has not arrived when the intake atom is
reached: that atom waits on E1; the rest of the tree does not block.

### 3.5 Setup minimum (INFO-006 P5)
From «фаундер сказал да» to the first running atom: **≤15 minutes, zero technical
questions**. Self-hosted per accepted §3.2/§3.4 of the strategy inputs: their
machine, their runtime subscription, their private repo with the constitution as
a dependency. Telemetry: whitelist of operational files only (STATUS, RESULT cost
blocks, run.log, status.yaml, verdicts — pilot-design closed list) pushed to
`qroky/pilot-telemetry`; the push script is **open** (founder can read every
line); deactivatable, with a fixed deletion date (pilot-design consent text is
the master — do not re-draft its substance).

### 3.6 Exchange, red lines, cadence (accepted — reference, do not reopen)
INFO-001: case study + 2–3 intros; red lines — no turnkey production code, no
investment guarantees, no exclusivity, no team hiring. Flow Support v0: daily
owner review, sentinel atoms draft, human approves every intervention, SLA
«reaction to blocked within one business day». Execution tiers to deliver:
inline / micro / full (per §3.4 of the strategy inputs).

### 3.7 Naming
Rebrand «RPF» → Qroky is pending (TASKS decision 2.1). Founder-facing artifacts
use the working name **Qroky** where a name is unavoidable (the telemetry repo is
already `qroky/pilot-telemetry` — INFO-006); keep every mention sed-replaceable
and flag any hard-to-swap occurrence in RESULT.

## 4. Deliverable

The tree under `products/pilot-prerequisites-v1/` — exact decomposition is the
plan's job (G1), but the product set is fixed:
1. **Setup kit** — script + founder-facing quickstart meeting §3.5 (≤15 min, zero
   technical questions), incl. private-repo bootstrap with the constitution as a
   dependency (repo separation per accepted §3.2).
2. **Execution tiers** — inline / micro / full: what each is, when each applies,
   founder-visible behavior.
3. **Telemetry** — open push script + whitelist enforcement + consent flow
   (RO/RU renders of the pilot-design master text) + deletion mechanics with date.
4. **Intake protocol** — the mission-first onboarding conversation product
   (§3.1): conversation guide, `mission.md` template, derivation of goals/branches,
   machinery-hiding rules; reserved field-test section (§3.4).
5. **Cost-line showcase** — spec + generation wired into telemetry and
   founder-reply convention (§3.3).

## 5. Definition of Done

**Hard criteria (machine-checkable):**
- H1. Every §4 deliverable exists at the paths the decomposition plan names; the
  plan carries the perspective map with the four §3.2 lenses and the OD4 budget
  arithmetic. Check: file presence; map section present in plan.
- H2. A timed dry run of the setup kit on a clean machine profile is scripted and
  its transcript recorded: «yes» → first atom ≤ 15 min, zero technical questions
  asked of the founder. Check: transcript in the setup atom's workspace/RESULT.
- H3. The telemetry script contains an explicit whitelist equal to the
  pilot-design closed list; a negative test proves a non-whitelisted file is not
  pushed. Check: script inspection + test output.
- H4. Consent renders exist in RO and RU, substance-identical to the pilot-design
  master (EN); deletion date is a fill-in field, not prose. Check: files + diff of
  substance points (the 4 red lines, deletion clause, open-script clause present
  in both).
- H5. The cost-line spec derives every element (N, M, D, R, $X) from named
  RESULT/status fields (INFO-005 scheme); a worked example is generated from this
  repository's real data. Check: spec + example output.
- H6. `SYNTHESIS.md` of the fan exists per SYNTHESIS-PROTOCOL §6.2 with SY9
  per-lens coverage and every X-contradiction classified; the parent's RESULT
  carries FB4 fold-back evidence and the D7 subtree fields. Check: file presence +
  section grep.

**Soft criteria (judgment — judge named per criterion):**
- S1. A non-technical founder can complete setup and intake without ever meeting
  the words DoD, atom, verify — machinery fully hidden (§3.1) — judge: Verify
  agent (UX lens verdict as input).
- S2. The intake guide genuinely derives goals from `mission.md` values rather
  than collecting a task list — judge: Verify agent.
- S3. The cost line is honest (no flattering rounding; governance overhead visible
  per the D7 type breakdown) — judge: Verify agent.
- S4. The four §3.2 lenses produced at least one named contradiction each or a
  specific SY9 concurrence — no smoothed consensus — judge: Verify agent.
- S5. «Я бы подписал это как фаундер»: consent + expectations + setup read as
  honest and effortless from the founder's chair — judge: human (at G2).

**Maturity target:** reviewed. Do not gold-plate.

## 6. Method Hints (non-binding)

- Sequence sketch (the plan decides): setup/tiers/telemetry lens-fanned early;
  cost-line spec after telemetry; intake protocol **last** (§3.4); synthesis act
  before G2.
- The fan's lens atoms examine the same question over the same deliverables (LF2)
  — they are reviews-with-optics, not four separate builders; keep them S/M tier.
- Reuse pilot-design.md text verbatim where it is already accepted (consent
  master, SLA, criteria) — formalize, do not re-draft.
- The garden-test finding (as-is inventory, §3.4) applies to the intake guide's
  handling of a founder's *existing* project — transformational vs greenfield
  paths differ.
- Real counters at every closure (EC6); this tree's cost data feeds pricing
  re-anchor at pilot exit — measure like it matters.

## 7. Escalation

Stop and escalate (one consolidated question set) on triggers E1–E7 of ATOM-SPEC
§5.7 and E8 of SYNTHESIS-PROTOCOL SY8. Gates placed: G1 (plan + map → human, before
execution), G2 (before founder-facing final). Known waits: field-test verdict for
the intake atom (§3.4 — E1 hold on that atom only). Otherwise: do not ask for
permission on the normal path. Execute.

---
*End of launch file. Formulated 2026-07-07 from ATOM-006 §3.4, pilot-design.md,
INFO-001, INFO-005 and the CEO decisions recorded verbatim in INFO-006.*
