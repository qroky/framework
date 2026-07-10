#!/usr/bin/env bash
# send-event.sh — the ONE shared outbound helper of the dialogue contour
# (H7). Callable BY a live session and BY heartbeat alike: the side where an
# event is born sends it the moment it occurs, through this script.
#
# usage:
#   send-event.sh --kind gate|e1|result|overdue|beat|info --id <event-id> \
#     --text <message text> [--buttons "Label 1|Label 2|..."] [--risk] [--blocker]
#   send-event.sh --flush-queue     # deliver quiet-hours queue, blockers first
#
# Behavior:
# - quiet hours (profile) => the event is QUEUED, not sent (H14); the queue
#   is flushed when quiet hours end — blockers first. User-initiated replies
#   never come through here (the listener answers those directly).
# - --risk (risk-level HUMAN-TASK confirmation): buttons are REFUSED even if
#   passed; the text gains the explicit-typed-word instruction (H5).
# - kind=gate/e1 with buttons: sent as an inline keyboard; the FULL question
#   text as sent is persisted to state/pending-gates/<id> so the pickup can
#   render a parity record (H1); risk items are persisted with risk=1.
# - every successfully sent event id lands in today's signaled registry, so
#   the digest shows it as a status line, never as a second alarm (H6).
# - send failure: 2 auto-retries inside tg_api, then the event goes to the
#   queue and the log names the concrete human action (never lost, never an
#   infinite retry).

set -euo pipefail
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

QUEUE_DIR="$STATE_DIR/queue"

serialize() { # one queue file per event, shell-sourceable, atomic
  local dest="$1"
  atomic_write "$dest" <<EOF
KIND=$(printf '%q' "$KIND")
ID=$(printf '%q' "$ID")
TEXT=$(printf '%q' "$TEXT")
BUTTONS=$(printf '%q' "$BUTTONS")
RISK=$(printf '%q' "$RISK")
BLOCKER=$(printf '%q' "$BLOCKER")
EOF
}

deliver() { # actually send one event (quiet hours already cleared)
  local chat; chat="$(bound_chat_id)"
  [[ -n "$chat" ]] || { log send-event "no bound chat_id — event $ID queued; run install.sh --bind first"; queue_event; return 0; }

  local text="$TEXT" markup="" btn_lines=""
  if [[ "$RISK" == "1" ]]; then
    # H5: no buttons for risk-level HUMAN-TASKs — explicit typed word only.
    [[ -n "$BUTTONS" ]] && log send-event "risk item $ID: buttons refused by rule"
    markup=""
    text+=$'\n\n'"Это действие риск-уровня: кнопки не предлагаются. Чтобы подтвердить, набери слово $RISK_WORD (именно текстом)."
  elif [[ -n "$BUTTONS" ]]; then
    # callback_data = "<event-id>|<button-index>" — Telegram caps callback_data
    # at 64 BYTES; labels of any length ride as button TEXT only and are
    # resolved back from the pending-gates registry at press time (verbatim by
    # construction — verify finding M1). An id too long for the 64-byte cap is
    # a CALLER error and fails loudly right here, never a silent retry loop.
    local btn_out
    if ! btn_out="$(py - "$ID" "$BUTTONS" <<'PYEOF'
import sys, json
ev_id, raw = sys.argv[1], sys.argv[2]
labels = [b.strip() for b in raw.split("|") if b.strip()]
rows, lines = [], []
for i, b in enumerate(labels, 1):
    cd = f"{ev_id}|{i}"
    if len(cd.encode("utf-8")) > 64:
        sys.exit(3)
    rows.append([{"text": b, "callback_data": cd}])
    lines.append(f"button{i}: {b}")
print(json.dumps({"inline_keyboard": rows}, ensure_ascii=False))
print("\n".join(lines))
PYEOF
)"; then
      fatal send-event "event id '$ID' is too long for button callback_data (Telegram 64-byte cap) — shorten the id; the event was NOT sent and NOT queued"
    fi
    markup="$(printf '%s\n' "$btn_out" | head -1)"
    btn_lines="$(printf '%s\n' "$btn_out" | tail -n +2)"
  fi

  # Persist the full question AS SENT — and the button labels for press-time
  # resolution — for parity records BEFORE sending (H1): a crash after send
  # still finds everything on disk at pickup time; risk items store the
  # augmented text — exactly what the human saw.
  if [[ "$KIND" == "gate" || "$KIND" == "e1" ]]; then
    atomic_write "$STATE_DIR/pending-gates/$ID" <<EOF
risk: $RISK
sent: $(date -u +%Y-%m-%dT%H:%M:%SZ)
${btn_lines:+$btn_lines
}---
$text
EOF
  fi

  if send_text send-event "$chat" "$text" "$markup"; then
    mark_signaled "$ID"
    log send-event "sent kind=$KIND id=$ID blocker=$BLOCKER risk=$RISK"
  else
    log send-event "send FAILED kind=$KIND id=$ID — queued; check network and the token file at $TOKEN_FILE"
    queue_event
  fi
}

queue_event() { # blockers sort first at flush time (0- prefix beats 1-)
  local prio="1"; [[ "$BLOCKER" == "1" ]] && prio="0"
  serialize "$QUEUE_DIR/$prio-$(date +%s)-$$-$RANDOM-$ID.ev"
  log send-event "queued kind=$KIND id=$ID blocker=$BLOCKER (quiet-hours or send failure)"
}

flush_queue() {
  in_quiet_hours && { log send-event "flush skipped: still in quiet hours"; return 0; }
  local f
  for f in "$QUEUE_DIR"/*.ev; do        # glob sorts: 0-blockers first (H14)
    [[ -f "$f" ]] || continue
    # shellcheck disable=SC1090
    KIND="" ID="" TEXT="" BUTTONS="" RISK="0" BLOCKER="0"; . "$f"
    rm "$f"                             # claim before deliver; failure re-queues
    deliver
  done
}

KIND="" ID="" TEXT="" BUTTONS="" RISK="0" BLOCKER="0" FLUSH=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --kind) KIND="$2"; shift 2 ;;
    --id) ID="$2"; shift 2 ;;
    --text) TEXT="$2"; shift 2 ;;
    --buttons) BUTTONS="$2"; shift 2 ;;
    --risk) RISK=1; shift ;;
    --blocker) BLOCKER=1; shift ;;
    --flush-queue) FLUSH=1; shift ;;
    *) fatal send-event "unknown argument: $1" ;;
  esac
done

if [[ $FLUSH -eq 1 ]]; then flush_queue; exit 0; fi
[[ -n "$KIND" && -n "$ID" && -n "$TEXT" ]] \
  || fatal send-event "required: --kind --id --text (or --flush-queue)"
case "$KIND" in gate|e1|result|overdue|beat|info) ;; *) fatal send-event "unknown kind: $KIND" ;; esac

if in_quiet_hours; then
  # H14: night events queue; blockers flagged so they exit first at quiet-end.
  queue_event
else
  deliver
fi
