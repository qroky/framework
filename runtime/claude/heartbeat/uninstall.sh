#!/usr/bin/env bash
set -euo pipefail
LABEL="md.qroky.heartbeat"
PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"
launchctl bootout "gui/$(id -u)" "$PLIST" 2>/dev/null || true
rm -f "$PLIST"
echo "[heartbeat] removed. Local logs/out kept."
