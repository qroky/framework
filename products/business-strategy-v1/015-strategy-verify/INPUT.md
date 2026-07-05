---
atom: ATOM-015-VERIFY
product: VERDICT.md on ATOM-015 (products/business-strategy-v1/015-strategy-verify/VERDICT.md)
parent: RPF Business Strategy v1 (ATOM-006)
formulated_by: ATOM-006 orchestrator (formulating agent of the verified atom, VP1), 2026-07-05
verification: self
maturity_target: draft
instantiation: session
model_tier: L — judgment-heavy verification of a maturity-target `reviewed` product (MT3/MT4)
budget: ~75k tokens (SLIM package per decisions/GATE-008: protocol digest embedded below instead of full constitution reads; read estimate ~10k — INPUT+digest ~3.5k, product ~2.5k, spot-check reads ~4k — ×3.5 + 40k per knowledge/precedent/verify-envelope-calibration.md, amended lesson: ALL reads included)
recursion_allowance: 0
---

# ATOM-015-VERIFY — Input Specification (SLIM blind package, VP2 + GATE-008)

## 1. Verification round
round: 1; returns_used: 0 (VP15).

## 2. Target DoD (verbatim from ATOM-015 INPUT §5)
**Hard criteria:**
- H1. File exists at `products/business-strategy-v1/STRATEGY.md`. Check: `ls`.
- H2. ≤1500 words excluding heading lines. Check: `grep -v '^#' STRATEGY.md | wc -w` ≤ 1500.
- H3. All six named sections present as headings. Check: grep each of Segments/Channel/Pricing/Pilot/Name/Re-validation.
- H4. Every section cites its underlying analysis by repo path (≥6 distinct paths total). Check: grep.
- H5. Quantitative claims sourced or assumption-marked (inherited markers count when the citing path carries them). Check: grep spot-check.
- H6. Re-validation section states the quarterly gate mechanism (re-touch = diff + human gate). Check: grep `quarterly`.
- H7. Zero bare platform names (path citations excluded). Check: grep for platform/vendor/model names of the runtime; occurrences inside the literal path `runtime/claude/README.md` do not count.

**Soft criteria:**
- S1. Human can open three commercial conversations from this file alone — judge: human (G2) — **deferred, do not judge** (digest rule 4).
- S2. Every strategic claim sourced, assumed-and-marked, or human-answered — judge: Verify (this atom). Method: SPOT-CHECK — for each of the six sections pick ≥2 substantive claims and trace them into the cited file; exhaustive re-reads are out of scope (slim mandate).
- S3. No new analysis smuggled in — assembly only — judge: Verify (this atom). Method: any number/claim in STRATEGY.md absent from the spot-checked sources is a finding.

**Maturity target of the verified atom:** reviewed.

## 3. Product path(s) — the blind package (nothing else may be read, VP2)
- `products/business-strategy-v1/STRATEGY.md` (the product)
- Spot-check targets (read PARTIALLY, only to trace claims): `products/business-strategy-v1/naming/naming-verdict.md`, `products/business-strategy-v1/segments/segment-map.md`, `products/business-strategy-v1/channels/channel-comparison.md`, `products/business-strategy-v1/pricing/pricing-ladder.md`, `products/business-strategy-v1/pilot/pilot-design.md`, `products/business-strategy-v1/metrics/metrics-system.md`, `products/business-strategy-v1/NOT-DOING.md`, `decisions/GATE-008-atom-006-g1-direction.md`, `decisions/INFO-001-pilot-terms-startup-moldova.md`
- `products/business-strategy-v1/015-strategy/RESULT.md`, `products/business-strategy-v1/015-strategy/STATUS.md` (self-check claims — claims, not evidence, digest rule 2)

## 4. Reference standards — EMBEDDED DIGEST (replaces framework/ reads per decisions/GATE-008; do NOT read framework/ files)
1. **Blind discipline:** read only the files in §3. The executor's self-check is a claim, never evidence — re-run every hard check yourself and record command + output.
2. **Self-check ≠ evidence** (VP3): treat RESULT.md assertions as hypotheses to re-test.
3. **Findings** (VP8–VP11): every finding cites the criterion it fails, carries evidence (command output or quoted text), and a severity: `blocking` (criterion fails), `substantive` (criterion formally passes but the product misleads a consumer), `minor` (local defect, no propagation risk). A deferral is not a finding.
4. **Human-judged criteria** (VP9): criteria whose judge is the human are deferred, not judged — state the deferral in the verdict.
5. **Verdict vocabulary** (VP12): exactly `accept` or `return`. `return` iff ≥1 blocking or substantive finding stands. Minors transfer to the parent run log at closure.
6. **Round tracking** (VP15): record round and returns_used in VERDICT frontmatter.
7. **VERDICT.md template** (FEV-PROTOCOL §5.1 shape): frontmatter (verify_atom, target_atom, product, round, returns_used, verdict, executor, date) + sections: `## Blind package received`, `## Hard criteria — re-run` (table: criterion / check run / output / result), `## Soft criteria — judged` (table incl. deferrals), `## Findings` (### F<n> — severity — title, with Cites + Evidence), `## Verdict` (one paragraph, verdict + finding disposition).
8. **Own records:** besides VERDICT.md, write your own `STATUS.md`, `RESULT.md` (with BC4 `~` cost block; state your real token counter is unavailable to you — the parent records it), and `workspace/run.log` in `products/business-strategy-v1/015-strategy-verify/`.

## 5. Deliverable
`products/business-strategy-v1/015-strategy-verify/VERDICT.md` per digest rule 7, plus this atom's own STATUS.md, RESULT.md, workspace/run.log.

## 6. Escalation
Verdict is exactly `accept` or `return` (digest rule 5). No web access needed or permitted — all claims trace to repo files. If a §3 file is missing, that is evidence for the relevant criterion, not a stop. Nothing may be read beyond §3 (VP2); framework/ reads are explicitly out of scope for this slim run (GATE-008).
