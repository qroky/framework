---
verify_atom: ATOM-078-VERIFY
target_atom: ATOM-078
round: 1
returns_used: 0
verdict: accept
date: 2026-07-07
criteria: H1 pass · H2 pass · H3 pass · H4 pass · H5 pass · H6 pass · S1 pass · S2 pass
findings: 5 minor, 0 blocking
---

# VERDICT — ATOM-078 (fix-round over 071/072 artifacts), round 1: **accept**

Blind verify per the slim package (VP20). Every hard criterion re-run
independently in a /private/tmp sandbox (`/private/tmp/atom078-verify-sandbox`),
never trusted from the target's own report. References used as law:
SYNTHESIS.md «Fix-priority register» (22 rows), GATE-018 (E8-1/E8-2 verbatim),
INFO-009 (narrative spec).

## Hard criteria — all re-run, all pass

### H1 — register coverage + CEO-choice discipline: PASS
Spot-checked rows №1, №2, №4, №5, №6, №20 against the artifacts themselves:
- **№1 (rate checkstop):** verified behaviorally — `render.sh` with no
  `rate.config` prints «стоимость пока не показывается»; with `rate.config`
  = `8.00` (the placeholder) still refuses; with a confirmed `2.50` prints a
  `$` figure. TIERS.ro/ru both carry the honest-numbers note («ни один ответ
  ассистента не покажет вам сумму в долларах, пока этот тариф не будет
  подтверждён письменно»). cost-line-spec.md rule 4 documents the checkstop.
- **№2 (plain-language consent):** CONSENT.ro/ru body is plain-language;
  exact filenames confined to the marked technical footnote («Точный
  технический список» / «Lista tehnică exactă»).
- **№4 (install + scheduler):** bootstrap.sh Step 5 installs `telemetry/` +
  `consent/` from `QROKY_KIT_ROOT`, ships `telemetry/OFF` by default; Step 6
  registers a cron line with explicit workspace path passed to push.sh as
  `REPO_ROOT`, marker-comment idempotency, graceful no-crontab fallback.
  Re-ran dry-run.sh: run 1 registers the schedule, run 2 prints «already
  registered» — proven idempotent, network-free.
- **№5 (deletion by date / on revocation):** code side re-tested (negative-test
  TEST 4 green: OFF after a real send logs a dated, auditable deletion
  request); DELETE-BY date trigger auto-writes OFF; consent's «Удаление»
  paragraph discloses the manual-runbook completion step, explicitly flagged
  for CEO at G2 — see finding M2.
- **№6 (Step 0):** present in both QUICKSTART files — kit source + «шаг 1
  делается именно в этой папке».
- **№20 (multi-descendant branch):** `synthesis_file` lookup + descendant/role
  arrays re-ran against the real ATOM-007-SYNTH fan; output byte-identical to
  the committed worked examples (see H5).

CEO-choice rows: **№3** — «Вариант A — фильтрация / Вариант B — целиком»
labeled in both CONSENT files, «финальное решение перед началом пилота»,
both variants working code (TEST 3 proves the filtered path); **№9** —
«Вариант A / Вариант B» labeled in the new «Если вы откажетесь» section,
«ни один пока не выбран». **Nothing is chosen for the human anywhere** —
confirmed. №5's A/B labeling is descriptive rather than literal in the
in-perimeter artifacts (finding M2, minor).

### H2 — scripts: PASS
`bash -n` clean on all 5 scripts (exit 0). negative-test.sh re-run: TESTS
1–4 all PASSED, exit 0. dry-run.sh re-run in sandbox: run 1 exit 0 in 0–1s
(budget 900s), run 2 exit 0 with all «already …» reuse lines; scheduler
registration idempotent via fake-crontab stub; 0 questions asked.

### H3 — founder-facing jargon grep: PASS
Verbatim pattern re-run on all 6 RO/RU founder files. QUICKSTART.ro/ru,
TIERS.ro/ru: zero hits. CONSENT.ro/ru: hits confined to the invisible HTML
comment header (provenance paths/ids — path/code spans, never rendered) plus
one substring false positive («agregate», Romanian for "aggregate", contains
"gate"; pre-existing word, not jargon). No founder-visible jargon.

### H4 — E8 wiring quotes GATE-018 semantics exactly: PASS
- **E8-1:** CONSENT.ro/ru carry a separate, independent, default-unchecked
  opt-in item — «одна простая фраза, говорящая о том, что было построено …
  может быть показана Startup Moldova» — matching GATE-018's «Opt-in в
  consent» and the register's «одну простую фразу о построенном…» semantics
  exactly; team-summary-spec.md and render.sh quote the answer verbatim.
- **E8-2:** CONSENT «Наше обязательство по доступности» / «Angajamentul
  nostru de disponibilitate» states primary-duty (8 weeks) + the 2-of-5-
  consecutive-business-days breach trigger → automatic pause and
  renegotiation; same promise in both QUICKSTARTs; amendment proposal drafts
  it into pilot-design.md without applying it (correctly out of scope).
- **TEAM summary local-only by default, content line gated:** verified
  behaviorally in the deployed workspace shape — without
  `consent/TEAM-CONTENT-OPTIN` the external render shows «Not shown …» and
  push.sh strips `work_unit:`; with the marker, the one Summary sentence
  appears and `work_unit:` survives. Same flag drives both.
- **No INPUT.md reads in the perimeter-crossing render path:** code-audited
  (only `render_team_summary_local` touches `$input_md`) **and** proven
  behaviorally — `--external` renders cleanly with the atom's INPUT.md
  deleted entirely, and a planted INPUT token never appears in output.

### H5 — narrative spec + worked example: PASS
`showcase/narrative-spec.md` exists; spawn-brief and debrief sections each
mapped to named record fields (PLAN.md Perspective-map rows; SYNTHESIS.md
`question:`, `## Positions`, `### X<n>`, `→ **E8-<n>**`; gate record;
status.yaml real counters); the ≤5% subtree_cost budget rule stated (§4);
levels 1/2/3 with piercing constitutional events (§3). Re-ran
`render.sh --debrief . ATOM-007-SYNTH` and `--spawn-brief` against this
repo's real records: output **byte-identical** to the committed
`example-debrief.md` / `example-spawn-brief.md` (4 real lens verdicts, 8
contradictions, 2 value gates, GATE-018's recorded answers, 625,276-token
measured total). `--audit` passes on both.

### H6 — regression: PASS
- ATOM-071: dry run re-run exits 0, elapsed 0–1s « 15 min; idempotency
  intact; 0 questions.
- ATOM-072: `WHITELIST_FILENAMES` still exactly the closed list — STATUS.md,
  RESULT.md (cost block only, enforced by `copy_result_cost_block`), run.log,
  status.yaml, VERDICT.md — nothing added, nothing removed; deny-by-default
  re-proven by TEST 1 (planted INPUT.md/secret.txt rejected, RESULT.md
  Summary text absent from staging); OFF switch re-proven by TEST 2.

## Soft criteria

### S1 — edit minimality: PASS
`git diff fa33fea..d45f012` over 071/072: all 21 touched files map to
register rows or INFO-009; no out-of-scope file touched. The one wording
change outside an additive block — TIERS.ru «всегда» → «автоматически» —
is register №19's RO/RU alignment (matches «trece automat»). No unexplained
drive-by rewording found.

### S2 — debrief reads like a story: PASS (one small mechanics leak — M5)
The worked debrief is genuinely readable: a question, four named
perspectives with their answers, an honest account of disagreement, the
human's decisions, the cost. Minor leak noted below.

## Findings (all minor; none blocks acceptance)

- **M1 (report only)** — `078-fix-round/RESULT.md` H1 table row 3 labels
  «Variant A — wholefile / Variant B — filtered», the reverse of the
  artifacts themselves (push.sh header and both CONSENT files label
  вариант A = фильтрация, вариант B = целиком). The artifacts are
  internally consistent; only the coverage table's labels are swapped. Fix
  in any later RESULT touch; G2 brief must use the artifacts' labeling.
- **M2** — Register №5's CEO variant appears in CONSENT as one flagged
  «вариант … для подтверждения CEO на G2» rather than an explicit labeled
  A/B pair; the explicit pair lives in RESULT.md's table (and reportedly the
  runbook, which is outside this package's readable file list). No choice
  was made for the CEO — the discipline holds; only the labeling form
  differs from №3/№9.
- **M3** — Opt-in marker resolution bases differ: push.sh resolves
  `TEAM-CONTENT-OPTIN` script-relative (`$SCRIPT_DIR/../consent/`), render.sh
  `--external` repo-root-relative (`$REPO_ROOT/consent/`). They coincide in
  the deployed workspace shape bootstrap.sh guarantees (verified), but
  diverge if push.sh is ever pointed at a REPO_ROOT that is not the kit's
  own parent. Worth one alignment line in a future touch.
- **M4** — Dead code: `render_debrief` computes `pct` (awk, ~line 680 of
  render.sh) and never uses it.
- **M5** — Debrief «Who contributed» rows carry internal record numbers
  («founder-ux (073)») — a mild mechanics leak past the meaning-language
  rule; `--audit` cannot catch bare numbers. Cosmetic.

## Verdict

**accept** — all six hard criteria pass on independent re-runs; both soft
criteria pass; 5 minor findings, 0 blocking. The 20/22 direct coverage with
2 sub-items explicitly routed to ATOM-077's delivered tree is honest, not
silent dropping. CEO-choice rows leave every G2 decision genuinely open.
