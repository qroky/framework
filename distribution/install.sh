#!/usr/bin/env bash
# install.sh — Qroky distribution installer (single entry point)
#
# Author: pilot-toolsmith (ATOM-101, Distribution Kit v1) · Date: 2026-07-10
# Depends only on: bash, POSIX tools (mkdir/cat/grep/sed/date/chmod/mv...),
# curl, git. Checks for each and says in plain words what is missing (H1).
#
# WHAT THIS SCRIPT DOES: interviews you at exactly seven points (language,
# working folder, Claude Code check, subscription check, Telegram opt-in,
# daily-support-sharing opt-in, morning-digest opt-in), sets up a private
# workspace with the assistant's rulebook vendored into it, and ends with
# how to say "qroky start". Every step is safe to re-run: it checks what is
# already done before doing anything, so re-running never repeats work or
# re-asks a question you already answered — the answers live in
# <workdir>/install-state.json (H3/H8), a plain-text file you can read.
#
# WHAT NEVER LEAVES THIS COMPUTER: your Telegram bot token (if you connect
# one) is written ONLY to <workdir>/.qroky/telegram.token, a file only you
# can read (mode 600) — never printed to the log, the state file, or sent
# anywhere except the one live check against Telegram's own servers when
# you first paste it in (see distribution/README.<lang>.md, "What leaves
# this computer", for the complete, exact list of what daily support
# sharing sends if you opt in — nothing is sent before you say yes).
#
# TEST HOOKS (sandbox-only, all clearly marked, default OFF, zero effect in
# production): QROKY_TEST_STUBS=1 skips one soft heuristic that would
# otherwise print a spurious notice in a sandbox with no real Claude Code
# login on record (see step_subscription). QROKY_TEST_DELAY_STEP /
# QROKY_TEST_DELAY_SECONDS insert a deliberate pause before one step's
# commit so a test harness can kill the process mid-install at a known
# point and prove the resume path for real (see the delay hook below
# step_telegram). Everything else a sandbox needs to fake — the `claude`
# binary, the `curl` calls to Telegram, `launchctl`, and the framework
# source itself — is faked by shadowing the real executables on PATH and by
# overriding the same environment variables this script already reads for
# that purpose (QROKY_WORKSPACE_DIR, QROKY_FRAMEWORK_SOURCE,
# QROKY_FRAMEWORK_REF) — this script runs completely unmodified in that
# path, exactly like 071-setup-kit's proven dry-run pattern.
#
# USAGE:
#   bash install.sh                    interview + setup (resumes safely)
#   bash install.sh --check-update     read-only: is a new framework release out?
#   bash install.sh --show-update-details   more detail on a pending update
#   bash install.sh --apply-update     apply a pending update (asks to confirm)
#   bash install.sh --enable-heartbeat turn the morning digest on later

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_START_TIME=$(date +%s)
WORKDIR_POINTER="$SCRIPT_DIR/.qroky-workdir-pointer"

# ---------------------------------------------------------------------------
# Small helpers usable before a language is chosen (English fallback only —
# every founder-facing string AFTER the language step goes through lang/*.sh)
# ---------------------------------------------------------------------------
say() { printf '%s\n' "$*"; }
elapsed_now() { local now; now=$(date +%s); echo "$(( now - SCRIPT_START_TIME ))s"; }

json_escape() { local s="$1"; s="${s//\\/\\\\}"; s="${s//\"/\\\"}"; printf '%s' "$s"; }

mask_secret() {
  local s="$1" n=${#1}
  if (( n <= 4 )); then printf '****'; else printf '****%s' "${s: -4}"; fi
}

is_affirmative() {
  local v; v="$(printf '%s' "${1:-}" | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]')"
  case "$v" in yes|y|da|d|"да"|"д"|1) return 0 ;; *) return 1 ;; esac
}

read_answer() {
  # $1 = value to use on EOF (never blocks a non-interactive/harness run)
  local ans
  if IFS= read -r ans; then printf '%s' "$ans"; else printf '%s' "$1"; fi
}

# ---------------------------------------------------------------------------
# Log — self-contained (readable without session context: timestamp, step,
# outcome on every line). Secrets are NEVER passed to this function raw —
# callers mask first (see mask_secret above). Harness checklist point 4/5.
# ---------------------------------------------------------------------------
log() {
  local line; line="$(date -u +%Y-%m-%dT%H:%M:%SZ) $*"
  [[ -n "${LOG_FILE:-}" ]] && printf '%s\n' "$line" >> "$LOG_FILE" 2>/dev/null || true
}

fail_to_human() {
  # $1 = step key (for the log), $2.. = the exact message lines to show
  local step="$1"; shift
  L_FAIL_HEADER
  printf '%s\n' "$*"
  L_FAIL_FOOTER
  log "$step FAILED-TO-HUMAN"
  exit 1
}

# ---------------------------------------------------------------------------
# Failure ladder (H9, harness-checklist point 3): self-diagnosis already
# happened by the time the caller invokes this (the check function names
# the cause); this wrapper only owns the "try the same known remedy twice,
# automatically, then stop" shape. Max 2 auto-attempts; the 3rd failure
# always falls through to the caller, which prints the concrete human
# action and exits — never a silent/endless retry.
# ---------------------------------------------------------------------------
run_with_ladder() {
  # First try + up to 2 automatic retries = 3 total tries; the 3rd failure
  # (not the 3rd retry) always falls through to the caller's human message
  # — "max 2 auto-attempts per step" (H9/harness-checklist point 3).
  local step="$1" fn="$2" attempt=0
  while true; do
    if "$fn"; then return 0; fi
    attempt=$((attempt + 1))
    log "$step LADDER-ATTEMPT-FAILED attempt=$attempt"
    if (( attempt >= 3 )); then return 1; fi
    L_RETRYING "$attempt"
    sleep 1
  done
}

# ---------------------------------------------------------------------------
# State — install-state.json (H8): flat, single-level JSON so every key
# grep-extracts unambiguously with no YAML/JSON library (POSIX+curl+git
# only, H1) — same "template is regular enough" reasoning as
# 072/telemetry/push.sh's status.yaml parsing. Whole file is rewritten fresh
# from the process's own shell variables on every commit (no associative
# arrays — bash 3.2 compatible, same constraint 071/RESULT.md flagged).
# ---------------------------------------------------------------------------
state_get() {
  [[ -f "$STATE_FILE" ]] || return 1
  grep -oE "\"$1\": *\"[^\"]*\"" "$STATE_FILE" | head -1 | sed -E "s/.*: *\"([^\"]*)\"/\1/"
}

state_load() {
  [[ -f "$STATE_FILE" ]] || return 1
  ANSWER_LANGUAGE="$(state_get answer_language || true)"
  ANSWER_WORKDIR="$(state_get answer_workdir || true)"
  ANSWER_TELEGRAM_OPTIN="$(state_get answer_telegram_optin || true)"
  ANSWER_TELEGRAM_TOKEN_STORED="$(state_get answer_telegram_token_stored || true)"
  ANSWER_TELEMETRY_OPTIN="$(state_get answer_telemetry_optin || true)"
  ANSWER_HEARTBEAT_OPTIN="$(state_get answer_heartbeat_optin || true)"
  STEP_LANGUAGE="$(state_get step_language || true)"
  STEP_WORKDIR="$(state_get step_workdir || true)"
  STEP_FRAMEWORK="$(state_get step_framework || true)"
  STEP_CLAUDE_CODE="$(state_get step_claude_code || true)"
  STEP_SUBSCRIPTION="$(state_get step_subscription || true)"
  STEP_TELEGRAM="$(state_get step_telegram || true)"
  STEP_TELEMETRY="$(state_get step_telemetry || true)"
  STEP_HEARTBEAT="$(state_get step_heartbeat || true)"
  FRAMEWORK_SOURCE="$(state_get framework_source || true)"
  FRAMEWORK_REF="$(state_get framework_ref || true)"
  FRAMEWORK_TAG="$(state_get framework_tag || true)"
  return 0
}

state_commit() {
  local tmp; tmp="${STATE_FILE}.tmp.$$"
  mkdir -p "$(dirname "$STATE_FILE")"
  {
    printf '{\n'
    printf '  "version": 1,\n'
    printf '  "generated_at": "%s",\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    printf '  "answer_language": "%s",\n' "$(json_escape "${ANSWER_LANGUAGE:-}")"
    printf '  "answer_workdir": "%s",\n' "$(json_escape "${ANSWER_WORKDIR:-}")"
    printf '  "answer_telegram_optin": "%s",\n' "$(json_escape "${ANSWER_TELEGRAM_OPTIN:-}")"
    printf '  "answer_telegram_token_stored": "%s",\n' "$(json_escape "${ANSWER_TELEGRAM_TOKEN_STORED:-no}")"
    printf '  "answer_telemetry_optin": "%s",\n' "$(json_escape "${ANSWER_TELEMETRY_OPTIN:-}")"
    printf '  "answer_heartbeat_optin": "%s",\n' "$(json_escape "${ANSWER_HEARTBEAT_OPTIN:-}")"
    printf '  "step_language": "%s",\n' "$(json_escape "${STEP_LANGUAGE:-pending}")"
    printf '  "step_workdir": "%s",\n' "$(json_escape "${STEP_WORKDIR:-pending}")"
    printf '  "step_framework": "%s",\n' "$(json_escape "${STEP_FRAMEWORK:-pending}")"
    printf '  "step_claude_code": "%s",\n' "$(json_escape "${STEP_CLAUDE_CODE:-pending}")"
    printf '  "step_subscription": "%s",\n' "$(json_escape "${STEP_SUBSCRIPTION:-pending}")"
    printf '  "step_telegram": "%s",\n' "$(json_escape "${STEP_TELEGRAM:-pending}")"
    printf '  "step_telemetry": "%s",\n' "$(json_escape "${STEP_TELEMETRY:-pending}")"
    printf '  "step_heartbeat": "%s",\n' "$(json_escape "${STEP_HEARTBEAT:-pending}")"
    printf '  "framework_source": "%s",\n' "$(json_escape "${FRAMEWORK_SOURCE:-}")"
    printf '  "framework_ref": "%s",\n' "$(json_escape "${FRAMEWORK_REF:-}")"
    printf '  "framework_tag": "%s"\n' "$(json_escape "${FRAMEWORK_TAG:-}")"
    printf '}\n'
  } > "$tmp"
  mv "$tmp" "$STATE_FILE"
  log "STATE-COMMIT"
}

# ---------------------------------------------------------------------------
# Step 1 — language (IV-POINT:1:language). Printed in the neutral trilingual
# form (labels of each language name are self-explanatory in any language)
# because we do not know the answer yet. Resumed silently if already known.
# ---------------------------------------------------------------------------
step_language() {
  if [[ "${STEP_LANGUAGE:-}" == "done" && -n "${ANSWER_LANGUAGE:-}" ]]; then
    source "$SCRIPT_DIR/lang/${ANSWER_LANGUAGE}.sh"
    L_STEP_HEADER 1 "$(L_STEP_LANGUAGE_NAME)"
    L_LANGUAGE_SET "$ANSWER_LANGUAGE"
    return 0
  fi
  source "$SCRIPT_DIR/lang/en.sh"   # neutral fallback for the prompt itself
  L_STEP_HEADER 1 "$(L_STEP_LANGUAGE_NAME)"
  local tries=0 ans lang=""
  while (( tries < 5 )); do
    L_ASK_LANGUAGE
    ans="$(read_answer "")"          # IV-POINT:1:language
    case "$(printf '%s' "$ans" | tr '[:upper:]' '[:lower:]')" in
      1|en) lang="en" ;;
      2|ro) lang="ro" ;;
      3|ru) lang="ru" ;;
      "") tries=$((tries + 1)); continue ;;
      *) tries=$((tries + 1)); continue ;;
    esac
    break
  done
  [[ -z "$lang" ]] && lang="en"   # non-interactive/EOF fallback, documented (Deviations)
  ANSWER_LANGUAGE="$lang"
  source "$SCRIPT_DIR/lang/${lang}.sh"
  L_LANGUAGE_SET "$lang"
  STEP_LANGUAGE="done"
  # not committed yet — no workdir/STATE_FILE exists until step 2 completes;
  # see step_workdir for the first commit (both steps land together).
}

# ---------------------------------------------------------------------------
# Step 2 — working folder (IV-POINT:2:workdir). Also where STATE_FILE/
# LOG_FILE first come into existence, so this is the first possible commit.
# ---------------------------------------------------------------------------
resolve_candidate_workdir() {
  if [[ -n "${QROKY_WORKSPACE_DIR:-}" ]]; then
    printf '%s' "$QROKY_WORKSPACE_DIR"
  elif [[ -f "$WORKDIR_POINTER" ]]; then
    cat "$WORKDIR_POINTER"
  else
    printf '%s' "./qroky"
  fi
}

step_workdir() {
  L_STEP_HEADER 2 "$(L_STEP_WORKDIR_NAME)"
  if [[ "${STEP_WORKDIR:-}" == "done" && -n "${ANSWER_WORKDIR:-}" ]]; then
    WORKSPACE_DIR="$ANSWER_WORKDIR"
    L_WORKDIR_ALREADY
    return 0
  fi
  local suggested; suggested="$(resolve_candidate_workdir)"
  local abs_suggested
  abs_suggested="$(cd "$(dirname "$suggested")" 2>/dev/null && pwd)/$(basename "$suggested")" 2>/dev/null || abs_suggested="$suggested"
  L_ASK_WORKDIR "$abs_suggested"
  local ans; ans="$(read_answer "")"   # IV-POINT:2:workdir
  [[ -z "$ans" ]] && ans="$suggested"
  mkdir -p "$ans" || fail_to_human workdir \
    "Could not create the folder: $ans — check permissions/space, fix that, then run this installer again."
  WORKSPACE_DIR="$(cd "$ans" && pwd)"
  ANSWER_WORKDIR="$WORKSPACE_DIR"
  STATE_FILE="$WORKSPACE_DIR/install-state.json"
  LOG_FILE="$WORKSPACE_DIR/install.log"
  DECISIONS_DIR="$WORKSPACE_DIR/decisions"
  FRAMEWORK_DIR="$WORKSPACE_DIR/framework"
  TOKEN_FILE="$WORKSPACE_DIR/.qroky/telegram.token"
  mkdir -p "$DECISIONS_DIR" "$WORKSPACE_DIR/.qroky" "$WORKSPACE_DIR/mission" "$WORKSPACE_DIR/atoms"
  printf '%s' "$WORKSPACE_DIR" > "$WORKDIR_POINTER"
  L_WORKDIR_SET "$WORKSPACE_DIR"
  STEP_WORKDIR="done"
  state_commit
  log "workdir DONE path=$WORKSPACE_DIR"
}

# ---------------------------------------------------------------------------
# Framework vendoring — automatic, no question (not one of the 7 points).
# Adapts 071/bootstrap.sh Step 3 + the qroky skill's §4 vendoring pattern
# (PROVENANCE.md: source + commit + date). Self-update (H11) reads
# framework_tag/framework_ref back out of state to compare later.
# ---------------------------------------------------------------------------
_framework_vendor_attempt() {
  if [[ ! -d "$WORKSPACE_DIR/.git" ]]; then
    git init -q "$WORKSPACE_DIR" || return 1
  fi
  if [[ -e "$FRAMEWORK_DIR/.git" ]]; then
    git -C "$FRAMEWORK_DIR" fetch --quiet --tags origin || return 1
  else
    ( cd "$WORKSPACE_DIR" && git submodule add --quiet "$FRAMEWORK_SOURCE" framework ) || return 1
  fi
  local ref="$FRAMEWORK_REF" tag=""
  tag="$(git -C "$FRAMEWORK_DIR" tag -l 'v*' --sort=-v:refname 2>/dev/null | head -1)"
  if [[ -n "$tag" ]]; then
    ref="$tag"
  elif [[ -z "$ref" ]]; then
    ref="$(git -C "$FRAMEWORK_DIR" rev-parse HEAD)"
  fi
  git -C "$FRAMEWORK_DIR" checkout --quiet "$ref" || return 1
  FRAMEWORK_REF="$(git -C "$FRAMEWORK_DIR" rev-parse HEAD)"
  FRAMEWORK_TAG="$tag"
  cat > "$FRAMEWORK_DIR/PROVENANCE.md" <<EOF
# Provenance

- Source: $FRAMEWORK_SOURCE
- Commit: $FRAMEWORK_REF
- Release tag: ${tag:-"(none published yet — pinned to a commit)"}
- Vendored: $(date -u +%Y-%m-%dT%H:%M:%SZ)

This copy is read-only by convention — your own work lives outside this
folder (see mission/ and atoms/ at the top of your workspace).
EOF
  return 0
}

step_framework() {
  L_STEP_HEADER 3 "$(L_STEP_CLAUDE_NAME)"
  if [[ "${STEP_FRAMEWORK:-}" == "done" && -e "$FRAMEWORK_DIR/.git" ]]; then
    L_STEP_ALREADY_DONE
    return 0
  fi
  FRAMEWORK_SOURCE="${QROKY_FRAMEWORK_SOURCE:-${FRAMEWORK_SOURCE:-https://github.com/qroky/framework.git}}"
  FRAMEWORK_REF="${QROKY_FRAMEWORK_REF:-${FRAMEWORK_REF:-}}"
  if run_with_ladder framework _framework_vendor_attempt; then
    STEP_FRAMEWORK="done"
    state_commit
    log "framework DONE ref=$FRAMEWORK_REF tag=${FRAMEWORK_TAG:-none}"
  else
    STEP_FRAMEWORK="failed"
    state_commit
    fail_to_human framework \
      "Could not reach $FRAMEWORK_SOURCE to download the assistant's rulebook.
  Check the internet connection, then run this installer again — it will
  continue from exactly this step.
  If this keeps failing, whoever gave you this kit can send a local copy to
  point QROKY_FRAMEWORK_SOURCE at instead."
  fi
}

# ---------------------------------------------------------------------------
# Step 3 — Claude Code check (IV-POINT:3:claude_code — a check, not a
# question; no `read` call, per the method hint: install with human hints).
# No automatic remedy exists for "software not installed" — the human step
# IS the remedy, so this goes straight there without a retry ladder
# (documented design choice, harness-checklist point 3 note).
# ---------------------------------------------------------------------------
step_claude_code() {
  if [[ "${STEP_CLAUDE_CODE:-}" == "done" ]] && command -v claude >/dev/null 2>&1; then
    L_CLAUDE_FOUND "$(claude --version 2>&1 | head -n1)"
    return 0
  fi
  if ! command -v claude >/dev/null 2>&1; then
    STEP_CLAUDE_CODE="failed"; state_commit
    L_CLAUDE_MISSING
    log "claude_code FAILED-TO-HUMAN"
    exit 1
  fi
  L_CLAUDE_FOUND "$(claude --version 2>&1 | head -n1)"
  STEP_CLAUDE_CODE="done"
  state_commit
  log "claude_code DONE"
}

# ---------------------------------------------------------------------------
# Step 4 — subscription/login check (IV-POINT:4:subscription — a soft
# check, never blocks; "not a purchase flow" per method hints). The ONE
# QROKY_TEST_STUBS=1 hook in this script lives here: a sandbox HOME never
# has real Claude Code credentials, so without this hook every sandbox run
# would print a spurious notice that has nothing to do with what is under
# test. Production behavior (hook unset) is unaffected.
# ---------------------------------------------------------------------------
step_subscription() {
  L_STEP_HEADER 4 "$(L_STEP_SUBSCRIPTION_NAME)"
  if [[ "${STEP_SUBSCRIPTION:-}" == "done" ]]; then L_STEP_ALREADY_DONE; return 0; fi
  if [[ "${QROKY_TEST_STUBS:-0}" == "1" ]]; then
    L_SUBSCRIPTION_OK   # TEST HOOK — sandbox-only, see header comment
  elif [[ -f "$HOME/.claude.json" || -f "$HOME/.claude/credentials" || -d "$HOME/.config/claude" ]]; then
    L_SUBSCRIPTION_OK
  else
    L_SUBSCRIPTION_SOFT_NOTICE
  fi
  STEP_SUBSCRIPTION="done"
  state_commit
  log "subscription DONE (soft check)"
}

# ---------------------------------------------------------------------------
# Step 5 — Telegram opt-in (IV-POINT:5:telegram_optin, IV-POINT:5:telegram_token
# loop). Hand-held BotFather walkthrough -> live getMe validation -> token
# stored ONLY at TOKEN_FILE, mode 600, NEVER in state/log (H4).
# ---------------------------------------------------------------------------
_telegram_getme() {
  local token="$1" resp
  resp="$(curl -s --max-time 10 "https://api.telegram.org/bot${token}/getMe" 2>/dev/null || true)"
  if printf '%s' "$resp" | grep -q '"ok":true'; then
    printf '%s' "$resp" | grep -oE '"username":"[^"]*"' | head -1 | sed -E 's/.*:"([^"]*)"/\1/'
    return 0
  fi
  return 1
}

step_telegram() {
  L_STEP_HEADER 5 "$(L_STEP_TELEGRAM_NAME)"
  if [[ "${STEP_TELEGRAM:-}" == "done" ]]; then L_STEP_ALREADY_DONE; return 0; fi
  L_TELEGRAM_ASK_OPTIN
  local optin_ans; optin_ans="$(read_answer "n")"   # IV-POINT:5:telegram_optin
  if ! is_affirmative "$optin_ans"; then
    L_TELEGRAM_SKIPPED
    ANSWER_TELEGRAM_OPTIN="no"
    STEP_TELEGRAM="done"
    state_commit
    log "telegram DONE optin=no"
    return 0
  fi
  L_TELEGRAM_WALKTHROUGH
  local tries=0 token="" username=""
  while (( tries < 5 )); do
    L_TELEGRAM_ASK_TOKEN
    token="$(read_answer "skip")"   # IV-POINT:5:telegram_token
    if [[ "$(printf '%s' "$token" | tr '[:upper:]' '[:lower:]')" == "skip" || -z "$token" ]]; then
      token=""; break
    fi
    L_TELEGRAM_VALIDATING
    if username="$(_telegram_getme "$token")" && [[ -n "$username" ]]; then
      L_TELEGRAM_TOKEN_OK "$username"
      break
    fi
    L_TELEGRAM_TOKEN_BAD
    tries=$((tries + 1))
    token=""
  done
  if [[ -z "$token" ]]; then
    L_TELEGRAM_SKIPPED
    ANSWER_TELEGRAM_OPTIN="no"
    ANSWER_TELEGRAM_TOKEN_STORED="no"
  else
    ( umask 077; printf '%s' "$token" > "$TOKEN_FILE" )
    chmod 600 "$TOKEN_FILE"
    L_TELEGRAM_STORED "$(mask_secret "$token")"
    ANSWER_TELEGRAM_OPTIN="yes"
    ANSWER_TELEGRAM_TOKEN_STORED="yes"
  fi

  # TEST HOOK — sandbox-only kill-mid-install window (see header comment).
  # Absent in production: both env vars are unset, so this is a no-op.
  if [[ "${QROKY_TEST_DELAY_STEP:-}" == "telegram" ]]; then
    sleep "${QROKY_TEST_DELAY_SECONDS:-0}"
  fi

  STEP_TELEGRAM="done"
  state_commit
  log "telegram DONE optin=$ANSWER_TELEGRAM_OPTIN token_stored=$ANSWER_TELEGRAM_TOKEN_STORED"
}

# ---------------------------------------------------------------------------
# Step 6 — daily-support-sharing opt-in (IV-POINT:6:telemetry_optin).
# Shows exactly what would leave BEFORE asking (072 pattern) — the same
# whitelist push.sh (072-telemetry-showcase) implements; this step only
# records consent, it does not vendor push.sh itself (out of this atom's
# deliverable list — see RESULT.md Deviations).
# ---------------------------------------------------------------------------
step_telemetry() {
  L_STEP_HEADER 6 "$(L_STEP_TELEMETRY_NAME)"
  if [[ "${STEP_TELEMETRY:-}" == "done" ]]; then L_STEP_ALREADY_DONE; return 0; fi
  L_TELEMETRY_ASK_OPTIN
  local ans; ans="$(read_answer "n")"   # IV-POINT:6:telemetry_optin
  mkdir -p "$WORKSPACE_DIR/telemetry"
  if is_affirmative "$ans"; then
    rm -f "$WORKSPACE_DIR/telemetry/OFF"
    L_TELEMETRY_ON
    ANSWER_TELEMETRY_OPTIN="yes"
  else
    touch "$WORKSPACE_DIR/telemetry/OFF"
    L_TELEMETRY_OFF
    ANSWER_TELEMETRY_OPTIN="no"
  fi
  STEP_TELEMETRY="done"
  state_commit
  log "telemetry DONE optin=$ANSWER_TELEMETRY_OPTIN"
}

# ---------------------------------------------------------------------------
# Step 7 — morning-digest / heartbeat consent (IV-POINT:7:heartbeat_optin,
# H10). Generates a user-facing heartbeat runner + launchd plist adapted to
# THIS machine's own paths (never this repo's paths) regardless of the
# answer; "да" additionally loads it into launchd, "нет" leaves the file in
# place, uninstalled, plus the one-command enable instruction.
# ---------------------------------------------------------------------------
_write_heartbeat_files() {
  cat > "$WORKSPACE_DIR/.qroky/heartbeat.sh" <<EOF
#!/usr/bin/env bash
# Generated by install.sh — read-only daily digest + self-update check.
# Paths below are THIS machine's own (never the framework author's repo).
set -euo pipefail
WORKDIR="$WORKSPACE_DIR"
INSTALL_SH="$SCRIPT_DIR/install.sh"
OUT="\$WORKDIR/.qroky/heartbeat-\$(date +%Y-%m-%d).md"
{
  echo "# Qroky morning digest — \$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo ""
  echo "## What's waiting"
  find "\$WORKDIR/atoms" "\$WORKDIR/mission" -type f -newer "\$WORKDIR/install-state.json" 2>/dev/null | sed 's/^/- changed: /' || echo "- nothing new since last check"
  echo ""
  echo "## Framework update"
} > "\$OUT"
if [[ -x "\$INSTALL_SH" ]]; then
  bash "\$INSTALL_SH" --check-update >> "\$OUT" 2>&1 || true
fi
echo "Digest written to: \$OUT"
EOF
  chmod +x "$WORKSPACE_DIR/.qroky/heartbeat.sh"

  mkdir -p "$WORKSPACE_DIR/.qroky/launchd"
  local label="md.qroky.heartbeat.$(basename "$WORKSPACE_DIR")"
  cat > "$WORKSPACE_DIR/.qroky/launchd/$label.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key><string>$label</string>
    <key>ProgramArguments</key>
    <array><string>/bin/bash</string><string>$WORKSPACE_DIR/.qroky/heartbeat.sh</string></array>
    <key>StartCalendarInterval</key>
    <array>
        <dict><key>Weekday</key><integer>1</integer><key>Hour</key><integer>9</integer><key>Minute</key><integer>7</integer></dict>
        <dict><key>Weekday</key><integer>2</integer><key>Hour</key><integer>9</integer><key>Minute</key><integer>7</integer></dict>
        <dict><key>Weekday</key><integer>3</integer><key>Hour</key><integer>9</integer><key>Minute</key><integer>7</integer></dict>
        <dict><key>Weekday</key><integer>4</integer><key>Hour</key><integer>9</integer><key>Minute</key><integer>7</integer></dict>
        <dict><key>Weekday</key><integer>5</integer><key>Hour</key><integer>9</integer><key>Minute</key><integer>7</integer></dict>
    </array>
    <key>RunAtLoad</key><false/>
    <key>KeepAlive</key><false/>
    <key>StandardOutPath</key><string>$WORKSPACE_DIR/.qroky/launchd.stdout.log</string>
    <key>StandardErrorPath</key><string>$WORKSPACE_DIR/.qroky/launchd.stderr.log</string>
</dict>
</plist>
EOF
  printf '%s' "$label"
}

heartbeat_enable() {
  local label="$1"
  local dst="$HOME/Library/LaunchAgents/$label.plist"
  mkdir -p "$HOME/Library/LaunchAgents"
  cp "$WORKSPACE_DIR/.qroky/launchd/$label.plist" "$dst"
  launchctl bootout "gui/$(id -u)" "$dst" 2>/dev/null || true
  launchctl bootstrap "gui/$(id -u)" "$dst"
}

step_heartbeat() {
  L_STEP_HEADER 7 "$(L_STEP_HEARTBEAT_NAME)"
  if [[ "${STEP_HEARTBEAT:-}" == "done" ]]; then L_STEP_ALREADY_DONE; return 0; fi
  L_HEARTBEAT_ASK_OPTIN
  local ans; ans="$(read_answer "y")"   # IV-POINT:7:heartbeat_optin, default yes
  local label; label="$(_write_heartbeat_files)"
  if ! command -v launchctl >/dev/null 2>&1; then
    L_HEARTBEAT_NO_LAUNCHD "$WORKSPACE_DIR"
    ANSWER_HEARTBEAT_OPTIN="no"
  elif is_affirmative "$ans" || [[ -z "$ans" ]]; then
    heartbeat_enable "$label"
    L_HEARTBEAT_ON
    ANSWER_HEARTBEAT_OPTIN="yes"
  else
    L_HEARTBEAT_OFF
    ANSWER_HEARTBEAT_OPTIN="no"
  fi
  STEP_HEARTBEAT="done"
  state_commit
  log "heartbeat DONE optin=$ANSWER_HEARTBEAT_OPTIN"
}

# Shared by every flag-driven command (--check-update, --show-update-details,
# --apply-update, --enable-heartbeat): resolves the same workdir the
# interview would (env override, else the pointer file, else ./qroky), THEN
# loads state from it. Must resolve STATE_FILE before calling state_load —
# state_load only reads $STATE_FILE, it never computes it (caught by
# actually running the self-update scenario against a real sandbox; see
# run.log).
resolve_and_load_state() {
  local candidate; candidate="$(resolve_candidate_workdir)"
  if [[ ! -f "$candidate/install-state.json" ]]; then
    say "No install found at: $candidate"
    say "Run this installer once, without flags, first."
    exit 1
  fi
  WORKSPACE_DIR="$(cd "$candidate" && pwd)"
  STATE_FILE="$WORKSPACE_DIR/install-state.json"
  LOG_FILE="$WORKSPACE_DIR/install.log"
  DECISIONS_DIR="$WORKSPACE_DIR/decisions"
  FRAMEWORK_DIR="$WORKSPACE_DIR/framework"
  TOKEN_FILE="$WORKSPACE_DIR/.qroky/telegram.token"
  state_load
  source "$SCRIPT_DIR/lang/${ANSWER_LANGUAGE:-en}.sh"
}

cmd_enable_heartbeat() {
  resolve_and_load_state
  local label; label="$(_write_heartbeat_files)"
  if ! command -v launchctl >/dev/null 2>&1; then
    L_HEARTBEAT_NO_LAUNCHD "$WORKSPACE_DIR"
    exit 1
  fi
  heartbeat_enable "$label"
  L_HEARTBEAT_ON
  ANSWER_HEARTBEAT_OPTIN="yes"
  state_commit
}

# ---------------------------------------------------------------------------
# Finale (H5) — printed at the end of every successful run, fresh install
# or healthy rerun alike.
# ---------------------------------------------------------------------------
finale() { L_FINALE "$WORKSPACE_DIR"; log "FINALE-SHOWN"; }

# ---------------------------------------------------------------------------
# Self-update (H11). Release tags only, never main. Digest -> да/позже/
# подробнее -> apply only on explicit yes, mini-atom record in the USER's
# own decisions/, reconciliation of local edits shown before apply.
# ---------------------------------------------------------------------------
_latest_tag() { git -C "$FRAMEWORK_DIR" tag -l 'v*' --sort=-v:refname 2>/dev/null | head -1; }

cmd_check_update() {
  resolve_and_load_state
  git -C "$FRAMEWORK_DIR" fetch --quiet --tags origin 2>/dev/null || true
  local latest; latest="$(_latest_tag)"
  if [[ -z "$latest" ]]; then
    say "(no release tags published yet — nothing to compare against)"
    return 0
  fi
  if [[ "$latest" == "${FRAMEWORK_TAG:-}" ]]; then
    L_UPDATE_NONE
    return 0
  fi
  local changelog; changelog="$(git -C "$FRAMEWORK_DIR" tag -n99 "$latest" 2>/dev/null | sed '1s/^[^ ]*  *//' | head -3)"
  [[ -z "$changelog" ]] && changelog="(see the release for details)"
  L_UPDATE_AVAILABLE "${FRAMEWORK_TAG:-"(unversioned)"}" "$latest" "$changelog"
  printf '%s' "$latest" > "$WORKSPACE_DIR/.qroky/update-available"
}

cmd_show_update_details() {
  resolve_and_load_state
  local latest; latest="$(_latest_tag)"
  [[ -z "$latest" ]] && { say "(no release tags published yet)"; return 0; }
  git -C "$FRAMEWORK_DIR" tag -n99 "$latest"
}

cmd_apply_update() {
  resolve_and_load_state
  git -C "$FRAMEWORK_DIR" fetch --quiet --tags origin 2>/dev/null || true
  local latest; latest="$(_latest_tag)"
  if [[ -z "$latest" || "$latest" == "${FRAMEWORK_TAG:-}" ]]; then
    L_UPDATE_NONE
    return 0
  fi
  local conflict_text=""
  conflict_text="$(git -C "$FRAMEWORK_DIR" status --porcelain 2>/dev/null || true)"
  if [[ -n "$conflict_text" ]]; then
    L_UPDATE_CONFLICT
    printf '%s\n' "$conflict_text"
  fi
  L_UPDATE_ASK_CONFIRM
  local ans; ans="$(read_answer "no")"
  if ! is_affirmative "$ans"; then
    L_UPDATE_CANCELLED
    return 0
  fi
  local stashed=0
  if [[ -n "$conflict_text" ]]; then
    git -C "$FRAMEWORK_DIR" stash push -u -m "qroky-update-$(date +%s)" >/dev/null && stashed=1
  fi
  local old_tag="${FRAMEWORK_TAG:-"(unversioned)"}" old_ref="${FRAMEWORK_REF:-}"
  git -C "$FRAMEWORK_DIR" checkout --quiet "$latest"
  FRAMEWORK_REF="$(git -C "$FRAMEWORK_DIR" rev-parse HEAD)"
  FRAMEWORK_TAG="$latest"
  local pop_note="no local edits to reconcile"
  if [[ "$stashed" -eq 1 ]]; then
    if git -C "$FRAMEWORK_DIR" stash pop >/dev/null 2>&1; then
      pop_note="local edits re-applied cleanly after the update"
    else
      pop_note="local edits could NOT be re-applied automatically — they are safe in the stash; run: git -C \"$FRAMEWORK_DIR\" stash list"
    fi
  fi
  state_commit
  rm -f "$WORKSPACE_DIR/.qroky/update-available"
  mkdir -p "$DECISIONS_DIR"
  local record="$DECISIONS_DIR/UPDATE-$(date -u +%Y-%m-%d)-${latest}.md"
  cat > "$record" <<EOF
# Framework update applied

- From: $old_tag ($old_ref)
- To: $latest ($FRAMEWORK_REF)
- Confirmed by: you (explicit yes), $(date -u +%Y-%m-%dT%H:%M:%SZ)
- Local edits: $pop_note

$(git -C "$FRAMEWORK_DIR" tag -n99 "$latest" 2>/dev/null | sed '1s/^[^ ]*  *//')
EOF
  L_UPDATE_APPLIED "$old_tag" "$latest" "$record"
  log "self-update APPLIED $old_tag -> $latest"
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
main_interview() {
  if ! command -v git >/dev/null 2>&1; then
    say "SETUP STOPPED."
    say "git is not installed on this machine. Install it, then run this installer again."
    say "  Mac: open Terminal and type: xcode-select --install"
    say "  Windows: download and run the installer from https://git-scm.com/downloads"
    say "  Linux: install the 'git' package with this machine's package manager"
    exit 1
  fi
  if ! command -v curl >/dev/null 2>&1; then
    say "SETUP STOPPED."
    say "curl is not installed on this machine. Install it, then run this installer again."
    exit 1
  fi

  local candidate; candidate="$(resolve_candidate_workdir)"
  local resumed=0
  if [[ -f "$candidate/install-state.json" ]]; then
    WORKSPACE_DIR="$(cd "$candidate" && pwd)"
    STATE_FILE="$WORKSPACE_DIR/install-state.json"
    LOG_FILE="$WORKSPACE_DIR/install.log"
    DECISIONS_DIR="$WORKSPACE_DIR/decisions"
    FRAMEWORK_DIR="$WORKSPACE_DIR/framework"
    TOKEN_FILE="$WORKSPACE_DIR/.qroky/telegram.token"
    state_load
    resumed=1
  fi

  # Title: correct language immediately if resuming a known answer, English
  # (self-explanatory, neutral) on a first-ever run before language is
  # chosen — step_language below prints its own header either way.
  if [[ "$resumed" -eq 1 && -n "${ANSWER_LANGUAGE:-}" ]]; then
    source "$SCRIPT_DIR/lang/${ANSWER_LANGUAGE}.sh"
  else
    source "$SCRIPT_DIR/lang/en.sh"
  fi
  L_SETUP_TITLE
  say ""

  step_language;   say ""
  step_workdir;    say ""
  step_framework
  step_claude_code; say ""
  step_subscription; say ""
  step_telegram;   say ""
  step_telemetry;  say ""
  step_heartbeat;  say ""

  finale
  say ""
  say "(total elapsed: $(elapsed_now))"
}

case "${1:-}" in
  --check-update) cmd_check_update ;;
  --show-update-details) cmd_show_update_details ;;
  --apply-update) cmd_apply_update ;;
  --enable-heartbeat) cmd_enable_heartbeat ;;
  "") main_interview ;;
  *) say "Unknown option: $1"; say "Usage: install.sh [--check-update|--show-update-details|--apply-update|--enable-heartbeat]"; exit 2 ;;
esac
