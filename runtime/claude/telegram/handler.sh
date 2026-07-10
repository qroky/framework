#!/usr/bin/env bash
# handler.sh — the ONLY place an LLM lives in the Telegram head (H3). Woken
# by the listener after an ack is already sent and the event is already
# durable in decisions/inbox/. One --pass: consume gate answers (via
# pickup.sh, mechanical), resume open promises, then think about kroky and
# free-text items.
#
# Honest degradation: if the claude CLI is missing, the human is told so in
# the chat and the event STAYS in the inbox for a live session to pick up —
# nothing is lost, nothing pretends to think.
#
# Promise physics (H13): before long work starts, the «принял, результат к N»
# message is sent AND a promise file is written to the inbox — a kill between
# ack and result leaves the promise on disk; the next pass resumes it and N
# is kept (or an honest delay message is sent).
#
# Free-input router (H9): first message -> exactly ONE clarifying question
# (state/router/<chat>.pending); the reply -> a formulated task file
# kind=task-proposal in decisions/inbox/ for a session to pick up. The bot
# executes NOTHING itself.
#
# Test hook: QROKY_TEST_LLM=<script> replaces the claude CLI (stub reads the
# prompt on stdin, writes the reply to stdout).

set -euo pipefail
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

CLAUDE_BIN="${CLAUDE_BIN:-$HOME/.local/bin/claude}"
PROMISE_MINUTES=30

run_llm() { # run_llm <mode> (prompt on stdin) -> reply on stdout, rc!=0 = no LLM
  local mode="$1"
  if [[ -n "${QROKY_TEST_LLM:-}" ]]; then
    "$QROKY_TEST_LLM" "$mode"; return $?
  fi
  [[ -x "$CLAUDE_BIN" ]] || return 1
  "$CLAUDE_BIN" -p "$(cat)" --allowedTools "Read" "Glob" "Grep" 2>>"$LOG_FILE"
}

llm_burn_note() { log handler "budget: 1 LLM call (${QROKY_TEST_LLM:+stub}${QROKY_TEST_LLM:-claude -p}) for $1"; }

send_to_owner() { # reply on the dialogue contour; owner-initiated => no quiet gating
  local chat; chat="$(bound_chat_id)"
  [[ -n "$chat" ]] && send_text handler "$chat" "$1"
}

promise_open() { # promise_open <work-id> <due HH:MM> — durable BEFORE work
  inbox_write promise "$1" >/dev/null <<EOF
kind: promise
work: $1
due: $2
timestamp: $(date -u +%Y-%m-%dT%H:%M:%SZ)
EOF
}

promise_close() { # move ALL promise files of this work id to done/
  local p
  for p in "$INBOX_DIR"/*-promise-"$1".md; do
    [[ -f "$p" ]] && mv "$p" "$INBOX_DIR/done/$(basename "$p")"
  done
}

due_time() { # now + PROMISE_MINUTES, HH:MM (BSD date on macOS, GNU elsewhere)
  date -v "+${PROMISE_MINUTES}M" +%H:%M 2>/dev/null \
    || date -d "+${PROMISE_MINUTES} minutes" +%H:%M
}

work_kroky() { # <inbox-file>; ack already sent by the listener
  local f="$1" msg reply id
  id="$(basename "$f" .md)"
  msg="$(awk 'flag{print} /^---$/{flag=1}' "$f")"
  if ! promise_is_open "$id"; then
    local due; due="$(due_time)"
    promise_open "$id" "$due"
    send_to_owner "Принял, результат к $due — осматриваюсь по протоколу «кроки»."
  fi
  if reply="$(printf '%s' "$msg" | run_llm kroky)"; then
    llm_burn_note "kroky"
    send_to_owner "$reply"
    promise_close "$id"
    mv "$f" "$INBOX_DIR/done/$(basename "$f")"
    log handler "kroky $id done"
  else
    send_to_owner "Не могу поднять обработчик «кроки» на этой машине (claude CLI недоступен) — запрос сохранён, живая сессия его подхватит. Детали: telegram.log."
    log handler "kroky $id: NO LLM — event kept in inbox for a live session"
  fi
}

promise_is_open() { compgen -G "$INBOX_DIR/*-promise-$1.md" >/dev/null; }

work_user_message() { # <inbox-file>; router: ONE re-ask, then task-proposal
  local f="$1" chat msg pending reply
  chat="$(sed -n 's/^chat_id: //p' "$f" | head -1)"
  msg="$(awk 'flag{print} /^---$/{flag=1}' "$f")"
  pending="$STATE_DIR/router/$chat.pending"

  if [[ -f "$pending" ]]; then
    # second message = the clarification answer -> formulate the task
    if reply="$(printf 'ORIGINAL:\n%s\n\nCLARIFICATION:\n%s\n' "$(cat "$pending")" "$msg" | run_llm formulate)"; then
      llm_burn_note "router-formulate"
      inbox_write task-proposal "$(date +%s)" >/dev/null <<EOF
kind: task-proposal
chat_id: $chat
timestamp: $(date -u +%Y-%m-%dT%H:%M:%SZ)
---
$reply
EOF
      rm -f "$pending"
      send_to_owner "Оформил как задачу — живая сессия увидит её в decisions/inbox. Формулировка:"$'\n'"$reply"
      log handler "router: task-proposal written for chat $chat"
    else
      send_to_owner "Не могу сформулировать без обработчика (claude CLI недоступен) — твой ответ сохранён, живая сессия оформит. Детали: telegram.log."
      log handler "router: NO LLM at formulate — kept in inbox"
      return 0    # keep the inbox file: a live session finishes the job
    fi
  else
    # first message -> exactly ONE clarifying question
    if reply="$(printf '%s' "$msg" | run_llm clarify)"; then
      llm_burn_note "router-clarify"
      printf '%s' "$msg" > "$pending.tmp" && mv "$pending.tmp" "$pending"
      send_to_owner "$reply"
      log handler "router: clarifying question sent to chat $chat"
    else
      send_to_owner "Записал. Обработчик на этой машине недоступен (claude CLI) — живая сессия разберёт твоё сообщение из decisions/inbox."
      log handler "router: NO LLM at clarify — kept in inbox"
      return 0
    fi
  fi
  mv "$f" "$INBOX_DIR/done/$(basename "$f")"
}

case "${1:---pass}" in
  --pass)
    bash "$TG_LIB_DIR/pickup.sh"                   # mechanical parity records first

    # resume promises whose OWN work item is gone (crash window). Precision
    # per verify M3: check the exact work file this promise names — unrelated
    # inbox traffic must never hide an orphan.
    for p in "$INBOX_DIR"/*-promise-*.md; do
      [[ -f "$p" ]] || continue
      work="$(sed -n 's/^work: //p' "$p" | head -1)"
      if [[ -n "$work" && ! -f "$INBOX_DIR/$work.md" ]]; then
        # promise without ITS work item: the result was never sent — say so
        send_to_owner "По обещанию «результат к $(sed -n 's/^due: //p' "$p" | head -1)»: работа была прервана и её вход утерян — повтори запрос, пожалуйста. Это честный сбой, он записан."
        log handler "orphan promise $work — owner notified, promise closed"
        mv "$p" "$INBOX_DIR/done/$(basename "$p")"
      fi
    done

    for f in "$INBOX_DIR"/*-kroky-*.md;        do [[ -f "$f" ]] && work_kroky "$f"; done
    for f in "$INBOX_DIR"/*-user-message-*.md; do [[ -f "$f" ]] && work_user_message "$f"; done
    log handler "pass done"
    ;;
  *) fatal handler "unknown argument: $1 (only --pass)" ;;
esac
