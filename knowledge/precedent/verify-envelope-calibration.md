---
source: products/framework-v1/002-fev-protocol/workspace/run.log (COST entry, 2026-07-05) and ATOM-003 INPUT §3.9
date: 2026-07-05
type: precedent
tags: [budget, verify, calibration, formulate]
---

# Calibrate envelopes from the input package, not from expected output

**What happened.** ATOM-002-VERIFY was given a ~15k-token envelope estimated from the expected size of its output (a verdict). Its actual consumption, measured by the runtime, was ~120k tokens — roughly eight times the envelope — dominated by reading the blind package (the product under verification plus the reference standards its DoD cites). No E4 hard stop fired, because the executor had no counter over its own reads; the overrun surfaced only in the parent's cost accounting.

**The lesson.** Reading the input package counts toward the envelope, and for verification-style work the reads dominate the writes. Calibrate every envelope from package size — estimated input tokens ≈ total input bytes ÷ 3, plus a working margin — and treat an envelope smaller than the read estimate as a Formulate defect. Formalized as BC1–BC3 in `framework/REPO-STRUCTURE.md`. Exact metering remains a runtime concern (BC4): where no real counter exists, mark estimates with `~` and size envelopes conservatively.
