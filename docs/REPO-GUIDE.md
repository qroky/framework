# Repository guide

*The repository navigator, preserved content-identical from the pre-launch README (ATOM-120 H2). For the storefront, see [README.md](../README.md).*

**Quickstart:**

1. Read the constitution, in order: [ATOM-SPEC](../framework/ATOM-SPEC.md) → [FEV-PROTOCOL](../framework/FEV-PROTOCOL.md) → [REPO-STRUCTURE](../framework/REPO-STRUCTURE.md) → [ORCHESTRATION](../framework/ORCHESTRATION.md).
2. To run atoms on the reference runtime, follow [runtime/claude/README.md](../runtime/claude/README.md) — session start, tier mapping, human sign-off, headless mode.
3. Watch a real cycle: any atom folder in the public factory, [qroky/lab](https://github.com/qroky/lab), shows the full record — `INPUT.md` → product → blind `VERDICT.md` → human acceptance in its `decisions/`.

**Repository map:**

| Path | What lives there |
| :---- | :---- |
| [MANIFEST.md](../MANIFEST.md) | The manifesto — why Qroky exists, who it is for, what is open |
| [framework/](../framework/) | The constitution: four normative documents binding every atom |
| [knowledge/](../knowledge/) | The knowledge layer: domain, organizational, procedural, precedent |
| [runtime/](../runtime/) | Runtime bindings — how atoms run on a concrete platform |
| [distribution/](../distribution/) | The installer kit: `install.sh`, the dist-manifest, the freeze check |
| [qroky.sh](../qroky.sh) | The one-command entry — installed as the `qroky` command on PATH: `qroky install \| update \| uninstall` |
| [LICENSE](../LICENSE) | Apache License 2.0 — the open boundary is recorded in the decision journal (RISK-002, in the lab) |

This repository is the PRODUCT — what every instance receives, whole
(see [distribution/dist-manifest](../distribution/dist-manifest) and
[docs/separation.md](separation.md)). The full self-construction
journal — every product folder, every decision, every gate, verbatim —
lives in the public factory: **[qroky/lab](https://github.com/qroky/lab)**.
