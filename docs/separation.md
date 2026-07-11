# The two houses — framework (product) and lab (factory)

*ATOM-130 / GATE-031 / INFO-043. How this repository relates to
[qroky/lab](https://github.com/qroky/lab), and the rules that keep them
apart.*

## The split

- **qroky/framework (this repository) = the product.** Everything here is
  universal for every instance: the constitution (`framework/`), the
  runtime bindings (`runtime/`), the machine-wide skill, the installer kit
  (`distribution/`), the docs and knowledge layers, the one-command entry
  (`qroky.sh` — installed as the `qroky` command on PATH, so `qroky update`
  and `qroky uninstall` work from anywhere; INFO-044),
  CHANGELOG/README/LICENSE/MANIFEST. The exact list is the
  whitelist [`distribution/dist-manifest`](../distribution/dist-manifest).
  Principle: **universal whole, or it does not ship.**
- **qroky/lab = the public factory.** The full self-construction journal:
  `products/` (every atom folder, INPUT → product → blind VERDICT),
  `decisions/` (gates, risk acceptances, information — verbatim,
  append-only), `TASKS.md`, launch files, working `roles/`. It is the
  proof that the framework built itself under its own rules — and it never
  reaches a user's machine.
- **Instances stay private.** A founder's workspace (mission, atoms,
  decisions, tokens) belongs to the founder; nothing of it flows to either
  public repository.

## How agents work after the split

The same session usually touches both houses, with a hard rule per file:

- Product changes (constitution, runtime, kit, docs, knowledge, this file)
  → **framework**.
- Work records (atom folders, RESULT/STATUS/NARRATIVE, decision entries,
  TASKS, launch files) → **lab**.
- A decision that CHANGES the product is recorded in lab and IMPLEMENTED
  in framework — the lab entry names the framework commit/tag once it
  lands.

## The freeze rule

The distribution is frozen to the manifest at three layers:

1. **Vendoring** — `install.sh` materializes ONLY manifest paths in every
   instance (sparse checkout; trees older than the manifest vendor whole,
   so published tags keep working unchanged).
2. **Freeze check** — [`distribution/verify.sh`](../distribution/verify.sh)
   fails on any non-manifest file in a distribution tree; it runs in the
   kit harness and is the seed of the full release verify (INFO-043).
3. **History is never rewritten.** The published tags (v0.1.2 … v0.3.2)
   and the self-update channel of live instances stand on this history;
   the cleanup of this repository is HEAD-forward only.
