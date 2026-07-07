---
atom: ATOM-077
product: Intake protocol — mission-first onboarding conversation (§4.4 of ATOM-007 INPUT)
status: delivered
maturity_claimed: reviewed
cost:
  units_in: ~62k
  units_out: ~21k
  unit: tokens
  wall_time: ~40m
  executor: claude-fable-5
  sub_atoms_spawned: 0
---

# RESULT — ATOM-077

## Summary
The mission-first intake protocol is complete: an operator's conversation
guide (`INTAKE-GUIDE.md`) sequencing values → mission → perimeter →
derivation, a founder-facing `mission.md` template in RO (primary) + RU
(mirror), an operator-facing derivation method with a worked example and a
disguised-task-list test the method passes on itself, and a closed
field-test-lessons record quoting both delivered garden-test lessons
verbatim plus the GATE-018 closure. Both mission templates are zero-hit on
the jargon grep (DoD/atom/verify/INPUT/gate, RO+RU forms). The guide
implements the two closed field-test lessons (as-is inventory for
transformational tasks; TEAM-summary expectation set at intake), the
detail-level question (INFO-009, asked once, default 2), and register items
№10 (auto-escalation worked example, cost-plan section) and №17 (governance-
layer cost + economy-variant trade-off disclosed, operator-facing) from
`007-synth/SYNTHESIS.md`'s fix-priority register.

## Deliverables
| File | Purpose |
| :---- | :---- |
| `intake/INTAKE-GUIDE.md` | operator's conversation guide (RU): full flow, detail-level question, cost-plan + auto-escalation worked example, as-is inventory branch, TEAM-summary expectation line, machinery-hiding glossary, self-check |
| `intake/mission-template.ro.md` | founder-facing `mission.md` template, Romanian (primary) |
| `intake/mission-template.ru.md` | founder-facing `mission.md` template, Russian (mirror) |
| `intake/derivation.md` | operator-facing (RU): three-step derivation method, disguised-task-list test, worked example (Maria/handmade jewelry), self-check of the method against its own example |
| `intake/field-test-lessons.md` | both lessons quoted verbatim (INFO-006, INFO-007) + GATE-018 closure quote, and how each shaped the guide |

## DoD Self-Check
| Criterion | Result | Evidence |
| :---- | :---- | :---- |
| H1 | met | `ls intake/` → all 5 named files present at `077-intake-protocol/intake/` |
| H2 | met | `grep -inE '\b(DoD|atom|atoms|verify|verified|verification|input|gate|gates)\b\|атом\|атомы\|верифи\|инпут\|гейт' mission-template.ro.md mission-template.ru.md` → zero matches in both files (exit 1) |
| H3 | met | Point-by-point table below: both templates carry the same 4 sections in the same order, same fill-in structure, same 3-option detail-level block |
| H4 | met | `grep -n` in `INTAKE-GUIDE.md`: detail-level question at §2 (L51/56); cost-plan + auto-escalation worked example at §5.2 (L127/136, "~$40" cumulative figure); as-is inventory branch at §3 (L71–, "Сохранить/Изменить/Убрать"); TEAM-summary expectation line at §6 (L171, spoken commitment quoted verbatim in the guide) |
| H5 | met | `grep -F` of the exact verbatim substrings against `decisions/INFO-006-atom-007-intake-decisions.md`, `decisions/INFO-007-field-test-lesson-2-team-visibility.md`, `decisions/GATE-018-atom-007-synthesis-e8-gate.md` vs `intake/field-test-lessons.md` — all three quotes (lesson 1, lesson 2, closure) match the source records exactly, differing only by added quotation marks for readability |
| S1 | self-reviewed | `derivation.md` §2 gives the reverse-value test ("would this branch change if a different value were named?") plus a stronger double-check (delete `mission.md`, does the branch list still make sense on its own?); §4 applies both tests to its own §3 worked example and records the pass for each of the 3 branches — a disguised task list would fail the double-check (the list would keep making sense without the mission) — judge: Verify |
| S2 | self-reviewed | Both mission templates open with an explicit anti-checklist framing ("nu e un formular birocratic" / "это не анкета") and close with a plain reassurance that the document drives the work, not the other way around; sections use warm, first-person prompts with worked examples rather than bare labels — judge: Verify |

**Maturity target: reviewed. Not gold-plated** — the guide references `TIERS.ro/ru.md` and `team-summary-spec.md` rather than duplicating their content; the cost-plan passage (§5) is deliberately spoken-language, not a second copy of the tiers table.

## RO/RU point-by-point table (H3)

| Element | `mission-template.ro.md` | `mission-template.ru.md` |
| :---- | :---- | :---- |
| §1 — value-constraints, 2–4 fill-ins | "Ce contează pentru mine (limitele mele)" — 4 blank lines, worked examples "minimum de implicare zilnică" / "nu cedez 30%" | "Что для меня важно (мои границы)" — 4 blank lines, same two worked examples translated |
| §2 — mission without metrics | "Misiunea mea (fără cifre)" — free-text block, worked example (clients ordering without waiting for a personal reply) | "Моя миссия (без цифр)" — same structure, same example |
| §3 — red-line perimeter | "Ce nu accept niciodată (linia roșie)" — 2 blank lines, examples (nothing public without review; no price change without consent) | "Чего я не приемлю никогда (красная линия)" — same 2 blank lines, same two examples |
| §4 — detail-level, 3 checkboxes | "Cât de multe detalii vreau să văd pe parcurs" — 1/2/3, option 2 marked "(recomandat — alegerea implicită)" | "Сколько подробностей я хочу видеть по ходу дела" — 1/2/3, option 2 marked "(рекомендуется — выбор по умолчанию)" |
| Closing note | drives-not-driven framing, identical claim | same claim, translated |

## Decisions Made by Executor
1. **Cost figures in the guide are spoken as estimates, not facts.** `007-synth/SYNTHESIS.md` condition 1 (X4) blocks any dollar figure reaching a founder until the token rate is contracted and reconciled in writing; `ATOM-078` (the parallel fix-round) had not landed a confirmed rate at the time this atom ran. `INTAKE-GUIDE.md` §5.2/§5.4 therefore frames every dollar figure ("~$40" cumulative example) as an oral estimate with an explicit disclaimer line ("точная ставка ещё не зафиксирована письменно") rather than reusing `TIERS.ro/ru.md`'s current, uncaveated wording — satisfies condition 1's intent without waiting on or duplicating ATOM-078's fix.
2. **Auto-escalation worked example uses the decided cohort size (2 founders), not the 4-founder hypothetical in 074-F2's original finding.** GATE-018 (E8-2) fixed the pilot at 2 founders with primary-duty commitment; the register item №10 method (deliverables/week × weeks × founders, half escalate) is preserved, the input numbers are updated to the actual pilot shape, yielding ~32 deliverables → ~16 escalated → ~$40 (vs. the finding's illustrative $80 at 4 founders) — same method, correct cohort.
3. **Register item №17 (governance-layer cost + economy-variant trade-off) is placed as an operator-only subsection (§5.3), not spoken verbatim to the founder.** GATE-016/017 already resolved the underlying choice (full independent verify, not the cheaper self-verify variant, at successively raised envelopes) — nothing remains for the founder to decide; disclosure is satisfied by making the operator aware of the trade-off and giving one honest, short line the operator may say if asked ("настройка бесплатна для вас, мы вкладываемся сами"), plus the commitment to publish real cost after the first pilot closes.
4. **Detail-level question wording follows INFO-009 verbatim options** (1 / 2 default / 3), asked once at the end of the values-mission-perimeter sequence (not at the very start, where a founder has no context yet to judge how much detail they want) — recorded directly on the mission template (§4) rather than a separate profile file, since the template is already the founder's own artifact and travels with them.
5. **`field-test-lessons.md` quotes GATE-018's two sad-verdict lines** (the confused first pass and the plain-language-reformulated second pass) rather than only the reformulated one — preserves the HP7 lesson (plain-language reformulation was necessary) as part of the closure evidence, matching the DoD's "closure decision" requirement literally.
6. **No sixth deliverable file was created for the detail-level question separately** — INFO-009's "founder profile records it" is satisfied by §4 of the mission template itself (the founder's own document), avoiding a redundant profile artifact that duplicates data already living in `mission.md`.

## Deviations & Known Limitations
- The $/token rate underlying every dollar figure in §5.2 remains an unconfirmed placeholder as of this atom's closure (ATOM-078 fix-round had not landed a written contracted rate). This atom does not fix the rate — out of its named deliverable scope — it only ensures no figure in its own artifacts is spoken as certain (Decision 1 above). Once ATOM-078 lands a real rate, `INTAKE-GUIDE.md` §5.2's "~$40" example should be recomputed with the confirmed number; the method and cohort size do not need to change.
- `INTAKE-GUIDE.md` references `TIERS.ro/ru.md` for the tier-cost detail rather than reproducing it; if ATOM-078 changes `TIERS.ro/ru.md`'s wording (per register item №1, TIERS currently overclaims "măsurate direct... nu sunt cifre de marketing"), no update to this guide is required — it never quoted that claim.
- This is the first live exercise of the mission-first derivation method (`derivation.md`) against a worked example; it has not yet been run against a real founder in this repository's records. The self-check (§4 of `derivation.md`) is a construction-time check, not a field validation.

## Handoff
Verification mode: independent (slim VP20). Verify receives: DoD
(`INPUT.md` §5) + the 5 deliverable files under `intake/` + this
`RESULT.md` + `STATUS.md`. H1–H5 are script-checkable (`ls`, `grep -inE`,
`grep -F` against the three named decision records) — no judgment rests on
digested text for the hard criteria; S1/S2 are the only judgment calls,
both pointed at specific, named passages above.
