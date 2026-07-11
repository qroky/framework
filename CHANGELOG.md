# Changelog

One entry per release tag, written in user-benefit language (what gets
better for you). Rendered from the release's verified records — nothing here
is composed from memory. Rule (INFO-024): a release without a changelog
entry is not published.

## v0.4.1 — 2026-07-11

- The problem is solved, not hinted at (INFO-044): setup now puts a real
  `qroky` command on your machine (`~/.local/bin/qroky`, plus one marked
  PATH line in your shell profile only if it was needed). From your next
  terminal window on, `qroky update` and `qroky uninstall` work from ANY
  folder, forever — you never again need to know where a clone lives or
  `cd` anywhere first. The finish screen names exactly what was set up,
  and `qroky uninstall` removes it along with everything else.
- Getting started is now ONE command, with nothing to download first:
  `bash <(curl -fsSL https://raw.githubusercontent.com/qroky/framework/main/qroky.sh) install`
  — it fetches its own kit copy and runs the same eight-question interview.
  (Cloning by hand still works, documented as the air-gapped alternative.)
- Existing installs get the `qroky` command automatically on their next
  update — no reinstall.
- Every message the kit prints now says `qroky update` / `qroky details` /
  `qroky uninstall` — no paths, no «go to the folder first».

## v0.4 — 2026-07-11

- Your instance now receives the PRODUCT and nothing else. Until now the
  rulebook copy arrived with the project's entire working history —
  hundreds of files of other people's records inside your workspace. From
  this release the installer materializes only the published whitelist
  (`distribution/dist-manifest`): the constitution, the runtime, the kit,
  the docs. Existing installs shed that history silently on their next
  update — one «да», your data, bot link, and answers untouched.
- One command to remember, from any folder: `bash qroky.sh install`,
  `bash qroky.sh update`, `bash qroky.sh uninstall`. You never need to
  know where a clone lives — install keeps its own kit copy under
  `~/.qroky/kit`, and uninstall/update find your install by a machine
  trace, not by path.
- The freeze is checkable: `distribution/verify.sh <tree>` fails loudly on
  any file that is not on the whitelist — the same manifest drives the
  installer and the check, so they can never disagree.
- The full history of how this framework built itself did not disappear —
  it moved to its own public home, **qroky/lab**, linked from the README.
  Published releases and their tags are untouched.

## v0.3.2 — 2026-07-11

- Installing over an existing folder is now a first-class path, not an
  error. Run the installer where Qroky already lives and it asks what you
  want — reinstall (your data stays untouched, only the assistant's
  rulebook copy is recreated fresh), update, or cancel — in your language,
  with «да/da/yes» accepted everywhere. No more raw
  «fatal: destination path 'framework' already exists».
- The same door is your repair kit: if the rulebook copy ever breaks (an
  interrupted update, a half-finished download), running the installer
  again rebuilds it to a working state — your answers, token, and files
  are not touched and nothing is asked twice.
- A leftover rulebook clone with no data next to it is recognized as an
  orphan: the installer offers to recreate it and start clean, or leaves
  everything exactly as it was if you say no.
- After `--uninstall`, the final screen now says the simple truth: to
  reinstall, just run the installer again — your data will stay.
- New honest note at the finish line, in the bot's hello, and in the
  assistant's own instructions: only NEW Claude Code chats see what was
  just installed. A window opened before the install does not know the
  starting phrase yet — open a fresh chat (the assistant will suggest
  exactly that instead of a bare "not found").
- One question fewer: the installer no longer asks whether the starting
  phrase should work machine-wide — it just makes it work, everywhere
  («qroky» answers in any Claude Code session on this machine). It is
  still exactly two small files, the finish screen names them, and one
  command removes everything entirely: `bash install.sh --uninstall`.
  Eight questions now, same three minutes.

## v0.3.1 — 2026-07-11

- Your language now truly follows you to the very end. The answer to
  question 1 governs every later screen — including the update
  confirmation, which speaks your language and accepts «да», «da» AND
  «yes» on any path. If the installer ever has to fall back to English
  (unrecognized answer, missing saved language), it now SAYS so in three
  languages instead of switching silently.
- The bot speaks your language too: the greeting and everything the
  assistant sends to your phone — acknowledgments, the morning digest,
  status replies, button questions — arrive in the language you chose at
  question 1 (English, Romanian, or Russian).
- Starting over is one honest command: `bash install.sh --uninstall`
  removes everything the kit put on the machine — scheduled jobs, the
  machine-wide gesture files (only if they are really ours), saved answers,
  and the bot token (with a warning first). Every step is printed before it
  runs; your working folder is never touched — its path is printed so you
  decide. After it, a fresh install runs exactly like the first time.
- Nothing changes for existing installs: updating stays question-free, and
  a machine that never chose a language keeps working exactly as before.

## v0.3 — 2026-07-10

- One bot, all your projects: events arrive labeled «[project]», a button
  press files the decision in the RIGHT project, the morning digest is one
  message with a section per project, and «что в работе <имя>» filters to
  one. A thought that names no project gets exactly one clarifying question
  with buttons.
- If you have one project, nothing changes — output is byte-identical to
  before; the router switches on only when a second project appears (a new
  workspace simply JOINS the already-connected bot: no second key, no
  second Start).
- Existing installs migrate silently on update: no questions, no re-binding,
  no repeated greeting. Updating also auto-completes a half-connected
  Telegram (the «gave the key, nothing happened» case is gone).

## v0.2 — 2026-07-10

- Gave your bot key → the bot greets you right away: «Я на связи. Завтра
  утром пришлю первый дайджест» — and it means it. The Telegram assistant
  now installs itself with the kit: replies to you within a minute, sends a
  morning digest, delivers gates as buttons you can answer from your phone
  (a press has the same force as an answer typed at the computer).
- You always know where you are: the installer opens with a map (9
  questions → ~3 minutes → two lines to start), every question says «N из
  9», and the finish screen gives you a ready copy-paste block with YOUR
  real folder path — plus a line for VS Code users.
- New question 9: make «qroky start» work from any chat on this machine
  (optional, exactly two small files, removal documented).
- New «Первые 5 минут» guide section: what to say first and what success
  looks like.

## v0.1.2 — 2026-07-10

- «qroky start» now works out of the box: the starting gesture ships inside
  the kit and the installer wires it into your working folder automatically
  (this closes the first field-test finding — the finish screen used to
  promise a phrase your machine had never been taught).
- The default working folder moved to `~/qroky-work` — outside the
  downloaded kit, so kit updates never sit next to your own work.
- The finish screen and the guides now include a line for VS Code users
  (File → Open Folder → your working folder) and say honestly that the
  starting phrase lives in that folder.

*Earlier kit versions (v0.1.0 installer, v0.1.1 backup + disclaimer) predate
tagging and shipped by commit; their records live in
`products/distribution-kit-v1/`.*
