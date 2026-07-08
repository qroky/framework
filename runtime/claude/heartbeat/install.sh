#!/usr/bin/env bash
# Idempotent installer for the Qroky heartbeat LaunchAgent (this Mac).
# Pattern: _BUSOS/tools/hermes-24x7/install.sh
set -euo pipefail

HB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LABEL="md.qroky.heartbeat"
PLIST_SRC="$HB_DIR/launchd/$LABEL.plist"
PLIST_DST="$HOME/Library/LaunchAgents/$LABEL.plist"

echo "[heartbeat] prerequisites…"
command -v claude >/dev/null || { echo "FATAL: claude CLI not in PATH"; exit 2; }
[[ -f "$PLIST_SRC" ]] || { echo "FATAL: $PLIST_SRC missing"; exit 2; }

echo "[heartbeat] installing plist -> $PLIST_DST"
sed "s|__HOME__|$HOME|g" "$PLIST_SRC" > "$PLIST_DST"

# Re-bootstrap idempotently
launchctl bootout "gui/$(id -u)" "$PLIST_DST" 2>/dev/null || true
launchctl bootstrap "gui/$(id -u)" "$PLIST_DST"

echo "[heartbeat] verify:"
launchctl list | grep "$LABEL" || { echo "FATAL: agent not listed"; exit 1; }
echo "[heartbeat] installed. Schedule: Mon-Fri 09:07 local. Beat log: $HB_DIR/heartbeat.log"
echo "[heartbeat] manual test run: bash $HB_DIR/heartbeat.sh"
