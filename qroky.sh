#!/usr/bin/env bash
# qroky.sh — the one memorable command (ATOM-130; ATOM-131 INFO-044):
#
#   qroky install      set Qroky up on this machine
#   qroky update       update an existing install
#   qroky uninstall    remove everything the installer put here
#
# First time (no clone, no cwd assumptions — this file runs fine from a
# process substitution, so the README's ONE entry command is):
#   bash <(curl -fsSL https://raw.githubusercontent.com/qroky/framework/main/qroky.sh) install
# The install then puts a launcher on PATH (~/.local/bin/qroky), so from the
# next terminal on, the bare word `qroky` works from anywhere, forever.
#
# Works from ANY folder — you never need to know where a clone lives:
# install keeps its own kit copy under ~/.qroky/kit, and uninstall/update
# find your install by the machine trace (~/.qroky/workdir), not by path.
# This script owns ONLY the entry: getting a healthy kit copy without ever
# showing you a raw git error. Everything else — the interview, the
# reinstall dialog over an occupied folder (ATOM-106), updates, the clean
# slate — is install.sh's, invoked from here. No logic is duplicated.
#
# Overrides (tests / air-gapped installs): QROKY_KIT_SOURCE (repo to clone),
# QROKY_KIT_HOME (default ~/.qroky/kit), QROKY_WORKSPACE_DIR.

set -euo pipefail

CMD="${1:-help}"
KIT_SOURCE="${QROKY_KIT_SOURCE:-https://github.com/qroky/framework.git}"
KIT_HOME="${QROKY_KIT_HOME:-$HOME/.qroky/kit}"

say() { printf '%s\n' "$*"; }

_kit_ready() {
  # A healthy kit copy at $KIT_HOME, freshest release tag checked out.
  # An occupied non-git folder gets an honest sentence, never a git fatal.
  if [[ -d "$KIT_HOME/.git" ]]; then
    git -C "$KIT_HOME" fetch --quiet --tags origin 2>/dev/null || true
  elif [[ -e "$KIT_HOME" && -n "$(ls -A "$KIT_HOME" 2>/dev/null)" ]]; then
    say "The folder $KIT_HOME exists but is not Qroky's kit copy."
    say "Move it away (or point QROKY_KIT_HOME elsewhere), then run this command again."
    exit 1
  else
    mkdir -p "$(dirname "$KIT_HOME")"
    if ! git clone --quiet "$KIT_SOURCE" "$KIT_HOME" 2>/dev/null; then
      say "Could not download Qroky from: $KIT_SOURCE"
      say "This is almost always the internet connection. Check it and run this command again."
      exit 1
    fi
  fi
  local tag
  tag="$(git -C "$KIT_HOME" tag -l 'v*' --sort=-v:refname 2>/dev/null | head -1)"
  [[ -n "$tag" ]] && git -C "$KIT_HOME" checkout --quiet "$tag" 2>/dev/null || true
}

_find_installer() {
  # For uninstall/update: prefer the kit copy; else the install's OWN
  # vendored framework (it ships distribution/ by manifest) — so removal
  # works even offline, even if the kit copy is gone.
  if [[ -f "$KIT_HOME/distribution/install.sh" ]]; then
    printf '%s' "$KIT_HOME/distribution/install.sh"; return 0
  fi
  local wd=""
  if [[ -n "${QROKY_WORKSPACE_DIR:-}" ]]; then wd="$QROKY_WORKSPACE_DIR"
  elif [[ -f "$HOME/.qroky/workdir" ]]; then wd="$(cat "$HOME/.qroky/workdir")"
  fi
  if [[ -n "$wd" && -f "$wd/framework/distribution/install.sh" ]]; then
    printf '%s' "$wd/framework/distribution/install.sh"; return 0
  fi
  return 1
}

case "$CMD" in
  install)
    _kit_ready
    exec bash "$KIT_HOME/distribution/install.sh"
    ;;
  update)
    _kit_ready
    exec bash "$KIT_HOME/distribution/install.sh" --apply-update
    ;;
  details)
    # what the pending update changes, in full (the digest names this word)
    if INSTALLER="$(_find_installer)"; then
      exec bash "$INSTALLER" --show-update-details
    fi
    say "No Qroky install found on this machine — nothing to show details for."
    exit 1
    ;;
  uninstall)
    if INSTALLER="$(_find_installer)"; then
      exec bash "$INSTALLER" --uninstall
    fi
    # no kit copy, no machine trace: genuinely nothing of ours here
    say "Nothing to remove — this machine has no Qroky install. All clean already."
    exit 0
    ;;
  *)
    say "qroky — one command for the whole journey:"
    say "  qroky install      set Qroky up on this machine"
    say "  qroky update       update an existing install"
    say "  qroky uninstall    remove everything it put on this machine"
    say ""
    say "Not installed yet? One command, from anywhere:"
    say "  bash <(curl -fsSL https://raw.githubusercontent.com/qroky/framework/main/qroky.sh) install"
    exit 2
    ;;
esac
