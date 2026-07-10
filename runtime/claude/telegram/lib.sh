#!/usr/bin/env bash
# lib.sh — shared plumbing of the Telegram head (ATOM-110).
# Sourced by listener.sh / handler.sh / send-event.sh / digest.sh /
# record-decision.sh / pickup.sh. Plain bash + curl + /usr/bin/python3 (JSON
# parsing only). No inbound ports, no daemons, no LLM here.
#
# Sandbox overrides (tests only; production needs no env):
#   QROKY_TG_HOME     — where profile.conf / state / telegram.log live
#                       (default: this directory)
#   QROKY_TG_ROOT     — repo root holding decisions/ and products/
#                       (default: three levels up from this directory)
#   QROKY_TEST_NOW_HM — fake "HH:MM" clock for quiet-hours logic
#   QROKY_TEST_DELAY_INBOX — seconds to sleep between tmp-write and rename
#                       (kill-mid-write scenario hook)

set -euo pipefail

TG_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TG_HOME="${QROKY_TG_HOME:-$TG_LIB_DIR}"
TG_ROOT="${QROKY_TG_ROOT:-$(cd "$TG_LIB_DIR/../../.." && pwd)}"

STATE_DIR="$TG_HOME/state"
LOG_FILE="$TG_HOME/telegram.log"
INBOX_DIR="$TG_ROOT/decisions/inbox"
DECISIONS_DIR="$TG_ROOT/decisions"
PRODUCTS_DIR="$TG_ROOT/products"

mkdir -p "$STATE_DIR" "$STATE_DIR/queue" "$STATE_DIR/signaled" \
  "$STATE_DIR/narrative" "$STATE_DIR/pending-gates" "$STATE_DIR/router" \
  "$INBOX_DIR" "$INBOX_DIR/done" "$INBOX_DIR/quarantine"

# ---- profile (KEY=VALUE, shell-sourceable); defaults first, file overrides --
DIGEST_TIME="09:05"          # digest contour: daily send time (profile)
QUIET_START="23:00"          # dialogue contour: quiet hours start
QUIET_END="08:00"            # dialogue contour: quiet hours end
DETAIL_LEVEL="2"             # narrative feed level: 1 gates only, 2 beats, 3 full
RISK_WORD="ПОДТВЕРЖДАЮ"      # explicit word for risk-level HUMAN-TASKs
TOKEN_FILE="$TG_HOME/.token" # PRODUCTION: point at the kit's stored path
                             #   <workspace>/.qroky/telegram.token
API_BASE="https://api.telegram.org"
[[ -f "$TG_HOME/profile.conf" ]] && . "$TG_HOME/profile.conf"

log() { # log <component> <message...> — self-sufficient line, no secrets
  printf '[%s] %s %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$1" "${*:2}" >> "$LOG_FILE"
}

fatal() { # loud failure with a concrete human action, never silent
  log "$1" "FATAL: ${*:2}"
  printf 'telegram-head %s: %s\n' "$1" "${*:2}" >&2
  exit 1
}

tg_token() { # token from file path ONLY; never echoed into any log
  [[ -f "$TOKEN_FILE" ]] || fatal "${1:-lib}" \
    "no bot token at $TOKEN_FILE — create the bot via @BotFather and put the token in that file (mode 600)"
  tr -d ' \n' < "$TOKEN_FILE"
}

tg_api() { # tg_api <component> <method> [--data-urlencode k=v ...] -> body
  # curl only. The token-bearing URL is NEVER logged: curl's stderr (which
  # can echo the URL on connection errors) is captured and the token masked
  # to bot****<last4> before any of it reaches the log (verify M5).
  local component="$1" method="$2"; shift 2
  local token; token="$(tg_token "$component")"
  local body="" rc=0 attempt err errfile="$STATE_DIR/.curl-err.$$"
  for attempt in 1 2 3; do            # 1 try + max 2 auto-retries (ladder)
    body="$(curl -sS --max-time 20 "$API_BASE/bot$token/$method" "$@" 2>"$errfile")" && rc=0 || rc=$?
    if [[ $rc -eq 0 ]] && printf '%s' "$body" | grep -q '"ok"[[:space:]]*:[[:space:]]*true'; then
      rm -f "$errfile"; printf '%s' "$body"; return 0
    fi
    err="$(cat "$errfile" 2>/dev/null || true)"
    err="${err//"$token"/bot****${token: -4}}"   # mask — never the raw token
    log "$component" "api $method attempt $attempt failed rc=$rc${err:+ err: ${err//$'\n'/ | }}"
  done
  rm -f "$errfile"
  log "$component" "api $method GAVE UP after 2 retries — check network and the token file at $TOKEN_FILE"
  return 1
}

py() { /usr/bin/python3 "$@"; }
require_python() {
  command -v /usr/bin/python3 >/dev/null 2>&1 || fatal "$1" \
    "/usr/bin/python3 not found — install Apple Command Line Tools (xcode-select --install); unprocessed updates stay on Telegram's side and are re-delivered next pass"
}

atomic_write() { # atomic_write <dest-path>  (content on stdin): tmp+rename
  local dest="$1" dir tmp
  dir="$(dirname "$dest")"; tmp="$dir/.tmp.$$.$RANDOM"
  cat > "$tmp"
  [[ -n "${QROKY_TEST_DELAY_INBOX:-}" ]] && sleep "$QROKY_TEST_DELAY_INBOX"
  mv "$tmp" "$dest"
}

inbox_write() { # inbox_write <kind> <id> (frontmatter+body on stdin) -> path
  local kind="$1" id="$2"
  local name; name="$(date +%s)-$$-$RANDOM-$kind-$id.md"
  atomic_write "$INBOX_DIR/$name"
  printf '%s' "$INBOX_DIR/$name"
}

now_hm() { printf '%s' "${QROKY_TEST_NOW_HM:-$(date +%H:%M)}"; }

in_quiet_hours() { # true when now is inside [QUIET_START, QUIET_END)
  local now s e
  now="$(now_hm)"; s="$QUIET_START"; e="$QUIET_END"
  if [[ "$s" < "$e" ]]; then          # window inside one day
    [[ "$now" > "$s" || "$now" == "$s" ]] && [[ "$now" < "$e" ]]
  else                                # window crosses midnight (23:00-08:00)
    [[ "$now" > "$s" || "$now" == "$s" || "$now" < "$e" ]]
  fi
}

signaled_file() { printf '%s' "$STATE_DIR/signaled/$(date +%Y-%m-%d).list"; }
mark_signaled() { printf '%s\n' "$1" >> "$(signaled_file)"; }
was_signaled_today() { [[ -f "$(signaled_file)" ]] && grep -qxF "$1" "$(signaled_file)"; }

bound_chat_id() { [[ -f "$STATE_DIR/chat_id" ]] && tr -d ' \n' < "$STATE_DIR/chat_id" || printf ''; }

send_text() { # send_text <component> <chat_id> <text> [reply_markup_json]
  local component="$1" chat="$2" text="$3" markup="${4:-}"
  local args=(--data-urlencode "chat_id=$chat" --data-urlencode "text=$text")
  [[ -n "$markup" ]] && args+=(--data-urlencode "reply_markup=$markup")
  tg_api "$component" sendMessage "${args[@]}" >/dev/null
}

render_status() { # /status: plain-language summary from products/*/status.yaml
  # Mechanical rendering, no LLM. One message, hard-capped.
  local out="" f prod
  for f in "$PRODUCTS_DIR"/*/status.yaml; do
    [[ -f "$f" ]] || continue
    prod="$(basename "$(dirname "$f")")"
    out+="$(py - "$f" "$prod" <<'PYEOF'
import sys, re
path, prod = sys.argv[1], sys.argv[2]
lines = open(path, encoding="utf-8", errors="replace").read().splitlines()
cur = None; rows = []
for ln in lines:
    m = re.match(r'\s+(?:- id:\s*)?([A-Z][A-Z0-9-]+):?\s*$', ln)
    if m: cur = m.group(1); continue
    m = re.match(r'\s+- id:\s*(\S+)', ln)
    if m: cur = m.group(1); continue
    m = re.match(r'\s+(?:status|state):\s*(.+)$', ln)
    if m and cur:
        rows.append((cur, m.group(1).strip())); cur = None
act = [(a, s) for a, s in rows if not s.startswith(("closed", "delivered"))]
done = [(a, s) for a, s in rows if s.startswith(("closed", "delivered"))]
if act or done:
    print(f"• {prod}:")
    for a, s in act: print(f"    {a} — {s}")
    if done: print(f"    готово/закрыто: {len(done)}")
PYEOF
)"$'\n'
  done
  [[ -n "${out//[$'\n' ]/}" ]] || out="Пока нет ни одной задачи в products/ — статусов нет."
  # ≤1 message: Telegram cap 4096; keep margin and say so when truncated
  if [[ ${#out} -gt 3800 ]]; then out="${out:0:3800}"$'\n'"…(обрезано — полная картина в утреннем дайджесте)"; fi
  printf '%s' "$out"
}
