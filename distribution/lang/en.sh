#!/usr/bin/env bash
# lang/en.sh — English strings for distribution/install.sh
#
# Author: pilot-toolsmith (ATOM-101, Distribution Kit v1) · Date: 2026-07-10
# Loaded by install.sh via `source`. Every function below prints ONE
# user-facing message. No method jargon (atom, verify, FEV, DoD, gate) — see
# the role's plain-language rule. Plain words only: checklist, rules, test,
# proof, step.
#
# Keep en.sh / ro.sh / ru.sh substance-identical: same steps, same order,
# same information — wording adapted to the language, not the content.

L_SETUP_TITLE() { printf '== Qroky setup ==\n'; }

L_STEP_HEADER() { printf 'Step %s of 9 — %s\n' "$1" "$2"; }
L_STEP_ALREADY_DONE() { printf '  already set up — nothing to do (health check)\n'; }

# v0.2 (GATE-027): the whole road in one paragraph, up front.
L_JOURNEY_MAP() {
  cat <<'EOF'
Here is the whole road: 9 questions, about 3 minutes of setup, and at the
end you get two ready lines to copy-paste for your first conversation.
Every question says which number it is; optional ones can be skipped with
a single Enter. Nothing installs behind your back.
EOF
}

L_STEP_LANGUAGE_NAME() { printf 'choose your language'; }
L_STEP_WORKDIR_NAME() { printf 'choose your working folder'; }
L_STEP_CLAUDE_NAME() { printf 'check the Claude Code assistant'; }
L_STEP_SUBSCRIPTION_NAME() { printf 'check your subscription'; }
L_STEP_TELEGRAM_NAME() { printf 'connect Telegram (optional)'; }
L_STEP_TELEMETRY_NAME() { printf 'daily support sharing (optional)'; }
L_STEP_HEARTBEAT_NAME() { printf 'morning digest (optional)'; }
L_STEP_MACHINEWIDE_NAME() { printf 'starting phrase everywhere on this machine (optional)'; }

L_ASK_LANGUAGE() {
  printf 'Which language do you want to use?\n'
  printf '  1) English (en)\n  2) Română (ro)\n  3) Русский (ru)\n'
  printf 'Type 1, 2, 3, or the code (en/ro/ru): '
}
L_LANGUAGE_SET() { printf '  language set: %s\n' "$1"; }

L_ASK_WORKDIR() {
  printf 'Where should your private Qroky folder live?\n'
  printf 'Press Enter to use the suggested folder, or type a different path.\n'
  printf 'Suggested: %s\n' "$1"
  printf '> '
}
L_WORKDIR_SET() { printf '  working folder: %s\n' "$1"; }
L_WORKDIR_ALREADY() { printf '  this folder is already your Qroky workspace — reusing it\n'; }

L_FRAMEWORK_VENDORING() { printf '  downloading the rulebook the assistant follows (pinned to one fixed version, so it never changes without asking you)...\n'; }
L_FRAMEWORK_ALREADY() { printf '  the rulebook is already in place — nothing to do (health check)\n'; }

# --- v0.1.2 (gesture wiring — automatic, not a question) ---
L_GESTURE_WIRING() { printf '  teaching this folder the starting phrase ("qroky start")...\n'; }
L_GESTURE_DONE() { printf '  starting phrase wired — a chat opened IN THIS FOLDER will understand "qroky start"\n'; }
L_GESTURE_ALREADY() { printf '  the starting phrase is already in place — nothing to do (health check)\n'; }

L_CLAUDE_FOUND() { printf '  Claude Code — found (%s)\n' "$1"; }
L_CLAUDE_MISSING() {
  printf 'The Claude Code assistant is not installed on this machine.\n'
  printf 'Install it, then run this installer again — it will pick up right here.\n'
  printf '  Instructions: https://claude.com/claude-code\n'
}

L_SUBSCRIPTION_OK() { printf '  subscription/login — looks active\n'; }
L_SUBSCRIPTION_SOFT_NOTICE() {
  printf 'NOTICE: could not confirm an active login/subscription automatically.\n'
  printf 'This is only a heads-up, not a stop — if "claude" already works for you,\n'
  printf 'you can ignore this. If not: run "claude" once and follow its own login\n'
  printf 'steps, then continue.\n'
}

L_TELEGRAM_ASK_OPTIN() {
  printf 'Enter = skip, connect later (one command: bash install.sh --enable-telegram).\n'
  printf 'Or: would you like your assistant on Telegram — a morning digest, updates,\n'
  printf 'and questions it can ask you on your phone? Type y to connect now: '
}
L_TELEGRAM_SKIPPED() { printf '  Telegram — skipped. Connect any time with one command:\n      bash install.sh --enable-telegram\n'; }
L_TELEGRAM_WALKTHROUGH() {
  cat <<'EOF'
  Let's create your own Telegram bot — this takes about 2 minutes:
    1. Open the Telegram app.
    2. In the search bar, type: BotFather (it has a blue checkmark).
    3. Open the chat with BotFather and send: /newbot
    4. It will ask for a name — type anything you like (e.g. "My Qroky").
    5. It will ask for a username — must end in "bot" (e.g. "my_qroky_bot").
    6. BotFather replies with a message containing a long code — this is
       your bot's TOKEN. It looks like: 123456789:ABCdefGhIJKlmNoPQRsTUVwxyZ
    7. Copy that whole code.
EOF
}
L_TELEGRAM_ASK_TOKEN() { printf 'Paste the token here (or type "skip" to skip this step): '; }
L_TELEGRAM_VALIDATING() { printf '  checking the token with Telegram...\n'; }
L_TELEGRAM_TOKEN_OK() { printf '  token works — connected to bot: %s\n' "$1"; }
L_TELEGRAM_TOKEN_BAD() {
  printf '  that token did not work. Common causes:\n'
  printf '    - a space or line break got copied along with it — copy again, carefully\n'
  printf '    - it was already reset — open BotFather, send /token, and use the new one\n'
  printf '  Try again, or type "skip" to skip this step.\n'
}
L_TELEGRAM_STORED() { printf '  token saved on this computer only (never sent anywhere else): %s\n' "$1"; }

# --- v0.2 (GATE-027 «дал ключ — бот пнул»): the loop closes inside question 5 ---
L_TELEGRAM_PRESS_START() {
  printf '  Now open your bot in Telegram — @%s — and press Start\n' "$1"
  printf '  (or send it any message). I am waiting for it here, up to %s seconds...\n' "$2"
}
L_TELEGRAM_BOUND() { printf '  got you — your Telegram is now linked to this assistant (only YOUR chat will ever be served)\n'; }
L_TG_HELLO_TEXT() { printf 'I am connected. Tomorrow morning I will send your first digest. — Qroky'; }
L_TELEGRAM_HELLO_SENT() { printf '  the bot just wrote back to you — check your phone\n'; }
L_TELEGRAM_HELLO_FAILED() {
  printf '  the link is set, but the hello message could not be sent right now (often a\n'
  printf '  network hiccup) — the bot will reach you on its next scheduled message.\n'
}
L_TELEGRAM_NO_START() {
  printf '  nobody pressed Start within the wait — that is fine, nothing broke.\n'
  printf '  Your token is saved; the bot connects later with one command:\n'
  printf '      bash install.sh --enable-telegram\n'
  printf '  Setup continues.\n'
}
L_TELEGRAM_HEAD_MISSING() {
  printf '  the Telegram assistant files are not in the downloaded rulebook (its version\n'
  printf '  predates this installer). Your token and link are saved. Try:\n'
  printf '      bash install.sh --apply-update   and then: bash install.sh --enable-telegram\n'
  printf '  Setup continues.\n'
}
L_TELEGRAM_DEPLOYING() { printf '  connecting the bot to this computer (checks every 30 seconds; daily digest at 09:05)...\n'; }
L_TELEGRAM_DEPLOYED() { printf '  Telegram assistant — ON (listener every 30 s, digest daily at 09:05; its files live in .qroky/telegram/ inside your workspace)\n'; }
L_TELEGRAM_LISTENER_OK() { printf '  first listener pass — healthy\n'; }
L_TELEGRAM_LISTENER_WARN() {
  printf '  NOTICE: the first listener pass reported a problem (details saved to the\n'
  printf '  install log). The scheduled jobs are still installed and will keep trying.\n'
}
L_TELEGRAM_SCHEDULE_FAILED() {
  printf '  NOTICE: the Telegram jobs could not be scheduled automatically right now.\n'
  printf '  Everything else is fine — your bot link is saved. Try again later with:\n'
  printf '      bash install.sh --enable-telegram\n'
}
L_TELEGRAM_NO_LAUNCHD() {
  printf 'NOTICE: this machine has no "launchctl" (common outside macOS), so the\n'
  printf 'Telegram jobs cannot be scheduled automatically. Your link is set — run\n'
  printf '%s/run-listener.sh every 30 s and %s/run-digest.sh daily with your own scheduler.\n' "$1" "$1"
}

L_TELEMETRY_ASK_OPTIN() {
  cat <<'EOF'
Daily support sharing — before asking, here is EXACTLY what would leave this
computer if you say yes. The complete list — nothing else is ever read:
  1. task progress files (STATUS.md)  — status word, date, task id only
  2. cost summaries (RESULT.md)       — token/time cost figures ONLY; the
                                        summary and content sections, where
                                        your product would be described,
                                        are never copied
  3. step logs (run.log)              — timestamps and step names only
  4. the status board (status.yaml)   — one line per task, free-text notes
                                        stripped
  5. independent check results (VERDICT.md) — the verdict line only, never
                                        the findings text
Free-text sentences are stripped from every one of these before copying.
Your code, specs, and product content are not on this list and are never
read. Note: saying yes today only records your choice — no sending
mechanism is installed by this installer, so nothing can leave yet; you
will be shown the sending script itself, line by line, before it is ever
added.
EOF
  printf 'Turn daily support sharing on? Yes/no (y/n), default n: '
}
L_TELEMETRY_ON() { printf '  daily support sharing — ON\n'; }
L_TELEMETRY_OFF() { printf '  daily support sharing — OFF (nothing is ever sent while this stays off)\n'; }

L_HEARTBEAT_ASK_OPTIN() {
  cat <<'EOF'
Morning digest — a short daily message: what got done, what is waiting for
you. Yes/no now, you can change your mind later. One honest line about how
it works: it only READS your own workspace to build the summary — it never
takes actions on its own and never sends anything anywhere except this
digest to you. Recommended: yes.
EOF
  printf 'Turn the morning digest on? Yes/no (y/n), default y: '
}
L_HEARTBEAT_ON() { printf '  morning digest — installed and ON\n'; }
L_HEARTBEAT_OFF() { printf '  morning digest — installed but OFF. Turn it on any time with:\n      bash install.sh --enable-heartbeat\n'; }
L_HEARTBEAT_NO_LAUNCHD() {
  printf 'NOTICE: this machine has no "launchctl" (common outside macOS), so the\n'
  printf 'morning digest cannot be scheduled automatically. Nothing else failed —\n'
  printf 'run it by hand any day with: bash %s/.qroky/heartbeat.sh\n' "$1"
}
L_HEARTBEAT_SCHEDULE_FAILED() {
  printf 'NOTICE: the morning digest could not be scheduled automatically right now.\n'
  printf 'Everything else finished fine — the digest is installed but off.\n'
  printf 'Try again later with:\n      bash install.sh --enable-heartbeat\n'
}

L_FINALE() {
  cat <<EOF

== Setup finished. Nothing failed. ==

Copy-paste this into your terminal:

    cd $1 && claude

then say:

    qroky start

(In VS Code instead: File → Open Folder → $1 → start a new chat — same phrase.)

One honest note: the FIRST time claude starts, it asks a couple of its own
questions (color theme, login) — that is normal; answer them and continue.
Your first 5 minutes are described in the README next to this installer
("Your first 5 minutes").
EOF
}

L_FAIL_HEADER() { printf '\nSETUP STOPPED.\n'; }
L_FAIL_FOOTER() {
  printf '\nNothing was changed silently — the message above is the whole story.\n'
  printf 'Fix that one thing, then run this installer again; it picks up exactly here.\n'
}
L_RETRYING() { printf '  that did not work — trying again automatically (attempt %s of 2)...\n' "$1"; }

L_UPDATE_AVAILABLE() {
  local from="$1" to="$2" changelog="$3"
  cat <<EOF
A new version of the framework your assistant follows is available: $from -> $to
What improves for you:
$changelog
To accept now:   bash install.sh --apply-update
To see more:     bash install.sh --show-update-details
To decide later: do nothing — you will see this again next time
EOF
}
L_UPDATE_NONE() { printf '  no update available — you are on the latest release\n'; }
L_UPDATE_CONFLICT() {
  printf '\nYour own copy has local changes that the update would touch. Nothing was\n'
  printf 'overwritten. Here is exactly what differs:\n'
}
L_UPDATE_ASK_CONFIRM() { printf 'Apply this update now? Type "yes" to confirm, anything else cancels: '; }
L_UPDATE_APPLIED() { printf '  update applied: %s -> %s. A record was written to: %s\n' "$1" "$2" "$3"; }
L_UPDATE_CANCELLED() { printf '  update cancelled — nothing changed\n'; }

# --- v0.1.1 amendment (ATOM-102, INFO-030 p.3/p.4): backup + disclaimer ---
L_STEP_BACKUP_NAME() { printf 'backup to your own GitHub (optional)'; }
L_BACKUP_ASK_OPTIN() {
  cat <<'EOF'
Backup — keep a private, off-computer copy of your workspace, so a lost or
broken computer never means lost work. One honest line about where it goes:
the backup is stored in YOUR OWN private GitHub account — nobody else's;
nobody but you can see it. Recommended: yes.
EOF
  printf 'Turn the backup on? Yes/no (y/n), default y: '
}
L_BACKUP_GH_MISSING() {
  printf '  the small helper program "gh" (GitHub'\''s own command line tool) is not\n'
  printf '  on this machine, so the backup cannot be set up right now. Nothing else\n'
  printf '  is affected — setup continues without the backup.\n'
  printf '  To add it later:\n'
  printf '    1. Install gh: Mac: brew install gh   |   other: https://cli.github.com\n'
  printf '    2. Run: bash install.sh --enable-backup\n'
}
L_BACKUP_AUTH_WALKTHROUGH() {
  cat <<'EOF'
  Let's connect your own GitHub account — about 2 minutes, no prior
  knowledge needed (GitHub is a free service for storing private copies
  of folders; your copy will be visible only to you):
    1. A sign-in helper will start right now, in this window.
    2. If you don't have a GitHub account yet, it will offer to create
       one — free, only an email address is needed.
    3. Pick "Login with a web browser" when asked.
    4. It shows a short one-time code — copy it.
    5. Your browser opens; paste the code there and approve.
    6. Come back to this window — setup continues by itself.
EOF
}
L_BACKUP_AUTH_FAILED() {
  printf '  could not connect the GitHub account this time. Nothing else is\n'
  printf '  affected — setup continues without the backup.\n'
  printf '  To try again later: bash install.sh --enable-backup\n'
}
L_BACKUP_CREATING() { printf '  creating your private backup copy and sending the first snapshot...\n'; }
L_BACKUP_DONE() {
  printf '  backup is ON — a private copy named "%s" now lives in YOUR GitHub account.\n' "$1"
  printf '  To restore on any computer (one command): gh repo clone %s\n' "$1"
  printf '  (your secret files — like the Telegram token — are never included in the backup)\n'
}
L_BACKUP_FAILED() {
  printf '  the first backup could not be completed (often a network hiccup).\n'
  printf '  Nothing else is affected — setup continues without the backup.\n'
  printf '  To try again later: bash install.sh --enable-backup\n'
}
L_BACKUP_SKIPPED() {
  printf '  backup — off, as you chose. Turn it on any time with:\n'
  printf '      bash install.sh --enable-backup\n'
}
L_DISCLAIMER() {
  printf 'A note on responsibility: the system produces drafts and analysis; legal,\n'
  printf 'financial, and medical decisions and signatures are always made by a human.\n'
  printf 'Not professional advice.\n'
}

# --- v0.2 (ATOM-104, GATE-028): question 9 — machine-wide starting phrase ---
L_MACHINEWIDE_ASK_OPTIN() {
  cat <<'EOF'
Make "qroky start" work in ANY chat on this machine, not only in your
working folder? [we recommend: yes] One honest line about what that means:
we would write exactly two files into ~/.claude (a copy of the phrase's
rulebook page and a short trigger note) — nothing else, and both are named
to you and easy to remove.
EOF
  printf 'Type y for machine-wide; Enter = no, working folder only: '
}
L_MACHINEWIDE_DONE() {
  printf '  done — "qroky start" now works in any chat on this machine.\n'
  printf '  Exactly two files were written (to remove, delete them):\n'
  printf '    ~/.claude/skills/qroky/SKILL.md\n'
  printf '    the marked block in ~/.claude/CLAUDE.md (between the qroky-machinewide markers)\n'
}
L_MACHINEWIDE_SKIPPED() { printf '  as you chose: the phrase works in your working folder only. Nothing was written outside it.\n'; }
L_MACHINEWIDE_FAILED() {
  printf '  NOTICE: the machine-wide setup did not succeed (most often: the rulebook\n'
  printf '  version predates this installer, or ~/.claude is not writable). Nothing\n'
  printf '  else is affected — the phrase still works in your working folder, and you\n'
  printf '  can re-run this installer any time to try again.\n'
}
