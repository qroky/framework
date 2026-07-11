# Qroky — self-service install

## What this installer does

One script, `install.sh`, takes a clean computer to a working assistant in
under 15 minutes. It asks you exactly **eight questions** (listed below),
sets up a private folder on your own computer, and ends with a ready
copy-paste block for your first conversation. It never asks anything beyond
those eight questions — every other line it prints is either progress, a
check result, or (on a real problem) a plain-language fix instruction
naming the exact next step. The very first screen is a map of the whole
road: 8 questions, ~3 minutes, two lines at the end.

## The one command

```
bash <(curl -fsSL https://raw.githubusercontent.com/qroky/framework/main/qroky.sh) install
```

That is the whole entry — run it from anywhere, no download, no clone, no
folder to find first. It fetches its own kit copy under `~/.qroky/kit`,
starts the interview, and puts a small `qroky` command on your PATH. From
your next terminal window on, the whole journey is one word from any folder:

```
qroky update       # update your assistant
qroky uninstall    # remove everything it put on this machine
```

You never need to remember where anything lives. If something is
missing (git, curl, the Claude Code assistant itself), the script stops and
tells you exactly what to install and how — then you run the same command
again, and it continues from exactly where it stopped. Nothing is repeated,
nothing you already answered is asked twice.

*Alternative (air-gapped or curl-less machines): clone this repository by
hand and run `bash qroky.sh install` — or `bash install.sh` from this
folder — the same interview, the same result.*

## Your first 5 minutes

Setup is done — here is a hand on the shoulder for the very first
conversation.

**What to do.** The setup finale already gave you a ready block — copy it:

```
cd <your working folder> && claude
```

The **first** time `claude` starts, it asks a couple of its own questions
(color theme, login) — that is normal; answer them and continue. Then say:
`qroky start`.

**What happens.** The system looks around the folder (read-only), asks you
about the two "whys" of your work, and proposes a plan on one screen. You
answer **"go"** ("го") — or correct it in plain words, like you would a
person. Until your explicit go, it does nothing.

**What success looks like.** After the first conversation your working
folder gains: `qroky/mission.md` — your two whys, recorded verbatim; and,
next to the work in progress, `NARRATIVE.md` — a live, human-language
account of what is being done and why. Tasks and their statuses accumulate
in the same folder — everything is plain text you can open and read.

One honest note: the starting phrase works **in any Claude Code chat on
this machine** — the installer sets that up itself (exactly two files under
`~/.claude`; the finish screen names them, and
`qroky uninstall` removes everything entirely).

## The eight questions

1. **Language** — English, Română, or Русский. Everything after this point
   is shown in the language you pick.
2. **Working folder** — where your private Qroky workspace should live. A
   sensible default is suggested; press Enter to accept it, or type your
   own path.
3. **Claude Code check** — the installer checks whether the Claude Code
   assistant is already on this machine. If not, you get the exact install
   link and instructions; run the installer again once it's in.
4. **Subscription check** — a quick, non-blocking check that your Claude
   Code login/subscription looks active. This is a check, not a purchase
   flow — if it can't tell, it just reminds you, it never stops you.
5. **Telegram (optional)** — the assistant in your pocket: a morning
   digest, updates, and questions it can ask you on your phone. Skipping is
   zero effort: just press Enter (connect later with one command:
   `bash install.sh --enable-telegram`). If you say yes, the installer
   walks you through creating your own bot with BotFather, checks the token
   live, asks you to press **Start** on your bot — and the bot
   **immediately writes back** ("I am connected; tomorrow morning you get
   your first digest"). The whole link goes live right there: a message
   check every 30 seconds and a daily digest at 09:05. If nobody presses
   Start in time, nothing breaks: the token is saved, setup continues, and
   the same one command finishes the connection later.
6. **Daily support sharing (optional)** — see "What leaves this computer"
   below before you're asked. Off by default.
7. **Morning digest (optional)** — a short daily message: what got done,
   what's waiting for you. Recommended: yes. You can change your mind any
   time (see "Don't touch my instance" below).
8. **Backup (optional, recommended)** — keep a private safety copy of your
   Qroky folder in **your own** GitHub account. You don't need to know what
   GitHub is: if you say yes, the installer walks you through connecting
   (or creating, for free) your account step by step, the same hand-held
   way as the Telegram bot. **The backup goes to YOUR account** — a private
   copy visible only to you, never to us or anyone else. Your secret files
   (like the Telegram token) are excluded from every backup, automatically.
There used to be a ninth question here — "starting phrase everywhere on
this machine?" — but it asked for understanding a new user cannot have, so
the installer now just does it (exactly **two files** under `~/.claude`: a
copy of the phrase's rules page at `~/.claude/skills/qroky/SKILL.md` and a
marked trigger block in `~/.claude/CLAUDE.md` — nothing else, ever). The
trace replaces the question: the assistant answers to «qroky» in ANY Claude
Code session on this machine, and one command removes it all entirely:
`qroky uninstall`. The same rule gives you the `qroky` command itself: a
small launcher at `~/.local/bin/qroky` (plus one marked PATH line in your
shell profile, only if `~/.local/bin` was not on PATH already) — named on
the finish screen, removed by the same `qroky uninstall`.

## What leaves this computer

If you turn on daily support sharing at question 6, this — and only this —
would ever leave this machine (the complete list; anything not on it is
skipped, never read):

1. **Task progress files (`STATUS.md`)** — status word, date, and task id
   only; free-text notes stripped.
2. **Cost summaries (`RESULT.md`)** — the token/time cost figures ONLY;
   the summary and content sections, where your product would be
   described, are never copied.
3. **Step logs (`run.log`)** — timestamps and step names only.
4. **The status board (`status.yaml`)** — one line per task; free-text
   notes stripped.
5. **Independent check results (`VERDICT.md`)** — the verdict line only,
   never the findings text.

Never your product's code, specs, or content — those are not on the list
and are never read. Note that this installer only **records your choice**:
no sending mechanism is installed today, so nothing can leave even after a
yes. Before any sending script is ever added to your workspace, you will
be shown that script itself — plain, readable bash you can check line by
line against the list above.

## Don't touch my instance

The installer never changes anything you didn't ask for, and every
optional piece it turns on can be turned off just as easily:

- **Disable the morning digest:** delete the file inside your workspace's
  `.qroky/launchd/` folder from `~/Library/LaunchAgents/`, or simply don't
  answer "yes" at question 7 in the first place — the digest ships
  installed-but-off in that case, with the exact enable command printed
  for you.
- **Enable the morning digest later:** `bash install.sh --enable-heartbeat`
- **Enable the backup later** (if you said no at question 8):
  `bash install.sh --enable-backup`
- **Connect (or finish connecting) Telegram later** (if you skipped
  question 5 or Start wasn't pressed in time):
  `bash install.sh --enable-telegram`
- **Disable the Telegram assistant:** delete the two files
  `md.qroky.telegram.listener.plist` and `md.qroky.telegram.digest.plist`
  from `~/Library/LaunchAgents/` (its working files live in
  `.qroky/telegram/` inside your workspace and do nothing by themselves).
- **Remove the machine-wide starting phrase**: delete exactly the two
  files that were written — the file
  `~/.claude/skills/qroky/SKILL.md` and the marked block between the
  `qroky-machinewide` markers in `~/.claude/CLAUDE.md`.
- **Remove the `qroky` command by hand**: delete `~/.local/bin/qroky` and
  the marked block between the `qroky command` markers in your shell
  profile. Beyond these, `~/.qroky` (the kit copy and one pointer file),
  the installer wrote nothing else under `~` — and `qroky uninstall` does
  all of this for you.
- **See everything a pending update changes:**
  `qroky details`
- **Apply a pending update (only after you explicitly confirm — with no
  update pending this changes nothing and says so):**
  `qroky update` — if you have made your own edits inside
  the vendored `framework/` folder, the installer SHOWS you exactly what
  would be affected before touching anything; it never silently overwrites
  your changes.

## Safe to re-run, always

Every step the installer takes is a "check, then do" pair: on a healthy,
already-set-up workspace, running `install.sh` again is a free health
check that changes nothing and re-asks nothing. If the installer gets
killed partway through (power loss, closed terminal, anything), running it
again resumes exactly where it left off — the answers you already gave are
remembered in `install-state.json` inside your workspace, a plain text file
you're welcome to read.

## Backup and restore

If you turned the backup on (question 8), a private copy of your Qroky
folder named `qroky-backup` lives in **your own** GitHub account — nobody
else's, and nobody else can see it. Restoring on any computer is one
command:

```
gh repo clone qroky-backup
```

Then run `bash install.sh` once inside the restored folder — it re-attaches
the pinned rulebook and re-checks everything, asking nothing you already
answered. Your secret files (the Telegram token and anything secret-shaped)
are excluded from every backup by a `.gitignore` the installer writes for
you — they never leave this machine.

## A note on responsibility

The system produces drafts and analysis; legal, financial, and medical
decisions and signatures are always made by a human. Not professional
advice.

## Starting from a clean slate

One command removes everything the installer put on this MACHINE — the
scheduled jobs, the machine-wide gesture files (only if they carry this
kit's provenance), the `~/.qroky` state, the saved answers, and the bot
token file (announced before deletion; its contents are never read):

    qroky uninstall

Every step is printed before it runs, and the end is a list of what was
removed. Your working folder is NOT touched — its path is printed so you
can delete it yourself if you want a complete zero. On a machine with no
install this command is a polite no-op.

What this undoes, among the rest: the assistant answers to «qroky» in any
Claude Code session on this machine — that machine-wide setup is removed
entirely by this one command, together with the `qroky` command itself
(`~/.local/bin/qroky` and its PATH line — foreign lines in your profile are
never touched). To reinstall later — one command, from anywhere; your data
will stay:

    bash <(curl -fsSL https://raw.githubusercontent.com/qroky/framework/main/qroky.sh) install
