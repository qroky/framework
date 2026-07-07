# TEAM-summary spec — rendered at every parent-atom closure

**Atom:** ATOM-072 · **Date:** 2026-07-07 · **Fix-round:** ATOM-078
(register #8, #20) — 2026-07-07
**Source:** INFO-007(b) — garden-test lesson 2 ("the invisible team blurs
the value — the CEO lived through a project without seeing which roles
worked, through which perspectives, and where they disagreed"). This
document names, section by section, which repo records `showcase/render.sh`
reads to answer that lesson, and the plain-language style every section
must keep.

## Two variants: local vs external (register #8 — GATE-018 E8-1 wiring)

GATE-018 answered E8-1 verbatim: **"Opt-in в consent (Recommended)"** — the
TEAM summary is local-only by default; a founder may separately opt in, via
one explicit consent item ("одну простую фразу о построенном можно
показывать Startup Moldova"), to let one plain content sentence cross the
perimeter. `render.sh` implements this as two distinct render functions,
not a single output with a redaction pass — the safer design, since a
missing redaction step fails open while a missing opt-in file fails closed:

- **Local (`render.sh <repo-root> <atom-id>`, the default)** — full detail,
  as originally specified below: `## Who worked`, `## Which perspectives
  looked at this` (reads `INPUT.md`), `## Where perspectives disagreed`,
  `## Independent check, in full`. Never leaves the founder's own machine;
  no opt-in gate applies to it, because nothing about it crosses the
  perimeter.
- **External (`render.sh --external <repo-root> <atom-id>`)** — the only
  variant a real cross-perimeter path may ever read from. Two hard rules,
  both enforced in code, not just documented: (1) it **never opens
  `INPUT.md`** — no fan-decision line, ever, in this variant, satisfying
  the register's own text verbatim ("no INPUT.md reads in the
  perimeter-crossing path"); (2) the one content sentence (`## What was
  built`, sourced from `RESULT.md`'s own `## Summary`) is included **only**
  when a marker file, `consent/TEAM-CONTENT-OPTIN`, is present next to the
  rendered atom's repo root — the same marker `telemetry/push.sh` checks
  before including a `work_unit` field (register #11, same opt-in). Absent
  that marker, the external variant shows roles and check counts only.

## Section → source fields

| # | Section | What it answers | Source fields |
| :- | :---- | :---- | :---- |
| 1 | **Who worked on this, and what they did** | roles + one-line contribution each | for the atom + every subtree member: role from `workspace/run.log`'s `CYCLE-START ... as <role>` line; contribution from `RESULT.md`'s `## Summary` first sentence; the independent-check row from the sibling `<atom-id>-verify/VERDICT.md` (`round`, `verdict`, `returns_used`); the human row derived from the product's `status.yaml` closure note (distilled to plain language — see rule 3 below, never quoted raw) |
| 2 | **Which perspectives looked at this** | the lens map | the atom's own `INPUT.md`, `**Fan decision:**` line (PM1–PM6 perspective-map section, ORCHESTRATION §8.2 template) |
| 3 | **Where perspectives disagreed, and how it was settled** | synthesis conflicts with outcomes | `SYNTHESIS.md` (REPO-STRUCTURE NC7 reserved filename) when a lens fan actually ran and closed; otherwise the section states plainly that no fan has run — see rule 2 below |
| 4 | **Independent check, in full** | verify returns | the sibling `<atom-id>-verify/VERDICT.md` frontmatter (`round`, `verdict`, `returns_used`) — a return means the checker sent work back once for a named fix; zero means first-read acceptance |

For a **parent** atom with a real subtree, section 3 now reads the actual
`SYNTHESIS.md` when one exists (register #20 — was previously a stub that
only printed "this branch is not implemented"). `render.sh` looks for a
`SYNTHESIS.md` anywhere one level under the product folder whose own
frontmatter names this atom as `parent:` (or, for a synthesis atom
rendering itself, `synthesis_atom:`); when found, it reads the `##
Positions` table for the per-lens one-line claims and counts the `###
X<n>` contradiction headings and the `→ **E8-<n>**` value-gate markers for
the disagreement summary. **Fallback, honored exactly as the register asks:**
when no `SYNTHESIS.md` is found, the section prints the plain, honest
"no fan has run yet" sentence unchanged from before — it never crashes and
never fabricates a synthesis that does not exist. The worked example that
proves this branch is real is `ATOM-007-SYNTH` itself (`example-debrief.md`
— the closure-debrief render, `narrative-spec.md`), read against its own
`SYNTHESIS.md` and its four lens verdicts (`073`–`076`); per RESULT.md's own
handoff note, this is also the branch that **must be working before the
parent's (`ATOM-007`'s) own first live closure render** — it now is.

## Plain-language style rules (no method jargon reaches a founder)

1. **Substitution glossary** — every section, table header, and sentence a
   founder reads uses the plain word, never the method word:

   | Method word | Founder-facing word |
   | :---- | :---- |
   | atom | task |
   | Verify / verify atom | independent check |
   | RESULT.md | report |
   | STATUS.md | progress log |
   | VERDICT.md | check result |
   | gate | decision point |
   | DoD | checklist |
   | round (of verify) | pass |
   | return (verify return) | fix-round |

2. **No fan yet is said plainly, not hidden.** When `total_descendants` is
   0 (pre-fan atom — the ordinary case everywhere in this repo today, since
   the pilot's own atom fan is the framework's first real one), section 3
   renders exactly the Method-Hints-sanctioned sentence: *«конфликтов не
   было — веер ещё не запускался»* (there were no conflicts — the fan
   hasn't run yet), followed by one plain-English sentence restating why.
   This is an honest state, not a placeholder to be embarrassed about.
3. **Never echo a raw closure note.** `status.yaml` notes are written for
   the framework's own audit trail and are dense with rule ids (gate
   numbers, criterion ids). `render.sh` never copies that note verbatim
   into a founder-facing row; it derives one plain sentence from it (e.g.
   *"Reviewed the finished work and said **go** — approved it."*) and
   discards the rest. The raw note stays in `status.yaml`, available to
   anyone who wants the audit trail, never forced on a founder.
4. **One line per contribution.** Section 1's contribution cell is the
   `## Summary`'s first sentence only (split on the first `.`) — not the
   whole paragraph. A founder reads a table, not a report.
5. **Distill the fan-decision line too, not just the closure note** (register
   #14 — ATOM-072-VERIFY's S2 found `render.sh` copying `INPUT.md`'s
   `**Fan decision:**` line verbatim, including a bare rule-id like "per
   PM4"). Rule 3 above already forbids this for the human-decision row;
   the same discipline now applies to section 2 — `render.sh` maps the raw
   line to one of a small set of plain sentences ("This task was done by
   one perspective alone…" / "…reviewed by several perspectives on
   purpose…") and never prints a rule-id.

## Provenance
| Event | Atom | Date |
| :---- | :---- | :---- |
| Created | ATOM-072 | 2026-07-07 |
| Amended — external/local split (register #8, GATE-018 E8-1), real multi-descendant branch (register #20), fan-decision distillation rule (register #14) | ATOM-078 | 2026-07-07 |
