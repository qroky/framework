---
atom: ATOM-079
product: consent package restructured as a DEAL per GATE-019 pivot + register №3=A/№5=B/№9 wiring
parent: Pilot Prerequisites v1 (ATOM-007)
role: pilot-toolsmith (reused — roles/pilot-toolsmith.md)
formulated_by: formulating agent (launch session), 2026-07-07
verification: blind (ATOM-079-VERIFY, L-tier)
maturity_target: reviewed (accepted at G2 round 3 or by re-verify + human re-read)
instantiation: subagent
model_tier: M (MT2 — artifact/code execution; INFO-008 rule 1)
budget: ~200k tokens
recursion_allowance: 0
---

# ATOM-079 — Input Specification (fix-round r2: consent as deal)

## 1. Mission
G2 returned **pivot** (GATE-019, verbatim in the decision record): the consent
package currently asks the founder to sign an *instruction*; it must ask them
to sign a *deal*. Restructure the founder-facing package accordingly and wire
the three answered register choices into text and code. You are editing
accepted artifacts: minimal diffs outside the fix list; log every change.

## 2. The closed fix list (from GATE-019 — the law; read the record first)
**P1 — page 1 «Ce este Qroky».** New first page of CONSENT.ro.md (+ RU mirror
«Что такое Qroky» in CONSENT.ru.md): for a reader with ZERO context; half a
page; human language; not a single system term (no atom/verify/gate/tier/
telemetry-jargon — plain words only).

**P2 — signature subject = pilot deal.** Restructure both consents so what is
signed is the deal:
- founder GETS: the system + Flow Support, 12 weeks, free;
- founder GIVES: operational telemetry WITHOUT business content, a case
  study, feedback;
- RED LINES: no production code; no guarantees; no exclusivity;
- EXIT: right to leave at any moment + data deletion right.
Keep the existing GATE-018 substance (opt-in item verbatim «одну простую
фразу о построенном…», primary-duty + 2-of-5-days breach protocol) — it moves
into the deal structure, it does not disappear.

**P3 — QUICKSTART becomes a post-yes appendix.** Remove any signature line /
sign-off framing from QUICKSTART.ro/ru.md; reference it from the consent as
«приложение после да» (annexă după „da"). TIERS stays an appendix likewise.

**P4 — register №3 = A (content filtering).** Make filtering the ONE mode:
`push.sh` ships only structural fields from the 4 whole-copied files (free
text stripped) — variant A code path becomes the only path, variant B text
removed from consent; consent promises exactly what the code does.
`negative-test.sh` keeps/extends the filter test; regenerate
`negative-test-output.txt`.

**P5 — register №5 = B (runbook).** Deletion-by-date/withdrawal = dated,
logged step in the owner's weekly runbook. Wire the chosen variant into
consent text (single policy, no A/B menu) and wherever the weekly checklist
lives in the setup kit.

**P6 — register №9 = chosen policy.** Refusal of the telemetry checkbox:
pilot continues, case study honestly drops out of the exchange. Single policy
in consent (remove the A/B menu at ro:95-100 / ru:91-96 area).

**P7 — RO/RU substance identity** preserved everywhere you touch.

## 3. Files you may touch
`072-telemetry-showcase/consent/CONSENT.ro.md`, `CONSENT.ru.md`;
`072-telemetry-showcase/telemetry/push.sh`, `negative-test.sh`,
`negative-test-output.txt`; `071-setup-kit/setup/QUICKSTART.ro.md`,
`QUICKSTART.ru.md` (+ TIERS only if a signature/appendix line requires it);
weekly-runbook location in setup kit (find it; if none exists, the runbook
step lands in QUICKSTART's owner section). Your own folder: RESULT.md,
STATUS.md, workspace/. Read first: `decisions/GATE-019-atom-007-g2-pivot-consent-as-deal.md`
(verbatim law), `decisions/GATE-018-atom-007-synthesis-e8-gate.md` (E8 substance
that must survive).

## 4. Definition of Done
**Hard:**
- H1. CONSENT.ro/ru page 1 = «Ce este Qroky»/«Что такое Qroky»: ≤ half page
  (≤~200 words), zero system terms (jargon grep `DoD|атом|atom|verify|INPUT|гейт|gate|tier|телеметр|telemetr` zero-hit on page 1 specifically).
- H2. Consent body restructured as deal: four blocks (gets / gives / red
  lines / exit+deletion) each explicitly present; GATE-018 opt-in item +
  primary-duty + 2-of-5 protocol survive verbatim in substance.
- H3. QUICKSTART.ro/ru contain no signature framing; consent references them
  as post-yes appendix.
- H4. №3=A wired: push.sh single filtered path (whole-file copy path removed
  or dead-switched with comment), negative-test re-run green, output file
  regenerated; consent variant-B text gone.
- H5. №5=B and №9 wired as single policies in consent (no remaining
  «Вариант A/Varianta A … Вариант B/Varianta B» menus anywhere in consent);
  runbook step exists, dated + logged.
- H6. RO/RU substance-identical (section-by-section table in RESULT).
- H7. `bash -n` green on touched scripts; every change mapped to P1–P7 in
  RESULT (no drive-by edits).
**Soft:**
- S1 (the GATE-019 acceptance test, verbatim): «читатель, не знающий слова
  Qroky, за 10 минут понимает, что это, что за сделка и подписывает
  осознанно» — simulate this read in workspace/ (cold-reader walkthrough,
  timed by wc-based estimate) and report; final judge = human at G2 r2.
- S2. The deal reads invited-not-processed; name any clause a founder would
  stumble on.

## 5. Budget & discipline
~200k. run.log in workspace/ append-only. Do NOT touch status.yaml. Chat
reply is a signal; files are the product.
