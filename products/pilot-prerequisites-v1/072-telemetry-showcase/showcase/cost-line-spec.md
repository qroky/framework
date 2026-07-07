# Cost-line spec — «⚙ N агентов · M ролей · глубина D · возвратов verify R · $X»

**Atom:** ATOM-072 · **Date:** 2026-07-07
**Format is fixed** (INFO-006 P3, verbatim): every founder-facing reply and
every telemetry push carries this exact line shape from day one. Nothing in
this document redefines the format — it only names, field by field, where
each element comes from and how `showcase/render.sh` computes it.

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
2. **Governance overhead stays visible.** `subtree_cost` carries the O4.3
   four-way breakdown (`execute` / `verify` / `role_creation` /
   `synthesis`). `render.sh`'s comment block (appended under the cost line
   in `example-cost-line.txt`) always states which of the four types the
   tokens came from, so a founder — or Startup Moldova — can see how much
   of $X is "thinking" versus governance overhead, not just the total.
3. **Round the dollar amount up, never down.** `$X` is computed as
   `tokens ÷ 1,000,000 × rate`, then rounded **up** to the next whole cent
   (ceiling, not nearest). A founder is never under-quoted.
4. **State the assumption, with a date.** The `$/token` rate is a
   **placeholder blended rate — $8.00 per million tokens, assumption dated
   2026-07-07** — because `pricing/pricing-ladder.md` is outside this
   atom's named input scope (ATOM-072 does not open pricing documents; see
   its `INPUT.md` §1). `render.sh` prints this rate and its date inline
   with every cost line it produces so the assumption is never hidden.
   **This placeholder MUST be replaced with the actual contracted rate at
   ATOM-007 setup**, before any real founder sees a cost line derived from
   it.

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
