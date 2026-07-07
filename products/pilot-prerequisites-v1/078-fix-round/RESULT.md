# RESULT — ATOM-078 (fix-round)

**Executor:** pilot-toolsmith · **Source of work order:** `007-synth/SYNTHESIS.md` §Fix-priority register (INPUT.md §3 is a summary only, per instruction) · **Gates consulted:** GATE-018 (E8-1/E8-2 answers), INFO-009 (narrative-spec requirement)

**Verdict: all 5 Hard DoD criteria (H1-H5) PASS.** See §H-checks below for literal commands and outputs.

---

## H1 — coverage table (every «исполнитель» row mapped to a change)

22 register rows total. 20 addressed directly in this fix-round's own edits. 2 sub-items (parts of #10 and #17) name artifacts outside this atom's obligations (071/072 artifact folders + `078-fix-round/` itself) and belong to ATOM-077's own tree, which delivered mid-session in parallel (PLAN.md Addendum 2, Wave 4 = ATOM-078 ‖ ATOM-077).

| № | Register item | Disposition | File(s) changed | What changed |
|---|---|---|---|---|
| 1 | No dollar figure may show before a confirmed rate | done | `render.sh`, `cost-line-spec.md`, `TIERS.ro.md`, `TIERS.ru.md` | Hard checkstop: `rate.config` absent or still the `8.00` placeholder ⇒ render prints "стоимость пока не показывается" / equivalent instead of any `$X`; spec + TIERS text now state the mechanism instead of a placeholder disclaimer |
| 2 | Consent body must be plain-language, no jargon | done | `CONSENT.ro.md`, `CONSENT.ru.md` | Data-collection paragraph rewritten against team-summary-spec's own glossary; jargon confined to the invisible HTML comment header (pre-existing repo convention) |
| 3 | **CEO-choice** — content-filter mode for telemetry (whole-file vs. field-filtered) | done, both variants delivered | `push.sh`, `CONSENT.ro.md`, `CONSENT.ru.md` | `CONTENT_FILTER_MODE` env var: **Variant A — `wholefile`** (default, previously-tested behavior) / **Variant B — `filtered`** (new: `copy_status_filtered()`, `copy_run_log_filtered()`, `copy_status_yaml_filtered()`, `copy_verdict_filtered()`, strips prose/findings, keeps structural fields). Consent footnote states both variants plainly under "Точный технический список" / "Lista tehnică exactă" — **выбор CEO на G2, не сделан здесь** |
| 4 | Setup kit must install daily support tooling + scheduler; H2 requires idempotent + dry-runnable | done | `bootstrap.sh`, `dry-run.sh` | New Step 5 (installs `telemetry/`+`consent/` from `QROKY_KIT_ROOT`, ships `telemetry/OFF` by default) and Step 6 (idempotent cron registration via marker-comment check, graceful no-`crontab` fallback); `dry-run.sh` gained a fake `crontab` stub + assembled sandbox kit root so both steps run for real, twice, network-free |
| 5 | **CEO-choice** — deletion-on-revocation enforcement: code-only vs. code+human runbook as the permanent mechanism | done, both variants delivered | `push.sh`, `telemetry-deletion-runbook.md`, `CONSENT.ro.md`, `CONSENT.ru.md` | Code side (real, tested): `DELETE_BY_FILE`/`EVER_SENT_FILE` tracking, `log_deletion_request()` fires on date-trigger or OFF-after-ever-sent, auto-switches OFF on date-trigger. **Variant A** = this code-only detection+log is deemed sufficient once a real remote exists / **Variant B** = the human-executed `telemetry-deletion-runbook.md` stays the permanent completion step even after a real remote exists. Consent text flags this explicitly as "вариант, отмеченный для подтверждения CEO на G2" — **не выбран здесь** |
| 6 | QUICKSTART needs a Step 0 (kit source, which folder to open a terminal in) | done | `QUICKSTART.ro.md`, `QUICKSTART.ru.md` | New Step 0 added; steps renumbered 0-6 |
| 7 | E8-2 (2-founder pilot conditioned on primary-duty + 2-of-5-days breach protocol) must be wired into founder-facing text | **CEO-answered via GATE-018, wired** | `CONSENT.ro.md`, `CONSENT.ru.md`, `QUICKSTART.ro.md`, `QUICKSTART.ru.md`, `pilot-design-amendment-proposal.md` | Consent gained "Наше обязательство по доступности"/"Angajamentul nostru de disponibilitate" section quoting GATE-018's E8-2 answer ("2 фаундера + primary-duty") verbatim in plain language, including the 2-of-5-business-days breach trigger and its automatic pause/renegotiate outcome; amendment proposal drafts the same into `pilot-design.md`'s own SLA section (not applied — out of this atom's edit scope, CEO/`business-strategy-v1` atom applies it) |
| 8 | E8-1 (TEAM-summary opt-in, local-only default) must be wired into founder-facing text + render code | **CEO-answered via GATE-018, wired** | `render.sh`, `CONSENT.ro.md`, `CONSENT.ru.md`, `team-summary-spec.md`, `pilot-design-amendment-proposal.md` | `render.sh --external` mode: never opens `INPUT.md`; content line (the one plain sentence) shown only if `consent/TEAM-CONTENT-OPTIN` exists. Consent gained a separate, distinct opt-in checkbox section (independent of the telemetry consent) quoting GATE-018's E8-1 answer ("Opt-in в consent") verbatim. `team-summary-spec.md` documents local-vs-external as two named variants |
| 9 | **CEO-choice** — consequence of declining/revoking consent | done, both variants delivered | `CONSENT.ro.md`, `CONSENT.ru.md` | New "Если вы откажетесь"/"Dacă refuzați" section: **Variant A** = pilot continues without that data stream, no penalty / **Variant B** = a reduced/manual-only support mode applies. Both stated plainly — **выбор CEO на G2, не сделан здесь** |
| 10 | Auto-escalation worked example (tier-3 cost) + ATOM-077 intake cost-plan-section | **partially done** — worked example done; intake component out of scope | `TIERS.ro.md`, `TIERS.ru.md` | Worked example added ("8 elemente × ~$2.50 ≈ $20" matched number-for-number RO/RU). The intake cost-plan-section half names an `077-intake-protocol/` artifact — outside this atom's 071/072/078 obligations; ATOM-077 delivered its own tree mid-session (`status.yaml` shows `ATOM-077: delivered`, 2026-07-07T14:24:52Z) — that atom's own RESULT.md is the record of whether it absorbed this sub-item, not duplicated here |
| 11 | `work_unit` cost sub-field must be gated on the same opt-in as E8-1 | done | `push.sh` | `copy_result_cost_block()` now strips `work_unit:` unless `consent/TEAM-CONTENT-OPTIN` is present — same flag `render.sh --external` reads |
| 12 | Daily manual spot-check of honesty (jargon-free, fields present) should be automatable | done | `render.sh` | New `--audit <file>` mode: shape-check for cost-line files, jargon-check (scoped past the fixed glossary intro) for narrative/team-summary files |
| 13 | Founder needs to know exactly what reaches them vs. what's internal audit trail | done | `cost-line-spec.md` | New "What actually reaches a founder" section: only the `⚙` line is founder-facing, the rest is internal |
| 14 | Fan-decision line shows raw rule-ids, not a plain sentence | done | `render.sh`, `team-summary-spec.md` | `plain_fan_decision()` maps raw strings ("opt-out per PM4" etc.) to plain sentences, no rule-id ever shown; documented as rule 5 |
| 15 | Founder-facing QUICKSTART points at an internal-evidence file (`dry-run-transcript.txt`) | done | `QUICKSTART.ro.md`, `QUICKSTART.ru.md` | Raw pointer removed; replaced with a plain measured-time footer. Transcript stays Verify-only evidence |
| 16 | Closing timing claim conflates scripted time with (untested) network-download time | done | `QUICKSTART.ro.md`, `QUICKSTART.ru.md` | Claim split: scripted portion stated separately from the network leg, which is named as untested rather than folded into one number |
| 17 | Intake protocol needs a G2 brief component | **deferred — out of scope** | — | Names an `077-intake-protocol/` / G2-brief artifact outside 071/072/078; belongs to ATOM-077's own delivered tree (parallel wave, PLAN.md Addendum 2), not duplicated here |
| 18 | Windows path: QUICKSTART silent on Git Bash requirement | done | `QUICKSTART.ro.md`, `QUICKSTART.ru.md` | Explicit "open Git Bash" line added to Step 1 |
| 19 | RO/RU wording drift (071V-M3): "framework" phrased differently in each language | done | `TIERS.ro.md`, `TIERS.ru.md` | Aligned: "construcției acestui cadru" ↔ "конструкции этого фреймворка"; "trece automat" ↔ "автоматически проходит" |
| 20 | Multi-descendant render branch untested against a real fan; no worked SYNTHESIS.md lookup | done | `render.sh`, `team-summary-spec.md`, `example-debrief.md`, `example-spawn-brief.md` | `synthesis_file` lookup added (searches for a `SYNTHESIS.md` naming this atom as `parent`); descendant/role arrays built from real fan references when frontmatter is silent; worked examples generated against ATOM-007-SYNTH's real 4-lens fan |
| 21 | Cost breakdown (`subtree_cost` sub-fields) never actually populates | done | `render.sh`, `cost-line-spec.md` | Root cause found: awk anchor required column-0, real YAML is indented — fixed; breakdown line now populates for real records; spec claim softened to match (emitted only when data present) |
| 22 | Russian plural of "роль" wrong for counts other than 1 | done | `render.sh` | `ru_role_word()` — роль/роли/ролей by count |

**Register rows done (fully or with both CEO-choice variants delivered): 20/22. Deferred to CEO / another atom's scope: 2/22 (sub-parts of #10, #17 — both landed in ATOM-077's own delivered tree, per PLAN.md Addendum 2's parallel-wave split, not this atom's obligations).**

CEO-choice rows requiring a G2 decision (no choice made here, per instruction): **#3, #5, #9** — each delivered as two labeled, working variants.
CEO-answered rows wired verbatim from GATE-018 (no further decision needed): **#7, #8**.

---

## H-checks (self-check, literal commands + outcome)

### H2 — `bash -n` on every touched script; negative-test + OFF-switch re-run green; new scheduler install idempotent + dry-runnable

```
$ bash -n products/pilot-prerequisites-v1/071-setup-kit/setup/bootstrap.sh \
       products/pilot-prerequisites-v1/071-setup-kit/setup/dry-run.sh \
       products/pilot-prerequisites-v1/072-telemetry-showcase/telemetry/push.sh \
       products/pilot-prerequisites-v1/072-telemetry-showcase/telemetry/negative-test.sh \
       products/pilot-prerequisites-v1/072-telemetry-showcase/showcase/render.sh
```
→ exit 0, no output (all 5 clean) on the final combined sweep.

```
$ bash products/pilot-prerequisites-v1/072-telemetry-showcase/telemetry/negative-test.sh
```
→ TEST 1, TEST 2 (pre-existing, unchanged, still green), TEST 3 (new — filtered mode strips Findings prose, keeps `verdict: accept`), TEST 4 (new — OFF after a real send logs an auditable deletion request) all `PASSED`; final banner `ALL NEGATIVE TESTS PASSED`.

```
$ bash products/pilot-prerequisites-v1/071-setup-kit/setup/dry-run.sh
```
→ `Verdict: PASS — run 1 exited 0 in <1s, within the 900s budget.` / `Idempotency: PASS — run 2 exited 0 and reused the existing workspace.` / `Count: 0` questions asked, both runs, scheduler included (new fake-`crontab` stub proves Step 6 registers once on run 1, reports "already registered" on run 2).

**H2: PASS.**

### H3 — founder-facing jargon grep (ATOM-071 H3 pattern) stays zero-hit on all touched RO/RU files

```
$ grep -inE "DoD|атом|atom|verify|INPUT|гейт|gate" \
    products/pilot-prerequisites-v1/071-setup-kit/setup/QUICKSTART.ro.md \
    products/pilot-prerequisites-v1/071-setup-kit/setup/QUICKSTART.ru.md \
    products/pilot-prerequisites-v1/071-setup-kit/setup/TIERS.ro.md \
    products/pilot-prerequisites-v1/071-setup-kit/setup/TIERS.ru.md \
    products/pilot-prerequisites-v1/072-telemetry-showcase/consent/CONSENT.ro.md \
    products/pilot-prerequisites-v1/072-telemetry-showcase/consent/CONSENT.ru.md
```
→ QUICKSTART.ro/ru.md, TIERS.ro/ru.md: **zero hits**. CONSENT.ro/ru.md: hits confined to the invisible HTML comment header (repo convention per 073-M2 precedent, lines identifying the source decision for audit purposes only, never rendered founder-facing) plus one pre-existing, unrelated substring false-positive (`agregate`, Romanian for "aggregate," contains the substring "gate" — confirmed present verbatim in the original accepted file before this fix-round, unrelated to any real leak, disappears under a word-boundary-refined grep).

**H3: PASS.**

### H4 — E8-1/E8-2 texts quote GATE-018 semantics exactly; both CEO-choice items present as labeled A/B

Verified by direct comparison: `CONSENT.ro.md`/`CONSENT.ru.md`'s E8-2 section states "2 founders + primary-duty" and the "2 of any 5 consecutive business days" breach trigger — matches GATE-018's recorded E8-2 answer text verbatim in substance. The E8-1 opt-in checkbox section matches GATE-018's "Opt-in в consent (Recommended)" answer, implemented as a genuinely separate consent item from telemetry consent (not folded in). Register rows #3, #5, #9 each show two explicitly labeled variants in both CONSENT files (grepped for "Variant A"/"Variant B" equivalents in RO/RU — both present, three times each, once per row).

**H4: PASS.**

### H5 — narrative-spec.md exists; render.sh produces a real worked debrief example; ≤5% budget rule stated

```
$ ls products/pilot-prerequisites-v1/072-telemetry-showcase/showcase/narrative-spec.md
$ bash products/pilot-prerequisites-v1/072-telemetry-showcase/showcase/render.sh --debrief . ATOM-007-SYNTH \
    > products/pilot-prerequisites-v1/072-telemetry-showcase/showcase/example-debrief.md
```
→ `narrative-spec.md` exists, states the ≤5% of `subtree_cost` budget rule as a design constraint. `example-debrief.md` renders a real worked example against ATOM-007-SYNTH's actual 4-lens fan (073/074/075/076), 8 real contradiction headings, both real E8 gates, GATE-018's actual recorded answers distilled plainly, and a token total (625,276) independently hand-verified against the sum of `status.yaml`'s five real counters for that subtree — matches exactly. `example-spawn-brief.md` likewise renders against the same real record ("4 perspective(s)", matching PLAN.md's actual Perspective-map table row count after the counting-scope bug was fixed).

**H5: PASS.**

### H1 (confirmation)

Every row marked «исполнитель» in the register maps to a real, committed change — see the coverage table above; all 20 directly-owned rows show file(s) + change description; the 2 out-of-scope sub-items are explicitly named as deferred, not silently dropped.

**H1: PASS.**

---

## Obligations check

- `pilot-design.md` — **not edited.** `git diff --stat products/business-strategy-v1/pilot/pilot-design.md` returns empty throughout. The E8-1/E8-2 amendment is a **proposal only**, in `workspace/pilot-design-amendment-proposal.md`, explicitly marked not-applied, CEO/`business-strategy-v1`-tree atom's to apply at G2.
- `status.yaml` — **not edited by this atom.** Its one diff hunk in the working tree (`ATOM-077: running → delivered`, `+ATOM-077-VERIFY` entry) is ATOM-077's own sibling process writing its own two rows, confirmed via timestamp (`2026-07-07T14:24:52Z`) and content (ATOM-077's own token counters) — no line in that diff touches `ATOM-078`'s own entry.
- Edits confined to `071-setup-kit/`, `072-telemetry-showcase/`, and `078-fix-round/` itself — confirmed via `git status --porcelain` scoped to those three paths; no other path appears in the working tree.

## Recommended follow-up (not applied — outside 071/072/078 artifact-folder mandate)

`rate.config` (register #1's checkstop input) should be added to root `.gitignore` once a real rate is confirmed and a founder or CEO creates that file locally — repo-root `.gitignore` sits outside this atom's edit scope. Noted here as a recommendation, not actioned.

## Cost / token estimate

This fix-round's own real usage (per this session's context growth across ~35 tool-call rounds: reading 4 lens-verdicts + 2 verify-verdicts + SYNTHESIS.md + GATE-018 + INFO-009 + PLAN.md + pilot-design.md in full, plus iterative script rewrites/debug cycles on render.sh in particular): **estimated ~165,000-180,000 tokens** (in line with the ~170k envelope named in this atom's own `status.yaml` note at spawn time). A slim re-verify round is expected next, per the same note, at materially lower cost (targeted diff review, not full-context re-read).

## Provenance
| Event | Atom | Date |
| :---- | :---- | :---- |
| Fix-round executed against 007-synth register + GATE-018 + INFO-009 | ATOM-078 | 2026-07-07 |
