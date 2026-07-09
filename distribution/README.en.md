# Qroky — self-service install

## What this installer does

One script, `install.sh`, takes a clean computer to a working assistant in
under 15 minutes. It asks you exactly **seven questions** (listed below),
sets up a private folder on your own computer, and ends with the words you
say to start your first conversation. It never asks anything beyond those
seven questions — every other line it prints is either progress, a check
result, or (on a real problem) a plain-language fix instruction naming the
exact next step.

## The one-liner

```
bash install.sh
```

Run it from the folder where you unpacked/cloned this kit. If something is
missing (git, curl, the Claude Code assistant itself), the script stops and
tells you exactly what to install and how — then you run the same command
again, and it continues from exactly where it stopped. Nothing is repeated,
nothing you already answered is asked twice.

## The seven questions

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
5. **Telegram (optional)** — want a morning digest and updates through
   Telegram? If yes, the installer walks you through creating your own bot
   with BotFather, step by step, and checks the token works live before
   saving it. Skippable any time — type "skip".
6. **Daily support sharing (optional)** — see "What leaves this computer"
   below before you're asked. Off by default.
7. **Morning digest (optional)** — a short daily message: what got done,
   what's waiting for you. Recommended: yes. You can change your mind any
   time (see "Don't touch my instance" below).

## What leaves this computer

If you turn on daily support sharing at question 6, only short, structural
progress and cost information ever leaves this machine — never your
product's code, specs, or content. The exact whitelist and the script that
enforces it (deny-by-default: anything not on the list is skipped, never
read) live in this repository's `products/pilot-prerequisites-v1/
072-telemetry-showcase/telemetry/push.sh` — it is plain, readable bash, not
a black box. Nothing is ever sent while this stays off, and it stays off
until you say yes.

## Don't touch my instance

The installer never changes anything you didn't ask for, and every
optional piece it turns on can be turned off just as easily:

- **Disable the morning digest:** delete the file inside your workspace's
  `.qroky/launchd/` folder from `~/Library/LaunchAgents/`, or simply don't
  answer "yes" at question 7 in the first place — the digest ships
  installed-but-off in that case, with the exact enable command printed
  for you.
- **Enable the morning digest later:** `bash install.sh --enable-heartbeat`
- **Check for a framework update (read-only, changes nothing):**
  `bash install.sh --check-update`
- **See more detail on a pending update:**
  `bash install.sh --show-update-details`
- **Apply a pending update (only after you explicitly confirm):**
  `bash install.sh --apply-update` — if you have made your own edits inside
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
