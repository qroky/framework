---
atom: ATOM-079-VERIFY
product: VERDICT.md on ATOM-079 (consent-deal pivot fix-round)
parent: Pilot Prerequisites v1 (ATOM-007)
formulated_by: formulating agent (launch session), 2026-07-07
verification: self
maturity_target: draft
instantiation: subagent (fresh context — VP4)
model_tier: L (MT3/MT4; INFO-008 rule 3)
budget: ~110k tokens (slim package ~20k read ×3.5 + 40k, ≥25% margin per VP20)
recursion_allowance: 0
---

# ATOM-079-VERIFY — Input Specification (slim blind package, VP20)

You are a blind Verify atom. Self-contained: do NOT read framework documents,
the target's `INPUT.md`, `STATUS.md`, `workspace/` or run.log. From the
target's `RESULT.md` read ONLY the P1–P7 change map and the H6 RO/RU table.
Round: **1**. Returns: **0**.

## 1. Job
The target restructured the accepted consent package per a CEO pivot (a
closed 4-point fix list + 3 register choices). Re-run its hard criteria,
check regression on the previously-accepted substance, judge soft criteria,
write `VERDICT.md` (accept / return-with-closed-fix-list) into
`products/pilot-prerequisites-v1/079-consent-deal-pivot-verify/`.

## 2. Files you may read (complete list)
1. `products/pilot-prerequisites-v1/072-telemetry-showcase/consent/CONSENT.ro.md`, `CONSENT.ru.md`
2. `products/pilot-prerequisites-v1/071-setup-kit/setup/QUICKSTART.ro.md`, `QUICKSTART.ru.md`, `TIERS.ro.md`, `TIERS.ru.md`
3. `products/pilot-prerequisites-v1/072-telemetry-showcase/telemetry/push.sh`, `negative-test.sh`, `negative-test-output.txt`
4. `products/pilot-prerequisites-v1/079-consent-deal-pivot/RESULT.md` — ONLY the P1–P7 change map + H6 table
5. **References (the law):** `decisions/GATE-019-atom-007-g2-pivot-consent-as-deal.md` (the verbatim pivot + register choices), `decisions/GATE-018-atom-007-synthesis-e8-gate.md` (E8 substance that must survive)
Instruments: ls, wc, grep, diff, `bash -n`; re-running negative-test.sh in a
/private/tmp sandbox is allowed and encouraged (no network, no real pushes).

## 3. Criteria (verbatim from the target's DoD + regression)
**Hard:**
- H1. CONSENT.ro/ru page 1 = «Ce este Qroky»/«Что такое Qroky»: ≤ half page
  (≤~200 words), zero system terms on page 1 — grep
  `DoD|атом|atom|verify|INPUT|гейт|gate|tier|телеметр|telemetr` (path/code
  spans excepted). Check: wc + grep on the page-1 span.
- H2. Consent body = deal: four blocks explicitly present (gets: system +
  Flow Support 12 weeks free / gives: operational telemetry without business
  content + case study + feedback / red lines: no production code, no
  guarantees, no exclusivity / exit + deletion right); GATE-018 opt-in item
  («одну простую фразу о построенном…») + primary-duty + 2-of-5-days breach
  protocol survive in substance. Check: read against GATE-018/019 records.
- H3. QUICKSTART.ro/ru: no signature framing; consent names QUICKSTART+TIERS
  as post-yes appendices. Check: grep + read.
- H4. Register №3=A wired: push.sh has a single filtered path (no whole-file
  copy branch), negative-test re-run green in sandbox, output file matches a
  real run; consent contains no variant-B disclosure text. Check: read code +
  re-run.
- H5. №5=B and №9 wired as single policies — grep confirms NO remaining
  «Вариант A|Varianta A|Вариант B|Varianta B» menus in consent; a dated,
  logged deletion runbook step exists in the setup kit. Check: grep + read.
- H6. RO/RU substance-identical — spot-check the target's H6 table against
  the files (pick ≥3 sections yourself). Check: table + files.
- H7. `bash -n` green on push.sh and negative-test.sh. Check: run.
**Soft (you judge; final S1 judge = human at G2 r2):**
- S1 (the CEO's acceptance test, verbatim): «читатель, не знающий слова
  Qroky, за 10 минут понимает, что это, что за сделка и подписывает
  осознанно» — do your own cold-read of CONSENT.ro or .ru top-to-bottom and
  give a reasoned estimate; name any passage where a zero-context founder
  would be lost.
- S2. Minimality: name any diff-visible change that maps to no P-item
  (drive-by edits) — compare against the P1–P7 change map.

## 4. Verdict discipline
`accept` only if every H passes your own re-run and no blocking soft failure;
otherwise `return` with a CLOSED fix list (file, line, what, why). Findings:
blocking / minor. Write `VERDICT.md`, `STATUS.md`, `RESULT.md`,
`workspace/run.log` in YOUR folder. Do NOT touch status.yaml. Chat reply is a
signal; files are the product.
