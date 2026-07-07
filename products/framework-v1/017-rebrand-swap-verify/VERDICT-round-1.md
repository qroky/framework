---
verify_atom: ATOM-017-VERIFY
target_atom: ATOM-017
product: MANIFEST.md; README.md; TASKS.md; ATOM-007-LAUNCH.md; products/business-strategy-v1/{STRATEGY.md, segments/segment-map.md, pilot/pilot-design.md, pricing/pricing-ladder.md, metrics/metrics-system.md, channels/channel-comparison.md}
round: 1
returns_used: 0
verdict: return
executor: claude-fable-5
date: 2026-07-07
---

# VERDICT — ATOM-017, round 1: return

## Blind package received
`products/framework-v1/017-rebrand-swap-verify/INPUT.md` (DoD verbatim + GATE-012 boundary context); the 10 living files listed in the frontmatter `product` field; `framework/FEV-PROTOCOL.md` (§5.1 template, VP rules); `decisions/GATE-012-rebrand-now-and-chain-order.md`; `roles/framework-architect.md`. Nothing else was read. Instrument commands only (`grep`, `git status --porcelain`, `git remote get-url origin`, `head -1`) were run over the repository, including frozen paths, without reading contents beyond match counts. Target workspace/run.log/RESULT.md and all other decision/launch files: not read.

## Hard criteria — re-run
| Criterion | Check run | Output | Result |
| :---- | :---- | :---- | :---- |
| H1 | `grep -c 'RPF'` + `grep -n 'RPF'` per living file | MANIFEST 0; README 0; segment-map 0; pilot-design 0; pricing-ladder 0; metrics-system 0; channel-comparison 0; TASKS 1 (line 45, under «## Закрыто недавно» — exemption a); STRATEGY 1 (line 39, §Name, verbatim «"RPF"→Qroky» swap-history — exemption b); ATOM-007-LAUNCH 1 (line 131, §3.7 — judged exempt, see below) | **pass** |
| H2 | `grep -n 'brand name is pending' MANIFEST.md`; `grep -n '¹' MANIFEST.md`; `grep -n 'pending' MANIFEST.md` | no match ×3 (exit 1) | **pass** |
| H3 | `git status --porcelain` | 10 `M` lines = exactly the living files; `M products/framework-v1/status.yaml`; `?? decisions/GATE-012-rebrand-now-and-chain-order.md`; `?? products/framework-v1/017-rebrand-swap/`; `?? products/framework-v1/017-rebrand-swap-verify/` (this Verify atom's own folder — excluded: postdates target delivery, mandated by VP1/VP6); **`?? Handover1.md` — outside the allowed set** | **fail → F1** |
| H4 | `head -1 MANIFEST.md`; `head -1 README.md` | `# Qroky — Recursive Product Framework` — both, exact | **pass** |
| H5 | `git remote get-url origin` | `https://github.com/qroky/framework.git` | **pass** |

**H1 — formulator's round-1 question, judged explicitly.** ATOM-007-LAUNCH.md:131 («Rebrand «RPF» → Qroky executed per GATE-012 (ATOM-017); the repository lives at `qroky/framework`») **falls under the same history exemption**: the old name appears solely in quotation as the object of the completed rebrand — a swap-history record structurally identical to the STRATEGY §Name mention the DoD exempts «if retained as history»; the GATE-012 frame freezes history (append-only), and §3.7's own following sentence enforces the boundary going forward («Founder-facing artifacts use **Qroky**; «Recursive Product Framework» remains the methodology's spelled-out name»). It is a history position, not a brand position. Not a finding.

**H3 — frozen-set half of the criterion passes**: zero modified/deleted tracked files outside living set + `status.yaml`; `decisions/` others, `knowledge/`, atom metadata, closed launch files, `naming-verdict.md`, `framework/` untouched. The failure is solely the out-of-set untracked path `Handover1.md` (F1).

## Soft criteria — judged
| Criterion | Judge | Outcome |
| :---- | :---- | :---- |
| S1 | Verify | **no findings** — justification specific to S1: exhaustive enumeration (`grep -n 'Recursive Product Framework'` over the living set) yields exactly 5 spelled-out occurrences, every one in a methodology-name position: MANIFEST:1 and README:1 (titles mandated by H4), README:31 (explicit brand-vs-methodology definition sentence), TASKS:26 (quotation of the GATE-012 boundary itself), ATOM-007-LAUNCH:132–133 (boundary-definition sentence). Case-variant sweep (`grep -in 'rpf'`) finds no brand position reading RPF — only the 3 H1-exempt history lines. Brand positions throughout read Qroky (all five business-strategy doc titles, consent-text header, MANIFEST/README body). |
| S2 | Verify | **no findings** — justification specific to S2: full read of all 10 files; every sentence embedding the brand name is grammatical and natural («One person plus Qroky is a company», «Qroky sells one thing: a founder operating as CEO of agents», «jobs they would hire Qroky for»); the consent text reads as native first-person address («You run Qroky on your own machine, your own subscription, and your own private repository») with no broken agreement, doubled word, or substitution seam found anywhere in the set. |
| S3 | human | deferred to human sign-off (VP9) — «Имя на витрине — моё». |

## Findings
### F1 — blocking — Out-of-set change in working tree: untracked `Handover1.md` at repository root
- Cites: H3 (VP8 — failed hard criterion is automatically blocking)
- Evidence: `git status --porcelain` output contains the line `?? Handover1.md`. H3 permits changes ONLY in the living files, the ATOM-017 atom folder, `status.yaml`, and the GATE-012 record; untracked additions count as changes in this criterion's sense (the allowed set itself lists two untracked paths). `Handover1.md` matches none of the allowed categories. Its content was not read (blind package); provenance is not determinable by permitted instruments — the check as stated (FP2) is deterministic and fails.

## Verdict
**return**, per finding F1. All hard criteria except H3 pass; S1–S2 carry justified "no findings"; S3 deferred to the human (VP9).

## Return instruction
Fix list (closed):
1. F1 — Make `git status --porcelain` show no paths outside the H3 allowed set: move `Handover1.md` out of the repository working tree (or into an allowed location). If the file is not the executor's to move, do not skip or reinterpret this entry — raise the single consolidated question set to the formulating agent per VP14 before reworking.
Apply minimally and redeliver; do not change anything else.
