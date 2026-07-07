# Cost-line spec — «⚙ N агентов · M ролей · глубина D · возвратов verify R · $X»

**Atom:** ATOM-072 · **Date:** 2026-07-07 · **Fix-round:** ATOM-078
(register #1, #13, #21) — 2026-07-07
**Format is fixed** (INFO-006 P3, verbatim): every founder-facing reply and
every telemetry push carries this exact line shape from day one. Nothing in
this document redefines the format — it only names, field by field, where
each element comes from and how `showcase/render.sh` computes it.

## What actually reaches a founder (register #13)

**Only the single cost line itself** — the text starting `⚙` — is ever
pasted into a founder-facing reply or shown in the kit's output. Everything
`render.sh` writes below the blank line that follows it (the `# ---` comment
block: source atom, field-by-field derivation, breakdown, honesty notes) is
an **internal audit trail**, kept in the same file purely so the derivation
is checkable by anyone who wants to verify it — never surfaced to a founder
without translation first. `render.sh --audit` (register #12) enforces this
split mechanically: it only jargon-checks the first line of a cost-line
file, never the comment block below it.

## Element → field → file

| Element | Meaning | Source field | Lives in |
| :---- | :---- | :---- | :---- |
| N | agents | `total_descendants` (O4.3) | the rendered atom's own `RESULT.md` frontmatter |
| M | roles | count of **distinct executor roles across the subtree** (the atom itself + every descendant counted by `total_descendants`) | each subtree member's `workspace/run.log` `CYCLE-START ... executor <model> as <role>` line |
| D | depth | `max_depth_reached` (O4.3) | the rendered atom's own `RESULT.md` frontmatter |
| R | verify returns | **sum** of `returns_used` across the atom's own Verify verdict and every descendant's Verify verdict | each subtree member's sibling `<atom-id>-verify/VERDICT.md` frontmatter (`returns_used`, FEV-PROTOCOL VP15) |
| $X | cost | `subtree_cost.total`, expressed in the model's blended `$/token` rate (below) | the rendered atom's own `RESULT.md` frontmatter `subtree_cost.total` (O4.3), reconciled against the product's `status.yaml` closure note when a **real** runtime counter is present there |

`N`, `M`, `D`, `R` are exact integer counts — never rounded, never estimated.
Only `$X` involves an assumption (the `$/token` rate) and a rounding rule,
both stated below.

## Honest-rounding rule (S3)

1. **Prefer measured over estimated.** `RESULT.md`'s `subtree_cost.total`
   is frequently written as a pre-close **estimate** (marked `~`, per BC4
   discipline — no mid-flight counter). When the product's `status.yaml`
   closure note carries a **real, measured** counter for the same atom
   (the `"executor real <n>"` pattern), `render.sh` uses the real number,
   never the estimate, even when the real number is *larger* than the
   estimate — as it is in this repo's worked example (real 177,951 vs.
   estimated ~152,000 tokens for ATOM-018). Showing a bigger, truer number
   is not a defect; showing a smaller, stale one to look cheaper would be.
2. **Governance overhead stays visible when it is available.** `subtree_cost`
   *can* carry the O4.3 four-way breakdown (`execute` / `verify` /
   `role_creation` / `synthesis`). `render.sh`'s comment block emits that
   breakdown line whenever the source `RESULT.md` actually populated those
   four sub-fields (register #21 — ATOM-072-VERIFY's F2 found the earlier
   text claimed "always" while the shipped render never emitted one; that
   claim is corrected here to match what the code actually does). When the
   sub-fields are absent, the comment block says so plainly ("breakdown not
   available for this atom") instead of silently omitting the promise.
3. **Round the dollar amount up, never down.** `$X` is computed as
   `tokens ÷ 1,000,000 × rate`, then rounded **up** to the next whole cent
   (ceiling, not nearest). A founder is never under-quoted.
4. **No dollar figure until the rate is confirmed in writing — a hard
   checkstop, not a disclosure (register #1).** The earlier text here
   published a placeholder blended rate ($8.00/M, dated 2026-07-07) inline
   with every cost line; 074-F1 (token-economics lens) measured that
   placeholder at ~3.2× a plausible blended real rate (~$2.50/M for the
   PLAN's actual tier mix), and both `073-B3` and `076-F4` independently
   flagged the same gap as founder-facing false certainty. The fix: no
   disclosure text substitutes for a confirmed rate. `render.sh` now reads
   a single-line `rate.config` file next to itself (git-ignored by
   convention — never commit a real contracted rate into this public
   showcase folder). If that file is absent, or still holds the old
   placeholder value `8.00`, `render.sh` refuses to compute or print any
   `$X` at all — the cost line instead reads *"стоимость пока не
   показывается"* ("cost not shown yet") and the comment block explains
   why and how to unblock it. This is the literal reading of the register's
   own instruction: **no founder-visible dollar until a contract rate is
   written in.** Once `rate.config` carries the real contracted `$/M` rate,
   the cost line resumes showing `$X`, computed and rounded exactly as
   rules 1 and 3 above describe.

## Honesty note — a leaf atom's N can legitimately read 0

`total_descendants` counts only atoms **spawned by** the rendered atom, at
any depth — never the atom itself. An atom that ran alone (opted out of a
lens fan, or simply has not spawned anything yet) has `total_descendants:
0`, and the cost line for it correctly reads **"0 агентов"**. This is not a
bug in the mapping; it is what the field means. `render.sh`'s worked
example (ATOM-018, `framework-v1`) is exactly this case — see
`example-cost-line.txt`'s trailing comment for the plain-language
explanation, repeated there for anyone reading the file cold.

## Provenance
| Event | Atom | Date |
| :---- | :---- | :---- |
| Created | ATOM-072 | 2026-07-07 |
| Amended — rate checkstop (register #1), founder-visibility note (register #13), breakdown claim softened to match code (register #21) | ATOM-078 | 2026-07-07 |
