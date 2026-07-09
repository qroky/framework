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

L_STEP_HEADER() { printf 'Step %s of 7 — %s\n' "$1" "$2"; }
L_STEP_ALREADY_DONE() { printf '  already set up — nothing to do (health check)\n'; }

L_STEP_LANGUAGE_NAME() { printf 'choose your language'; }
L_STEP_WORKDIR_NAME() { printf 'choose your working folder'; }
L_STEP_CLAUDE_NAME() { printf 'check the Claude Code assistant'; }
L_STEP_SUBSCRIPTION_NAME() { printf 'check your subscription'; }
L_STEP_TELEGRAM_NAME() { printf 'connect Telegram (optional)'; }
L_STEP_TELEMETRY_NAME() { printf 'daily support sharing (optional)'; }
L_STEP_HEARTBEAT_NAME() { printf 'morning digest (optional)'; }

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
  printf 'Would you like a morning digest and updates through Telegram?\n'
  printf 'This step is optional — you can skip it and add it later.\n'
  printf 'Yes/no (y/n), default n: '
}
L_TELEGRAM_SKIPPED() { printf '  Telegram — skipped, you can add it later by running this installer again\n'; }
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

L_TELEMETRY_ASK_OPTIN() {
  cat <<'EOF'
Daily support sharing — before asking, here is EXACTLY what would leave this
computer, in plain words: short progress logs and cost summaries about HOW
the work went (never WHAT you are building — no code, no specs, no product
content). You can read the exact list and the script that sends it any time
at: distribution/README.<lang>.md, section "What leaves this computer".
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

L_FINALE() {
  cat <<EOF

== Setup finished. Nothing failed. ==

Your assistant is ready. To start:
  1. Open a terminal in: $1
  2. Type: claude
  3. Say: qroky start

That single phrase — "qroky start" — is all you need; it works in any
language you type it in.
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
