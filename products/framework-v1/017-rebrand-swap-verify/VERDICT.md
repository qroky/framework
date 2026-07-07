---
verify_atom: ATOM-017-VERIFY
target_atom: ATOM-017
product: MANIFEST.md; README.md; TASKS.md; ATOM-007-LAUNCH.md; products/business-strategy-v1/{STRATEGY.md, segments/segment-map.md, pilot/pilot-design.md, pricing/pricing-ladder.md, metrics/metrics-system.md, channels/channel-comparison.md}
round: 2
returns_used: 1
verdict: accept
executor: claude-fable-5
date: 2026-07-07
---

# VERDICT — ATOM-017, round 2: accept

## Blind package received
Same package as round 1 (`INPUT.md` DoD + GATE-012 boundary; the 10 living files; `framework/FEV-PROTOCOL.md`; `decisions/GATE-012-rebrand-now-and-chain-order.md`; `roles/framework-architect.md`). Instruments only (`grep`, `git status --porcelain`, `git remote get-url origin`, `head -1`) run over the repository; target workspace/RESULT/run.log and all other decision/launch files: not read. Round-1 fix under re-verification (closed fix list, one entry): F1 — relocate `Handover1.md` out of the repository working tree.

## Hard criteria — full re-run (VP16)
| Criterion | Check run | Output | Result |
| :---- | :---- | :---- | :---- |
| H1 | `grep -c 'RPF'` per living file + `grep -n` on non-zero files | MANIFEST 0; README 0; segment-map 0; pilot-design 0; pricing-ladder 0; metrics-system 0; channel-comparison 0; TASKS 1 (line 45, «✅ 05.07.2026 — ATOM-006: RPF Business Strategy v1…» under closed-history — exemption a); STRATEGY 1 (line 39, verbatim «"RPF"→Qroky» swap-history — exemption b); ATOM-007-LAUNCH 1 (line 131, §3.7 swap-history — judged exempt in round 1, unchanged) | **pass** |
| H2 | `grep -n 'brand name is pending' MANIFEST.md`; `grep -n '¹' MANIFEST.md` | no match ×2 (exit 1) | **pass** |
| H3 | `git status --porcelain` | Exactly: 10 `M` lines = the living files; `M products/framework-v1/status.yaml`; `?? decisions/GATE-012-rebrand-now-and-chain-order.md`; `?? products/framework-v1/017-rebrand-swap/`; `?? products/framework-v1/017-rebrand-swap-verify/` (this Verify atom's own folder — legitimate sibling per VP6). **No out-of-set entry. `?? Handover1.md` is gone** (`git status --porcelain` piped to `grep -c 'Handover'` = 0). Frozen set (decisions/ others, knowledge/, atom metadata, closed launch files, naming-verdict.md, framework/) untouched | **pass** |
| H4 | `head -1 MANIFEST.md`; `head -1 README.md` | `# Qroky — Recursive Product Framework` — both, exact | **pass** |
| H5 | `git remote get-url origin` | `https://github.com/qroky/framework.git` | **pass** |

## Delta inspection — F1 cleared
Round-1 blocking finding F1 cited the single porcelain line `?? Handover1.md`. The round-2 porcelain capture contains no such line and no other out-of-set path; every remaining entry is in H3's own allowed listing plus this verify atom's folder (VP6). The fix (relocation out of git's view) is exactly the closed fix list's entry 1, applied minimally. **F1 resolved.**

## No-drift spot-check (fix touched no file content)
Round-1 verified positions re-checked and found byte-identical in sense:
- Titles: MANIFEST:1 and README:1 both `# Qroky — Recursive Product Framework` (H4 raw output).
- License line: README:31 «Licensed under [Apache-2.0](LICENSE). **Qroky** is the product's brand name; the methodology it implements is the **Recursive Product Framework**.» — unchanged.
- Consent line: pilot-design.md:47 «You run Qroky on your own machine, your own subscription, and your own private repository…» — unchanged, natural.
- ATOM-007-LAUNCH §3.7 (lines 131–133): «Rebrand «RPF» → Qroky executed per GATE-012 (ATOM-017)… «Recursive Product Framework» remains the methodology's spelled-out name (ATOM-017 boundary B2).» — unchanged; round-1 history-exemption judgment stands.
- Spelled-out enumeration: `grep -rn 'Recursive Product Framework'` over the living set yields the same 5 occurrences as round 1 (MANIFEST:1, README:1, README:31, TASKS:26, ATOM-007-LAUNCH:132–133 line-wrapped) — all methodology-name positions.
- `git status --porcelain` differs from round 1 by exactly one line: the removal of `?? Handover1.md`. No new modification appeared.

**No drift found.**

## Soft criteria
| Criterion | Judge | Outcome |
| :---- | :---- | :---- |
| S1 | Verify | round-1 «no findings» stands — spelled-out enumeration re-run identical (5 positions, all methodology-name); no drift detected, full re-read not triggered |
| S2 | Verify | round-1 «no findings» stands — spot-checked sentences (license, consent, §3.7) unchanged and natural; no drift detected, full re-read not triggered |
| S3 | human | deferred to human sign-off (VP9) — «Имя на витрине — моё» (GATE-013) |

**Full soft re-read: NOT performed.** Reason: the fix was a pure working-tree relocation of an untracked file; the porcelain delta shows zero content modifications since round 1, and every spot-checked round-1 position is unchanged. Per the re-verify scope (VP16), a full re-read is warranted only on drift; none was found.

## Findings
None.

## Verdict
**accept.** All hard criteria H1–H5 pass; F1 resolved by the prescribed minimal fix; no drift outside the fix; S1–S2 no findings carried with justification; S3 remains deferred to the human (VP9, GATE-013).
