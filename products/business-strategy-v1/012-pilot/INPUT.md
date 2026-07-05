---
atom: ATOM-012
product: Pilot design — Flow Support v0 (products/business-strategy-v1/pilot/pilot-design.md)
parent: RPF Business Strategy v1 (ATOM-006)
formulated_by: ATOM-006 orchestrator (formulating-agent duties per LP5), 2026-07-05
verification: self
maturity_target: draft
instantiation: subagent
model_tier: M — operational design against accepted §3.4 inputs + INFO-001 (executed inline at session tier L; upward substitution logged)
budget: ~7k tokens
recursion_allowance: 0
---

# ATOM-012 — Input Specification

## 1. Product Identity
| Field | Value |
| :---- | :---- |
| Product | `products/business-strategy-v1/pilot/pilot-design.md` |
| Atom ID | ATOM-012 |
| Parent product | RPF Business Strategy v1 |
| Executor role | venture-strategist (roles/venture-strategist.md — F2 satisfied) |
| Input product(s) | ATOM-006 INPUT §3.4 (pilot mode, telemetry scope, Flow Support v0, SLA, ATOM-007 boundary), §3.2 (repo separation), §3.9; `decisions/INFO-001-pilot-terms-startup-moldova.md` (exchange + red lines); `pricing/pricing-ladder.md` (assumptions the pilot must convert to data); `channels/channel-comparison.md` (capacity kill trigger, bank-bridge role) |
| Consumer(s) | ATOM-013 (metrics), ATOM-015 (Pilot section); future ATOM-007 (prerequisites — reference only) |
| Maturity target | draft |
| Gates | none (G2 covers final assembly; pilot terms already human-fixed by INFO-001) |
| Instantiation | subagent |
| Verification mode | self — internal analysis per parent INPUT §4 authorization; risk low: draft, human at G2, terms already human-decided |
| Budget envelope | ~7k tokens |
| Recursion-depth allowance | 0 |

## 2. Job To Be Done
Turn the accepted pilot inputs into an executable pilot design: framing, exchange terms with red lines, measurable success criteria that convert the strategy's marked assumptions into data, the telemetry consent text, SLA and operating cadence, timeline, and exit conditions — referencing ATOM-007 for prerequisites without building them.

## 3. Context — Decisions Already Made (formalize, do not reopen)
§3.4 verbatim: partner Startup Moldova (verbal agreement — a couple of startups incl. non-technical founders). Mode: self-hosted (their machine, their own runtime subscription, their private repo per §3.2 repo separation) + our collaborator access + selective telemetry push — operational files only: STATUS, RESULT cost blocks, run.log, status.yaml, verdicts; no business content; open script; explicit consent; deletable after pilot, date fixed. Flow Support v0: observation is a service, not a payment — daily owner review (deliberately daily), sentinel atoms draft interventions, human approves/sends; SLA "reaction to blocked within one business day"; human-hours measured as future tier unit-economics. Prerequisites owned by future ATOM-007 (setup script, execution tiers) — reference, do not build.
INFO-001 (human-decided): exchange = public case study + 2–3 introductions (banks/funds/follow-on accelerators). Red lines — NOT promised to founders: no turnkey production code, no investment guarantees, no exclusivity, no team hiring. Equity frozen.
H9 discipline: runtime referenced by path (`runtime/claude/README.md`), no bare platform names in prose.

## 4. Deliverable
`products/business-strategy-v1/pilot/pilot-design.md` — sections: Framing; Exchange & red lines; Success criteria (measurable, mapped to the strategy assumptions they test); Telemetry & consent (the consent text itself); Operating cadence & SLA; Timeline; Exit. English per HP2; note that founder-facing consent script ships RO/RU at ATOM-007 setup.

## 5. Definition of Done
**Hard criteria:**
- H1. File exists at the path above. Check: `ls`.
- H2. All seven §4 sections present as headings. Check: grep.
- H3. Consent text names exactly the §3.4 operational-file scope (STATUS, RESULT cost blocks, run.log, status.yaml, verdicts) and contains: no-business-content, open script, explicit consent, deletion date. Check: grep each element.
- H4. All four INFO-001 red lines present. Check: grep.
- H5. SLA "within one business day" present. Check: grep.
- H6. ≥4 success criteria each with a number and a measurement instrument, mapped to a named strategy assumption. Check: grep criterion rows.
- H7. ATOM-007 referenced as prerequisite owner; nothing prerequisite-shaped built here. Check: grep `ATOM-007`.
- H8. Quantitative claims sourced or marked; zero bare platform names (path citations excluded). Check: grep.

**Soft criteria:**
- S1. The consent text could be handed to a founder as-is (translated) without a lawyer flinching or a founder misreading scope — judge: executor self-review; human sees it at G2.

**Maturity target:** draft. Do not gold-plate.

## 6. Method Hints (non-binding)
The success criteria are the pricing/channels sensitivity tables turned into instruments: WTP, cycles/month, tier mix, owner minutes/day, capacity ≥6 founders. Timeline: one accelerator cohort rhythm.

## 7. Escalation
E1–E7 per ATOM-SPEC §5.7. Terms are human-fixed (INFO-001) — changing them is E3, not executor discretion. Otherwise execute.
