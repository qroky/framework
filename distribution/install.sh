#!/usr/bin/env bash
# install.sh — Qroky distribution installer (single entry point)
#
# Author: pilot-toolsmith (ATOM-101, Distribution Kit v1) · Date: 2026-07-10
# Depends only on: bash, POSIX tools (mkdir/cat/grep/sed/date/chmod/mv...),
# curl, git. Checks for each and says in plain words what is missing (H1).
#
# WHAT THIS SCRIPT DOES: interviews you at exactly eight points (language,
# working folder, Claude Code check, subscription check, Telegram opt-in,
# daily-support-sharing opt-in, morning-digest opt-in, backup opt-in to
# your OWN private GitHub — v0.1.1; the machine-wide starting phrase is set
# up WITHOUT a question since INFO-042 — a trace on the finale replaces the
# former question 9), sets up a private workspace with the assistant's rulebook
# vendored into it, wires the "qroky start" gesture into the workspace
# itself (v0.1.2, automatic — the gesture's rulebook page is copied to
# <workdir>/.claude/skills/qroky/SKILL.md and a marker-guarded trigger note
# is written to <workdir>/CLAUDE.md, so the closing promise actually works
# on THIS machine), and ends with a ready copy-paste block for the first
# conversation. v0.2 (ATOM-104, GATE-027/028): if you connect Telegram, the
# loop CLOSES inside question 5 — you paste the token, press Start on your
# own bot, the installer catches your chat, the bot immediately writes back
# («я на связи»), and the reviewed Telegram head is deployed (listener every
# 30 s + daily digest) with its state under <workdir>/.qroky/telegram/.
# Every step is safe to re-run: it checks what is
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
# step_telegram). QROKY_TEST_START_WAIT shrinks question 5's honest ~60 s
# wait for the owner's Start press so the no-Start timeout scenario need
# not spend a real minute (unset in production = 60). Everything else a
# sandbox needs to fake — the `claude`
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
#   bash install.sh --enable-backup    turn the GitHub backup on later (v0.1.1)
#   bash install.sh --enable-telegram  connect (or finish connecting) the
#                                      Telegram bot later — one command (v0.2)

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
  ANSWER_TELEGRAM_BOUND="$(state_get answer_telegram_bound || true)"
  ANSWER_MACHINEWIDE_OPTIN="$(state_get answer_machinewide_optin || true)"
  ANSWER_TELEMETRY_OPTIN="$(state_get answer_telemetry_optin || true)"
  ANSWER_HEARTBEAT_OPTIN="$(state_get answer_heartbeat_optin || true)"
  ANSWER_BACKUP_OPTIN="$(state_get answer_backup_optin || true)"
  STEP_LANGUAGE="$(state_get step_language || true)"
  STEP_WORKDIR="$(state_get step_workdir || true)"
  STEP_FRAMEWORK="$(state_get step_framework || true)"
  STEP_GESTURE="$(state_get step_gesture || true)"
  STEP_CLAUDE_CODE="$(state_get step_claude_code || true)"
  STEP_SUBSCRIPTION="$(state_get step_subscription || true)"
  STEP_TELEGRAM="$(state_get step_telegram || true)"
  STEP_TELEMETRY="$(state_get step_telemetry || true)"
  STEP_HEARTBEAT="$(state_get step_heartbeat || true)"
  STEP_BACKUP="$(state_get step_backup || true)"
  STEP_MACHINEWIDE="$(state_get step_machinewide || true)"
  BACKUP_REPO="$(state_get backup_repo || true)"
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
    printf '  "answer_telegram_bound": "%s",\n' "$(json_escape "${ANSWER_TELEGRAM_BOUND:-no}")"
    printf '  "answer_machinewide_optin": "%s",\n' "$(json_escape "${ANSWER_MACHINEWIDE_OPTIN:-}")"
    printf '  "answer_telemetry_optin": "%s",\n' "$(json_escape "${ANSWER_TELEMETRY_OPTIN:-}")"
    printf '  "answer_heartbeat_optin": "%s",\n' "$(json_escape "${ANSWER_HEARTBEAT_OPTIN:-}")"
    printf '  "answer_backup_optin": "%s",\n' "$(json_escape "${ANSWER_BACKUP_OPTIN:-}")"
    printf '  "step_language": "%s",\n' "$(json_escape "${STEP_LANGUAGE:-pending}")"
    printf '  "step_workdir": "%s",\n' "$(json_escape "${STEP_WORKDIR:-pending}")"
    printf '  "step_framework": "%s",\n' "$(json_escape "${STEP_FRAMEWORK:-pending}")"
    printf '  "step_gesture": "%s",\n' "$(json_escape "${STEP_GESTURE:-pending}")"
    printf '  "step_claude_code": "%s",\n' "$(json_escape "${STEP_CLAUDE_CODE:-pending}")"
    printf '  "step_subscription": "%s",\n' "$(json_escape "${STEP_SUBSCRIPTION:-pending}")"
    printf '  "step_telegram": "%s",\n' "$(json_escape "${STEP_TELEGRAM:-pending}")"
    printf '  "step_telemetry": "%s",\n' "$(json_escape "${STEP_TELEMETRY:-pending}")"
    printf '  "step_heartbeat": "%s",\n' "$(json_escape "${STEP_HEARTBEAT:-pending}")"
    printf '  "step_backup": "%s",\n' "$(json_escape "${STEP_BACKUP:-pending}")"
    printf '  "step_machinewide": "%s",\n' "$(json_escape "${STEP_MACHINEWIDE:-pending}")"
    printf '  "backup_repo": "%s",\n' "$(json_escape "${BACKUP_REPO:-}")"
    printf '  "framework_source": "%s",\n' "$(json_escape "${FRAMEWORK_SOURCE:-}")"
    printf '  "framework_ref": "%s",\n' "$(json_escape "${FRAMEWORK_REF:-}")"
    printf '  "framework_tag": "%s"\n' "$(json_escape "${FRAMEWORK_TAG:-}")"
    printf '}\n'
  } > "$tmp"
  mv "$tmp" "$STATE_FILE"
  log "STATE-COMMIT"
}

# ---------------------------------------------------------------------------
# Reinstall path (ATOM-106, INFO-040): running the installer over an
# OCCUPIED folder is a first-class scenario, never a raw git fatal. By
# construction framework/ is a recreatable read-only vendored copy; the
# founder's data lives NEXT to it (install-state, .qroky/, mission/,
# decisions/, atoms/, the workdir CLAUDE.md). Three entry cases:
#   (a) framework/ + live data  -> dialog [reinstall / update / cancel]
#   (b) framework/ alone        -> "orphaned clone — recreate?"
#   (c) clean folder            -> the ordinary install, byte-identical.
# The same (a)/(b) branch is the recovery path after a broken self-update.
# These prompts are deliberately OUTSIDE the 9-point interview inventory
# (same standing as the --apply-update confirmation): they exist only on an
# occupied-folder entry, never on a fresh install — hence this block sits
# ABOVE step_language, outside the inventory scan range.
# ---------------------------------------------------------------------------
_workdir_has_live_data() {
  local w="$1" d
  [[ -f "$w/install-state.json" || -f "$w/CLAUDE.md" ]] && return 0
  for d in .qroky .claude mission decisions atoms; do
    [[ -d "$w/$d" ]] || continue
    [[ -n "$(find "$w/$d" -type f -print -quit 2>/dev/null)" ]] && return 0
  done
  return 1
}

_framework_purge() {
  # Tolerates every half-state a broken clone or an interrupted self-update
  # can leave behind: dir present, dir gone with the submodule slot still
  # held (index entry, .gitmodules section, .git/modules copy) — a fresh
  # `git submodule add` dies on ANY of those with exactly the raw fatal the
  # founder must never meet. Raw git noise goes to the log, never the screen.
  local fw="$WORKSPACE_DIR/framework"
  if [[ -e "$WORKSPACE_DIR/.git" ]]; then
    git -C "$WORKSPACE_DIR" submodule deinit -f framework >>"${LOG_FILE:-/dev/null}" 2>&1 || true
    git -C "$WORKSPACE_DIR" rm -f -q framework >>"${LOG_FILE:-/dev/null}" 2>&1 || true
    git -C "$WORKSPACE_DIR" rm -rf -q --cached framework >>"${LOG_FILE:-/dev/null}" 2>&1 || true
    git -C "$WORKSPACE_DIR" config -f "$WORKSPACE_DIR/.gitmodules" \
      --remove-section submodule.framework >>"${LOG_FILE:-/dev/null}" 2>&1 || true
    git -C "$WORKSPACE_DIR" config --remove-section submodule.framework >>"${LOG_FILE:-/dev/null}" 2>&1 || true
    # Deliberately NOT deleting an emptied .gitmodules from the worktree:
    # `git rm` leaves the empty file registered in the index, and a
    # worktree-only deletion makes the next `git submodule add` die with
    # «please make sure that the .gitmodules file is in the working tree»
    # (caught by the harness on the first full run of scenario 3).
    rm -rf "$WORKSPACE_DIR/.git/modules/framework"
  fi
  rm -rf "$fw"
}

_reinstall_do_purge() {
  L_REINSTALL_START
  _framework_purge
  log "reinstall-gate FRAMEWORK-PURGED"
  if [[ -f "${STATE_FILE:-}" ]]; then
    STEP_FRAMEWORK="pending"; FRAMEWORK_REF=""; FRAMEWORK_TAG=""
    state_commit
  fi
}

_reinstall_dialog() {
  # Case (a). The answer words of all three locales are accepted on every
  # path (the q1 lesson, ATOM-105); Enter/EOF = cancel — the only safe
  # non-answer default. Cancel leaves without a trace.
  L_REINSTALL_FOUND "$WORKSPACE_DIR"
  local tries=0 ans choice=""
  while (( tries < 5 )); do
    L_REINSTALL_ASK
    ans="$(read_answer "")"
    case "$(printf '%s' "$ans" | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]')" in
      1|r|reinstall|переустановить|переустановка|reinstalez|reinstaleaza|reinstalează|reinstalare) choice="reinstall" ;;
      2|u|update|обновить|обновление|actualizez|actualizeaza|actualizează|actualizare) choice="update" ;;
      3|c|cancel|отмена|отменить|anulez|anuleaza|anulează|anulare|no|нет|nu|n|"") choice="cancel" ;;
      *) tries=$((tries + 1)); continue ;;
    esac
    if [[ "$choice" == "update" && ! -f "$WORKSPACE_DIR/install-state.json" ]]; then
      # post-uninstall there is no install record — nothing to diff an
      # update against; say so honestly and re-ask instead of dying later
      L_REINSTALL_UPDATE_NEEDS_STATE
      choice=""; tries=$((tries + 1)); continue
    fi
    break
  done
  [[ -z "$choice" ]] && choice="cancel"
  case "$choice" in
    cancel)
      L_REINSTALL_CANCELLED
      log "reinstall-gate CANCELLED"
      exit 0 ;;
    update)
      L_REINSTALL_UPDATE_ROUTE
      log "reinstall-gate ROUTE-UPDATE"
      QROKY_WORKSPACE_DIR="$WORKSPACE_DIR" cmd_apply_update
      exit 0 ;;
    reinstall)
      log "reinstall-gate REINSTALL chosen"
      _reinstall_do_purge
      return 0 ;;
  esac
}

_orphan_dialog() {
  # Case (b): framework/ with nothing alive next to it — an orphaned clone.
  L_ORPHAN_FOUND "$WORKSPACE_DIR"
  L_ORPHAN_ASK
  local ans; ans="$(read_answer "no")"
  if is_affirmative "$ans"; then
    log "reinstall-gate ORPHAN-RECREATE"
    _reinstall_do_purge
    return 0
  fi
  L_ORPHAN_DECLINED
  log "reinstall-gate ORPHAN-DECLINED"
  exit 0
}

_reinstall_gate() {
  # Fires only when the chosen folder is already occupied by framework/ or
  # by its leftover git half-state. A mid-interview resume is NOT a
  # reinstall — the idempotent walkthrough already owns that recovery; only
  # a COMPLETE install (or no record at all) reaches the dialog.
  [[ -n "${WORKSPACE_DIR:-}" ]] || return 0
  local occupied=0
  [[ -e "$WORKSPACE_DIR/framework" ]] && occupied=1
  [[ -d "$WORKSPACE_DIR/.git/modules/framework" ]] && occupied=1
  (( occupied == 1 )) || return 0
  if [[ -f "$WORKSPACE_DIR/install-state.json" && "${STEP_MACHINEWIDE:-}" != "done" ]]; then
    return 0
  fi
  if _workdir_has_live_data "$WORKSPACE_DIR"; then
    _reinstall_dialog
  else
    _orphan_dialog
  fi
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
      1|en|eng|english) lang="en" ;;
      2|ro|rom|romana|română|romaneste|românește) lang="ro" ;;
      3|ru|rus|русский|по-русски) lang="ru" ;;
      "") tries=$((tries + 1)); continue ;;
      *) tries=$((tries + 1)); continue ;;
    esac
    break
  done
  if [[ -z "$lang" ]]; then
    # ATOM-105: the EOF/5-unrecognized-answers fallback is now HONEST —
    # silent English here is exactly the «EN-финал» class of surprise.
    # Trilingual because no language was ever chosen on this path.
    lang="en"
    say "(no recognizable answer — continuing in English / răspuns nerecunoscut — continuăm în engleză / ответ не распознан — продолжаю по-английски. Change any time: bash install.sh)"
  fi
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
  elif [[ -f "$HOME/.qroky/workdir" ]]; then
    # ATOM-130 machine trace: the install is findable WITHOUT knowing the
    # clone path (the CEO's «нормальная команда uninstall» carry-over) —
    # a fresh clone, or qroky.sh run from anywhere, resolves through here.
    cat "$HOME/.qroky/workdir"
  else
    # v0.1.2 (M1): suggest a folder OUTSIDE this kit clone — the old
    # "./qroky" default landed the workspace inside distribution/.
    printf '%s' "$HOME/qroky-work"
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
  # ATOM-106 (INFO-040): if the chosen folder already carries an install
  # record this run did not resume from (the kit was re-cloned, so the
  # pointer next to install.sh was lost), ADOPT it before the gate — a
  # reinstall then walks idempotently over the recorded answers instead of
  # re-asking. The language chosen in THIS conversation wins over the
  # stored one; the workdir is the one just confirmed.
  if [[ -f "$STATE_FILE" ]]; then
    local _adopt_lang="${ANSWER_LANGUAGE:-}"
    state_load
    ANSWER_LANGUAGE="$_adopt_lang"
    ANSWER_WORKDIR="$WORKSPACE_DIR"
  fi
  # Reinstall gate (ATOM-106): an occupied folder gets a dialog, never a
  # raw git fatal. May exit (cancel / orphan-no / update route) — nothing
  # has been written into the folder yet, so leaving leaves no trace.
  _reinstall_gate
  LOG_FILE="$WORKSPACE_DIR/install.log"
  DECISIONS_DIR="$WORKSPACE_DIR/decisions"
  FRAMEWORK_DIR="$WORKSPACE_DIR/framework"
  TOKEN_FILE="$WORKSPACE_DIR/.qroky/telegram.token"
  mkdir -p "$DECISIONS_DIR" "$WORKSPACE_DIR/.qroky" "$WORKSPACE_DIR/mission" "$WORKSPACE_DIR/atoms"
  printf '%s' "$WORKSPACE_DIR" > "$WORKDIR_POINTER"
  # ATOM-130 machine trace: a second, machine-level pointer under ~/.qroky —
  # so `qroky.sh uninstall|update` (and any fresh clone) can find this
  # install from anywhere, without knowing the clone path. Best-effort:
  # a read-only ~ must never kill the install over a convenience pointer.
  { mkdir -p "$HOME/.qroky" && printf '%s' "$WORKSPACE_DIR" > "$HOME/.qroky/workdir"; } 2>/dev/null || true
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
# Sparse vendoring (ATOM-130, GATE-031): the working copy materializes ONLY
# the paths whitelisted in the tree's own distribution/dist-manifest — the
# user gets the PRODUCT, never the factory's working history. Implemented
# as git sparse-checkout (non-cone: the manifest names root FILES too, and
# cone mode force-materializes every root file) so the vendored copy stays
# a real tag-pinned git checkout — the self-update channel (fetch/checkout/
# status/stash) is untouched. A tree WITHOUT a manifest (v0.3.x tags and
# older) vendors whole, exactly as before — old releases lose nothing.
# Re-applied after every self-update checkout: a newer tag's manifest wins,
# and a FULL v0.3.x instance silently shrinks to the product on its first
# v0.4 update (untracked user files inside hidden dirs are left alone —
# sparse-checkout never deletes what git does not track).
# ---------------------------------------------------------------------------
_framework_apply_manifest() {
  local mf_ref="HEAD:distribution/dist-manifest" line patterns=()
  if ! git -C "$FRAMEWORK_DIR" cat-file -e "$mf_ref" 2>>"${LOG_FILE:-/dev/null}"; then
    log "framework MANIFEST-ABSENT (pre-v0.4 tree) — full vendoring, unchanged behavior"
    return 0
  fi
  while IFS= read -r line; do
    line="${line%%#*}"
    line="$(printf '%s' "$line" | tr -d '[:space:]')"
    [[ -n "$line" ]] && patterns+=("/$line")
  done < <(git -C "$FRAMEWORK_DIR" show "$mf_ref" 2>>"${LOG_FILE:-/dev/null}")
  if [[ ${#patterns[@]} -eq 0 ]]; then
    log "framework MANIFEST-EMPTY — full vendoring kept (a broken manifest must not brick the copy)"
    return 0
  fi
  if git -C "$FRAMEWORK_DIR" sparse-checkout set --no-cone "${patterns[@]}" 2>>"${LOG_FILE:-/dev/null}"; then
    log "framework SPARSE-APPLIED ${#patterns[@]} manifest paths"
  else
    # a git too old for sparse-checkout: degrade to the full copy, honestly
    # in the log — never a broken install over a cosmetic feature
    log "framework SPARSE-UNSUPPORTED (git too old?) — full vendoring fallback"
  fi
  return 0
}

_framework_vendor_attempt() {
  # Raw git noise (fatal:, Cloning into..., etc.) goes to install.log, not
  # the founder's screen — the founder sees the human-language messages of
  # step_framework only (round-2 fix, verify F7).
  if [[ ! -d "$WORKSPACE_DIR/.git" ]]; then
    git init -q "$WORKSPACE_DIR" 2>>"${LOG_FILE:-/dev/null}" || return 1
  fi
  if [[ -e "$FRAMEWORK_DIR/.git" ]]; then
    git -C "$FRAMEWORK_DIR" fetch --quiet --tags origin 2>>"${LOG_FILE:-/dev/null}" || return 1
  else
    ( cd "$WORKSPACE_DIR" && git submodule add --quiet "$FRAMEWORK_SOURCE" framework ) 2>>"${LOG_FILE:-/dev/null}" || return 1
  fi
  local ref="$FRAMEWORK_REF" tag=""
  tag="$(git -C "$FRAMEWORK_DIR" tag -l 'v*' --sort=-v:refname 2>/dev/null | head -1)"
  if [[ -n "$tag" ]]; then
    ref="$tag"
  elif [[ -z "$ref" ]]; then
    ref="$(git -C "$FRAMEWORK_DIR" rev-parse HEAD)"
  fi
  git -C "$FRAMEWORK_DIR" checkout --quiet "$ref" 2>>"${LOG_FILE:-/dev/null}" || return 1
  _framework_apply_manifest
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
  # PROVENANCE.md is the installer's own file, written untracked into the
  # framework checkout — exclude it from git status so it never shows up
  # as a phantom "your own copy has local changes" conflict on updates
  # (round-2 fix, verify F3).
  local gitdir
  gitdir="$(git -C "$FRAMEWORK_DIR" rev-parse --absolute-git-dir 2>/dev/null)" || return 1
  mkdir -p "$gitdir/info"
  grep -qx 'PROVENANCE.md' "$gitdir/info/exclude" 2>/dev/null \
    || echo 'PROVENANCE.md' >> "$gitdir/info/exclude"
  return 0
}

# Not one of the 7 interview points and not the Claude Code check — this is
# the rulebook download, announced under its own plain-language line
# (round-2 fix, verify F7: a framework-source failure used to appear under
# the "check the Claude Code assistant" header).
step_framework() {
  if [[ "${STEP_FRAMEWORK:-}" == "done" && -e "$FRAMEWORK_DIR/.git" ]]; then
    L_FRAMEWORK_ALREADY
    return 0
  fi
  L_FRAMEWORK_VENDORING
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
      "Could not download the assistant's rulebook (the address it tried: $FRAMEWORK_SOURCE).
  This is almost always the internet connection. Check it, then run this
  installer again — it will continue from exactly this step.
  If this keeps failing, whoever gave you this kit can send a local copy to
  point QROKY_FRAMEWORK_SOURCE at instead.
  (The technical details were saved to: ${LOG_FILE:-the install log})"
  fi
}

# ---------------------------------------------------------------------------
# Gesture wiring — automatic, no question (question inventory stays 8;
# v0.1.2, first G2 dry-run BLOCKING finding: the finale promised "qroky
# start" but nothing on the target machine ever knew the gesture — the
# skill file lived only on the author's computer). Wired at PROJECT level
# only (the gesture protocol's own rule: never write into ~ or system
# paths): the vendored rulebook page is copied to
# <workdir>/.claude/skills/qroky/SKILL.md and a marker-guarded trigger
# note is appended to <workdir>/CLAUDE.md — check→do, idempotent (re-run
# never duplicates the block; same pattern as the backup .gitignore).
# ---------------------------------------------------------------------------
GESTURE_MARKER_START="<!-- qroky-gesture:start -->"
GESTURE_MARKER_END="<!-- qroky-gesture:end -->"

_gesture_wire_attempt() {
  local src="$FRAMEWORK_DIR/runtime/claude/skill/qroky/SKILL.md"
  local dst="$WORKSPACE_DIR/.claude/skills/qroky/SKILL.md"
  # The source ships inside the vendored rulebook — if it is absent the
  # rulebook copy predates v0.1.2 and no retry will conjure it (the ladder
  # still runs for uniformity; the human message after it names the fix).
  [[ -s "$src" ]] || return 1
  mkdir -p "$(dirname "$dst")" || return 1
  # check→do: copy only when missing or different (keeps healthy reruns
  # write-free for H3's health-check promise).
  if [[ ! -f "$dst" ]] || ! cmp -s "$src" "$dst"; then
    cp "$src" "$dst" || return 1
  fi
  # check→do: append the trigger note only if its marker is absent —
  # re-runs leave exactly ONE block, never two.
  local claude_md="$WORKSPACE_DIR/CLAUDE.md"
  if ! grep -qF "$GESTURE_MARKER_START" "$claude_md" 2>/dev/null; then
    cat >> "$claude_md" <<EOF
$GESTURE_MARKER_START
# Qroky gesture (written by install.sh — safe to leave; re-runs never duplicate this block)
A chat message STARTING with «кроки» or «qroky» (case-insensitive) — including
«qroky start» — triggers the protocol in \`.claude/skills/qroky/SKILL.md\`:
read that file and follow it exactly (survey read-only → propose a one-screen
plan → wait for an explicit «го»). The word inside ordinary prose does NOT
trigger. Mission orientation: the confirmed two whys live in \`qroky/mission.md\`
once set up, and parent runs narrate themselves in \`NARRATIVE.md\` next to
\`STATUS.md\` (skill §7 M6).
$(L_MARKER_SESSION_NOTE)
$GESTURE_MARKER_END
EOF
  fi
  return 0
}

step_gesture() {
  local dst="$WORKSPACE_DIR/.claude/skills/qroky/SKILL.md"
  if [[ "${STEP_GESTURE:-}" == "done" && -s "$dst" ]] \
     && grep -qF "$GESTURE_MARKER_START" "$WORKSPACE_DIR/CLAUDE.md" 2>/dev/null; then
    L_GESTURE_ALREADY
    return 0
  fi
  L_GESTURE_WIRING
  if run_with_ladder gesture _gesture_wire_attempt; then
    L_GESTURE_DONE
    STEP_GESTURE="done"
    state_commit
    log "gesture DONE skill=$dst trigger=CLAUDE.md"
  else
    STEP_GESTURE="failed"
    state_commit
    fail_to_human gesture \
      "The starting phrase (\"qroky start\") could not be wired into your working
  folder: the rulebook copy downloaded in the previous step does not contain
  the gesture file it should (runtime/claude/skill/qroky/SKILL.md).
  This usually means the rulebook version is older than this installer.
  Try: bash install.sh --apply-update   — then run this installer again;
  if that shows no update, whoever gave you this kit can send the matching
  rulebook version.
  (The technical details were saved to: ${LOG_FILE:-the install log})"
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
  L_STEP_HEADER 3 "$(L_STEP_CLAUDE_NAME)"
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
# v0.2 (ATOM-104, GATE-027 «дал ключ — бот пнул»): the question closes its
# own loop — token accepted -> «нажмите Start» -> the installer polls
# getUpdates (honest ~60 s timeout) -> captures the owner's chat_id -> binds
# it (this IS the Telegram head's H4 binding file, written non-interactively)
# -> the bot IMMEDIATELY replies («я на связи; утром пришлю первый дайджест»)
# -> the reviewed head is deployed: profile.conf rendered, both launchd jobs
# installed, one listener pass health-checked. Skip = zero effort, stated
# FIRST on the question screen. Timeout / no Start / no token -> honest line,
# install continues, one later command finishes everything:
# bash install.sh --enable-telegram.
#
# Design notes (declared, not silent — full reasoning in the atom's run.log):
# - The head (framework/runtime/claude/telegram/) gets ZERO edits. Its state
#   home is pointed OUTSIDE the read-only vendored checkout — at
#   <workdir>/.qroky/telegram/ — via QROKY_TG_HOME/QROKY_TG_ROOT, the same
#   overrides the head already reads; two tiny wrapper scripts own those two
#   env lines and exec the head's own listener.sh/digest.sh unmodified.
# - This installer speaks the Bot API directly with curl (getMe/getUpdates/
#   sendMessage) instead of sourcing the head's lib.sh: both files define
#   log(), and a source would silently shadow one of them.
# - chat_id is parsed with sed/grep over the Bot API's machine-generated
#   compact JSON — keeps this script's bash+POSIX+curl+git-only contract.
# - Today's digest marker is pre-written before the jobs start, so the FIRST
#   digest genuinely arrives next morning — exactly what the hello promises —
#   instead of firing at install time whenever it is already past digest time.
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

# Wait for the owner to press Start (or send anything) — honest, timed wait,
# not a retry ladder: waiting longer is not a remedy, the enable-later
# command is. Sets TG_CHAT_ID / TG_UPDATE_ID on success.
TG_CHAT_ID=""
TG_UPDATE_ID=""
_telegram_wait_for_start() {
  local token="$1" wait_max="${QROKY_TEST_START_WAIT:-60}" waited=0 resp
  TG_CHAT_ID=""; TG_UPDATE_ID=""
  while (( waited <= wait_max )); do
    resp="$(curl -s --max-time 10 "https://api.telegram.org/bot${token}/getUpdates?timeout=0" 2>/dev/null || true)"
    if printf '%s' "$resp" | grep -q '"ok":true'; then
      TG_CHAT_ID="$(printf '%s' "$resp" | grep -oE '"chat":\{"id":-?[0-9]+' | tail -1 | grep -oE '\-?[0-9]+$' || true)"
      TG_UPDATE_ID="$(printf '%s' "$resp" | grep -oE '"update_id":[0-9]+' | tail -1 | grep -oE '[0-9]+$' || true)"
      [[ -n "$TG_CHAT_ID" ]] && return 0
    fi
    (( waited >= wait_max )) && break
    sleep 2; waited=$((waited + 2))
  done
  return 1
}

_telegram_send_hello() {
  # ≤2 auto-retries (the standard ladder shape), then an honest line.
  # Token never reaches the log: curl stderr is discarded, outcome only.
  local token="$1" chat="$2" text="$3" attempt resp
  for attempt in 1 2 3; do
    resp="$(curl -s --max-time 10 "https://api.telegram.org/bot${token}/sendMessage" \
      --data-urlencode "chat_id=$chat" --data-urlencode "text=$text" 2>/dev/null || true)"
    printf '%s' "$resp" | grep -q '"ok":true' && return 0
    log "telegram HELLO-ATTEMPT-FAILED attempt=$attempt"
    sleep 1
  done
  return 1
}

# Deploy the reviewed Telegram head from the vendored rulebook. check->do
# throughout: a healthy rerun rewrites nothing (H3). Returns 0 always —
# every degradation is an honest line plus the enable-later command, never
# a dead install (INPUT §1).
TG_HOME_DIR=""
_telegram_deploy_head() {
  local head_src="$FRAMEWORK_DIR/runtime/claude/telegram"
  TG_HOME_DIR="$WORKSPACE_DIR/.qroky/telegram"
  if [[ ! -f "$head_src/listener.sh" || ! -f "$head_src/digest.sh" ]]; then
    L_TELEGRAM_HEAD_MISSING
    log "telegram HEAD-MISSING (vendored rulebook predates v0.2; enable-later shown)"
    return 0
  fi
  L_TELEGRAM_DEPLOYING
  mkdir -p "$TG_HOME_DIR/state" "$TG_HOME_DIR/launchd"

  # profile.conf — the head's own config surface (sourced by its lib.sh):
  # token path = the kit's stored file; digest default morning; quiet hours
  # default night. Rewritten only when it differs (check->do).
  local profile_tmp="$TG_HOME_DIR/.profile.tmp.$$"
  cat > "$profile_tmp" <<EOF
# profile.conf — generated by install.sh; plain KEY=VALUE, edit freely.
TOKEN_FILE="$TOKEN_FILE"
DIGEST_TIME="09:05"
QUIET_START="23:00"
QUIET_END="08:00"
DETAIL_LEVEL="2"
LANGUAGE="${ANSWER_LANGUAGE:-ru}"
EOF
  if [[ ! -f "$TG_HOME_DIR/profile.conf" ]] || ! cmp -s "$profile_tmp" "$TG_HOME_DIR/profile.conf"; then
    mv "$profile_tmp" "$TG_HOME_DIR/profile.conf"
  else
    rm -f "$profile_tmp"
  fi

  # Wrapper scripts — the ONLY glue between launchd and the head: two env
  # lines pointing the head's state home and repo root at THIS workspace,
  # then exec the head's own scripts, byte-identical and unmodified.
  local w
  for w in listener digest; do
    local wrap_tmp="$TG_HOME_DIR/.run-$w.tmp.$$"
    cat > "$wrap_tmp" <<EOF
#!/usr/bin/env bash
# Generated by install.sh — runs the vendored Telegram head unmodified.
export QROKY_TG_HOME="$TG_HOME_DIR"
export QROKY_TG_ROOT="$WORKSPACE_DIR"
exec /bin/bash "$head_src/$w.sh"
EOF
    if [[ ! -f "$TG_HOME_DIR/run-$w.sh" ]] || ! cmp -s "$wrap_tmp" "$TG_HOME_DIR/run-$w.sh"; then
      mv "$wrap_tmp" "$TG_HOME_DIR/run-$w.sh"
    else
      rm -f "$wrap_tmp"
    fi
    chmod +x "$TG_HOME_DIR/run-$w.sh"
  done

  # Pre-mark today's digest BEFORE anything can run: the head's listener has
  # a same-day catch-up net that would otherwise send a digest at install
  # time whenever it is already past 09:05 — the first digest must arrive
  # next morning, as the hello just promised.
  touch "$TG_HOME_DIR/state/digest-sent-$(date +%Y-%m-%d)"

  # One listener pass, health-checked, BEFORE launchd takes over (afterwards
  # a manual pass could collide with the scheduled one on the head's lock
  # and prove nothing). Output goes to install.log.
  if ( export QROKY_TG_HOME="$TG_HOME_DIR" QROKY_TG_ROOT="$WORKSPACE_DIR"; \
       /bin/bash "$head_src/listener.sh" ) >>"${LOG_FILE:-/dev/null}" 2>&1; then
    L_TELEGRAM_LISTENER_OK
    log "telegram LISTENER-PASS-OK"
  else
    L_TELEGRAM_LISTENER_WARN
    log "telegram LISTENER-PASS-FAILED (details above in this log; jobs still installed)"
  fi

  # Both launchd jobs — kit-rendered plists pointing at the wrappers.
  cat > "$TG_HOME_DIR/launchd/md.qroky.telegram.listener.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key><string>md.qroky.telegram.listener</string>
    <key>ProgramArguments</key>
    <array><string>/bin/bash</string><string>$TG_HOME_DIR/run-listener.sh</string></array>
    <key>StartInterval</key><integer>30</integer>
    <key>RunAtLoad</key><true/>
    <key>KeepAlive</key><false/>
    <key>EnvironmentVariables</key>
    <dict>
        <key>PATH</key><string>$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin</string>
        <key>HOME</key><string>$HOME</string>
    </dict>
    <key>StandardOutPath</key><string>$TG_HOME_DIR/state/launchd.listener.stdout.log</string>
    <key>StandardErrorPath</key><string>$TG_HOME_DIR/state/launchd.listener.stderr.log</string>
    <key>ProcessType</key><string>Background</string>
</dict>
</plist>
EOF
  cat > "$TG_HOME_DIR/launchd/md.qroky.telegram.digest.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key><string>md.qroky.telegram.digest</string>
    <key>ProgramArguments</key>
    <array><string>/bin/bash</string><string>$TG_HOME_DIR/run-digest.sh</string></array>
    <key>StartCalendarInterval</key>
    <dict><key>Hour</key><integer>9</integer><key>Minute</key><integer>5</integer></dict>
    <key>RunAtLoad</key><false/>
    <key>KeepAlive</key><false/>
    <key>EnvironmentVariables</key>
    <dict>
        <key>PATH</key><string>$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin</string>
        <key>HOME</key><string>$HOME</string>
    </dict>
    <key>StandardOutPath</key><string>$TG_HOME_DIR/state/launchd.digest.stdout.log</string>
    <key>StandardErrorPath</key><string>$TG_HOME_DIR/state/launchd.digest.stderr.log</string>
    <key>ProcessType</key><string>Background</string>
</dict>
</plist>
EOF

  if command -v launchctl >/dev/null 2>&1; then
    if run_with_ladder telegram_jobs _telegram_bootstrap_attempt; then
      L_TELEGRAM_DEPLOYED
      log "telegram HEAD-DEPLOYED (listener 30s; digest 09:05 daily; state=$TG_HOME_DIR)"
    else
      L_TELEGRAM_SCHEDULE_FAILED
      log "telegram JOBS-ENABLE-FAILED-TO-HUMAN (files in place; enable-later shown)"
    fi
  else
    L_TELEGRAM_NO_LAUNCHD "$TG_HOME_DIR"
    log "telegram NO-LAUNCHD (files in place; manual scheduling instruction shown)"
  fi

  # ATOM-111 (router): enroll this workspace in the machine-level project
  # registry — ONE listener per machine serves every registered project.
  # Idempotent by construction (register.sh checks before appending); a
  # rulebook that predates the router simply has no register.sh — no-op.
  if [[ -f "$head_src/register.sh" ]]; then
    if /bin/bash "$head_src/register.sh" "$WORKSPACE_DIR" >>"${LOG_FILE:-/dev/null}" 2>&1; then
      log "telegram REGISTERED workspace in ${QROKY_REGISTRY:-$HOME/.qroky/registry}"
    else
      log "telegram REGISTER-FAILED (non-fatal; run runtime/claude/telegram/register.sh manually)"
    fi
  fi
  return 0
}

_telegram_bootstrap_attempt() {
  local label dst
  mkdir -p "$HOME/Library/LaunchAgents" || return 1
  for label in md.qroky.telegram.listener md.qroky.telegram.digest; do
    dst="$HOME/Library/LaunchAgents/$label.plist"
    cp "$TG_HOME_DIR/launchd/$label.plist" "$dst" || return 1
    launchctl bootout "gui/$(id -u)" "$dst" 2>/dev/null || true
    launchctl bootstrap "gui/$(id -u)" "$dst" 2>>"${LOG_FILE:-/dev/null}" || return 1
  done
  return 0
}

# First registry entry (comments/blanks stripped) — the machine's PRIMARY
# workspace, whose .qroky/telegram/ is the human-level home (ATOM-111).
_registry_primary() {
  local rf="${QROKY_REGISTRY:-$HOME/.qroky/registry}"
  [[ -f "$rf" ]] || return 0
  grep -v '^[[:space:]]*#' "$rf" 2>/dev/null | grep -v '^[[:space:]]*$' | head -1 || true
}

# The whole connect journey, shared by question 5 and --enable-telegram:
# token (reuse a stored one when it still works) -> Start press -> bind ->
# hello -> deploy. Sets ANSWER_TELEGRAM_* fields; never kills the install.
_telegram_connect_flow() {
  local token="" username="" tries=0

  # ATOM-111 (router): a machine whose PRIMARY workspace is already bound has
  # its one listener and one digest running — a SECOND workspace only joins
  # the registry. No second token ask, no second Start wait, no second hello,
  # no second launchd pair (NOT-DOING: per-project bots).
  local reg_primary; reg_primary="$(_registry_primary)"
  if [[ -n "$reg_primary" && "$reg_primary" != "$WORKSPACE_DIR" \
        && -s "$reg_primary/.qroky/telegram/state/chat_id" ]]; then
    local head_src="$FRAMEWORK_DIR/runtime/claude/telegram"
    if [[ -f "$head_src/register.sh" ]]; then
      /bin/bash "$head_src/register.sh" "$WORKSPACE_DIR" >>"${LOG_FILE:-/dev/null}" 2>&1 || true
    fi
    L_TELEGRAM_ALREADY_CONNECTED "$(basename "$reg_primary")"
    ANSWER_TELEGRAM_OPTIN="yes"
    ANSWER_TELEGRAM_TOKEN_STORED="primary"
    ANSWER_TELEGRAM_BOUND="yes"
    log "telegram ROUTER-REGISTERED (primary=$reg_primary; this workspace joins the shared listener — no second bot)"
    return 0
  fi
  # A token stored by an earlier run (e.g. the Start wait timed out then)
  # is reused when it still validates — no re-asking what is already known.
  if [[ -s "$TOKEN_FILE" ]]; then
    token="$(tr -d ' \n' < "$TOKEN_FILE")"
    if username="$(_telegram_getme "$token")" && [[ -n "$username" ]]; then
      L_TELEGRAM_TOKEN_OK "$username"
    else
      token=""
    fi
  fi
  if [[ -z "$token" ]]; then
    L_TELEGRAM_WALKTHROUGH
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
      ANSWER_TELEGRAM_BOUND="no"
      return 0
    fi
    ( umask 077; printf '%s' "$token" > "$TOKEN_FILE" )
    chmod 600 "$TOKEN_FILE"
    L_TELEGRAM_STORED "$(mask_secret "$token")"
    # Round-2 fix (verify F4): the MASKED confirmation goes into the log
    # too, so the redaction is auditable from install.log alone — never
    # the raw token (H4's negative grep must stay empty).
    log "telegram TOKEN-STORED masked=$(mask_secret "$token") file_mode=600"
  fi
  ANSWER_TELEGRAM_OPTIN="yes"
  ANSWER_TELEGRAM_TOKEN_STORED="yes"

  # «Дал ключ — бот пнул»: close the loop right here.
  L_TELEGRAM_PRESS_START "$username" "${QROKY_TEST_START_WAIT:-60}"
  if _telegram_wait_for_start "$token"; then
    printf '%s' "$TG_CHAT_ID" > "$WORKSPACE_DIR/.qroky/.chat_id.tmp.$$"
    mkdir -p "$WORKSPACE_DIR/.qroky/telegram/state"
    mv "$WORKSPACE_DIR/.qroky/.chat_id.tmp.$$" "$WORKSPACE_DIR/.qroky/telegram/state/chat_id"
    # Offset handoff: the head's listener starts AFTER the Start press we
    # just consumed — the owner's first message is never processed twice.
    if [[ -n "$TG_UPDATE_ID" ]]; then
      printf '%s' "$TG_UPDATE_ID" > "$WORKSPACE_DIR/.qroky/telegram/state/offset.tmp.$$" \
        && mv "$WORKSPACE_DIR/.qroky/telegram/state/offset.tmp.$$" "$WORKSPACE_DIR/.qroky/telegram/state/offset"
    fi
    ANSWER_TELEGRAM_BOUND="yes"
    L_TELEGRAM_BOUND
    log "telegram CHAT-BOUND (id written to the head's state, never to this log or state file)"
    if _telegram_send_hello "$token" "$TG_CHAT_ID" "$(L_TG_HELLO_TEXT "$WORKSPACE_DIR")"; then
      L_TELEGRAM_HELLO_SENT
      log "telegram HELLO-SENT"
    else
      L_TELEGRAM_HELLO_FAILED
      log "telegram HELLO-FAILED after ladder (binding kept; deploy continues)"
    fi
    _telegram_deploy_head
  else
    ANSWER_TELEGRAM_BOUND="no"
    L_TELEGRAM_NO_START
    log "telegram START-TIMEOUT (token stored; head not deployed — no half-alive unbound listener; enable-later shown)"
  fi
  return 0
}

step_telegram() {
  L_STEP_HEADER 5 "$(L_STEP_TELEGRAM_NAME)"
  if [[ "${STEP_TELEGRAM:-}" == "done" ]]; then L_STEP_ALREADY_DONE; return 0; fi
  L_TELEGRAM_ASK_OPTIN
  local optin_ans; optin_ans="$(read_answer "")"   # IV-POINT:5:telegram_optin
  if ! is_affirmative "$optin_ans"; then
    L_TELEGRAM_SKIPPED
    ANSWER_TELEGRAM_OPTIN="no"
    STEP_TELEGRAM="done"
    state_commit
    log "telegram DONE optin=no"
    return 0
  fi
  _telegram_connect_flow

  # TEST HOOK — sandbox-only kill-mid-install window (see header comment).
  # Absent in production: both env vars are unset, so this is a no-op.
  if [[ "${QROKY_TEST_DELAY_STEP:-}" == "telegram" ]]; then
    sleep "${QROKY_TEST_DELAY_SECONDS:-0}"
  fi

  STEP_TELEGRAM="done"
  state_commit
  log "telegram DONE optin=$ANSWER_TELEGRAM_OPTIN token_stored=${ANSWER_TELEGRAM_TOKEN_STORED:-no} bound=${ANSWER_TELEGRAM_BOUND:-no}"
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

# Round-2 fix (verify F8): a launchctl bootstrap failure used to abort the
# whole script (set -e) with raw launchd output and no human next step.
# The enable attempt now runs through the same failure ladder as every
# other step with a real automatic remedy (a transient gui-session error
# can cure on retry); a final failure degrades gracefully — the digest
# stays installed-but-off with the exact one-command enable instruction —
# instead of killing an otherwise-finished install.
HB_LABEL=""
_heartbeat_enable_attempt() {
  local dst="$HOME/Library/LaunchAgents/$HB_LABEL.plist"
  mkdir -p "$HOME/Library/LaunchAgents" || return 1
  cp "$WORKSPACE_DIR/.qroky/launchd/$HB_LABEL.plist" "$dst" || return 1
  launchctl bootout "gui/$(id -u)" "$dst" 2>/dev/null || true
  launchctl bootstrap "gui/$(id -u)" "$dst" 2>>"${LOG_FILE:-/dev/null}" || return 1
  return 0
}

step_heartbeat() {
  L_STEP_HEADER 7 "$(L_STEP_HEARTBEAT_NAME)"
  if [[ "${STEP_HEARTBEAT:-}" == "done" ]]; then L_STEP_ALREADY_DONE; return 0; fi
  L_HEARTBEAT_ASK_OPTIN
  local ans; ans="$(read_answer "y")"   # IV-POINT:7:heartbeat_optin, default yes
  HB_LABEL="$(_write_heartbeat_files)"
  if ! command -v launchctl >/dev/null 2>&1; then
    L_HEARTBEAT_NO_LAUNCHD "$WORKSPACE_DIR"
    ANSWER_HEARTBEAT_OPTIN="no"
  elif is_affirmative "$ans" || [[ -z "$ans" ]]; then
    if run_with_ladder heartbeat _heartbeat_enable_attempt; then
      L_HEARTBEAT_ON
      ANSWER_HEARTBEAT_OPTIN="yes"
    else
      L_HEARTBEAT_SCHEDULE_FAILED
      ANSWER_HEARTBEAT_OPTIN="no"
      log "heartbeat ENABLE-FAILED-TO-HUMAN (installed disabled; enable instruction shown)"
    fi
  else
    L_HEARTBEAT_OFF
    ANSWER_HEARTBEAT_OPTIN="no"
  fi
  STEP_HEARTBEAT="done"
  state_commit
  log "heartbeat DONE optin=$ANSWER_HEARTBEAT_OPTIN"
}

# ---------------------------------------------------------------------------
# Step 8 — backup opt-in to the USER'S OWN private GitHub
# (IV-POINT:8:backup_optin — v0.1.1 amendment, INFO-030 p.3: the interview's
# closed list was extended to eight points by its owner). Hand-held gh flow
# in the BotFather pattern; secrets never enter the backup (.gitignore
# written below + harness negative grep over the pushed tree); gh/network
# failures degrade with a concrete human action and the install CONTINUES
# without backup, never dies (INPUT §1).
# ---------------------------------------------------------------------------
BACKUP_REPO_NAME="qroky-backup"

_backup_ensure_gitignore() {
  # check->do: append the exclusion block only if its marker is absent.
  # Secrets never leave this machine: the token file and any secret-shaped
  # path are excluded from every backup; install.log too (it is a local
  # audit trail, not user work).
  local marker="# qroky-backup exclusions"
  if ! grep -qF "$marker" "$WORKSPACE_DIR/.gitignore" 2>/dev/null; then
    cat >> "$WORKSPACE_DIR/.gitignore" <<EOF
$marker — secrets and local logs never leave this machine
.qroky/telegram.token
*.token
.env
.env.*
*.pem
*.key
*secret*
*credential*
install.log
EOF
  fi
}

_backup_push_attempt() {
  # add + commit + create private repo + initial push. Identity fallback:
  # a non-technical founder's machine often has no git user.email — fall
  # back to a neutral backup identity WITHOUT overriding an existing one.
  if git -C "$WORKSPACE_DIR" config user.email >/dev/null 2>&1; then
    git -C "$WORKSPACE_DIR" add -A 2>>"${LOG_FILE:-/dev/null}" || return 1
    git -C "$WORKSPACE_DIR" diff --cached --quiet 2>/dev/null \
      || git -C "$WORKSPACE_DIR" commit -q -m "Qroky backup $(date -u +%Y-%m-%d)" 2>>"${LOG_FILE:-/dev/null}" || return 1
  else
    git -C "$WORKSPACE_DIR" add -A 2>>"${LOG_FILE:-/dev/null}" || return 1
    git -C "$WORKSPACE_DIR" diff --cached --quiet 2>/dev/null \
      || git -C "$WORKSPACE_DIR" -c user.name="Qroky backup" -c user.email="qroky-backup@local" \
           commit -q -m "Qroky backup $(date -u +%Y-%m-%d)" 2>>"${LOG_FILE:-/dev/null}" || return 1
  fi
  if git -C "$WORKSPACE_DIR" remote get-url qroky-backup >/dev/null 2>&1; then
    git -C "$WORKSPACE_DIR" push -q qroky-backup HEAD 2>>"${LOG_FILE:-/dev/null}" || return 1
  else
    gh repo create "$BACKUP_REPO_NAME" --private \
      --source "$WORKSPACE_DIR" --remote qroky-backup --push \
      >>"${LOG_FILE:-/dev/null}" 2>&1 || return 1
  fi
  return 0
}

_backup_flow() {
  # Returns 0 with ANSWER_BACKUP_OPTIN=yes on success; returns 0 with
  # ANSWER_BACKUP_OPTIN=no on every degradation path (the install always
  # continues — INPUT §1).
  if ! command -v gh >/dev/null 2>&1; then
    L_BACKUP_GH_MISSING
    ANSWER_BACKUP_OPTIN="no"
    log "backup DEGRADED gh-missing (install continues; enable-later shown)"
    return 0
  fi
  _backup_ensure_gitignore
  if ! gh auth status >/dev/null 2>&1; then
    L_BACKUP_AUTH_WALKTHROUGH
    if ! gh auth login --web --git-protocol https 2>>"${LOG_FILE:-/dev/null}"; then
      L_BACKUP_AUTH_FAILED
      ANSWER_BACKUP_OPTIN="no"
      log "backup DEGRADED auth-failed (install continues; enable-later shown)"
      return 0
    fi
  fi
  L_BACKUP_CREATING
  if run_with_ladder backup _backup_push_attempt; then
    BACKUP_REPO="$BACKUP_REPO_NAME"
    L_BACKUP_DONE "$BACKUP_REPO_NAME"
    ANSWER_BACKUP_OPTIN="yes"
    log "backup DONE repo=$BACKUP_REPO_NAME (private, user's own account)"
  else
    L_BACKUP_FAILED
    ANSWER_BACKUP_OPTIN="no"
    log "backup FAILED-TO-HUMAN after ladder (install continues; enable-later shown)"
  fi
  return 0
}

step_backup() {
  L_STEP_HEADER 8 "$(L_STEP_BACKUP_NAME)"
  if [[ "${STEP_BACKUP:-}" == "done" ]]; then L_STEP_ALREADY_DONE; return 0; fi
  L_BACKUP_ASK_OPTIN
  local ans; ans="$(read_answer "y")"   # IV-POINT:8:backup_optin, recommended yes
  if is_affirmative "$ans" || [[ -z "$ans" ]]; then
    _backup_flow
  else
    L_BACKUP_SKIPPED
    ANSWER_BACKUP_OPTIN="no"
    log "backup DONE optin=no (choice recorded, no nagging)"
  fi
  STEP_BACKUP="done"
  state_commit
  log "backup DONE optin=$ANSWER_BACKUP_OPTIN"
}

# ---------------------------------------------------------------------------
# Machine-wide starting phrase — EXACTLY two files under ~/.claude: a copy
# of the gesture's rulebook page at ~/.claude/skills/qroky/SKILL.md and a
# marker-guarded trigger note appended to ~/.claude/CLAUDE.md (created if
# absent) — and NOTHING else under ~ ever. History: v0.2/GATE-028 made this
# interview question 9 (explicit opt-in); INFO-042 (2026-07-11, lex
# posterior) REMOVED the question — the two files are written at every
# install, because the target user has no basis to answer and a wrong «no»
# strands the whole install. The vendored skill file documents the amended
# I3 exception with the same provenance. Idempotent (markers + cmp — re-runs
# never duplicate or re-copy); removable (the trace on the finale and the
# uninstall doc name both paths and the one command that removes it all).
# ---------------------------------------------------------------------------
MACHINEWIDE_MARKER_START="<!-- qroky-machinewide:start -->"
MACHINEWIDE_MARKER_END="<!-- qroky-machinewide:end -->"

_machinewide_wire_attempt() {
  local src="$FRAMEWORK_DIR/runtime/claude/skill/qroky/SKILL.md"
  local dst="$HOME/.claude/skills/qroky/SKILL.md"
  [[ -s "$src" ]] || return 1
  mkdir -p "$(dirname "$dst")" || return 1
  if [[ ! -f "$dst" ]] || ! cmp -s "$src" "$dst"; then
    cp "$src" "$dst" || return 1
  fi
  local claude_md="$HOME/.claude/CLAUDE.md"
  if ! grep -qF "$MACHINEWIDE_MARKER_START" "$claude_md" 2>/dev/null; then
    cat >> "$claude_md" <<EOF
$MACHINEWIDE_MARKER_START
# Qroky gesture, machine-wide (written by install.sh — INFO-042: set up at every install, with the removal named below; re-runs never duplicate this block)
A chat message STARTING with «кроки» or «qroky» (case-insensitive) — including
«qroky start» — in ANY folder on this machine triggers the protocol in
\`~/.claude/skills/qroky/SKILL.md\`: read that file and follow it exactly
(survey read-only → propose a one-screen plan → wait for an explicit «го»).
The word inside ordinary prose does NOT trigger.
To remove: delete this block (between its two marker comments) and the file
\`~/.claude/skills/qroky/SKILL.md\` — nothing else was written.
$(L_MARKER_SESSION_NOTE)
$MACHINEWIDE_MARKER_END
EOF
  fi
  return 0
}

# Machine-wide gesture — automatic since INFO-042 (2026-07-11, supersedes
# the GATE-028 q9 opt-in, lex posterior): question 9 asked for understanding
# the target user does not have, and a wrong/default «no» made the install
# useless («Кроки есть, но никто не знает где»). The same EXACTLY TWO files
# are written, idempotently; the perimeter did not grow by a single path.
# A TRACE replaces the question: the finale and the uninstall doc say what
# was written and name the one-command removal. The gesture is read-only
# until an explicit «го» by construction — foreign projects are protected
# by the gesture's behavior, not by install scope.
step_machinewide() {
  if [[ "${STEP_MACHINEWIDE:-}" == "done" ]] \
     && [[ -s "$HOME/.claude/skills/qroky/SKILL.md" ]] \
     && grep -qF "$MACHINEWIDE_MARKER_START" "$HOME/.claude/CLAUDE.md" 2>/dev/null; then
    L_MACHINEWIDE_ALREADY
    return 0
  fi
  L_MACHINEWIDE_WIRING
  if run_with_ladder machinewide _machinewide_wire_attempt; then
    L_MACHINEWIDE_DONE
    ANSWER_MACHINEWIDE_OPTIN="yes"
    STEP_MACHINEWIDE="done"
  else
    # Deliberately NOT marked done: a re-run retries this step, so «run the
    # installer again» stays a true sentence. The install itself continues —
    # this degradation never kills it.
    L_MACHINEWIDE_FAILED
    ANSWER_MACHINEWIDE_OPTIN="no"
    STEP_MACHINEWIDE=""
    state_commit
    log "machinewide FAILED-TO-HUMAN after ladder (left pending so a re-run retries; install continues)"
    return 0
  fi
  state_commit
  log "machinewide DONE (always-on, INFO-042)"
}

# ---------------------------------------------------------------------------
# The `qroky` command (ATOM-131, INFO-044 — «решить проблему, а не
# подсказывать»): a tiny launcher at ~/.local/bin/qroky, so update/uninstall
# work FROM ANYWHERE, forever, without knowing where any clone lives. The
# launcher carries NO logic — it resolves the machine's own kit copy
# (~/.qroky/kit; falls back to the install's vendored framework) and execs
# qroky.sh there. This is the THIRD machine-wide file (+ one possible PATH
# marker line in the shell profile, added ONLY when ~/.local/bin is not on
# PATH already): the finale names both, uninstall removes both. Never
# /usr/local/bin, never sudo. Best-effort — a read-only ~ never kills an
# install over a convenience command.
# ---------------------------------------------------------------------------
LAUNCHER_FILE="$HOME/.local/bin/qroky"
LAUNCHER_PATH_MARKER_START='# >>> qroky command (added by the Qroky installer, INFO-044; removed by `qroky uninstall`) >>>'
LAUNCHER_PATH_MARKER_END='# <<< qroky command <<<'
LAUNCHER_PATH_ADDED=""   # set to the profile file when a PATH line exists/was added

_launcher_profile() {
  case "${SHELL:-}" in
    */zsh)  printf '%s' "$HOME/.zshrc" ;;
    */bash) printf '%s' "$HOME/.bashrc" ;;
    *)      printf '%s' "$HOME/.profile" ;;
  esac
}

_launcher_wire() {
  if ! { mkdir -p "$HOME/.local/bin" \
         && cat > "$LAUNCHER_FILE" <<'LAUNCHER_EOF'
#!/bin/sh
# qroky — the Qroky command (installed by the Qroky installer, INFO-044;
# removed by `qroky uninstall`). No logic lives here: resolve the machine's
# own kit copy and hand everything to qroky.sh.
KIT="${QROKY_KIT_HOME:-$HOME/.qroky/kit}"
[ -f "$KIT/qroky.sh" ] && exec bash "$KIT/qroky.sh" "$@"
WD=""
[ -f "$HOME/.qroky/workdir" ] && WD="$(cat "$HOME/.qroky/workdir" 2>/dev/null)"
[ -n "$WD" ] && [ -f "$WD/framework/qroky.sh" ] && exec bash "$WD/framework/qroky.sh" "$@"
echo "qroky: no kit copy on this machine yet. Set it up with one command:"
echo "  bash <(curl -fsSL https://raw.githubusercontent.com/qroky/framework/main/qroky.sh) install"
exit 1
LAUNCHER_EOF
         chmod +x "$LAUNCHER_FILE"; } 2>>"${LOG_FILE:-/dev/null}"; then
    log "launcher WRITE-FAILED (best-effort — install continues; qroky.sh still works)"
    return 0
  fi
  # PATH line: only when ~/.local/bin is genuinely absent from PATH, and
  # only once — the marker is checked across every profile zsh/bash read
  # (both .zshrc AND .zprofile, carefully), so re-runs never duplicate it.
  case ":$PATH:" in
    *":$HOME/.local/bin:"*) log "launcher PATH-ALREADY (~/.local/bin on PATH — no profile line written)" ;;
    *)
      local prof existing=""
      for prof in "$HOME/.zshrc" "$HOME/.zprofile" "$HOME/.bashrc" "$HOME/.bash_profile" "$HOME/.profile"; do
        if [[ -f "$prof" ]] && grep -qF "$LAUNCHER_PATH_MARKER_START" "$prof"; then existing="$prof"; break; fi
      done
      if [[ -n "$existing" ]]; then
        LAUNCHER_PATH_ADDED="$existing"
        log "launcher PATH-MARKER-PRESENT ($existing) — not duplicated"
      else
        prof="$(_launcher_profile)"
        if { printf '\n%s\n' "$LAUNCHER_PATH_MARKER_START"
             printf 'export PATH="$HOME/.local/bin:$PATH"\n'
             printf '%s\n' "$LAUNCHER_PATH_MARKER_END"; } >> "$prof" 2>>"${LOG_FILE:-/dev/null}"; then
          LAUNCHER_PATH_ADDED="$prof"
          log "launcher PATH-LINE-ADDED ($prof)"
        else
          log "launcher PATH-LINE-FAILED (best-effort — the launcher itself is in place)"
        fi
      fi
      ;;
  esac
  log "launcher DONE ($LAUNCHER_FILE)"
  return 0
}

# Shared by every flag-driven command (--check-update, --show-update-details,
# --apply-update, --enable-heartbeat, --enable-backup): resolves the same
# workdir the interview would (env override, else the pointer file, else
# ./qroky), THEN loads state from it. Must resolve STATE_FILE before calling
# state_load — state_load only reads $STATE_FILE, it never computes it
# (caught by actually running the self-update scenario against a real
# sandbox; see run.log).
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
  # ATOM-105: a missing language field must not silently anglicize a
  # subcommand — say so before falling back (trilingual: locale unknown).
  if [[ -z "${ANSWER_LANGUAGE:-}" ]]; then
    say "(no language stored in install-state.json — continuing in English / limbă nesalvată — continuăm în engleză / язык не сохранён — продолжаю по-английски. To choose: bash install.sh)"
  fi
  source "$SCRIPT_DIR/lang/${ANSWER_LANGUAGE:-en}.sh"
}

cmd_enable_heartbeat() {
  resolve_and_load_state
  HB_LABEL="$(_write_heartbeat_files)"
  if ! command -v launchctl >/dev/null 2>&1; then
    L_HEARTBEAT_NO_LAUNCHD "$WORKSPACE_DIR"
    exit 1
  fi
  if ! run_with_ladder heartbeat _heartbeat_enable_attempt; then
    L_HEARTBEAT_SCHEDULE_FAILED
    log "heartbeat ENABLE-FAILED-TO-HUMAN (--enable-heartbeat)"
    exit 1
  fi
  L_HEARTBEAT_ON
  ANSWER_HEARTBEAT_OPTIN="yes"
  state_commit
}

# The documented enable-later path for a backup opt-out (v0.1.1, INPUT §1).
cmd_enable_backup() {
  resolve_and_load_state
  _backup_flow
  STEP_BACKUP="done"
  state_commit
  [[ "$ANSWER_BACKUP_OPTIN" == "yes" ]] || exit 1
}

# The documented enable-later path for Telegram (v0.2): one command connects
# (or finishes connecting) the bot — reuses a stored token when it still
# works, walks BotFather otherwise, waits for Start, binds, says hello,
# deploys the head. Exactly what question 5 does, invoked later.
cmd_enable_telegram() {
  resolve_and_load_state
  _telegram_connect_flow
  STEP_TELEGRAM="done"
  state_commit
  [[ "${ANSWER_TELEGRAM_BOUND:-no}" == "yes" ]] || exit 1
}

# ---------------------------------------------------------------------------
# Finale (H5) — printed at the end of every successful run, fresh install
# or healthy rerun alike.
# ---------------------------------------------------------------------------
# INFO-041 (ATOM-106): the environment reads context at session START — a
# freshly installed gesture is invisible to windows opened BEFORE this
# install. The finale says so explicitly (touch point 1 of 3; the Telegram
# hello and the CLAUDE.md marker blocks are the other two).
# The finale also carries the machine-wide TRACE (INFO-042): what was set up
# without a question, and the one command that removes it entirely.
finale() { L_FINALE "$WORKSPACE_DIR"; say ""; L_FINALE_QROKY_COMMAND "${LAUNCHER_PATH_ADDED:-}"; say ""; L_FINALE_MACHINEWIDE_TRACE; say ""; L_FINALE_NEW_SESSION_NOTE; say ""; L_DISCLAIMER; log "FINALE-SHOWN"; }

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
    L_NO_RELEASE_TAGS
    return 0
  fi
  if [[ "$latest" == "${FRAMEWORK_TAG:-}" ]]; then
    L_UPDATE_NONE
    return 0
  fi
  # Round-2 fix (verify F2): take the tag message BODY only — the subject
  # line and the blank separator used to eat 2 of the 3 changelog lines.
  local changelog
  changelog="$(git -C "$FRAMEWORK_DIR" tag -l --format='%(contents:body)' "$latest" 2>/dev/null \
    | sed '/^[[:space:]]*$/d' | head -3)"
  [[ -z "$changelog" ]] && changelog="(see the release for details)"
  L_UPDATE_AVAILABLE "${FRAMEWORK_TAG:-"(unversioned)"}" "$latest" "$changelog"
  printf '%s' "$latest" > "$WORKSPACE_DIR/.qroky/update-available"
}

cmd_show_update_details() {
  resolve_and_load_state
  local latest; latest="$(_latest_tag)"
  [[ -z "$latest" ]] && { L_NO_RELEASE_TAGS; return 0; }
  git -C "$FRAMEWORK_DIR" tag -l --format='%(refname:short)%0a%0a%(contents)' "$latest"
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
  # PROVENANCE.md is the installer's own untracked file, never a founder
  # edit — filtered here too (belt and braces with the info/exclude entry
  # written at vendor time) so no false "local changes" alarm ever fires
  # on an untouched install (round-2 fix, verify F3).
  conflict_text="$(git -C "$FRAMEWORK_DIR" status --porcelain 2>/dev/null | grep -v ' PROVENANCE\.md$' || true)"
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
  # ATOM-130: the new tag's dist-manifest governs the working copy — a FULL
  # v0.3.x instance silently sheds the factory's history right here, with
  # zero questions and zero touch to anything outside framework/ (silent
  # migration, same doctrine as the v0.3 router fold).
  _framework_apply_manifest
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

$(git -C "$FRAMEWORK_DIR" tag -l --format='%(contents)' "$latest" 2>/dev/null)
EOF
  L_UPDATE_APPLIED "$old_tag" "$latest" "$record"
  log "self-update APPLIED $old_tag -> $latest"

  # ATOM-131 (INFO-044, DoD 6): an EXISTING install gets the `qroky` command
  # backfilled by its next update — no reinstall needed. Wired every time
  # (idempotent, keeps the launcher fresh); announced only when it is NEW.
  local had_launcher=0; [[ -f "$LAUNCHER_FILE" ]] && had_launcher=1
  _launcher_wire
  if [[ $had_launcher -eq 0 && -f "$LAUNCHER_FILE" ]]; then
    say ""; L_FINALE_QROKY_COMMAND "${LAUNCHER_PATH_ADDED:-}"
  fi

  # ATOM-111 fold of the recorded upgrade defect («токен есть, головы нет»):
  # an update that BRINGS the telegram head auto-completes a half-connected
  # install. Stored token + captured binding + head now vendored + not yet
  # deployed -> deploy right here, zero extra questions. A token WITHOUT a
  # binding cannot deploy (no half-alive unbound listener — same rule as
  # question 5): the one finishing command is named instead.
  local head_src="$FRAMEWORK_DIR/runtime/claude/telegram"
  if [[ -s "$TOKEN_FILE" && -f "$head_src/listener.sh" \
        && ! -f "$WORKSPACE_DIR/.qroky/telegram/run-listener.sh" ]]; then
    if [[ -s "$WORKSPACE_DIR/.qroky/telegram/state/chat_id" ]]; then
      log "self-update telegram AUTO-COMPLETE (token+binding present, head arrived with $latest)"
      _telegram_deploy_head
      ANSWER_TELEGRAM_OPTIN="yes"
      ANSWER_TELEGRAM_TOKEN_STORED="yes"
      ANSWER_TELEGRAM_BOUND="yes"
      STEP_TELEGRAM="done"
      state_commit
    else
      L_TELEGRAM_UPDATE_FINISH_HINT
      log "self-update telegram TOKEN-WITHOUT-BINDING — enable-later hint shown, nothing deployed"
    fi
  fi
}

# ---------------------------------------------------------------------------
# Clean slate (ATOM-105, INFO-035): everything the kit put on the MACHINE is
# removed — launchd jobs, machine-wide gesture files (only with OUR
# provenance), ~/.qroky, install-state, the workdir pointer, the token file
# (with a warning first; contents never read). The user's working folder
# stays — its path is printed so the human can delete it by hand for a full
# zero. Every step is announced BEFORE it runs; the end is a list of what
# was done. On a machine with nothing installed: a polite no-op.
# ---------------------------------------------------------------------------
UNINSTALL_DONE_LIST=""
_un_note() { UNINSTALL_DONE_LIST+="  - $1"$'\n'; }

cmd_uninstall() {
  # Resolve like every subcommand, but WITHOUT dying when nothing is there —
  # a clean machine is this command's happy path, not an error.
  local candidate; candidate="$(resolve_candidate_workdir)"
  local have_state=0
  if [[ -f "$candidate/install-state.json" ]]; then
    WORKSPACE_DIR="$(cd "$candidate" && pwd)"
    STATE_FILE="$WORKSPACE_DIR/install-state.json"
    TOKEN_FILE="$WORKSPACE_DIR/.qroky/telegram.token"
    state_load
    have_state=1
  fi
  source "$SCRIPT_DIR/lang/${ANSWER_LANGUAGE:-en}.sh"
  L_UNINSTALL_TITLE

  # 1) launchd jobs: telegram listener/digest + every kit heartbeat.
  local plist label
  for plist in "$HOME/Library/LaunchAgents/md.qroky.telegram.listener.plist" \
               "$HOME/Library/LaunchAgents/md.qroky.telegram.digest.plist" \
               "$HOME/Library/LaunchAgents"/md.qroky.heartbeat.*.plist; do
    [[ -f "$plist" ]] || continue
    label="$(basename "$plist" .plist)"
    L_UNINSTALL_STEP "launchd: $label"
    if command -v launchctl >/dev/null 2>&1; then
      launchctl bootout "gui/$(id -u)" "$plist" 2>/dev/null || true
    fi
    rm -f "$plist"
    _un_note "launchd: $label"
  done

  # 2) machine-wide gesture — ONLY files carrying OUR provenance. The skill
  # copy must contain the GATE-028 recorded-exception text the kit vendors;
  # anything else at that path is somebody's file and stays untouched.
  local mw_skill="$HOME/.claude/skills/qroky/SKILL.md"
  if [[ -f "$mw_skill" ]]; then
    if grep -qF "GATE-028" "$mw_skill"; then
      L_UNINSTALL_STEP "$mw_skill"
      rm -f "$mw_skill"
      rmdir "$HOME/.claude/skills/qroky" 2>/dev/null || true
      _un_note "$mw_skill"
    else
      L_UNINSTALL_FOREIGN_SKILL "$mw_skill"
    fi
  fi
  local claude_md="$HOME/.claude/CLAUDE.md"
  if [[ -f "$claude_md" ]] && grep -qF "$MACHINEWIDE_MARKER_START" "$claude_md"; then
    L_UNINSTALL_STEP "$claude_md (marker block only)"
    awk -v s="$MACHINEWIDE_MARKER_START" -v e="$MACHINEWIDE_MARKER_END" \
      '$0==s{skip=1; next} $0==e{skip=0; next} !skip' "$claude_md" > "$claude_md.tmp.$$" \
      && mv "$claude_md.tmp.$$" "$claude_md"
    _un_note "marker block in $claude_md"
  fi

  # 2b) the `qroky` command (ATOM-131, INFO-044): the launcher — ONLY with
  # our provenance (the INFO-044 line the installer writes; anything else at
  # that path is somebody's file and stays) — and the PATH marker block,
  # removed from whichever profile carries it. Foreign lines untouched: only
  # the block between our two markers goes.
  if [[ -f "$LAUNCHER_FILE" ]]; then
    if grep -qF "INFO-044" "$LAUNCHER_FILE"; then
      L_UNINSTALL_STEP "$LAUNCHER_FILE"
      rm -f "$LAUNCHER_FILE"
      rmdir "$HOME/.local/bin" 2>/dev/null || true
      _un_note "$LAUNCHER_FILE"
    else
      L_UNINSTALL_FOREIGN_SKILL "$LAUNCHER_FILE"
    fi
  fi
  local _prof
  for _prof in "$HOME/.zshrc" "$HOME/.zprofile" "$HOME/.bashrc" "$HOME/.bash_profile" "$HOME/.profile"; do
    if [[ -f "$_prof" ]] && grep -qF "$LAUNCHER_PATH_MARKER_START" "$_prof"; then
      L_UNINSTALL_STEP "$_prof (PATH marker block only)"
      # One-line lookbehind (verify F2): the installer prints one blank line
      # BEFORE the block — swallow exactly that held blank at excision time,
      # so install/uninstall cycles never accumulate blank lines. Everything
      # else outside the exact marker lines stays byte-identical.
      awk -v s="$LAUNCHER_PATH_MARKER_START" -v e="$LAUNCHER_PATH_MARKER_END" '
        $0==s { skip=1; if (held_set && held=="") held_set=0; next }
        $0==e { skip=0; next }
        skip  { next }
        { if (held_set) print held; held=$0; held_set=1 }
        END   { if (held_set) print held }' "$_prof" > "$_prof.tmp.$$" \
        && mv "$_prof.tmp.$$" "$_prof"
      _un_note "PATH marker block in $_prof"
    fi
  done

  # 3) machine-level qroky state: the registry and friends.
  if [[ -n "${QROKY_REGISTRY:-}" ]]; then
    # test override: touch ONLY the named file, never its parent dir
    if [[ -f "$QROKY_REGISTRY" ]]; then
      L_UNINSTALL_STEP "$QROKY_REGISTRY"
      rm -f "$QROKY_REGISTRY"
      _un_note "$QROKY_REGISTRY"
    fi
    # the ATOM-130 machine pointer — removed ONLY when it points at the
    # install being removed (same rule as the clone-local pointer)
    if [[ $have_state -eq 1 && -f "$HOME/.qroky/workdir" ]] \
       && [[ "$(cat "$HOME/.qroky/workdir" 2>/dev/null)" == "$WORKSPACE_DIR" ]]; then
      L_UNINSTALL_STEP "$HOME/.qroky/workdir"
      rm -f "$HOME/.qroky/workdir"
      _un_note "$HOME/.qroky/workdir"
    fi
  elif [[ -d "$HOME/.qroky" ]]; then
    L_UNINSTALL_STEP "$HOME/.qroky"
    rm -rf "$HOME/.qroky"
    _un_note "$HOME/.qroky"
  fi

  # 4) the bot token — warned about BEFORE it goes; contents never read.
  if [[ $have_state -eq 1 && -f "$TOKEN_FILE" ]]; then
    L_UNINSTALL_TOKEN_WARN "$TOKEN_FILE"
    rm -f "$TOKEN_FILE"
    _un_note "$TOKEN_FILE"
  fi

  # 5) install-state + the workdir pointer (both ours). The rest of the
  # working folder is the USER's — announced, never touched.
  if [[ $have_state -eq 1 ]]; then
    L_UNINSTALL_STEP "$STATE_FILE"
    rm -f "$STATE_FILE"
    _un_note "$STATE_FILE"
  fi
  # The pointer is removed ONLY when it points at the install being removed —
  # uninstalling «nothing» must never orphan somebody else's workdir pointer.
  if [[ $have_state -eq 1 && -f "$WORKDIR_POINTER" ]] \
     && [[ "$(cat "$WORKDIR_POINTER" 2>/dev/null)" == "$WORKSPACE_DIR" ]]; then
    L_UNINSTALL_STEP "$WORKDIR_POINTER"
    rm -f "$WORKDIR_POINTER"
    _un_note "$WORKDIR_POINTER"
  fi

  if [[ -z "$UNINSTALL_DONE_LIST" ]]; then
    L_UNINSTALL_NOOP
    return 0
  fi
  L_UNINSTALL_SUMMARY
  printf '%s' "$UNINSTALL_DONE_LIST"
  if [[ $have_state -eq 1 ]]; then
    L_UNINSTALL_KEEP_WORKDIR "$WORKSPACE_DIR"
  elif [[ -d "$candidate" ]]; then
    L_UNINSTALL_KEEP_WORKDIR "$candidate"
  fi
  # ATOM-106 (INFO-040): the uninstall finale points at the reinstall path.
  L_UNINSTALL_REINSTALL_HINT
  return 0
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

  # Journey map (v0.2, GATE-027 finding 3): a fresh install opens with the
  # whole road in one paragraph — 8 questions (INFO-042), ~3 minutes, two
  # lines at the end. Printed right after the language question so it
  # arrives in the human's own language (a map the reader cannot read is
  # not a map); the language question itself is announced as «1 из 8».
  # A resumed/healthy run skips the map — those runs are not a journey.
  local fresh_run=0
  [[ "$resumed" -eq 0 ]] && fresh_run=1

  step_language
  # Reinstall gate (ATOM-106) for the RESUMED entry: a COMPLETE install
  # re-run gets the [reinstall/update/cancel] dialog in the founder's own
  # language (right after the language step restored it); a mid-interview
  # resume passes straight through — the gate self-guards.
  if [[ "$resumed" -eq 1 ]]; then _reinstall_gate; fi
  if [[ "$fresh_run" -eq 1 ]]; then say ""; L_JOURNEY_MAP; fi
  say ""
  step_workdir;    say ""
  step_claude_code
  step_framework
  step_gesture;    say ""
  step_subscription; say ""
  step_telegram;   say ""
  step_telemetry;  say ""
  step_heartbeat;  say ""
  step_backup;     say ""
  step_machinewide; say ""
  _launcher_wire

  finale
  say ""
  L_TOTAL_ELAPSED "$(elapsed_now)"
}

case "${1:-}" in
  --check-update) cmd_check_update ;;
  --show-update-details) cmd_show_update_details ;;
  --apply-update) cmd_apply_update ;;
  --enable-heartbeat) cmd_enable_heartbeat ;;
  --enable-backup) cmd_enable_backup ;;
  --enable-telegram) cmd_enable_telegram ;;
  --uninstall) cmd_uninstall ;;
  "") main_interview ;;
  *) say "Unknown option: $1"; say "Usage: install.sh [--check-update|--show-update-details|--apply-update|--enable-heartbeat|--enable-backup|--enable-telegram|--uninstall]"; exit 2 ;;
esac
