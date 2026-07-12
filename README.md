# Qroky

**Qroky turns agent work into governed, verified, auditable product work.** You state a task and come back to a finished result — a governed work system for running a workforce of AI agents, not a coding harness. Built for solo founders first, and for regulated organizations where maker-checker is the law of the land.

The governance is the seat belt, not the product. Every result arrives with its accountability contour: who formulated the work, who executed it, who blind-verified it, where the human accepted the risk, what was spent, and what was delivered. That contour is what makes it safe to actually walk away while agents work.

---

## What you get in 15 minutes

One installer takes a clean machine to a working assistant in under 15 minutes — eight questions, about three minutes of your attention ([the full list](distribution/README.en.md)). At the end you have:

- the `qroky` command on your PATH — `qroky update`, `qroky uninstall`, one word from any folder;
- an assistant that answers to **«qroky start»** in any Claude Code chat on this machine;
- optional extras, each OFF unless you say yes: a Telegram assistant in your pocket, a morning digest, a private backup to **your own** GitHub account.

The whole system is plain markdown files and git in your own folder — no platform lock-in, no database of record, nothing to sign up for.

## How to install

One command, from anywhere — no download, no clone, no folder to find first:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/qroky/framework/main/qroky.sh) install
```

Air-gapped or curl-less machine? Clone this repository and run `bash qroky.sh install` — the same interview, the same result. Full installer guide: [distribution/README.en.md](distribution/README.en.md).

## What appears after «qroky start»

Open a chat in your working folder (`cd <your folder> && claude`) and say **qroky start**. The system looks around the folder read-only, asks you about the two «whys» of your work, and proposes a plan on one screen. Until your explicit **go**, it does nothing.

After the first conversation your folder gains: `qroky/mission.md` — your purpose, recorded verbatim; `NARRATIVE.md` — a live, human-language account of what is being done and why; and task records as plain text files you can open and read. First-five-minutes guide: [distribution/README.en.md](distribution/README.en.md).

## What stays local

Everything, by default. Your files, your Claude subscription, your Telegram bot token (if you connect one) live on your machine, and nothing leaves it without an explicit opt-in:

- **Nothing is sent anywhere** unless you turn on daily support sharing at install — and even then the shareable list is closed and short: status words, cost figures, step names — never your product's code, specs, or content ([the complete list](distribution/README.en.md)).
- **Backups go to YOUR OWN private GitHub account** — visible to you and nobody else; secret files are excluded from every backup automatically.
- Update checks fetch release tags from this repository and nothing else; applying one always waits for your explicit yes ([how updates work](docs/UPDATES.md)).

## How it works

Every piece of work is a **product** — it has a named consumer, acceptance criteria, and a maturity level — produced by one universal unit, the **atom**, that recurses from company strategy down to a paragraph. Duties are segregated: whoever specifies the work does not execute it, and whoever executes it never accepts their own result — an independent checker receives only the criteria and the product, never the producer's reasoning. Everything a human decides is recorded verbatim, and each answer feeds back so the same question is not asked twice.

In today's vocabulary, Qroky is an **agent harness** — what OpenAI calls **harness engineering** — applied to a company's whole work, not just to coding. OpenAI's published harness-engineering lessons converged on mechanics this framework had already built and recorded; the point-by-point comparison is on file ([INFO-039](https://github.com/qroky/lab/blob/main/decisions/INFO-039-openai-harness-lessons.md)).

No market claims — only what the record can show:

- The framework **wrote and blind-verified its own constitution**: the normative documents in [framework/](framework/) were produced by the framework's own atoms and accepted only after independent verification ([MANIFEST.md](MANIFEST.md), full run records in [qroky/lab](https://github.com/qroky/lab)).
- The largest verified tree ran **21 agents in 7 roles for ~2.76M measured tokens**, every independent check accepted on round one ([closure record](https://github.com/qroky/lab/blob/main/products/pilot-prerequisites-v1/007-pilot-prerequisites/RESULT.md)).
- Verification budgeting improved across three measured runs — from 8× over the envelope, to 1.8×, to within 6% ([knowledge/precedent/verify-envelope-calibration.md](knowledge/precedent/verify-envelope-calibration.md)).
- The decision journal is real: every gate, every risk acceptance, human answers verbatim — [qroky/lab/decisions](https://github.com/qroky/lab/tree/main/decisions).

## What you do / what the system does

You supply exactly three products — the three things agents cannot produce:

1. **Missing information** — you answer the questions only you can answer.
2. **Risk acceptance** — you accept, in writing, the risks only you can carry.
3. **Intent at gates** — go, no-go, or pivot, after a brief that states status, spend, and options.

The system does everything else: formulates the work, executes it, independently checks it, records every decision, and stops at budget envelopes. Human involvement is designed to fall over time — the escalation rate is a metric, not folklore.

## What's in the box

- The constitution — five normative documents binding every atom ([framework/](framework/)).
- The reference runtime binding for Claude Code, including headless operation ([runtime/claude/README.md](runtime/claude/README.md)).
- The installer kit: one-command install, eight questions, safe to re-run, honest uninstall ([distribution/](distribution/)).
- Optional Telegram assistant: morning digest, gate questions as buttons on your phone ([distribution/README.en.md](distribution/README.en.md)).
- Self-update that checks for releases, asks before applying — you're in control ([docs/UPDATES.md](docs/UPDATES.md)).
- The knowledge layer: precedents and reference data every atom can draw on ([knowledge/](knowledge/)).

## Skeptic FAQ

**Whose keys and whose data?**
Yours. Qroky runs on your own Claude Code subscription; there is no account with us and no key of ours in the loop. The optional Telegram assistant uses a bot **you** create, and its token is stored locally and excluded from every backup ([installer guide](distribution/README.en.md)).

**What leaves the machine?**
Nothing without opt-in. The only sharing feature is off by default, and its shareable list is closed: status words, cost figures, step names — never content ([the complete list](distribution/README.en.md)).

**Where do backups go?**
Backups go to YOUR OWN private GitHub account — nobody else's, and nobody else can see them ([backup and restore](distribution/README.en.md)).

**What does it really cost per month?**
We publish measured token counts, not invented dollar figures. A typical single atom runs ~178k tokens (measured worked example: [cost line](https://github.com/qroky/lab/blob/main/products/pilot-prerequisites-v1/072-telemetry-showcase/showcase/example-cost-line.txt)); the largest verified tree cost ~2.76M tokens for 21 agents ([closure record](https://github.com/qroky/lab/blob/main/products/pilot-prerequisites-v1/007-pilot-prerequisites/RESULT.md)). You run it on your own Claude subscription. A measured «typical user month» does not exist yet — that number is a placeholder until first external users produce it.

**How is this different from bare Claude Code?**
Claude Code is a capable pair of hands attached to your attention: you watch, steer, and accept your own results. Qroky is the layer above: work is specified, executed, and independently checked by *different* agents; results arrive with the accountability contour; every decision is recorded; budgets have envelopes that stop overruns. You leave, and you come back to something you can trust — or to an honest question the system could not answer for you.

**What are the known v1 limits?**
Single-human governance (no multi-approver delegation yet); the full atom lifecycle is heavy for micro-tasks; atoms run in dependency order (no concurrent-write protocol); budget stops are partially estimate-based, every estimate marked as such ([MANIFEST.md](MANIFEST.md)). The reference runtime is Claude Code, and the scheduled extras (morning digest, Telegram) use macOS launchd — other platforms go through runtime bindings ([CONTRIBUTING.md](CONTRIBUTING.md)).

**I don't work in English.**
Docs are English-only; the system itself speaks your language — set it in your profile. The installer itself runs in English, Romanian, or Russian.

**What if the project or its author disappears?**
Nothing breaks: everything is local, open source, works without us, and is forkable ([CONTRIBUTING.md](CONTRIBUTING.md)). Your instance never depends on our servers — there aren't any.

**Is this professional advice?**
No. The system produces drafts and analysis; legal/financial/medical decisions and signatures are always the human's; not professional advice.

## Early access

Qroky is built in the open, and v1 is early access. The full self-construction record — every product folder, every decision, every gate, verbatim — is public in the factory repo, **[qroky/lab](https://github.com/qroky/lab)**. This repository is the product itself: exactly what every instance receives ([distribution/dist-manifest](distribution/dist-manifest), [docs/separation.md](docs/separation.md)).

Issues are welcome and read: **[github.com/qroky/framework/issues](https://github.com/qroky/framework/issues)** is the feedback channel. Broke something in your first 15 minutes? That is exactly the report we want. To propose changes or fork, see [CONTRIBUTING.md](CONTRIBUTING.md).

---

Repository map and constitution reading order: [docs/REPO-GUIDE.md](docs/REPO-GUIDE.md).

Licensed under [Apache-2.0](LICENSE). **Qroky** is the product's brand name; the methodology it implements is the **Recursive Product Framework**.
