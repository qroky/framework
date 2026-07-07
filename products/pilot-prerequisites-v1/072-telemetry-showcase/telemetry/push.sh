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
#                                 frontmatter (tokens, time, who ran it).
#                                 The Summary, Deliverables, Decisions and
#                                 Handoff sections of RESULT.md are NEVER
#                                 copied — that is where your product would
#                                 be described, so it is excluded on purpose.
#     3. run.log               — the append-only step log inside workspace/
#     4. status.yaml           — the one-line-per-atom status board
#     5. VERDICT.md            — the independent reviewer's verdict file
#                                 ("verify verdicts")
#   Nothing else is ever read for content. Any other file — your INPUT.md,
#   your specs, your code, your decision records, a stray secrets.txt — is
#   found, logged as "SKIPPED (not on the whitelist)", and never opened.
#   This is "deny-by-default": the default answer for any file is NO.
#
# YOUR OFF SWITCH:
#   Create an empty file named "OFF" in this same folder (next to this
#   script, i.e. telemetry/OFF) and run this script again. It will print a
#   loud message, copy and push NOTHING, and exit 0 (success — "I did
#   nothing, on purpose" is not a failure). Delete telemetry/OFF to turn
#   telemetry back on.
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
#                   points this at their own repo)
#     STAGING_DIR   where the allowed copies are written (default: a fresh
#                   temp folder, printed at the end so you can inspect it)
#
# Author: pilot-toolsmith (ATOM-072) · Date: 2026-07-07
# Purpose: prove the whitelist mechanics end-to-end before pilot kickoff.
# What this script changes: nothing in REPO_ROOT (it only reads there); it
# writes only inside STAGING_DIR, which is never your repo.
# ============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OFF_FILE="$SCRIPT_DIR/OFF"

# --- OFF switch check (checked first, before anything else runs) ----------
if [[ -f "$OFF_FILE" ]]; then
  echo "=================================================================="
  echo "TELEMETRY IS OFF."
  echo "Found: $OFF_FILE"
  echo "This script is doing NOTHING — no files were read, nothing was"
  echo "staged, nothing was sent anywhere. Delete that file to turn"
  echo "telemetry back on."
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
  "STATUS.md"    # whole file — a short progress log, no product content
  "RESULT.md"    # NOT the whole file — see copy_result_cost_block() below;
                  # only the frontmatter "cost:" block is ever copied
  "run.log"      # whole file — step-by-step operational trail
  "status.yaml"  # whole file — one line per atom, state + timestamp + note
  "VERDICT.md"   # whole file — "verify verdicts" (FEV-PROTOCOL VP6)
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

# Extracts ONLY the "cost:" block from a RESULT.md frontmatter — never the
# Summary / Deliverables / Decisions / Handoff sections, which is exactly
# where a founder's product would be described. Naive, line-based, no YAML
# library: the ATOM-SPEC §6.2 template is regular enough for this to be
# reliable (cost: at column 0, its sub-fields indented, ending at the next
# column-0 key or the closing "---").
copy_result_cost_block() {
  local src="$1"
  local dst="$2"
  {
    echo "# Telemetry extract — cost block ONLY, from: $src"
    echo "# Everything else in this RESULT.md (Summary, Deliverables,"
    echo "# Decisions, Handoff) was NOT read for this push — closed"
    echo "# whitelist, pilot-design.md 'Telemetry & consent'."
    awk '
      BEGIN { fm = 0; incost = 0 }
      /^---[ \t]*$/ {
        fm++
        next
      }
      fm == 1 {
        if ($0 ~ /^cost:[ \t]*$/) { incost = 1; print; next }
        if (incost == 1) {
          if ($0 ~ /^[^ \t]/) { incost = 0 } else { print; next }
        }
      }
    ' "$src"
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

    if [[ "$base" == "RESULT.md" ]]; then
      copy_result_cost_block "$file" "$STAGING_DIR/${flat%.md}.cost-block.yaml"
    else
      cp "$file" "$STAGING_DIR/$flat"
    fi
    copied_count=$((copied_count + 1))
    echo "COPIED  (whitelisted: $base)  <-  $rel"
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

echo "=================================================================="
echo "Done. Staged copies are at: $STAGING_DIR"
echo "You can open and read every one of them."
echo "=================================================================="
