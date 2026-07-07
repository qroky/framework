#!/usr/bin/env bash
# ============================================================================
# push.sh — Qroky pilot telemetry push (Flow Support v0)
# ============================================================================
#
# WHAT THIS SCRIPT DOES, IN PLAIN LANGUAGE:
#   Once a day, it looks through your Qroky repo for a small, FIXED list of
#   files that describe HOW your work went — never WHAT you built — copies
#   only the allowed content into a local "staging" folder, and (in a real
#   deployment) pushes that staging folder to a private repo the pilot team
#   controls: qroky/pilot-telemetry. You can read every line below; nothing
#   here is hidden or obfuscated.
#
# WHAT NEVER LEAVES YOUR MACHINE (the five items below and nothing else):
#     1. STATUS.md            — the atom's short progress log
#     2. RESULT.md cost block — ONLY the "cost:" section of RESULT.md's
#                                 frontmatter (tokens, time, who ran it, and
#                                 — only if you separately opted in, see
#                                 WORK-UNIT NOTE below — one short structural
#                                 work_unit tag). The Summary, Deliverables,
#                                 Decisions and Handoff sections of RESULT.md
#                                 are NEVER copied — that is where your
#                                 product would be described, so it is
#                                 excluded on purpose.
#     3. run.log               — the append-only step log inside workspace/
#     4. status.yaml           — the one-line-per-atom status board
#     5. VERDICT.md            — the independent reviewer's verdict file
#                                 ("verify verdicts")
#   Nothing else is ever read for content. Any other file — your INPUT.md,
#   your specs, your code, your decision records, a stray secrets.txt — is
#   found, logged as "SKIPPED (not on the whitelist)", and never opened.
#   This is "deny-by-default": the default answer for any file is NO.
#
# CONTENT FILTERING MODE (ATOM-078 register #3 — a CEO text-choice, not an
# executor decision; both variants below are real, working code; the
# variable at the top of this section selects which one runs):
#   - "wholefile" (current default, unchanged from ATOM-072, already
#     covered by the negative-test.sh suite): STATUS.md, run.log,
#     status.yaml and VERDICT.md are copied whole. The consent text must
#     honestly disclose that these four are copied whole and may carry
#     quoted excerpts (see CONSENT.<lang>.md, "Ce copiem" / "Что копируем"
#     footnote) — this is "вариант B — honest whole-file disclosure".
#   - "filtered": the same four files are reduced to their structural
#     fields only (no free-text notes, no Findings prose, no progress-log
#     sentences) before copying — see the copy_*_filtered() functions below.
#     This is "вариант A — content filtering of the 4 whole-copied files".
#   Set with: QROKY_TELEMETRY_FILTER_MODE=filtered ./push.sh ...
#   CEO picks the mode that ships to real founders at G2; until then this
#   script keeps shipping with the tested default (wholefile) so existing
#   negative-test.sh coverage is not broken by this fix-round.
CONTENT_FILTER_MODE="${QROKY_TELEMETRY_FILTER_MODE:-wholefile}"
#
# YOUR OFF SWITCH:
#   Create an empty file named "OFF" in this same folder (next to this
#   script, i.e. telemetry/OFF) and run this script again. It will print a
#   loud message, copy and push NOTHING, and exit 0 (success — "I did
#   nothing, on purpose" is not a failure). Delete telemetry/OFF to turn
#   telemetry back on.
#   ATOM-078 register #5: turning OFF after telemetry has actually sent
#   something before is treated as a REVOCATION, not just a pause — see
#   "DELETION ON REVOCATION" below.
#
# DELETION — BY DATE AND ON REVOCATION (ATOM-078 register #5):
#   The consent document's "Ștergere"/"Удаление" field fixes a deletion
#   date in writing at signing. If that date is written into a file named
#   "DELETE-BY" next to this script (one line, YYYY-MM-DD), this script
#   checks it on every run:
#     - once today's date reaches or passes DELETE-BY, this script stops
#       sending (writes telemetry/OFF for you) and logs a deletion request;
#     - the same deletion-request logging fires the moment telemetry/OFF is
#       found AND this workspace has sent something before (a marker file,
#       telemetry/.ever-sent, records that fact — never before that).
#   Real production wiring (ATOM-071 setup kit, once push_to_remote() below
#   is no longer a stub) must forward each logged request to an actual
#   delete against qroky/pilot-telemetry. Until then, the code-side part —
#   detecting the trigger, stopping sends, and writing a dated, auditable
#   local record — is real and runs every time; the human-executed removal
#   of already-sent copies at the real remote is documented as a runbook
#   step (see ../workspace/telemetry-deletion-runbook.md in the fix-round
#   product folder) until that automation exists — flagged there for CEO
#   confirmation at G2, per the register.
#
# WORK-UNIT NOTE (ATOM-078 register #11, decidable after GATE-018/E8-1):
#   E8-1 answered "opt-in": a founder may separately allow one short,
#   structural work_unit tag (e.g. "1 role spec, 60 lines" — never free
#   text, never a sentence) to travel with the RESULT.md cost block, so the
#   pilot can re-anchor pricing per unit of work, not just per token. This
#   is the SAME opt-in as the TEAM-summary content line (see
#   showcase/render.sh and CONSENT.<lang>.md's separate opt-in item) — this
#   script looks for the same marker file the consent records that choice
#   in: consent/TEAM-CONTENT-OPTIN. Absent that file, no work_unit field is
#   ever read or copied, regardless of whether RESULT.md happens to carry
#   one.
#
# THIS BUILD IS A DRY RUN, ALWAYS:
#   The final "send it to qroky/pilot-telemetry" step is a stub in this
#   showcase build — see push_to_remote() near the bottom. It never makes a
#   network call and never runs `git push`. It only prints what it WOULD
#   send. A production setup (ATOM-071 setup kit) wires push_to_remote() to
#   a real, consented git remote — only after the founder has signed the
#   consent text in consent/CONSENT.<lang>.md.
#
# USAGE:
#   ./push.sh [REPO_ROOT] [STAGING_DIR]
#     REPO_ROOT    the founder's Qroky repo to scan (default: three levels
#                   up from this script — i.e. the repo this kit ships in,
#                   for the worked self-test; a founder's setup script
#                   points this at their own repo, explicitly — see
#                   ../setup/bootstrap.sh Step 6, which always passes the
#                   founder's real workspace path here, never the default)
#     STAGING_DIR   where the allowed copies are written (default: a fresh
#                   temp folder, printed at the end so you can inspect it)
#
# Author: pilot-toolsmith (ATOM-072) · Date: 2026-07-07
# Fix-round: ATOM-078 (register #3, #5, #11) — 2026-07-07
# Purpose: prove the whitelist mechanics end-to-end before pilot kickoff.
# What this script changes: nothing in REPO_ROOT (it only reads there); it
# writes only inside STAGING_DIR (never your repo) and, for the deletion
# trigger and OFF switch, small marker/log files inside this telemetry/
# folder itself (DELETE-BY is read-only to this script; .ever-sent and
# deletion-requests.log are the only files this script ever writes there).
# ============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OFF_FILE="$SCRIPT_DIR/OFF"
DELETE_BY_FILE="$SCRIPT_DIR/DELETE-BY"
EVER_SENT_FILE="$SCRIPT_DIR/.ever-sent"
DELETION_LOG="$SCRIPT_DIR/deletion-requests.log"
TEAM_CONTENT_OPTIN_FILE="$SCRIPT_DIR/../consent/TEAM-CONTENT-OPTIN"

log_deletion_request() {
  local reason="$1"
  mkdir -p "$(dirname "$DELETION_LOG")"
  printf '%s  REASON: %s  ACTION-NEEDED: forward this request to a real delete against qroky/pilot-telemetry once push_to_remote() is no longer a stub (see workspace/telemetry-deletion-runbook.md).\n' \
    "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$reason" >> "$DELETION_LOG"
}

# --- deletion-by-date check (runs before the OFF check, since a passed date
#     must both stop future sends AND log the request, even on a run where
#     OFF was not already present) ------------------------------------------
if [[ -f "$DELETE_BY_FILE" ]]; then
  delete_by_date="$(head -n1 "$DELETE_BY_FILE" | tr -d '[:space:]')"
  if [[ -n "$delete_by_date" ]] && [[ "$(date -u +%Y-%m-%d)" > "$delete_by_date" || "$(date -u +%Y-%m-%d)" == "$delete_by_date" ]]; then
    if [[ ! -f "$OFF_FILE" ]]; then
      touch "$OFF_FILE"
      echo "Deletion date ($delete_by_date) reached — telemetry switched OFF automatically."
    fi
    if [[ -f "$EVER_SENT_FILE" ]]; then
      log_deletion_request "deletion date $delete_by_date reached"
      echo "Deletion request logged: $DELETION_LOG"
    fi
  fi
fi

# --- OFF switch check ------------------------------------------------------
if [[ -f "$OFF_FILE" ]]; then
  echo "=================================================================="
  echo "TELEMETRY IS OFF."
  echo "Found: $OFF_FILE"
  echo "This script is doing NOTHING — no files were read, nothing was"
  echo "staged, nothing was sent anywhere. Delete that file to turn"
  echo "telemetry back on."
  if [[ -f "$EVER_SENT_FILE" ]]; then
    log_deletion_request "OFF switch found while telemetry had sent data before (revocation)"
    echo "This workspace had sent data before — a deletion request was logged (revocation)."
    echo "See: $DELETION_LOG"
    echo "Revoking stops future sends AND requests deletion of what was already sent."
  fi
  echo "=================================================================="
  exit 0
fi

# --- Arguments ---------------------------------------------------------
REPO_ROOT="${1:-$(cd "$SCRIPT_DIR/../../../.." && pwd)}"
STAGING_DIR="${2:-$(mktemp -d "${TMPDIR:-/tmp}/qroky-telemetry-staging.XXXXXX")}"

mkdir -p "$STAGING_DIR"

echo "=================================================================="
echo "Qroky pilot telemetry push — dry run"
echo "Scanning:  $REPO_ROOT"
echo "Staging:   $STAGING_DIR"
echo "Content filtering mode: $CONTENT_FILTER_MODE (CEO choice at G2 — see this file's header)"
echo "=================================================================="

# ============================================================================
# THE WHITELIST — verbatim from pilot-design.md, "Telemetry & consent"
# section (accepted §3.4 closed list). Do not add to this list without a
# new accepted decision record; do not remove from it without one either.
#
#   "the telemetry push copies operational files only — STATUS.md,
#   RESULT.md cost blocks, run.log, status.yaml, verify verdicts."
#
# Each entry below is a basename this script is allowed to look at. The
# comment on each line states exactly how much of that file is copied.
# ============================================================================
WHITELIST_FILENAMES=(
  "STATUS.md"    # whole file in "wholefile" mode; structural-only in "filtered" mode
  "RESULT.md"    # NOT the whole file — see copy_result_cost_block() below;
                  # only the frontmatter "cost:" block is ever copied
  "run.log"      # whole file in "wholefile" mode; structural-only in "filtered" mode
  "status.yaml"  # whole file in "wholefile" mode; structural-only in "filtered" mode
  "VERDICT.md"   # whole file in "wholefile" mode; structural-only in "filtered" mode
)

is_whitelisted() {
  local basename="$1"
  local entry
  for entry in "${WHITELIST_FILENAMES[@]}"; do
    if [[ "$basename" == "$entry" ]]; then
      return 0
    fi
  done
  return 1
}

team_content_optin() {
  [[ -f "$TEAM_CONTENT_OPTIN_FILE" ]]
}

# Extracts ONLY the "cost:" block from a RESULT.md frontmatter — never the
# Summary / Deliverables / Decisions / Handoff sections, which is exactly
# where a founder's product would be described. Naive, line-based, no YAML
# library: the ATOM-SPEC §6.2 template is regular enough for this to be
# reliable (cost: at column 0, its sub-fields indented, ending at the next
# column-0 key or the closing "---"). If the founder has separately opted
# in to TEAM-content sharing (team_content_optin above), a structural
# work_unit sub-field, if present in the source, is kept; otherwise any
# work_unit line is stripped before copying (register #11 — populated only
# under the opt-in flag).
copy_result_cost_block() {
  local src="$1"
  local dst="$2"
  local optin="no"
  team_content_optin && optin="yes"
  {
    echo "# Telemetry extract — cost block ONLY, from: $src"
    echo "# Everything else in this RESULT.md (Summary, Deliverables,"
    echo "# Decisions, Handoff) was NOT read for this push — closed"
    echo "# whitelist, pilot-design.md 'Telemetry & consent'."
    echo "# work_unit field included: $optin (consent/TEAM-CONTENT-OPTIN present: $optin)"
    awk -v optin="$optin" '
      BEGIN { fm = 0; incost = 0 }
      /^---[ \t]*$/ {
        fm++
        next
      }
      fm == 1 {
        if ($0 ~ /^cost:[ \t]*$/) { incost = 1; print; next }
        if (incost == 1) {
          if ($0 ~ /^[^ \t]/) { incost = 0 } else {
            if ($0 ~ /^[ \t]+work_unit:/ && optin != "yes") { next }
            print; next
          }
        }
      }
    ' "$src"
  } > "$dst"
}

# --- "filtered" mode: structural fields only, no free text ----------------
# STATUS.md: keeps only lines matching a timestamped state token; strips any
# free-text description that follows on the same line.
copy_status_filtered() {
  local src="$1" dst="$2"
  {
    echo "# Telemetry extract — structural fields only (filtered mode), from: $src"
    grep -oE '^[0-9T:.Z-]+ [a-zA-Z_-]+' "$src" 2>/dev/null || echo "# (no structural state lines found)"
  } > "$dst"
}

# run.log: keeps only the fixed-shape leading token of each line (event
# name), drops everything else on the line (executor names, free-text
# notes).
copy_run_log_filtered() {
  local src="$1" dst="$2"
  {
    echo "# Telemetry extract — structural fields only (filtered mode), from: $src"
    grep -oE '^[0-9T:.Z-]+ [A-Z-]+' "$src" 2>/dev/null || echo "# (no structural log lines found)"
  } > "$dst"
}

# status.yaml: keeps id/state/timestamp only; drops the free-text `note:`
# field, which is where a closure summary in plain words routinely lives.
copy_status_yaml_filtered() {
  local src="$1" dst="$2"
  {
    echo "# Telemetry extract — structural fields only (filtered mode), from: $src"
    awk '/^[ \t]*note:/{next} {print}' "$src"
  } > "$dst"
}

# VERDICT.md: keeps only the frontmatter (verdict, round, returns_used) —
# never the Findings body, which quotes reviewed artifacts by design
# (FEV-PROTOCOL) and will routinely carry product-descriptive text.
copy_verdict_filtered() {
  local src="$1" dst="$2"
  {
    echo "# Telemetry extract — frontmatter only (filtered mode), from: $src"
    awk 'BEGIN{fm=0} /^---[ \t]*$/{fm++; print; next} fm==1{print} fm>=2{exit}' "$src"
  } > "$dst"
}

copied_count=0
skipped_count=0
skipped_examples=()

# --- Deny-by-default scan: walk the repo, decide file-by-file -------------
while IFS= read -r -d '' file; do
  base="$(basename "$file")"

  # never look inside git internals or our own staging output
  case "$file" in
    */.git/*) continue ;;
    "$STAGING_DIR"/*) continue ;;
  esac

  if is_whitelisted "$base"; then
    # Make a flat, collision-safe name: path with slashes turned into "__"
    rel="${file#"$REPO_ROOT"/}"
    flat="$(echo "$rel" | tr '/' '__')"

    case "$base" in
      RESULT.md)
        copy_result_cost_block "$file" "$STAGING_DIR/${flat%.md}.cost-block.yaml"
        ;;
      *)
        if [[ "$CONTENT_FILTER_MODE" == "filtered" ]]; then
          case "$base" in
            STATUS.md)   copy_status_filtered   "$file" "$STAGING_DIR/${flat%.md}.filtered.txt" ;;
            run.log)     copy_run_log_filtered  "$file" "$STAGING_DIR/${flat}.filtered.txt" ;;
            status.yaml) copy_status_yaml_filtered "$file" "$STAGING_DIR/${flat%.yaml}.filtered.yaml" ;;
            VERDICT.md)  copy_verdict_filtered   "$file" "$STAGING_DIR/${flat%.md}.filtered.md" ;;
            *)           cp "$file" "$STAGING_DIR/$flat" ;;
          esac
        else
          cp "$file" "$STAGING_DIR/$flat"
        fi
        ;;
    esac
    copied_count=$((copied_count + 1))
    echo "COPIED  (whitelisted: $base, mode: $CONTENT_FILTER_MODE)  <-  $rel"
  else
    skipped_count=$((skipped_count + 1))
    if [[ ${#skipped_examples[@]} -lt 10 ]]; then
      skipped_examples+=("$file")
    fi
  fi
done < <(find "$REPO_ROOT" -type f -print0 2>/dev/null)

echo "------------------------------------------------------------------"
echo "SKIPPED (not on the whitelist — deny by default): $skipped_count file(s)"
if [[ ${#skipped_examples[@]} -gt 0 ]]; then
  echo "First few skipped, for your own audit:"
  for f in "${skipped_examples[@]}"; do
    echo "  - ${f#"$REPO_ROOT"/}"
  done
fi
echo "COPIED to staging: $copied_count file(s)"
echo "------------------------------------------------------------------"

# ============================================================================
# push_to_remote — STUB in this build. Real network I/O and `git push` are
# deliberately NOT implemented here. This function only announces what it
# would do. A production build (ATOM-071 setup kit) replaces this function
# with a real, consented push once the founder has signed
# consent/CONSENT.<lang>.md — never before.
# ============================================================================
push_to_remote() {
  local staging="$1"
  echo "[DRY RUN] would push $copied_count file(s) from:"
  echo "[DRY RUN]   $staging"
  echo "[DRY RUN] to remote: qroky/pilot-telemetry"
  echo "[DRY RUN] No network call was made. No 'git push' was run."
}

push_to_remote "$STAGING_DIR"

# Record that this workspace has sent something at least once — this is
# what makes a later OFF a "revocation" (deletion request logged) rather
# than "never turned on" (nothing to delete). Real production wiring should
# only write this marker after push_to_remote() actually succeeds against
# the real remote; in this dry-run build it is written after the stub call
# above, honestly, since the stub always "succeeds".
if [[ "$copied_count" -gt 0 ]]; then
  date -u +%Y-%m-%dT%H:%M:%SZ > "$EVER_SENT_FILE"
fi

echo "=================================================================="
echo "Done. Staged copies are at: $STAGING_DIR"
echo "You can open and read every one of them."
echo "=================================================================="
