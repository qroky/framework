# TEAM-summary spec — rendered at every parent-atom closure

**Atom:** ATOM-072 · **Date:** 2026-07-07
**Source:** INFO-007(b) — garden-test lesson 2 ("the invisible team blurs
the value — the CEO lived through a project without seeing which roles
worked, through which perspectives, and where they disagreed"). This
document names, section by section, which repo records `showcase/render.sh`
reads to answer that lesson, and the plain-language style every section
must keep.

## Section → source fields

| # | Section | What it answers | Source fields |
| :- | :---- | :---- | :---- |
| 1 | **Who worked on this, and what they did** | roles + one-line contribution each | for the atom + every subtree member: role from `workspace/run.log`'s `CYCLE-START ... as <role>` line; contribution from `RESULT.md`'s `## Summary` first sentence; the independent-check row from the sibling `<atom-id>-verify/VERDICT.md` (`round`, `verdict`, `returns_used`); the human row derived from the product's `status.yaml` closure note (distilled to plain language — see rule 3 below, never quoted raw) |
| 2 | **Which perspectives looked at this** | the lens map | the atom's own `INPUT.md`, `**Fan decision:**` line (PM1–PM6 perspective-map section, ORCHESTRATION §8.2 template) |
| 3 | **Where perspectives disagreed, and how it was settled** | synthesis conflicts with outcomes | `SYNTHESIS.md` (REPO-STRUCTURE NC7 reserved filename) when a lens fan actually ran and closed; otherwise the section states plainly that no fan has run — see rule 2 below |
| 4 | **Independent check, in full** | verify returns | the sibling `<atom-id>-verify/VERDICT.md` frontmatter (`round`, `verdict`, `returns_used`) — a return means the checker sent work back once for a named fix; zero means first-read acceptance |

For a **parent** atom with a real subtree (`total_descendants` > 0),
sections 1 and 4 repeat per descendant, and section 3 reads the actual
`SYNTHESIS.md`; `render.sh`'s current build renders the single-atom case in
full and stubs the multi-descendant walk with a clear comment (see
`render.sh`'s `PART 2` — the branch keyed on `n_agents == 0`), because no
atom with a closed real subtree exists yet in this repo's named data
sources (see rule 2).

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

## Provenance
| Event | Atom | Date |
| :---- | :---- | :---- |
| Created | ATOM-072 | 2026-07-07 |
