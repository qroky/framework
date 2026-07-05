---
verify_atom: ATOM-005-VERIFY
target_atom: ATOM-005
product: MANIFEST.md, README.md, LICENSE, decisions/RISK-002-open-core-boundary.md
round: 1
returns_used: 0
verdict: accept
executor: claude-fable-5
date: 2026-07-05
---

# VERDICT — ATOM-005, round 1: accept

## Blind package received
Deliverables: `MANIFEST.md`, `README.md`, `LICENSE`, `decisions/RISK-002-open-core-boundary.md`, `products/framework-v1/005-manifest/RESULT.md`, `products/framework-v1/005-manifest/STATUS.md`. Reference standards: `framework/ATOM-SPEC.md`, `framework/FEV-PROTOCOL.md`, `framework/REPO-STRUCTURE.md`, `framework/ORCHESTRATION.md`, `decisions/GATE-004-atom-003-acceptance.md`, `decisions/GATE-005-atom-004-acceptance.md`, `knowledge/precedent/verify-envelope-calibration.md`. Plus non-content instrument commands (`ls`, `wc`, `grep` counts) over the repository for H6/H7 factual checks, as the INPUT §3 permits — including the `id: ATOM-005` entry of `products/framework-v1/status.yaml`, which H7 names but §3 does not list (VP2 item 2: files a criterion references). Nothing else was read. Executor self-check claims in `RESULT.md` were treated as claims, not evidence (VP3): every hard criterion re-run below.

## Hard criteria — re-run
| Criterion | Check run | Output | Result |
| :---- | :---- | :---- | :---- |
| H1 | `ls -la MANIFEST.md README.md LICENSE decisions/RISK-002-open-core-boundary.md` | all four present: 6174 / 2807 / 11346 / 3008 bytes | pass |
| H2 | `grep -v '^#' MANIFEST.md \| wc -w`; `wc -l README.md` | `888` (≤ 1,100); `31 README.md` (≤ 60) | pass |
| H3 | `grep -c "Apache License" LICENSE`; `grep -c "Version 2.0" LICENSE`; `grep -n "^   4\. Redistribution" LICENSE` | `4`; `2`; `90:   4. Redistribution. You may reproduce and distribute copies of the` | pass |
| H4 | `grep -nE "Claude\|MCP\|Codex\|OpenClaw\|Hermes\|BMAD" MANIFEST.md README.md` | no match, exit 1. Case-insensitive instrument run found exactly one hit: README:15 `runtime/claude/README.md` — the quickstart pointer the criterion itself sanctions ("runtime specifics live behind the quickstart pointer") | pass |
| H4b | `grep -oE "RPF\|Recursive Product Framework" MANIFEST.md README.md` + full read | only `RPF` (9×) and its title expansion; footnote declares "a commercial brand name is pending"; no other coined name | pass |
| H5 | frontmatter key count against DR4; `grep -n "^## " decisions/RISK-002-open-core-boundary.md` | 8/8 keys (`id date kind status atom trigger answered_by recorded_by`); 4/4 sections (*Question / Brief*; *Answer (verbatim)*; *Consequences*; *Fed back to*); DR5 reconstruction marked with named source | pass |
| H6 (hard subset: numbers) | `ls framework/ \| wc -l`; grep of GATE-004, GATE-005, precedent file | `4` framework docs; "8×" = precedent "roughly eight times" (~120k vs ~15k); "1.8×" = GATE-004 "(8× → 1.8×)" (123 814 vs ~70k); "within 6%" = GATE-005 "+5.6%" (139 394 vs ~132k); "three measured runs" = GATE-005 "третьим замером". Every cited number matches repo state | pass |
| H6 (S-checked component) | claim-by-claim check against the four framework docs + repo | two accuracy defects → findings F1, F2 (minor) | pass with findings |
| H7 | read `RESULT.md` frontmatter; `tail -1 products/framework-v1/005-manifest/STATUS.md`; `grep -A3 "id: ATOM-005$" products/framework-v1/status.yaml` | cost block present, all estimates `~`-prefixed (BC4); STATUS last line `2026-07-05T12:45:11Z delivered …`; status.yaml `state: delivered`, note mirrors STATUS | pass |

## Soft criteria — judged
| Criterion | Judge | Outcome |
| :---- | :---- | :---- |
| S1 | human | deferred to human sign-off (VP9) |
| S2 | Verify | "no findings" — justification: hype-grep (`revolutionar\|game.chang\|10x\|paradigm\|disrupt\|unprecedented\|world.class\|cutting.edge\|breakthrough\|state.of.the.art`) matches nothing in either file; the strong claims that remain ("one person plus RPF is a company", "an operating system that asks") are carried by named mechanisms (blind verification, decision journal, escalation metric) and by the repo-verifiable proof section, which is exactly the "confidence through specifics" the criterion asks for |
| S3 | Verify | "no findings" — justification: all four limitations name a concrete missing mechanism (multi-approver delegation, lightweight execution tiers, concurrent-write protocol, runtime counters) rather than generic caveats; two name the successor product explicitly, the other two mark it with "yet"; no disclaimer boilerplate anywhere. The intro's "each with a planned successor" is marginally stronger than items 1 and 3 deliver — considered and dismissed as within honest reading |
| S4 | Verify | finding F3. Routing speed itself is met: 31 lines, what-is paragraph → MANIFEST (5 min), 3-step quickstart, 8-row fully-linked map; every mapped path verified to exist (`ls`). But one routing claim is inaccurate about what the reader will find (F3) |

## Findings
### F1 — minor — Precedent-location claim overstates what `knowledge/precedent/` holds
- Cites: H6 (every factual claim in MANIFEST verifiable inside the repo)
- Evidence: MANIFEST line 50: "each measurement recorded as a public precedent in [`knowledge/precedent/`]". Grep counts over `knowledge/precedent/verify-envelope-calibration.md`: `"eight times"` → 1, `"1.8"` → 0, `"6%|5.6"` → 0. Only the first of the three measurements lives at the cited location; the second and third live in `decisions/GATE-004` and `decisions/GATE-005`, whose *Fed back to* sections explicitly defer the precedent-file update to its next touch. The measurements are real and in the repo — the pointer is wrong.

### F2 — minor — Unqualified segregation claim contradicts the `self` verification mode
- Cites: H6 (zero contradictions with the four framework documents)
- Evidence: MANIFEST line 20: "whoever executes never accepts their own work. Verification is blind — the checker receives the criteria and the product, never the producer's reasoning." ATOM-SPEC §1.4 mode `self`: "The executor, in the verify phase of its own cycle"; L7: "Parent (**or executor on `self` mode**)" records acceptance; A9 scopes the prohibition to maturity ≥ `reviewed`. The unqualified "never"/"is blind" is contradicted by the framework's own low-risk mode. Mitigated but not cleared by the hedge "One line each — the normative documents carry the detail."

### F3 — minor — README's "any atom folder shows the full record" is false for two folders
- Cites: S4 (routes a reader to the right next document)
- Evidence: README line 16: "any atom folder under [products/framework-v1/] shows the full record — `INPUT.md` → product → blind `VERDICT.md` → human acceptance". `ls products/framework-v1/001-atom-spec/` → `INPUT.md RESULT.md STATUS.md workspace` (no verify sibling); same for `role-001-framework-architect/`; `ls products/framework-v1/*/VERDICT*.md` → only the 002/003/004/004h `-verify` folders. A reader sent to "watch a real cycle" can land on a folder whose record has no verdict step.

## Verdict
**accept**, per findings F1–F3 — all `minor`, no blocking or substantive finding open (VP12). The minors remain in this verdict and transfer to the parent's run log at closure (L7); natural absorption point is the next touch of MANIFEST.md/README.md or of `knowledge/precedent/verify-envelope-calibration.md`, whose deferred update (GATE-004/GATE-005 *Fed back to*) would clear F1's substance by itself. S1 is deferred to the human judge and resolves at sign-off (VP18).
