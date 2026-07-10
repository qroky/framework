#!/usr/bin/env bash
# listener.sh — ONE polling pass of the dialogue contour (H3, INFO-033 п.5).
#
# Physics: launchd runs this every 30 seconds (StartInterval). One pass =
# getUpdates (polling, NO inbound ports, NO webhooks), then for each update:
# instant ack SENT BY THE LISTENER ITSELF, durable event into
# decisions/inbox/ (atomic tmp+rename), and a handler wake for anything that
# needs thinking. The listener is a plain script — the LLM lives ONLY in the
# handler it wakes. 30s cadence + one-pass work keeps the ≤1 min ack (H13)
# with margin. The offset file survives restarts: no replayed old presses.
#
# Per pass it also: sweeps NARRATIVE feeds (beat events, profile level),
# flushes the quiet-hours queue when quiet hours have ended (blockers first).
#
# Test hooks (harness only): QROKY_TEST_DELAY_PASS (sleep mid-pass, lsof
# window), QROKY_TEST_DELAY_INBOX (see lib.sh), QROKY_TEST_NO_WAKE (harness
# runs the handler itself).

set -euo pipefail
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

require_python listener

# ---- overlap guard: second concurrent pass exits quietly (run-twice answer) --
# A crashed pass (SIGKILL — no trap runs) must not blind the next ones
# (verify finding M2): the lock carries the holder's PID, and a dead holder
# is stolen IMMEDIATELY — so the worst crash window without acks is one 30s
# cadence, not minutes. A lock without a pid yet (holder died between mkdir
# and the pid write) falls back to a 2-minute mtime bound.
LOCK_DIR="$STATE_DIR/listener.lock"
if ! mkdir "$LOCK_DIR" 2>/dev/null; then
  HOLDER="$(cat "$LOCK_DIR/pid" 2>/dev/null || true)"
  if [[ -n "$HOLDER" ]] && kill -0 "$HOLDER" 2>/dev/null; then
    log listener "pass skipped: another pass is running (pid $HOLDER)"
    exit 0
  fi
  if [[ -z "$HOLDER" ]] && [[ -z "$(find "$LOCK_DIR" -maxdepth 0 -mmin +2 2>/dev/null)" ]]; then
    log listener "pass skipped: young lock without pid yet"
    exit 0
  fi
  log listener "stale lock removed (holder ${HOLDER:-unknown} is dead)"
  rm -rf "$LOCK_DIR"
  mkdir "$LOCK_DIR" 2>/dev/null || { log listener "pass skipped: lock re-taken"; exit 0; }
fi
printf '%s' "$$" > "$LOCK_DIR/pid"
trap 'rm -rf "$LOCK_DIR" 2>/dev/null || true' EXIT

OFFSET_FILE="$STATE_DIR/offset"
OFFSET=0; [[ -f "$OFFSET_FILE" ]] && OFFSET="$(cat "$OFFSET_FILE")"

BODY="$(tg_api listener getUpdates --data-urlencode "offset=$((OFFSET + 1))" --data-urlencode "timeout=0")" \
  || { log listener "getUpdates failed — pass ends; updates stay on Telegram's side, next pass retries"; exit 0; }

[[ -n "${QROKY_TEST_DELAY_PASS:-}" ]] && sleep "$QROKY_TEST_DELAY_PASS"

# ---- parse to shell-sourceable spool files (python = parser, not agent) -----
SPOOL="$(mktemp -d "$STATE_DIR/.spool.XXXXXX")"
trap 'rm -rf "$SPOOL"; rm -rf "$LOCK_DIR" 2>/dev/null || true' EXIT
printf '%s' "$BODY" > "$SPOOL/body.json"
py - "$SPOOL" <<'PYEOF'
import sys, json, shlex, os
spool = sys.argv[1]
data = json.load(open(os.path.join(spool, "body.json"), encoding="utf-8"))
for i, u in enumerate(data.get("result", [])):
    rec = {"UPDATE_ID": str(u.get("update_id", "")), "TYPE": "other",
           "CHAT_ID": "", "TEXT": "", "CB_ID": "", "CB_DATA": ""}
    if "message" in u:
        m = u["message"]
        rec.update(TYPE="message",
                   CHAT_ID=str(m.get("chat", {}).get("id", "")),
                   TEXT=m.get("text", "") or "")
    elif "callback_query" in u:
        c = u["callback_query"]
        rec.update(TYPE="callback",
                   CHAT_ID=str(c.get("message", {}).get("chat", {}).get("id", "")
                               or c.get("from", {}).get("id", "")),
                   CB_ID=str(c.get("id", "")), CB_DATA=c.get("data", "") or "")
    with open(os.path.join(spool, f"u{i:04d}.sh"), "w", encoding="utf-8") as f:
        for k, v in rec.items():
            f.write(f"{k}={shlex.quote(v)}\n")
PYEOF

BOUND="$(bound_chat_id)"
NEED_WAKE=0

ack() { send_text listener "$1" "$2" || log listener "ack send failed for chat $1 (event already durable in inbox)"; }

pending_risk_ids() { # gate ids awaiting the explicit word
  local f
  for f in "$STATE_DIR/pending-gates"/*; do
    [[ -f "$f" && "$f" != *.answered ]] || continue
    if head -1 "$f" | grep -q '^risk: 1'; then basename "$f"; fi
  done
  return 0   # empty result is not an error (set -e caller)
}

handle_callback() { # button press → parity event or risk re-ask
  # callback_data is "<event-id>|<button-index>" (verify M1: 64-byte cap) —
  # the verbatim label is resolved from the pending-gates registry, so the
  # recorded answer is EXACTLY what the button displayed, at any length.
  local id idx label pfile
  id="${CB_DATA%%|*}"; idx="${CB_DATA#*|}"
  pfile="$STATE_DIR/pending-gates/$id"
  if [[ -f "$pfile" ]] && head -1 "$pfile" | grep -q '^risk: 1'; then
    # H5: button-press-style reply to a risk item → rejected and re-asked
    tg_api listener answerCallbackQuery --data-urlencode "callback_query_id=$CB_ID" >/dev/null || true
    ack "$CHAT_ID" "Это подтверждение риск-уровня — кнопкой его принять нельзя. Набери слово $RISK_WORD текстом."
    log listener "risk item $id: button-style reply rejected, re-asked"
    return 0
  fi
  tg_api listener answerCallbackQuery --data-urlencode "callback_query_id=$CB_ID" >/dev/null || true
  label="$(sed -n "s/^button$idx: //p" "$pfile" 2>/dev/null | head -1)"
  if [[ -z "$label" ]]; then
    ack "$CHAT_ID" "Не нашёл этот вопрос — возможно, он уже закрыт. Если он всё ещё ждёт решения, напиши ответ текстом."
    log listener "callback for unknown gate/button id=$id idx=$idx — no record made"
    return 0
  fi
  inbox_write gate-answer "$id" >/dev/null <<EOF
kind: gate-answer
gate: $id
answer: $label
timestamp: $(date -u +%Y-%m-%dT%H:%M:%SZ)
channel: telegram
EOF
  ack "$CHAT_ID" "Принял: «${label}» — записываю решение по $id."
  log listener "gate-answer persisted gate=$id"
  NEED_WAKE=1
}

handle_message() {
  local text="$TEXT" lower
  lower="$(printf '%s' "$text" | tr '[:upper:]' '[:lower:]')"

  if [[ "$lower" == "кроки"* || "$lower" == "qroky"* ]]; then
    # H9: «кроки»-prefixed → the skill protocol, via the handler (LLM side)
    inbox_write kroky "$(date +%s)" >/dev/null <<EOF
kind: kroky
chat_id: $CHAT_ID
timestamp: $(date -u +%Y-%m-%dT%H:%M:%SZ)
---
$text
EOF
    ack "$CHAT_ID" "Принял. Запускаю протокол «кроки» — осмотрюсь и пришлю предложение сюда; действий до твоего «го» не будет."
    NEED_WAKE=1; return 0
  fi

  if [[ "$text" == "/status" || "$lower" == "что в работе"* ]]; then
    ack "$CHAT_ID" "$(render_status)"   # mechanical, no LLM (H8)
    log listener "status rendered"
    return 0
  fi

  if [[ "$text" == "$RISK_WORD" || "$text" == "$RISK_WORD "* ]]; then
    local target="" ids n
    ids="$(pending_risk_ids)"; n=0; [[ -n "$ids" ]] && n="$(printf '%s\n' "$ids" | wc -l | tr -d ' ')"
    if [[ "$text" == "$RISK_WORD "* ]]; then target="${text#"$RISK_WORD" }"
    elif [[ "$n" == "1" ]]; then target="$ids"
    fi
    if [[ -z "$target" || ! -f "$STATE_DIR/pending-gates/$target" ]]; then
      if [[ "$n" == "0" ]]; then ack "$CHAT_ID" "Сейчас нет ожидающих подтверждений риск-уровня."
      else ack "$CHAT_ID" "Ожидают подтверждения: $(printf '%s' "$ids" | tr '\n' ' '). Уточни: $RISK_WORD <id>."
      fi
      return 0
    fi
    inbox_write gate-answer "$target" >/dev/null <<EOF
kind: gate-answer
gate: $target
answer: $text
timestamp: $(date -u +%Y-%m-%dT%H:%M:%SZ)
channel: telegram
EOF
    ack "$CHAT_ID" "Принял подтверждение по $target — записываю решение."
    log listener "risk confirmation persisted gate=$target (explicit word)"
    NEED_WAKE=1; return 0
  fi

  # Free text (H9/H13): instant ack by the listener itself, durable event,
  # thinking happens in the handler this pass wakes.
  inbox_write user-message "$(date +%s)" >/dev/null <<EOF
kind: user-message
chat_id: $CHAT_ID
timestamp: $(date -u +%Y-%m-%dT%H:%M:%SZ)
---
$text
EOF
  ack "$CHAT_ID" "Принял, смотрю — отвечу здесь."
  NEED_WAKE=1
}

for u in "$SPOOL"/u*.sh; do
  [[ -f "$u" ]] || continue
  UPDATE_ID="" TYPE="" CHAT_ID="" TEXT="" CB_ID="" CB_DATA=""
  # shellcheck disable=SC1090
  . "$u"

  if [[ -z "$BOUND" || "$CHAT_ID" != "$BOUND" ]]; then
    # H4: foreign (or not-yet-bound) chat — no action, one flag line,
    # quarantine record. Deny by default; no reply to the foreign chat.
    log listener "FLAG foreign chat_id=$CHAT_ID update=$UPDATE_ID -> quarantine"
    atomic_write "$INBOX_DIR/quarantine/$(date +%s)-$$-$UPDATE_ID-foreign-$CHAT_ID.md" <<EOF
kind: quarantined
chat_id: $CHAT_ID
update_id: $UPDATE_ID
timestamp: $(date -u +%Y-%m-%dT%H:%M:%SZ)
---
type=$TYPE
$TEXT$CB_DATA
EOF
  else
    case "$TYPE" in
      callback) handle_callback ;;
      message)  handle_message ;;
      *)        log listener "update $UPDATE_ID type=$TYPE ignored (v1)" ;;
    esac
  fi

  # advance offset only AFTER the update is durably handled (no loss);
  # a crash before this line means Telegram re-delivers next pass.
  printf '%s' "$UPDATE_ID" > "$OFFSET_FILE.tmp" && mv "$OFFSET_FILE.tmp" "$OFFSET_FILE"
done

# ---- NARRATIVE feed sweep (dialogue contour, kind=beat; H7/D8) --------------
if [[ "$DETAIL_LEVEL" != "1" ]]; then    # level 1 = gates only, no beats
  for nf in "$PRODUCTS_DIR"/*/NARRATIVE.md; do
    [[ -f "$nf" ]] || continue
    slug="$(basename "$(dirname "$nf")")"
    off_file="$STATE_DIR/narrative/$slug.offset"
    off=0; [[ -f "$off_file" ]] && off="$(cat "$off_file")"
    size="$(wc -c < "$nf" | tr -d ' ')"
    if [[ "$size" -gt "$off" ]]; then
      new="$(tail -c "+$((off + 1))" "$nf")"
      if [[ "$DETAIL_LEVEL" == "2" ]]; then
        # level 2 — broad strokes: beat headlines only (bold-opening lines)
        beat="$(printf '%s\n' "$new" | grep '^\*\*' || true)"
      else
        beat="$new"                       # level 3 — full reasoning beats
      fi
      if [[ -n "${beat//[$'\n' ]/}" ]]; then
        [[ ${#beat} -gt 3800 ]] && beat="${beat:0:3800}"$'\n'"…(продолжение в $slug/NARRATIVE.md)"
        "$TG_LIB_DIR/send-event.sh" --kind beat --id "narrative-$slug-$off" \
          --text "[$slug]"$'\n'"$beat" \
          || { log listener "beat send failed for $slug — offset kept, retry next pass"; continue; }
      fi
      printf '%s' "$size" > "$off_file.tmp" && mv "$off_file.tmp" "$off_file"
    fi
  done
fi

# ---- quiet-hours queue: flush when the window has ended (H14) ---------------
"$TG_LIB_DIR/send-event.sh" --flush-queue || log listener "queue flush failed — retry next pass"

# ---- digest safety net (verify M4): a failed or missed daily fire must not --
# cost the whole day. If today's sent-marker is absent past DIGEST_TIME (send
# failed at fire time, or the Mac slept through it), retry from this pass —
# digest.sh's own marker keeps this idempotent, so at most one digest a day.
if [[ ! -f "$STATE_DIR/digest-sent-$(date +%Y-%m-%d)" ]] && [[ "$(now_hm)" > "$DIGEST_TIME" ]]; then
  log listener "digest for today missing past $DIGEST_TIME — safety-net retry"
  bash "$TG_LIB_DIR/digest.sh" >> "$LOG_FILE" 2>&1 \
    || log listener "digest safety-net retry failed — next pass retries"
fi

# ---- wake the handler (the LLM side) for anything that needs thinking -------
if [[ $NEED_WAKE -eq 1 && -z "${QROKY_TEST_NO_WAKE:-}" ]]; then
  log listener "waking handler"
  nohup bash "$TG_LIB_DIR/handler.sh" --pass >> "$LOG_FILE" 2>&1 &
  disown || true
fi

exit 0
