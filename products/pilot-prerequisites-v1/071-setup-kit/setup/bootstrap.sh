#!/usr/bin/env bash
# bootstrap.sh — Qroky pilot setup kit
#
# Author: pilot-toolsmith (ATOM-071, Pilot Prerequisites v1)
# Date: 2026-07-07 · Fix-round: ATOM-078 (register #4) — 2026-07-07
# Purpose: take a founder from "yes" to a ready, working private repo in one
#          command, with zero technical questions asked of the founder.
#
# What this script changes on this machine:
#   - creates (or reuses) a folder for a private Qroky workspace
#   - turns that folder into its own private git repository (the founder's,
#     not ours)
#   - adds a read-only, version-pinned copy of the Qroky framework inside it,
#     as a git submodule named `framework/` (never edited by the founder)
#   - writes one small file (`CLAUDE.md`) at the top of the workspace so the
#     Claude Code assistant knows how to work inside it
#   - copies the daily-support tooling (`telemetry/` + `consent/`) into the
#     workspace, OFF by default (see Step 5) — nothing is sent anywhere
#     until the founder has signed the separate consent document and the OFF
#     file has been removed
#   - registers a daily scheduler (cron) that will run the telemetry step
#     once installed — it does nothing while telemetry stays OFF
#   - writes one marker file (`.qroky/bootstrapped`) so re-running this
#     script is safe and never redoes work that is already done
#
# What this script does NOT do: it never reads or sends any of the founder's
# files anywhere. It only touches this machine and the one framework
# repository it is pinning a copy of. It never prompts for input — every
# problem it can hit is either fixed automatically or explained in one plain
# message with the exact next step; nothing here asks the founder a
# technical question.

set -euo pipefail

# ---------------------------------------------------------------------------
# Configuration — safe defaults. A founder never needs to touch these; they
# exist so this same script can be pointed at a test copy of the framework
# (see dry-run.sh) without changing a line of it.
# ---------------------------------------------------------------------------
QROKY_WORKSPACE_DIR="${QROKY_WORKSPACE_DIR:-./qroky}"
QROKY_FRAMEWORK_SOURCE="${QROKY_FRAMEWORK_SOURCE:-https://github.com/qroky/framework.git}"
# Pinned to the framework commit current when this kit was built. Known
# limitation (recorded in RESULT.md): the framework has no release tags yet,
# so this pins to a commit SHA rather than a version number; update this
# default when a first tag exists.
QROKY_FRAMEWORK_REF="${QROKY_FRAMEWORK_REF:-cff87836dfe6acf83ba6058ba3a2e2044456819e}"
# The kit a founder receives is one folder containing three subfolders:
# setup/ (this script lives here), telemetry/, consent/ — siblings. Default:
# the parent of this script's own folder. Overridable for testing only (see
# dry-run.sh, which assembles a sandbox kit folder with the same shape).
SCRIPT_DIR_FOR_KIT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
QROKY_KIT_ROOT="${QROKY_KIT_ROOT:-$(cd "$SCRIPT_DIR_FOR_KIT/.." && pwd)}"

SCRIPT_START_TIME=$(date +%s)

# ---------------------------------------------------------------------------
# Small helpers — every message a founder sees is written for a founder.
# ---------------------------------------------------------------------------
say() { printf '%s\n' "$*"; }

fail() {
  printf '\n'
  printf 'SETUP STOPPED.\n'
  printf '%s\n' "$*"
  printf '\n'
  printf 'Nothing was changed silently — the message above is the whole story.\n'
  printf 'Fix that one thing, then run this script again; it will pick up where it left off.\n'
  exit 1
}

warn() {
  printf '\n'
  printf 'NOTICE (setup still finished — this one part needs your attention):\n'
  printf '%s\n' "$*"
  printf '\n'
}

elapsed_now() {
  local now
  now=$(date +%s)
  echo "$(( now - SCRIPT_START_TIME ))s"
}

say "== Qroky setup =="
say ""

# ---------------------------------------------------------------------------
# Step 1 — prerequisites. Every failure here names the exact fix.
# ---------------------------------------------------------------------------
say "Step 1 of 6 — checking what is already on this machine"

if ! command -v git >/dev/null 2>&1; then
  fail "git is not installed on this machine. Install it, then run this script again.
  - Mac: open Terminal and type: xcode-select --install
  - Windows: download and run the installer from https://git-scm.com/downloads
  - Linux: install the 'git' package with this machine's package manager"
fi
say "  git — found ($(git --version))"

if ! command -v claude >/dev/null 2>&1; then
  fail "The Claude Code assistant is not installed on this machine. Install it, then run this script again.
  Instructions: https://claude.com/claude-code
  Whoever gave you this kit can also install it for you in a few minutes."
fi
say "  Claude Code — found ($(claude --version 2>&1 | head -n1))"
say "  step done, $(elapsed_now) elapsed so far"
say ""

# ---------------------------------------------------------------------------
# Step 2 — the private workspace folder. Idempotent: safe to run twice.
# ---------------------------------------------------------------------------
say "Step 2 of 6 — creating the private workspace at: $QROKY_WORKSPACE_DIR"
mkdir -p "$QROKY_WORKSPACE_DIR" \
  || fail "Could not create the folder $QROKY_WORKSPACE_DIR. Check that this machine has room and that this account can write there, then run this script again."
cd "$QROKY_WORKSPACE_DIR"
WORKSPACE_ABS="$(pwd)"

ALREADY_DONE=0
if [ -f ".qroky/bootstrapped" ]; then
  say "  this workspace is already set up (found .qroky/bootstrapped) — re-checking instead of redoing the work"
  ALREADY_DONE=1
fi

if [ ! -d ".git" ]; then
  git init -q \
    || fail "Could not create a private repository inside $QROKY_WORKSPACE_DIR. Check permissions, then run this script again."
  say "  private repository created — this is this founder's own; nobody else has access unless invited"
else
  say "  a repository already exists here — reusing it"
fi
say "  step done, $(elapsed_now) elapsed so far"
say ""

# ---------------------------------------------------------------------------
# Step 3 — the framework, added as a read-only, pinned dependency.
# ---------------------------------------------------------------------------
say "Step 3 of 6 — adding the rulebook the assistant follows (pinned to one fixed version, so it never changes without notice)"

if [ -d "framework" ]; then
  say "  already added — making sure it is on the pinned version"
  git -C framework fetch --quiet origin \
    || fail "Could not reach $QROKY_FRAMEWORK_SOURCE to update the rulebook copy. Check the internet connection, then run this script again."
  git -C framework checkout --quiet "$QROKY_FRAMEWORK_REF" \
    || fail "Could not switch the rulebook copy to its pinned version. Delete the 'framework' folder inside $QROKY_WORKSPACE_DIR and run this script again."
else
  git submodule add --quiet "$QROKY_FRAMEWORK_SOURCE" framework \
    || fail "Could not download the rulebook from $QROKY_FRAMEWORK_SOURCE.
  Check the internet connection, then run this script again.
  If this keeps failing, whoever gave you this kit can send a local copy to use instead."
  git -C framework checkout --quiet "$QROKY_FRAMEWORK_REF" \
    || fail "Downloaded the rulebook but could not select its pinned version. Run this script again."
  say "  added and pinned to version ${QROKY_FRAMEWORK_REF:0:12}"
fi
say "  this copy is read-only by convention: the founder's own work never goes inside framework/ (see CLAUDE.md, written next)"
say "  step done, $(elapsed_now) elapsed so far"
say ""

# ---------------------------------------------------------------------------
# Step 4 — connect the assistant to this workspace + the working skeleton.
# ---------------------------------------------------------------------------
say "Step 4 of 6 — connecting the assistant to this workspace"
mkdir -p mission atoms .qroky

if [ ! -f "CLAUDE.md" ]; then
  cat > CLAUDE.md <<'EOF'
# This workspace runs on the Qroky framework.

Before doing anything else in this repository, read
`framework/runtime/claude/README.md` — it explains how to work here.

Do not edit anything inside `framework/`. It is a read-only, version-pinned
copy shared by every founder using this kit; edits there are lost on the
next update and never affect this founder's own work.

This founder's own work lives in `mission/` and `atoms/` at the top of this
workspace.
EOF
  say "  connected — CLAUDE.md written at the top of the workspace"
else
  say "  already connected — CLAUDE.md exists"
fi
say "  step done, $(elapsed_now) elapsed so far"
say ""

# ---------------------------------------------------------------------------
# Step 5 — daily support tooling, installed but OFF until consent is signed.
# (ATOM-078 register #4: this is the wiring that was previously missing —
# before this step existed, telemetry could never actually run for a real
# founder, no matter what the consent document promised.)
# ---------------------------------------------------------------------------
say "Step 5 of 6 — installing daily support tooling (stays OFF until you sign the separate consent document)"

if [ ! -d "telemetry" ]; then
  if [ -d "$QROKY_KIT_ROOT/telemetry" ]; then
    cp -R "$QROKY_KIT_ROOT/telemetry" ./telemetry \
      || fail "Could not copy the telemetry tooling into $QROKY_WORKSPACE_DIR/telemetry. Check permissions, then run this script again."
    say "  telemetry tooling copied in"
  else
    warn "Could not find a telemetry/ folder next to this script's kit
  (looked in: $QROKY_KIT_ROOT/telemetry). This is expected if you were
  given only the setup/ folder on its own; ask whoever gave you this kit
  for the telemetry/ and consent/ folders as well, if you want daily
  support. Skipping this part — nothing else in this setup is affected."
  fi
else
  say "  telemetry tooling already present — reusing it"
fi

if [ ! -d "consent" ]; then
  if [ -d "$QROKY_KIT_ROOT/consent" ]; then
    cp -R "$QROKY_KIT_ROOT/consent" ./consent \
      || fail "Could not copy the consent document into $QROKY_WORKSPACE_DIR/consent. Check permissions, then run this script again."
    say "  consent document copied in — read it when you are ready; nothing is sent until you sign it"
  else
    warn "Could not find a consent/ folder next to this script's kit
  (looked in: $QROKY_KIT_ROOT/consent). Skipping this part for the same
  reason as above."
  fi
fi

# Ship OFF by default: telemetry only ever turns on after the founder reads
# and signs the consent document, never automatically. This reuses the same
# tested OFF mechanism push.sh already honors (telemetry/negative-test.sh
# TEST 2) rather than inventing a second one.
if [ -d "telemetry" ] && [ ! -f "telemetry/OFF" ]; then
  touch "telemetry/OFF"
  say "  daily support switched OFF for now — this is the safe default"
  say "  (once you have signed the consent document, delete the file named"
  say "  OFF inside the telemetry folder, or ask the assistant to do it for"
  say "  you, to turn daily support on)"
fi
say "  step done, $(elapsed_now) elapsed so far"
say ""

# ---------------------------------------------------------------------------
# Step 6 — register the daily scheduler (idempotent) + finish.
# The scheduler runs every day regardless of the OFF file above — it is the
# OFF file, not the schedule, that decides whether anything is actually
# read or sent. This keeps the two concerns separate: "does this run daily"
# (this step) vs. "is it allowed to send anything today" (consent + OFF,
# checked inside push.sh itself, every single run).
# ---------------------------------------------------------------------------
say "Step 6 of 6 — finishing up"

if [ -d "telemetry" ]; then
  SCHEDULE_MARKER="# qroky-telemetry-push:${WORKSPACE_ABS}"
  CRON_LINE="0 9 * * * cd \"${WORKSPACE_ABS}\" && ./telemetry/push.sh \"${WORKSPACE_ABS}\" >> \"${WORKSPACE_ABS}/telemetry/cron.log\" 2>&1 ${SCHEDULE_MARKER}"

  if ! command -v crontab >/dev/null 2>&1; then
    warn "This machine has no 'crontab' command, so daily support cannot be
  scheduled automatically (this is common on Windows outside Git Bash / WSL).
  Nothing failed — you can still run daily support by hand any day with:
      cd ${WORKSPACE_ABS} && ./telemetry/push.sh
  Or ask whoever gave you this kit to help schedule it another way."
  elif crontab -l 2>/dev/null | grep -qF "$SCHEDULE_MARKER"; then
    say "  daily schedule already registered for this workspace — nothing to add"
  else
    if { crontab -l 2>/dev/null; echo "$CRON_LINE"; } | crontab -; then
      say "  daily schedule registered (runs once a day; does nothing while telemetry/OFF exists)"
    else
      warn "Could not register the daily schedule automatically. Nothing else
  was affected. You can still run daily support by hand any day with:
      cd ${WORKSPACE_ABS} && ./telemetry/push.sh"
    fi
  fi
fi

mkdir -p .qroky
printf 'bootstrapped_at=%s\nframework_ref=%s\n' \
  "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$QROKY_FRAMEWORK_REF" > .qroky/bootstrapped
say "  step done, $(elapsed_now) elapsed so far"
say ""

TOTAL_ELAPSED=$(elapsed_now)
say "== Setup finished in $TOTAL_ELAPSED. Nothing failed. =="
say ""
say "What to do next:"
say "  1. Open this folder ($(pwd)) in a terminal, or open it in Claude Code."
say "  2. Type: claude"
say "  3. Say hello — the first conversation starts there."
say ""
say "This workspace is private. Nothing here is sent anywhere unless a"
say "separate, explicit agreement to share is signed — that is its own step,"
say "described in the kit's telemetry consent document, not this one."
