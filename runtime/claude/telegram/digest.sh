#!/usr/bin/env bash
# digest.sh — the digest contour (H6, INFO-033 п.2). Strictly scheduled: a
# launchd StartCalendarInterval fires this daily at the profile DIGEST_TIME
# (install.sh bakes the time into the plist — that is the ±5 min guarantee,
# launchd's own precision). Content: «сделано / в работе / ждёт тебя сегодня /
# расход» + the 3-line changelog when a new framework release tag exists
# (INFO-023). Events already sent by the dialogue contour today appear ONLY
# as status lines — never as a second alarm.
#
# Independence: reads plain files (status.yaml, signaled registry, spend
# ledger, heartbeat's out/ if present). Heartbeat absent or disabled — the
# digest still ships; a data source missing — the section says so honestly
# instead of going quiet.

set -euo pipefail
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

TODAY="$(date +%Y-%m-%d)"
MARKER="$STATE_DIR/digest-sent-$TODAY"
if [[ -f "$MARKER" && -z "${QROKY_TEST_FORCE_DIGEST:-}" ]]; then
  log digest "already sent today — no duplicate"
  exit 0
fi

require_python digest

# ---- сделано / в работе / ждёт (products/*/status.yaml, one python pass) ----
DONE_LINES="" RUN_LINES="" WAIT_LINES=""
while IFS=$'\t' read -r state prod atom note; do
  case "$state" in
    done)    DONE_LINES+="• $prod/$atom${note:+ — $note}"$'\n' ;;
    running) RUN_LINES+="• $prod/$atom${note:+ — $note}"$'\n' ;;
    waiting) WAIT_LINES+="• $prod/$atom${note:+ — $note}"$'\n' ;;
  esac
done < <(py - "$PRODUCTS_DIR" <<'PYEOF'
import sys, os, re, glob
root = sys.argv[1]
for path in sorted(glob.glob(os.path.join(root, "*", "status.yaml"))):
    prod = os.path.basename(os.path.dirname(path))
    cur = None
    for ln in open(path, encoding="utf-8", errors="replace"):
        m = re.match(r'\s+([A-Z][A-Z0-9-]+):\s*$', ln) or re.match(r'\s+- id:\s*(\S+)', ln)
        if m: cur = m.group(1); continue
        m = re.match(r'\s+(?:status|state):\s*(.+)$', ln)
        if m and cur:
            s = m.group(1).strip()
            if s.startswith(("delivered", "closed", "reviewed")): kind = "done"
            elif s.startswith(("blocked", "awaiting", "pending")): kind = "waiting"
            else: kind = "running"
            print(f"{kind}\t{prod}\t{cur}\t{s}")
            cur = None
PYEOF
)

# ---- ждёт тебя сегодня: gates still awaiting an answer ----------------------
PENDING_LINES=""
for g in "$STATE_DIR/pending-gates"/*; do
  [[ -f "$g" && "$g" != *.answered ]] || continue
  PENDING_LINES+="• $(basename "$g") — ждёт твоего решения (кнопки в чате выше)"$'\n'
done

# ---- уже просигналено сегодня → строки статуса, не алармы (H6) --------------
SIGNALED_LINES=""
if [[ -f "$(signaled_file)" ]]; then
  while IFS= read -r ev; do
    [[ -n "$ev" ]] && SIGNALED_LINES+="• $ev — уже приходило событием сегодня, без повторной тревоги"$'\n'
  done < <(sort -u "$(signaled_file)")
fi

# ---- расход (честно: ledger или «данных нет») -------------------------------
SPEND_LINE="расход: данных за сегодня нет"
[[ -f "$STATE_DIR/spend/$TODAY" ]] && SPEND_LINE="расход: $(cat "$STATE_DIR/spend/$TODAY")"

# ---- changelog line on a new framework release tag (INFO-023) ---------------
CHANGELOG=""
FW_DIR="$TG_ROOT/framework"
if command -v git >/dev/null 2>&1 && [[ -e "$FW_DIR/.git" ]]; then
  latest="$(git -C "$FW_DIR" tag -l 'v*' --sort=-v:refname 2>>"$LOG_FILE" | head -1 || true)"
  last_seen=""; [[ -f "$STATE_DIR/last-release-tag" ]] && last_seen="$(cat "$STATE_DIR/last-release-tag")"
  if [[ -n "$latest" && "$latest" != "$last_seen" ]]; then
    body="$(git -C "$FW_DIR" tag -l "$latest" --format='%(contents:body)' 2>>"$LOG_FILE" | sed '/^[[:space:]]*$/d' | head -3)"
    CHANGELOG="Обновление правил $latest:"$'\n'"$body"
    printf '%s' "$latest" > "$STATE_DIR/last-release-tag.tmp" && mv "$STATE_DIR/last-release-tag.tmp" "$STATE_DIR/last-release-tag"
  fi
else
  log digest "changelog skipped: framework is not a git checkout here (or git missing) — honest degradation"
fi

# verify M6: blocked atoms and pending gates are ONE section — the
# «решений не ждём» line appears only when BOTH are empty, so a phone screen
# never shows waiting items and «ничего не ждёт» together.
WAIT_COMBINED="$WAIT_LINES$PENDING_LINES"
[[ -n "${WAIT_COMBINED//[$'\n' ]/}" ]] || WAIT_COMBINED="• решений не ждём"$'\n'

MSG="Доброе утро. Дайджест за $TODAY:

Сделано:
${DONE_LINES:-• пока пусто}
В работе:
${RUN_LINES:-• ничего не бежит}
Ждёт тебя сегодня:
${WAIT_COMBINED}
${SIGNALED_LINES:+Уже в ленте сегодня (статус, не тревога):
$SIGNALED_LINES}
$SPEND_LINE${CHANGELOG:+

$CHANGELOG}"

[[ ${#MSG} -gt 3900 ]] && MSG="${MSG:0:3900}"$'\n'"…(обрезано)"

CHAT="$(bound_chat_id)"
if [[ -z "$CHAT" ]]; then
  log digest "DEGRADED: no bound chat_id — digest not sent; run install.sh --bind"
  exit 0
fi
if send_text digest "$CHAT" "$MSG"; then
  : > "$MARKER"
  log digest "sent for $TODAY"
else
  log digest "send FAILED — will retry on next scheduled fire; check network and token file at $TOKEN_FILE"
  exit 1
fi
