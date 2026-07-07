# Narrative spec — the run narrative (spawn brief + closure debrief)

**Atom:** ATOM-078 · **Date:** 2026-07-07
**Source:** INFO-009 — field-test lesson 5, "prозрачность прогона" (run
transparency), recorded verbatim in
`decisions/INFO-009-field-test-lesson-5-run-transparency.md`. This document
is the third showcase spec, sibling to `cost-line-spec.md` and
`team-summary-spec.md`: the showcase is now **three artifact classes** —
cost line, TEAM summary, and run narrative. Same discipline as its two
siblings: names, section by section, which repo records `showcase/render.sh`
reads, and the plain-language style every section must keep.

## Why this exists (INFO-009, verbatim intent)

> нарратив прогона: родитель при спавне детей объявляет brief по-человечески
> (сколько ролей нужно, какие переиспользованы/созданы и зачем, план, ETA),
> при закрытии — debrief (кто что принёс, где спорили и как решил синтез,
> возвраты verify, итог, стоимость); язык смысла, не механики (никакого
> bash-уровня); рендер из status.yaml/вердиктов/subtree-данных, бюджет
> нарратива ≤5% subtree_cost.

Two moments, two formats, both **rendered from existing records** — never a
live prediction, never hand-written per-atom:

## 1. Spawn brief — `render.sh --spawn-brief <repo-root> <atom-id>`

Written when a task opens its next round of work (spawns children), from
the plan already on record.

| Section | What it answers | Source fields |
| :- | :---- | :---- |
| What is starting, and why | the shape of the round about to run | the atom's own decomposition plan (`PLAN.md`) — whether it names a perspective/lens fan |
| How many, and where they came from | headcount, reused vs. new | count of data rows in `PLAN.md`'s `## Perspective map` table (own atom's folder first, else the nearest `PLAN.md` under the product tree) |
| What happens next | the process shape, in plain words | fixed text describing the fan → synthesis → human-escalation pattern; not atom-specific data |

**Style:** meaning-language only — no atom ids, no tier letters, no budget
numbers, no gate names. "Several perspectives are being brought in to look
at the same question together" — never "a PM6-triggered fan opens with 4
lens atoms at tier M."

**Honesty fallback:** if no `PLAN.md` is found under the product tree, the
brief says so plainly ("no plan record found — cannot render a spawn
brief") instead of guessing or fabricating a headcount.

## 2. Closure debrief — `render.sh --debrief <repo-root> <atom-id>`

Written when a team review closes, from records that already exist —
nothing here is re-litigated or re-judged by the render.

| Section | What it answers | Source fields |
| :- | :---- | :---- |
| The question this team was asked | the shared question every perspective answered | `SYNTHESIS.md` frontmatter `question:` |
| Who contributed, and what each one found | one line per perspective, its own claim | `SYNTHESIS.md`'s `## Positions` table (lens name + bolded claim word — "Yes-with-conditions.", "NO —…") |
| Where they argued, and how it was settled | disagreement count + resolution shape | count of `### X<n>` contradiction headings; count of `→ **E8-<n>**` value-gate markers (unresolved-by-fact-checking disagreements that needed a person) |
| What the person decided | the human's actual answer, plain | the gate decision record (e.g. `decisions/GATE-*.md`) — distilled: gate-id and markdown bolding stripped, the human-readable parenthetical question kept, the verbatim quoted answer kept |
| What came out of it | the concrete output | fixed text (a written, prioritized fix list) |
| What it cost | the honest total | sum of `status.yaml` "real" counters across every named contributor + the debrief atom itself |

**Piercing events (INFO-009):** constitutional events — E4 raises, a value
synthesis conflict (an `E8-*` gate), E5 — are never summarized away at any
detail level; they are named explicitly in "Where they argued" and answered
in full in "What the person decided", regardless of which detail level a
human has chosen (see §3 below).

**Honesty fallback:** if no `SYNTHESIS.md` is found for the given atom, the
debrief says plainly that there is nothing to debrief yet — it never invents
a synthesis, and it never crashes.

**Worked example (H5):** `example-debrief.md`, rendered against
`ATOM-007-SYNTH` — this fix-round's own originating fan (`073`–`076`) and its
synthesis. Per INFO-009's own application note, "the fan and its synthesis
are the perfect story" — it is real data already committed to this repo:
four lens verdicts, eight named contradictions, two value gates routed to
the human, and `GATE-018`'s recorded answers.

## 3. Detail levels (INFO-009 §2)

A human-profile setting, not a per-render flag this spec computes:

| Level | Meaning |
| :- | :---- |
| 1 | result + necessary questions only |
| 2 | broad strokes per stage (**default**) |
| 3 | detailed |

Set once at onboarding (ATOM-077 intake — outside this atom's own artifact
scope; noted here for the spec's completeness only); switchable on the fly
by plain words, and by a one-off per-task override. Level changes are
logged in `~/.claude/qroky/delegation.log` as a trust-curve signal — that
logging is a runtime/orchestration behavior, not something `render.sh`
itself performs (`render.sh` only produces the two artifact kinds above; it
does not read or write a human's detail-level preference). Ghenadie's own
profile (`roles/humans/ghenadie.md`) already records level 2, per INFO-009's
direct amendment — referenced here, not re-declared.

Both render functions in this spec currently produce level-2-shaped output
(broad strokes per stage) — that is what "meaning-language, no mechanics"
above already describes. Level 1 (result-only) and level 3 (detailed) are
named here as the constitutional shape or a level-aware `render.sh` should
grow into next; this fix-round does not implement per-level branching in
the render functions themselves (out of the register's named scope — no
register item asks for it), only the level-2 default.

## 4. Narrative budget rule (INFO-009: ≤5% of subtree_cost)

Both render functions are **rule-compliant by construction, not by
counting their own tokens**: they read a small, fixed set of existing
records (a `PLAN.md` table, a `SYNTHESIS.md` header + two counted marker
patterns, one gate file, and a handful of `status.yaml` lines) and emit a
short, fixed-shape document — there is no branch in either function that
could grow proportionally with the size of the reviewed work. The rule is
stated here as a design constraint the render functions are built to honor
(short output, no re-reading of full source documents like `LENS-VERDICT.md`
bodies or `SYNTHESIS.md`'s full contradiction prose), not as a runtime
check `render.sh` performs on itself.

## Provenance
| Event | Atom | Date |
| :---- | :---- | :---- |
| Created (INFO-009 — showcase grows a third artifact class) | ATOM-078 | 2026-07-07 |
