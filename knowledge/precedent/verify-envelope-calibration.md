---
source: products/framework-v1/002-fev-protocol/workspace/run.log (COST entry, 2026-07-05) and ATOM-003 INPUT §3.9
date: 2026-07-05
type: precedent
tags: [budget, verify, calibration, formulate]
---

# Calibrate envelopes from the input package, not from expected output

**What happened.** ATOM-002-VERIFY was given a ~15k-token envelope estimated from the expected size of its output (a verdict). Its actual consumption, measured by the runtime, was ~120k tokens — roughly eight times the envelope — dominated by reading the blind package (the product under verification plus the reference standards its DoD cites). No E4 hard stop fired, because the executor had no counter over its own reads; the overrun surfaced only in the parent's cost accounting.

**The lesson.** Reading the input package counts toward the envelope, and for verification-style work the reads dominate the writes. Calibrate every envelope from package size — estimated input tokens ≈ total input bytes ÷ 3, plus a working margin — and treat an envelope smaller than the read estimate as a Formulate defect. Formalized as BC1–BC3 in `framework/REPO-STRUCTURE.md`. Exact metering remains a runtime concern (BC4): where no real counter exists, mark estimates with `~` and size envelopes conservatively.

**Measured runs to date** (real runtime counters; recorded per GATE-006 *Fed back to*, closing the update deferred by GATE-004/GATE-005):

| Verification | Envelope | Real consumption | vs envelope | vs read estimate |
| :---- | :---- | :---- | :---- | :---- |
| ATOM-002-VERIFY | ~15k (output-sized — the defect above) | ~120k | 8× over | — |
| ATOM-003-VERIFY | ~70k (~2× read) | 123 814 | 1.8× over | ~3.5× |
| ATOM-004-VERIFY | ~132k (~3.5× read) | 139 394 | +5.6% over | 3.7× |
| ATOM-005-VERIFY | ~185k (read ×3.5 + 40k constant) | 138 342 | 25% under | 3.4× |
| ATOM-008-VERIFY | ~50k (formula, but read estimate omitted reference standards) | 105 273 | 2.1× over | ~1.9× of the *corrected* read |
| ATOM-015-VERIFY | ~75k (SLIM package per GATE-008: protocol digest embedded, no framework/ reads; ALL reads in estimate) | 90 424 | 1.21× over | ~3.2× |

The working formula, confirmed by the fourth measurement: envelope = blind-package read estimate ×3.5 **+ ~40k constant term** for per-turn runtime overhead, which dominates small packages (carry-over lesson of ATOM-004).

**Amendment (5th measurement, ATOM-008-VERIFY, per GATE-008 *Fed back to*).** The read estimate must include **everything the verifier will read**, not just the product: reference standards (FEV-PROTOCOL + ATOM-SPEC ≈ 16k tokens of reading) dominated a small product package and produced a 2.1× overrun. Omitting any DoD-cited file from the estimate is the same Formulate defect as output-sizing.

**Amendment (6th measurement, ATOM-015-VERIFY, per GATE-010 closure).** A **slim package** — the protocol digest embedded in the Verify INPUT instead of full constitution reads, with soft criteria spot-checked rather than exhaustively re-read — cut real consumption to 90 424 vs a ~105k+ full-package prediction, at accept-round-1 quality. Two conditions for reuse: (1) hard criteria must be script-checkable so digest fidelity carries no judgment risk; (2) the package §3 must list **every file the product cites** — the verifier legitimately needed a cited file the formulator omitted, forcing a VP2 gray zone. Residual +21% overrun suggests keeping a ≥25% margin on slim envelopes.
