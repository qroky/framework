#!/usr/bin/env bash
# Qroky heartbeat — daily read-only scan of rpf, notifies CEO only on actions.
# Pattern borrowed from _BUSOS/tools/hermes-24x7 (proven launchd bundle).
set -euo pipefail

export TZ="Europe/Chisinau"
HB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RPF_DIR="$(cd "$HB_DIR/../../.." && pwd)"
OUT_DIR="$HB_DIR/out"
BEAT_LOG="$HB_DIR/heartbeat.log"
TODAY="$(date +%Y-%m-%d)"
OUT_FILE="$OUT_DIR/$TODAY.md"
CLAUDE_BIN="${CLAUDE_BIN:-$HOME/.local/bin/claude}"

mkdir -p "$OUT_DIR"

beat() { printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" >> "$BEAT_LOG"; }

notify() {
  local msg="$1"
  /usr/bin/osascript -e "display notification \"${msg//\"/\\\"}\" with title \"Qroky heartbeat\" sound name \"Ping\"" || true
}

beat "START"

if [[ ! -x "$CLAUDE_BIN" ]]; then
  beat "FATAL: claude CLI not found at $CLAUDE_BIN"
  notify "Сторож Qroky не нашёл claude CLI — пульс не снят"
  exit 2
fi

# Read-only scan: only Read/Glob/Grep and harmless listing commands allowed.
# Run from the repo root so relative paths in the prompt resolve.
cd "$RPF_DIR"
set +e
"$CLAUDE_BIN" -p "$(cat "$HB_DIR/heartbeat-prompt.md")" \
  --allowedTools "Read" "Glob" "Grep" "Bash(ls:*)" "Bash(head:*)" "Bash(tail:*)" "Bash(git log:*)" \
  > "$OUT_FILE" 2>>"$BEAT_LOG"
STATUS=$?
set -e

if [[ $STATUS -ne 0 || ! -s "$OUT_FILE" ]]; then
  beat "ERROR: scan failed (exit $STATUS)"
  notify "Сторож Qroky: скан не отработал (exit $STATUS) — проверь heartbeat.log"
  exit 1
fi

# First line, tolerant to markdown decoration (**bold**, #, leading spaces)
FIRST_LINE="$(head -1 "$OUT_FILE" | sed -E 's/^[#[:space:]*]+//; s/[[:space:]*]+$//')"

if [[ "$FIRST_LINE" == ALL-GREEN* ]]; then
  beat "OK all-green"
  # No notification by design: silence of the ping is not silence of the watcher —
  # the beat line above proves the watcher ran.
elif [[ "$FIRST_LINE" == ACTION:* ]]; then
  beat "OK action: ${FIRST_LINE#ACTION: }"
  notify "${FIRST_LINE#ACTION: } — детали: runtime/claude/heartbeat/out/$TODAY.md"
else
  beat "WARN: unexpected first line: $FIRST_LINE"
  notify "Сторож Qroky: неожиданный ответ скана — открой out/$TODAY.md"
fi

beat "END"
