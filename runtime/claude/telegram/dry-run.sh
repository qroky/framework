#!/usr/bin/env bash
# dry-run.sh — sandboxed harness of the Telegram head (H11). Runs BEFORE any
# real token exists: the Bot API is a PATH-shadowed curl stub (no network, no
# ports — getUpdates is served from a local updates file, sendMessage appends
# to a local sent.jsonl), the LLM is a deterministic stub script, the repo
# root (decisions/, products/, framework/) is a throwaway fixture. The
# production code path is exercised unmodified — only transport, LLM, and
# clock (QROKY_TEST_NOW_HM) are substituted, each behind a marked hook.
#
# Every assertion can fail (the ATOM-101 r1-F1 lesson): kill scenarios prove
# the kill landed, negative greps run over payloads proven non-empty.
#
# Transcripts: products/telegram-head-v1/110-telegram-head/workspace/

set -uo pipefail

TG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RPF_DIR="$(cd "$TG_DIR/../../.." && pwd)"
ATOM_WS="$RPF_DIR/products/telegram-head-v1/110-telegram-head/workspace"
mkdir -p "$ATOM_WS"

SB="$(mktemp -d "${TMPDIR:-/tmp}/qroky-tg-dry.XXXXXX")"
trap 'rm -rf "$SB"' EXIT

PASS=0; FAIL=0; SUMMARY="$ATOM_WS/SUMMARY.txt"
{
  echo "dry-run.sh — Telegram head, summary of all scenarios"
  echo "Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo ""
} > "$SUMMARY"
record() { # record <scenario> <PASS|FAIL> <detail>
  printf '%s — %s: %s\n' "$2" "$1" "$3" >> "$SUMMARY"
  if [[ "$2" == "PASS" ]]; then PASS=$((PASS+1)); else FAIL=$((FAIL+1)); fi
}

# ============================================================================
# SANDBOX FIXTURES
# ============================================================================
ROOT="$SB/root"; TGH="$SB/tg"; BIN="$SB/bin"; FAKE="$SB/fake-api"
mkdir -p "$ROOT/decisions" "$ROOT/products/demo-product" "$TGH" "$BIN" "$FAKE"

TEST_TOKEN="7777001234:TEST-SECRET-cafebabe-DO-NOT-LEAK"
printf '%s\n' "$TEST_TOKEN" > "$TGH/.token"; chmod 600 "$TGH/.token"

# DIGEST_TIME is 21:00 — LATER than the pinned harness clock (12:00), so the
# listener's M4 digest safety net stays quiet through scenarios 1-11 and is
# exercised deliberately in scenario 13.
cat > "$TGH/profile.conf" <<EOF
DIGEST_TIME="21:00"
QUIET_START="23:00"
QUIET_END="08:00"
DETAIL_LEVEL="2"
TOKEN_FILE="$TGH/.token"
EOF

OWNER_CHAT=424242
mkdir -p "$TGH/state" && printf '%s' "$OWNER_CHAT" > "$TGH/state/chat_id"

# demo product: status.yaml + NARRATIVE.md
cat > "$ROOT/products/demo-product/status.yaml" <<'EOF'
# status registry — demo-product
atoms:
  ATOM-D1:
    folder: d1
    status: running
  ATOM-D2:
    folder: d2
    status: delivered (accepted r1)
  ATOM-D3:
    folder: d3
    status: blocked (awaiting CEO gate)
EOF
cat > "$ROOT/products/demo-product/NARRATIVE.md" <<'EOF'
# NARRATIVE — demo

**10.07, старт.** Первый такт: роль выбрана, конверт назначен.
Механика такта скрыта на уровне 2.
EOF

# framework fixture with a release tag (sandbox-only git, never the real repo)
FW="$ROOT/framework"
mkdir -p "$FW"
git -C "$FW" init -q
echo "rulebook stub" > "$FW/README.md"
git -C "$FW" -c user.email=dry@qroky.local -c user.name="dry" add -A
git -C "$FW" -c user.email=dry@qroky.local -c user.name="dry" commit -qm "stub"
git -C "$FW" -c user.email=dry@qroky.local -c user.name="dry" tag -a v2.0.0 -m "v2.0.0

меняет правило подписи
улучшает след решений
добавляет карту ролей"

# ---- Bot API stub: PATH-shadowed curl --------------------------------------
UPDATE_SEQ="$FAKE/seq"; printf '100' > "$UPDATE_SEQ"
: > "$FAKE/updates.jsonl"; : > "$FAKE/sent.jsonl"

cat > "$BIN/curl" <<EOF
#!/usr/bin/env bash
# fake curl — Telegram Bot API stub (dry-run only). No network, no ports.
# Forced-failure hook (M5 scenario): while fail-remaining > 0, behave like a
# real curl connection error — non-zero exit and a stderr line that DOES
# contain the token-bearing URL, exactly the leak surface the masking must
# scrub.
if [[ -f "$FAKE/fail-remaining" ]]; then
  n="\$(cat "$FAKE/fail-remaining")"
  if [[ "\$n" -gt 0 ]]; then
    echo \$((n-1)) > "$FAKE/fail-remaining"
    echo "curl: (6) Could not resolve host: api.telegram.org (dry-run forced failure); request: \$*" >&2
    exit 6
  fi
fi
exec /usr/bin/python3 "$BIN/fake-api.py" "$FAKE" "$TGH/.token" "\$@"
EOF
chmod +x "$BIN/curl"

cat > "$BIN/fake-api.py" <<'PYEOF'
import sys, json, os, re
fake, token_file = sys.argv[1], sys.argv[2]
args = sys.argv[3:]
url = ""; params = {}
i = 0
while i < len(args):
    a = args[i]
    if a == "--data-urlencode":
        k, _, v = args[i+1].partition("="); params[k] = v; i += 2
    elif a.startswith("http"):
        url = a; i += 1
    else:
        i += 1  # -sS --max-time N etc.
m = re.match(r'.*/bot([^/]+)/(\w+)$', url)
if not m:
    print(json.dumps({"ok": False, "description": "bad url"})); sys.exit(0)
tok, method = m.group(1), m.group(2)
real = open(token_file).read().strip()
if tok != real:
    print(json.dumps({"ok": False, "error_code": 401, "description": "Unauthorized"})); sys.exit(0)
open(os.path.join(fake, "auth-ok"), "w").write("token validated\n")
if method == "getUpdates":
    offset = int(params.get("offset", "0") or 0)
    out = []
    for line in open(os.path.join(fake, "updates.jsonl")):
        line = line.strip()
        if not line: continue
        u = json.loads(line)
        if u["update_id"] >= offset: out.append(u)
    print(json.dumps({"ok": True, "result": out}, ensure_ascii=False))
else:
    # Model the REAL Bot API's 64-BYTE callback_data cap (verify M1): an
    # oversized button is rejected and NOT recorded — code truncating by
    # characters instead of bytes fails loudly here.
    if method == "sendMessage" and params.get("reply_markup"):
        try:
            rm = json.loads(params["reply_markup"])
        except ValueError:
            rm = {}
        for row in rm.get("inline_keyboard", []):
            for btn in row:
                if len(btn.get("callback_data", "").encode("utf-8")) > 64:
                    print(json.dumps({"ok": False, "error_code": 400,
                                      "description": "Bad Request: BUTTON_DATA_INVALID"}))
                    sys.exit(0)
    entry = {"method": method}; entry.update(params)
    with open(os.path.join(fake, "sent.jsonl"), "a", encoding="utf-8") as f:
        f.write(json.dumps(entry, ensure_ascii=False) + "\n")
    print(json.dumps({"ok": True, "result": {"message_id": 1}}))
PYEOF

# ---- LLM stub ----------------------------------------------------------------
cat > "$BIN/llm-stub" <<'EOF'
#!/usr/bin/env bash
mode="$1"; cat >/dev/null
sleep "${LLM_STUB_SLEEP:-0}"
case "$mode" in
  clarify)   echo "Уточни одно: для какого банка и к какому сроку это нужно?" ;;
  formulate) echo "Задача: лендинг для Energbank к пятнице. Вход: два твоих сообщения. Критерий: страница открывается и показывает оффер." ;;
  kroky)     echo "Осмотрелся: проект живой, горит одна задача. Предлагаю план из трёх шагов. Го?" ;;
  *)         echo "stub: unknown mode $mode"; exit 1 ;;
esac
EOF
chmod +x "$BIN/llm-stub"

# ---- helpers -----------------------------------------------------------------
export QROKY_TG_HOME="$TGH" QROKY_TG_ROOT="$ROOT" QROKY_TEST_NO_WAKE=1
export QROKY_TEST_NOW_HM="12:00"   # pin a daytime clock: quiet-hours logic is
                                   # deterministic no matter when the harness runs
export PATH="$BIN:$PATH"
export HOME="$SB/home"; mkdir -p "$HOME"   # isolate: no real LaunchAgents/HOME
git config --file "$HOME/.gitconfig" protocol.file.allow always 2>/dev/null || true

next_update_id() { local n; n="$(cat "$UPDATE_SEQ")"; n=$((n+1)); printf '%s' "$n" > "$UPDATE_SEQ"; printf '%s' "$n"; }
add_message() { # add_message <chat_id> <text>
  local id; id="$(next_update_id)"
  /usr/bin/python3 - "$FAKE/updates.jsonl" "$id" "$1" "$2" <<'PYEOF'
import sys, json
path, uid, chat, text = sys.argv[1], int(sys.argv[2]), int(sys.argv[3]), sys.argv[4]
u = {"update_id": uid, "message": {"message_id": uid, "chat": {"id": chat}, "text": text}}
open(path, "a", encoding="utf-8").write(json.dumps(u, ensure_ascii=False) + "\n")
PYEOF
}
add_callback() { # add_callback <chat_id> <callback_data>
  local id; id="$(next_update_id)"
  /usr/bin/python3 - "$FAKE/updates.jsonl" "$id" "$1" "$2" <<'PYEOF'
import sys, json
path, uid, chat, data = sys.argv[1], int(sys.argv[2]), int(sys.argv[3]), sys.argv[4]
u = {"update_id": uid, "callback_query": {"id": f"cb{uid}",
     "message": {"message_id": 1, "chat": {"id": chat}}, "data": data}}
open(path, "a", encoding="utf-8").write(json.dumps(u, ensure_ascii=False) + "\n")
PYEOF
}
sent_count() { wc -l < "$FAKE/sent.jsonl" | tr -d ' '; }
sent_since() { tail -n "+$((${1} + 1))" "$FAKE/sent.jsonl"; }
listener() { bash "$TG_DIR/listener.sh"; }
handler()  { QROKY_TEST_LLM="$BIN/llm-stub" bash "$TG_DIR/handler.sh" --pass; }
INBOX="$ROOT/decisions/inbox"

# ============================================================================
# SCENARIO 1 — H1: gate as buttons, press, parity record vs session record
# ============================================================================
T="$ATOM_WS/scenario-1-parity.txt"
{
  echo "Scenario 1 — decision parity (H1)"
  echo "Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
} > "$T"
GATE_Q="Гейт GATE-T1: принять план дерева demo? Вариант «Да, принять» двигает дерево; «Вернуть» открывает fix-раунд."
B0=$(sent_count)
bash "$TG_DIR/send-event.sh" --kind gate --id GATE-T1 --text "$GATE_Q" --buttons "Да, принять|Вернуть" >> "$T" 2>&1
GATE_SENT=$(sent_since "$B0" | grep -c '"reply_markup"' || true)
PENDING_HAS_Q=$(grep -cF "принять план дерева demo" "$TGH/state/pending-gates/GATE-T1" 2>/dev/null || true)
add_callback "$OWNER_CHAT" "GATE-T1|1"   # index format (M1); button1 = «Да, принять»
B1=$(sent_count)
listener >> "$T" 2>&1
ACKED=$(sent_since "$B1" | grep -c "Принял: «Да, принять»" || true)
INBOX_FILE=$(ls "$INBOX"/*-gate-answer-GATE-T1.md 2>/dev/null | head -1)
bash "$TG_DIR/pickup.sh" >> "$T" 2>&1
REC="$ROOT/decisions/GATE-T1-decision.md"
REC_OK=0
[[ -f "$REC" ]] && grep -qF "gate: GATE-T1" "$REC" && grep -qF "принять план дерева demo" "$REC" \
  && grep -qF "> Да, принять" "$REC" && grep -qF "channel: telegram" "$REC" && grep -q "timestamp: " "$REC" && REC_OK=1
# session-channel record for the SAME gate, same answer/timestamp:
TS="$(sed -n 's/^- timestamp: //p' "$REC" | head -1)"
mkdir -p "$SB/parity"
printf '%s\n' "$GATE_Q" > "$SB/parity/q.txt"
bash "$TG_DIR/record-decision.sh" --gate GATE-T1 --question-file "$SB/parity/q.txt" \
  --answer "Да, принять" --channel session --timestamp "$TS" --out-dir "$SB/parity" >> "$T" 2>&1
DIFF_OUT="$(diff "$REC" "$SB/parity/GATE-T1-decision.md" || true)"
DIFF_LINES=$(printf '%s' "$DIFF_OUT" | grep -c '^[<>]' || true)
DIFF_CHANNEL=$(printf '%s' "$DIFF_OUT" | grep -c '^[<>] - channel:' || true)
{
  echo ""; echo "--- assertions ---"
  echo "gate sent with inline buttons: $GATE_SENT (must be 1)"
  echo "full question persisted for pickup: $PENDING_HAS_Q (must be >0)"
  echo "press acked with the verbatim label: $ACKED (must be 1)"
  echo "inbox gate-answer file: ${INBOX_FILE:-MISSING}"
  echo "record carries gate id + full question + verbatim label + ts + channel: $REC_OK"
  echo "diff telegram-vs-session record: $DIFF_LINES changed lines, $DIFF_CHANNEL of them channel (must be 2 and 2 — the ONLY diff, and not empty)"
  echo ""; echo "--- diff (verbatim) ---"; printf '%s\n' "$DIFF_OUT"
  echo ""; echo "--- record (verbatim) ---"; cat "$REC"
} >> "$T"
if [[ "$GATE_SENT" -eq 1 && "$PENDING_HAS_Q" -gt 0 && "$ACKED" -eq 1 && -n "$INBOX_FILE" \
      && $REC_OK -eq 1 && "$DIFF_LINES" -eq 2 && "$DIFF_CHANNEL" -eq 2 ]]; then
  record "1-parity" PASS "press -> inbox -> record with full question + verbatim label; session record differs in channel line only (diff non-empty)"
else
  record "1-parity" FAIL "sent=$GATE_SENT q=$PENDING_HAS_Q ack=$ACKED inbox=${INBOX_FILE:-none} rec=$REC_OK diff=$DIFF_LINES/$DIFF_CHANNEL"
fi

# ============================================================================
# SCENARIO 2 — H2: closed-session press; exactly-once pickup; kill-mid-write
# ============================================================================
T="$ATOM_WS/scenario-2-closed-session.txt"
{ echo "Scenario 2 — the mandated DoD scenario (H2)"; echo "Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)"; } > "$T"
GATE_Q2="Гейт GATE-T2: конверт исчерпан на 90% — поднять на 100k?"
bash "$TG_DIR/send-event.sh" --kind gate --id GATE-T2 --text "$GATE_Q2" --buttons "Поднять|Стоп" >> "$T" 2>&1
add_callback "$OWNER_CHAT" "GATE-T2|1"   # button1 = «Поднять»
listener >> "$T" 2>&1        # NO session runs; QROKY_TEST_NO_WAKE=1 = nothing picks up
PERSISTED=$(ls "$INBOX"/*-gate-answer-GATE-T2.md 2>/dev/null | wc -l | tr -d ' ')
{ echo "press persisted while NO session runs: $PERSISTED file(s) in inbox"; } >> "$T"
bash "$TG_DIR/pickup.sh" >> "$T" 2>&1     # wake 1
bash "$TG_DIR/pickup.sh" >> "$T" 2>&1     # wake 2 (must be a no-op)
REC2=$(ls "$ROOT/decisions"/GATE-T2-decision.md 2>/dev/null | wc -l | tr -d ' ')
LEFT=$(ls "$INBOX"/*-gate-answer-GATE-T2.md 2>/dev/null | wc -l | tr -d ' ')
DONE2=$(ls "$INBOX/done"/*-gate-answer-GATE-T2.md 2>/dev/null | wc -l | tr -d ' ')
SECOND_NOOP=$(grep -c "pass done, consumed=0" "$TGH/telegram.log" || true)

# kill-mid-write: delay between tmp and rename, SIGKILL inside the window
GATE_Q3="Гейт GATE-T3: kill-window проверка"
bash "$TG_DIR/send-event.sh" --kind gate --id GATE-T3 --text "$GATE_Q3" --buttons "Ок|Нет" >> "$T" 2>&1
add_callback "$OWNER_CHAT" "GATE-T3|1"   # button1 = «Ок»
OFFSET_BEFORE=$(cat "$TGH/state/offset")
QROKY_TEST_DELAY_INBOX=6 bash "$TG_DIR/listener.sh" >> "$T" 2>&1 &
LPID=$!
KILLED=0
for _ in $(seq 1 50); do
  if ls "$INBOX"/.tmp.* >/dev/null 2>&1; then kill -9 "$LPID" 2>/dev/null && KILLED=1; break; fi
  sleep 0.1
done
wait "$LPID" 2>/dev/null
PARTIAL=$(ls "$INBOX"/*-gate-answer-GATE-T3.md 2>/dev/null | wc -l | tr -d ' ')
TMP_LEFT=$(ls "$INBOX"/.tmp.* 2>/dev/null | wc -l | tr -d ' ')
OFFSET_AFTER_KILL=$(cat "$TGH/state/offset")
LOCK_LEFT=0; [[ -d "$TGH/state/listener.lock" ]] && LOCK_LEFT=1
rm -f "$INBOX"/.tmp.*
# M2: do NOT clean the crashed pass's lock — the NEXT pass must detect the
# dead holder itself and steal the lock immediately (no minutes-long blind
# window after an abnormal listener death).
listener >> "$T" 2>&1        # re-delivery pass (offset was not advanced)
REDELIVERED=$(ls "$INBOX"/*-gate-answer-GATE-T3.md 2>/dev/null | wc -l | tr -d ' ')
STALE_STOLEN=$(grep -c "stale lock removed" "$TGH/telegram.log" || true)
{
  echo ""; echo "--- assertions ---"
  echo "record rendered after two wakes: $REC2 (must be 1 — exactly once)"
  echo "inbox residue: $LEFT (0), consumed ledger: $DONE2 (1), second wake was a no-op: $([[ $SECOND_NOOP -gt 0 ]] && echo yes || echo no)"
  echo "kill landed inside the tmp->rename window: $KILLED (must be 1 — otherwise the scenario is vacuous)"
  echo "complete-or-nothing: complete files after kill = $PARTIAL (0), tmp remnant = $TMP_LEFT (1, proves the window)"
  echo "offset NOT advanced by the killed pass: $OFFSET_BEFORE -> $OFFSET_AFTER_KILL (must be equal)"
  echo "SIGKILL left the lock behind: $LOCK_LEFT (must be 1 — otherwise the stale-lock check below is vacuous)"
  echo "next pass stole the dead holder's lock immediately (M2): $STALE_STOLEN stale-lock log line(s) (must be >0)"
  echo "re-delivery on next pass persisted the press: $REDELIVERED (must be 1 — no loss, no blind window)"
} >> "$T"
if [[ "$PERSISTED" -eq 1 && "$REC2" -eq 1 && "$LEFT" -eq 0 && "$DONE2" -eq 1 && $SECOND_NOOP -gt 0 \
      && $KILLED -eq 1 && "$PARTIAL" -eq 0 && "$TMP_LEFT" -eq 1 && $LOCK_LEFT -eq 1 \
      && "$STALE_STOLEN" -gt 0 \
      && "$OFFSET_BEFORE" == "$OFFSET_AFTER_KILL" && "$REDELIVERED" -eq 1 ]]; then
  record "2-closed-session" PASS "press with no session persisted; consumed exactly once across two wakes; SIGKILL inside the write window left complete-or-nothing; crashed pass's lock stolen IMMEDIATELY by the next pass (M2) and the press re-delivered, not lost"
else
  record "2-closed-session" FAIL "persisted=$PERSISTED rec=$REC2 left=$LEFT done=$DONE2 noop=$SECOND_NOOP killed=$KILLED partial=$PARTIAL tmp=$TMP_LEFT lock=$LOCK_LEFT stale=$STALE_STOLEN offset=$OFFSET_BEFORE/$OFFSET_AFTER_KILL redeliver=$REDELIVERED"
fi
bash "$TG_DIR/pickup.sh" >> "$T" 2>&1   # drain T3 so later scenarios start clean

# ============================================================================
# SCENARIO 3 — H3: no ports, offset survives restart, plists (cadence, ±5 min)
# ============================================================================
T="$ATOM_WS/scenario-3-physics.txt"
{ echo "Scenario 3 — listener physics (H3) + schedule assertions (H6/H13)"; echo "Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)"; } > "$T"
QROKY_TEST_DELAY_PASS=4 bash "$TG_DIR/listener.sh" >> "$T" 2>&1 &
LPID=$!
sleep 1.5
ALIVE=0; kill -0 "$LPID" 2>/dev/null && ALIVE=1
PORTS="$(lsof -a -p "$LPID" -iTCP -sTCP:LISTEN 2>/dev/null || true)"
wait "$LPID" 2>/dev/null
B3=$(sent_count)
listener >> "$T" 2>&1          # restart with no new updates
B3B=$(sent_count)
OFFSET_NOW=$(cat "$TGH/state/offset")
MAX_UPDATE=$(cat "$UPDATE_SEQ")
bash "$TG_DIR/install.sh" --render-plists-only "$SB/plists" >> "$T" 2>&1
INTERVAL=$(grep -A1 StartInterval "$SB/plists/md.qroky.telegram.listener.plist" | grep -o '[0-9]*' | head -1)
DHOUR=$(grep -o '<key>Hour</key><integer>[0-9]*' "$SB/plists/md.qroky.telegram.digest.plist" | grep -o '[0-9]*$' || true)
DMIN=$(grep -o '<key>Minute</key><integer>[0-9]*' "$SB/plists/md.qroky.telegram.digest.plist" | grep -o '[0-9]*$' || true)
WEEKDAY=$(grep -c '<key>Weekday</key>' "$SB/plists/md.qroky.telegram.digest.plist" || true)
{
  echo ""; echo "--- assertions ---"
  echo "listener alive when sampled: $ALIVE (must be 1 — otherwise lsof proves nothing)"
  echo "listening TCP ports of the live listener (must be empty):"
  echo "${PORTS:-  (none)}"
  echo "restart with no updates re-sent nothing: $B3 -> $B3B sends (must be equal — offset survived)"
  echo "offset file: $OFFSET_NOW, last issued update_id: $MAX_UPDATE (must be equal)"
  echo "listener cadence in plist: ${INTERVAL}s (must be 30 — sustains the <=1 min ack)"
  echo "digest plist time: $DHOUR:$DMIN (profile 21:00 -> must be 21:0), Weekday keys: $WEEKDAY (0 = daily)"
} >> "$T"
if [[ $ALIVE -eq 1 && -z "$PORTS" && "$B3" == "$B3B" && "$OFFSET_NOW" == "$MAX_UPDATE" \
      && "$INTERVAL" == "30" && "$DHOUR" == "21" && "$DMIN" == "0" && "$WEEKDAY" -eq 0 ]]; then
  record "3-physics" PASS "no listening ports on a live pass; restart replays nothing (offset survives); cadence 30s; digest calendar = profile time, daily"
else
  record "3-physics" FAIL "alive=$ALIVE ports=$([[ -n "$PORTS" ]] && echo YES || echo no) resend=$B3/$B3B offset=$OFFSET_NOW/$MAX_UPDATE interval=$INTERVAL digest=$DHOUR:$DMIN weekday=$WEEKDAY"
fi

# ============================================================================
# SCENARIO 4 — H4: foreign chat_id -> no action, flag line, quarantine
# ============================================================================
T="$ATOM_WS/scenario-4-foreign-chat.txt"
{ echo "Scenario 4 — chat_id binding (H4)"; echo "Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)"; } > "$T"
add_message 999999 "/status"
add_callback 999999 "GATE-T1|Да, принять"
B4=$(sent_count)
listener >> "$T" 2>&1
SENT_TO_FOREIGN=$(sent_since "$B4" | grep -c '"chat_id": "999999"' || true)
FLAGS=$(grep -c "FLAG foreign chat_id=999999" "$TGH/telegram.log" || true)
QUAR=$(ls "$INBOX/quarantine"/*foreign-999999.md 2>/dev/null | wc -l | tr -d ' ')
FOREIGN_EVENTS=$(ls "$INBOX"/*-gate-answer-*.md "$INBOX"/*-user-message-*.md 2>/dev/null | wc -l | tr -d ' ')
{
  echo ""; echo "--- assertions ---"
  echo "replies sent to the foreign chat: $SENT_TO_FOREIGN (must be 0 — no action)"
  echo "flag lines in the log: $FLAGS (must be 2 — one per foreign update)"
  echo "quarantine records: $QUAR (must be 2)"
  echo "inbox events created from foreign updates: $FOREIGN_EVENTS (must be 0)"
} >> "$T"
if [[ "$SENT_TO_FOREIGN" -eq 0 && "$FLAGS" -eq 2 && "$QUAR" -eq 2 && "$FOREIGN_EVENTS" -eq 0 ]]; then
  record "4-foreign-chat" PASS "foreign message AND foreign button press: zero replies, zero events, flagged + quarantined"
else
  record "4-foreign-chat" FAIL "sent=$SENT_TO_FOREIGN flags=$FLAGS quar=$QUAR events=$FOREIGN_EVENTS"
fi

# ============================================================================
# SCENARIO 5 — H5: risk-level HUMAN-TASK — word only, buttons refused
# ============================================================================
T="$ATOM_WS/scenario-5-risk-word.txt"
{ echo "Scenario 5 — risk-word rule (H5)"; echo "Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)"; } > "$T"
B5=$(sent_count)
bash "$TG_DIR/send-event.sh" --kind gate --id GATE-RISK --risk --buttons "Да|Нет" \
  --text "HUMAN-TASK риск-уровня: подтвердить отправку договора банку." >> "$T" 2>&1
RISK_MSG="$(sent_since "$B5")"
RISK_BUTTONS=$(printf '%s' "$RISK_MSG" | grep -c '"reply_markup"' || true)
RISK_WORD_NAMED=$(printf '%s' "$RISK_MSG" | grep -c "ПОДТВЕРЖДАЮ" || true)
add_callback "$OWNER_CHAT" "GATE-RISK|1"      # button-style reply -> must be rejected
B5B=$(sent_count)
listener >> "$T" 2>&1
REJECTED=$(sent_since "$B5B" | grep -c "кнопкой его принять нельзя" || true)
RISK_ANSWER_FILES=$(ls "$INBOX"/*-gate-answer-GATE-RISK.md 2>/dev/null | wc -l | tr -d ' ')
add_message "$OWNER_CHAT" "ПОДТВЕРЖДАЮ"       # the explicit typed word
listener >> "$T" 2>&1
WORD_FILE=$(ls "$INBOX"/*-gate-answer-GATE-RISK.md 2>/dev/null | head -1)
WORD_VERBATIM=0; [[ -n "$WORD_FILE" ]] && grep -qx "answer: ПОДТВЕРЖДАЮ" "$WORD_FILE" && WORD_VERBATIM=1
bash "$TG_DIR/pickup.sh" >> "$T" 2>&1
RISK_REC=0; grep -qF "> ПОДТВЕРЖДАЮ" "$ROOT/decisions/GATE-RISK-decision.md" 2>/dev/null && RISK_REC=1
{
  echo ""; echo "--- assertions ---"
  echo "risk message carries buttons: $RISK_BUTTONS (must be 0) and names the word: $RISK_WORD_NAMED (must be >0)"
  echo "button-style reply rejected and re-asked: $REJECTED (must be 1); events created by it: $RISK_ANSWER_FILES (must be 0)"
  echo "typed word recorded verbatim: $WORD_VERBATIM; decision record carries the word: $RISK_REC"
  echo ""; echo "--- risk message (verbatim) ---"; printf '%s\n' "$RISK_MSG"
} >> "$T"
if [[ "$RISK_BUTTONS" -eq 0 && "$RISK_WORD_NAMED" -gt 0 && "$REJECTED" -eq 1 \
      && "$RISK_ANSWER_FILES" -eq 0 && $WORD_VERBATIM -eq 1 && $RISK_REC -eq 1 ]]; then
  record "5-risk-word" PASS "no buttons on the risk item; button-style reply rejected + re-asked; only the typed word produced a record (verbatim)"
else
  record "5-risk-word" FAIL "buttons=$RISK_BUTTONS named=$RISK_WORD_NAMED rejected=$REJECTED files=$RISK_ANSWER_FILES verbatim=$WORD_VERBATIM rec=$RISK_REC"
fi

# ============================================================================
# SCENARIO 6 — H6: digest content, no duplicate alarm, changelog, once-a-day
# ============================================================================
T="$ATOM_WS/scenario-6-digest.txt"
{ echo "Scenario 6 — digest contour (H6)"; echo "Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)"; } > "$T"
mkdir -p "$TGH/state/spend"; printf '~120k токенов (ATOM-D1 executor)' > "$TGH/state/spend/$(date +%Y-%m-%d)"
GATE_QP="Гейт GATE-PEND: ждёт решения"
bash "$TG_DIR/send-event.sh" --kind gate --id GATE-PEND --text "$GATE_QP" --buttons "Ок|Нет" >> "$T" 2>&1
B6=$(sent_count)
bash "$TG_DIR/digest.sh" >> "$T" 2>&1
DIGEST="$(sent_since "$B6")"
SEC_OK=1
for sec in "Сделано:" "В работе:" "Ждёт тебя сегодня:" "расход:"; do
  printf '%s' "$DIGEST" | grep -qF "$sec" || SEC_OK=0
done
HAS_RUNNING=$(printf '%s' "$DIGEST" | grep -c "ATOM-D1" || true)
HAS_PEND=$(printf '%s' "$DIGEST" | grep -c "GATE-PEND" || true)
DEDUP=$(printf '%s' "$DIGEST" | grep -c "GATE-T1 — уже приходило событием сегодня, без повторной тревоги" || true)
SPEND_OK=$(printf '%s' "$DIGEST" | grep -c "120k токенов" || true)
CHANGELOG_OK=0
printf '%s' "$DIGEST" | grep -qF "Обновление правил v2.0.0" \
  && printf '%s' "$DIGEST" | grep -qF "меняет правило подписи" \
  && printf '%s' "$DIGEST" | grep -qF "улучшает след решений" \
  && printf '%s' "$DIGEST" | grep -qF "добавляет карту ролей" && CHANGELOG_OK=1
B6B=$(sent_count)
bash "$TG_DIR/digest.sh" >> "$T" 2>&1      # second run same day
B6C=$(sent_count)
{
  echo ""; echo "--- assertions ---"
  echo "all four sections present: $SEC_OK; running atom listed: $HAS_RUNNING; pending gate in 'ждёт тебя': $HAS_PEND"
  echo "already-signaled GATE-T1 shown as status line, not alarm: $DEDUP (must be 1)"
  echo "spend from ledger: $SPEND_OK; 3-line changelog for new tag v2.0.0: $CHANGELOG_OK"
  echo "second run same day sent nothing: $B6B -> $B6C (must be equal)"
  echo ""; echo "--- digest (verbatim) ---"; printf '%s\n' "$DIGEST"
} >> "$T"
if [[ $SEC_OK -eq 1 && "$HAS_RUNNING" -gt 0 && "$HAS_PEND" -gt 0 && "$DEDUP" -eq 1 \
      && "$SPEND_OK" -gt 0 && $CHANGELOG_OK -eq 1 && "$B6B" == "$B6C" ]]; then
  record "6-digest" PASS "four sections + running/pending content; planted already-signaled gate rendered as status line (no duplicate alarm); 3-line changelog on new tag; once per day"
else
  record "6-digest" FAIL "sec=$SEC_OK run=$HAS_RUNNING pend=$HAS_PEND dedup=$DEDUP spend=$SPEND_OK chlog=$CHANGELOG_OK dup=$B6B/$B6C"
fi

# ============================================================================
# SCENARIO 7 — H7: instant events (heartbeat path), narrative beats by level
# ============================================================================
T="$ATOM_WS/scenario-7-events-feed.txt"
{ echo "Scenario 7 — dialogue-contour events + NARRATIVE feed (H7)"; echo "Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)"; } > "$T"
B7=$(sent_count)
# event born with NO session and NO listener involvement — the heartbeat side
# calls the same shared helper directly:
bash "$TG_DIR/send-event.sh" --kind result --id RESULT-D2 --text "ATOM-D2 доставлен: verify принял с первого раунда." >> "$T" 2>&1
bash "$TG_DIR/send-event.sh" --kind overdue --id OVERDUE-D3 --blocker --text "Просрочка: ATOM-D3 ждёт гейта дольше суток — дерево стоит." >> "$T" 2>&1
INSTANT=$(sent_since "$B7" | grep -c '"method": "sendMessage"' || true)
# narrative sweep, level 2: headline only
cat >> "$ROOT/products/demo-product/NARRATIVE.md" <<'EOF'

**10.07, такт 2: verify вернул атом.** Возврат по двум находкам класса
доказательств. Механика правок — в run.log, здесь только смысл.
EOF
B7B=$(sent_count)
listener >> "$T" 2>&1
BEAT2="$(sent_since "$B7B" | grep '"text"' | grep 'такт 2' || true)"
BEAT2_HEADLINE=$(printf '%s' "$BEAT2" | grep -c 'такт 2: verify вернул атом' || true)
BEAT2_BODY=$(printf '%s' "$BEAT2" | grep -c 'Механика правок' || true)
B7C=$(sent_count)
listener >> "$T" 2>&1          # no new content -> no re-send
B7D=$(sent_count)
# level 3: full text
sed -i '' 's/DETAIL_LEVEL="2"/DETAIL_LEVEL="3"/' "$TGH/profile.conf"
cat >> "$ROOT/products/demo-product/NARRATIVE.md" <<'EOF'

**10.07, такт 3: закрытие.** Взвешивание: конфликт факта решён предъявлением
транскрипта; ценностных конфликтов не было. Запись ушла в decisions.
EOF
B7E=$(sent_count)
listener >> "$T" 2>&1
BEAT3="$(sent_since "$B7E" | grep 'такт 3' || true)"
BEAT3_FULL=$(printf '%s' "$BEAT3" | grep -c 'транскрипта' || true)
# level 1: gates only — a new beat must NOT be sent
sed -i '' 's/DETAIL_LEVEL="3"/DETAIL_LEVEL="1"/' "$TGH/profile.conf"
cat >> "$ROOT/products/demo-product/NARRATIVE.md" <<'EOF'

**10.07, такт 4: уровень 1.** Эта строка не должна уехать в чат.
EOF
B7F=$(sent_count)
listener >> "$T" 2>&1
LEVEL1_SENT=$(sent_since "$B7F" | grep -c 'такт 4' || true)
sed -i '' 's/DETAIL_LEVEL="1"/DETAIL_LEVEL="2"/' "$TGH/profile.conf"
# fixture reset: catch the narrative offset up past the level-1 beat so the
# quiet-hours scenario's queue counts are about ITS events only (level 1
# freezes the offset by design — beats are skipped, not consumed)
wc -c < "$ROOT/products/demo-product/NARRATIVE.md" | tr -d ' ' > "$TGH/state/narrative/demo-product.offset"
{
  echo ""; echo "--- assertions ---"
  echo "result + blocker events sent the moment they occur (no session, no listener): $INSTANT (must be 2)"
  echo "level 2 beat: headline sent: $BEAT2_HEADLINE (1), body suppressed: $BEAT2_BODY (0)"
  echo "no re-send of old beats: $B7C -> $B7D (must be equal)"
  echo "level 3 beat: full reasoning included: $BEAT3_FULL (must be >0)"
  echo "level 1: beat NOT sent: $LEVEL1_SENT (must be 0)"
} >> "$T"
if [[ "$INSTANT" -eq 2 && "$BEAT2_HEADLINE" -eq 1 && "$BEAT2_BODY" -eq 0 \
      && "$B7C" == "$B7D" && "$BEAT3_FULL" -gt 0 && "$LEVEL1_SENT" -eq 0 ]]; then
  record "7-events-feed" PASS "heartbeat-side events instant via the shared helper; beats ride the contour at levels 2/3, level 1 = gates only, no re-sends"
else
  record "7-events-feed" FAIL "instant=$INSTANT b2=$BEAT2_HEADLINE/$BEAT2_BODY resend=$B7C/$B7D b3=$BEAT3_FULL l1=$LEVEL1_SENT"
fi

# ============================================================================
# SCENARIO 8 — H13: ack <=1 min budget; «принял, результат к N»; kill-between
# ============================================================================
T="$ATOM_WS/scenario-8-ack-promise.txt"
{ echo "Scenario 8 — ack + promise survival (H13), «кроки» routing (H9)"; echo "Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)"; } > "$T"
add_message "$OWNER_CHAT" "кроки: осмотрись и предложи план"
B8=$(sent_count)
ACK_START=$(date +%s)
listener >> "$T" 2>&1
ACK_END=$(date +%s)
PASS_SECONDS=$((ACK_END - ACK_START))
ACKED8=$(sent_since "$B8" | grep -c "Принял. Запускаю протокол «кроки»" || true)
KROKY_FILE=$(ls "$INBOX"/*-kroky-*.md 2>/dev/null | head -1)
# handler with a SLOW LLM stub; kill between promise and result:
B8B=$(sent_count)
QROKY_TEST_LLM="$BIN/llm-stub" LLM_STUB_SLEEP=8 bash "$TG_DIR/handler.sh" --pass >> "$T" 2>&1 &
HPID=$!
PROMISED=0
for _ in $(seq 1 60); do
  if ls "$INBOX"/*-promise-*.md >/dev/null 2>&1; then PROMISED=1; break; fi
  sleep 0.2
done
sleep 0.5
kill -9 "$HPID" 2>/dev/null; KILLED8=$?
wait "$HPID" 2>/dev/null
PROMISE_MSG=$(sent_since "$B8B" | grep -c "результат к" || true)
RESULT_BEFORE=$(sent_since "$B8B" | grep -c "Осмотрелся" || true)
PROMISE_SURVIVES=$(ls "$INBOX"/*-promise-*.md 2>/dev/null | wc -l | tr -d ' ')
# wake: rerun the handler — the promise must be answered
B8C=$(sent_count)
handler >> "$T" 2>&1
RESULT_AFTER=$(sent_since "$B8C" | grep -c "Осмотрелся" || true)
PROMISE_CLOSED=$(ls "$INBOX"/*-promise-*.md 2>/dev/null | wc -l | tr -d ' ')
KROKY_DONE=$(ls "$INBOX/done"/*-kroky-*.md 2>/dev/null | grep -cv promise || true)
{
  echo ""; echo "--- assertions ---"
  echo "listener pass wall time: ${PASS_SECONDS}s; cadence 30s (scenario 3) => worst-case ack = pass + cadence < 60s"
  echo "instant ack sent by the listener itself: $ACKED8 (must be 1); durable kroky event: ${KROKY_FILE:-MISSING}"
  echo "promise message «результат к N» sent: $PROMISE_MSG (1); result before kill: $RESULT_BEFORE (0)"
  echo "kill -9 delivered to the working handler: rc=$KILLED8 (must be 0 — otherwise vacuous)"
  echo "promise file survives the kill: $PROMISE_SURVIVES (must be 1)"
  echo "after wake: result delivered: $RESULT_AFTER (1); promise closed: $PROMISE_CLOSED (0); kroky consumed: $KROKY_DONE (1)"
} >> "$T"
if [[ $PASS_SECONDS -lt 25 && "$ACKED8" -eq 1 && -n "$KROKY_FILE" && "$PROMISE_MSG" -ge 1 \
      && "$RESULT_BEFORE" -eq 0 && $KILLED8 -eq 0 && "$PROMISE_SURVIVES" -eq 1 \
      && "$RESULT_AFTER" -eq 1 && "$PROMISE_CLOSED" -eq 0 && "$KROKY_DONE" -eq 1 ]]; then
  record "8-ack-promise" PASS "ack within the polling budget; promise recorded in inbox BEFORE work; SIGKILL between ack and result -> promise survived and was answered after wake, N kept"
else
  record "8-ack-promise" FAIL "pass=${PASS_SECONDS}s ack=$ACKED8 kroky=${KROKY_FILE:-none} promise=$PROMISE_MSG before=$RESULT_BEFORE kill=$KILLED8 survive=$PROMISE_SURVIVES after=$RESULT_AFTER closed=$PROMISE_CLOSED done=$KROKY_DONE"
fi

# ============================================================================
# SCENARIO 9 — H14: quiet hours — queue, blockers first, user still acked
# ============================================================================
T="$ATOM_WS/scenario-9-quiet-hours.txt"
{ echo "Scenario 9 — quiet hours (H14)"; echo "Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)"; } > "$T"
B9=$(sent_count)
QROKY_TEST_NOW_HM="02:30" bash "$TG_DIR/send-event.sh" --kind result --id NIGHT-RESULT --text "Ночной результат: атом доставлен." >> "$T" 2>&1
QROKY_TEST_NOW_HM="02:35" bash "$TG_DIR/send-event.sh" --kind e1 --id NIGHT-BLOCKER --blocker --text "Ночной блокер: E1 — нужно твоё решение." >> "$T" 2>&1
NIGHT_SENT=$(($(sent_count) - B9))
QUEUED=$(ls "$TGH/state/queue"/*.ev 2>/dev/null | wc -l | tr -d ' ')
add_message "$OWNER_CHAT" "не спится, что там?"
B9B=$(sent_count)
QROKY_TEST_NOW_HM="02:40" bash "$TG_DIR/listener.sh" >> "$T" 2>&1
NIGHT_ACK=$(sent_since "$B9B" | grep -c "Принял, смотрю" || true)
NIGHT_FLUSH=$(ls "$TGH/state/queue"/*.ev 2>/dev/null | wc -l | tr -d ' ')
# morning: quiet hours over -> flush, blockers first
B9C=$(sent_count)
QROKY_TEST_NOW_HM="08:30" bash "$TG_DIR/listener.sh" >> "$T" 2>&1
MORNING="$(sent_since "$B9C" | grep '"method": "sendMessage"' || true)"
BLOCKER_LINE=$(printf '%s\n' "$MORNING" | grep -n "Ночной блокер" | cut -d: -f1 | head -1)
RESULT_LINE=$(printf '%s\n' "$MORNING" | grep -n "Ночной результат" | cut -d: -f1 | head -1)
ORDER_OK=0
[[ -n "$BLOCKER_LINE" && -n "$RESULT_LINE" && "$BLOCKER_LINE" -lt "$RESULT_LINE" ]] && ORDER_OK=1
{
  echo ""; echo "--- assertions ---"
  echo "night events sent at 02:xx: $NIGHT_SENT (must be 0), queued: $QUEUED (must be 2)"
  echo "user message at night still acked: $NIGHT_ACK (must be 1); queue untouched at night: $NIGHT_FLUSH (must be 2)"
  echo "morning flush order: blocker line $BLOCKER_LINE before result line $RESULT_LINE: $ORDER_OK (must be 1)"
} >> "$T"
if [[ "$NIGHT_SENT" -eq 0 && "$QUEUED" -eq 2 && "$NIGHT_ACK" -eq 1 && "$NIGHT_FLUSH" -eq 2 && $ORDER_OK -eq 1 ]]; then
  record "9-quiet-hours" PASS "night events queued (0 sent), user acked even at night, morning flush delivered blocker FIRST"
else
  record "9-quiet-hours" FAIL "night=$NIGHT_SENT queued=$QUEUED ack=$NIGHT_ACK untouched=$NIGHT_FLUSH order=$ORDER_OK"
fi
# drain the night user-message so scenario 10's router starts clean
handler >> "$T" 2>&1
rm -f "$TGH/state/router"/*.pending

# ============================================================================
# SCENARIO 10 — H8 /status + H9 free-input router (ONE re-ask -> task file)
# ============================================================================
T="$ATOM_WS/scenario-10-status-router.txt"
{ echo "Scenario 10 — /status (H8) + free-input router (H9)"; echo "Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)"; } > "$T"
add_message "$OWNER_CHAT" "/status"
add_message "$OWNER_CHAT" "что в работе?"
B10=$(sent_count)
listener >> "$T" 2>&1
STATUS_REPLIES=$(sent_since "$B10" | grep -c "ATOM-D1" || true)
STATUS_MSGS=$(sent_since "$B10" | grep -c '"method": "sendMessage"' || true)
add_message "$OWNER_CHAT" "нужен лендинг для банка, про рекуррентные платежи"
B10B=$(sent_count)
listener >> "$T" 2>&1
handler >> "$T" 2>&1
CLARIFY=$(sent_since "$B10B" | grep -c "Уточни одно" || true)
add_message "$OWNER_CHAT" "Energbank, к пятнице"
B10C=$(sent_count)
listener >> "$T" 2>&1
handler >> "$T" 2>&1
TASK_FILE=$(ls "$INBOX"/*-task-proposal-*.md 2>/dev/null | head -1)
TASK_OK=0; [[ -n "$TASK_FILE" ]] && grep -q "kind: task-proposal" "$TASK_FILE" && grep -q "Energbank" "$TASK_FILE" && TASK_OK=1
CONFIRMED=$(sent_since "$B10C" | grep -c "Оформил как задачу" || true)
SECOND_ASK=$(sent_since "$B10C" | grep -c "Уточни одно" || true)
{
  echo ""; echo "--- assertions ---"
  echo "/status and «что в работе» answered with real atoms: $STATUS_REPLIES (must be 2), one message each: $STATUS_MSGS (must be 2, <=1 per command)"
  echo "free text -> exactly ONE clarifying question: $CLARIFY (must be 1); after the reply NO second re-ask: $SECOND_ASK (must be 0)"
  echo "task-proposal file after the reply: ${TASK_FILE:-MISSING} valid=$TASK_OK; owner told: $CONFIRMED (must be 1)"
} >> "$T"
if [[ "$STATUS_REPLIES" -eq 2 && "$STATUS_MSGS" -eq 2 && "$CLARIFY" -eq 1 \
      && "$SECOND_ASK" -eq 0 && $TASK_OK -eq 1 && "$CONFIRMED" -eq 1 ]]; then
  record "10-status-router" PASS "/status + «что в работе» render from status.yaml in <=1 message; router asked exactly one question then filed a task-proposal; the bot executed nothing"
else
  record "10-status-router" FAIL "status=$STATUS_REPLIES msgs=$STATUS_MSGS clarify=$CLARIFY second=$SECOND_ASK task=$TASK_OK confirmed=$CONFIRMED"
fi

# ============================================================================
# SCENARIO 11 — H10: secrets — negative grep over every trace
# ============================================================================
T="$ATOM_WS/scenario-11-secrets.txt"
{ echo "Scenario 11 — token negative grep (H10)"; echo "Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)"; } > "$T"
AUTH_USED=0; [[ -f "$FAKE/auth-ok" ]] && AUTH_USED=1     # token really flowed
LEAKS=$(grep -r -l "TEST-SECRET" "$TGH/telegram.log" "$TGH/state" "$ROOT/decisions" "$FAKE/sent.jsonl" 2>/dev/null | grep -v "$TGH/.token" | wc -l | tr -d ' ')
# committed files: exclude the harness itself — it DEFINES the test-token
# fixture; the production token never appears in any committed file.
COMMITTED_LEAKS=$(grep -rc "TEST-SECRET" "$TG_DIR" --exclude=dry-run.sh 2>/dev/null | awk -F: '{s+=$2} END{print s+0}')
TRANSCRIPT_LEAKS=$(grep -rl "TEST-SECRET" "$ATOM_WS" 2>/dev/null | grep -v scenario-11 | wc -l | tr -d ' ')
SENT_NONEMPTY=$(wc -l < "$FAKE/sent.jsonl" | tr -d ' ')
{
  echo ""; echo "--- assertions ---"
  echo "token was genuinely used (stub validated it on every call): $AUTH_USED (must be 1 — grep below cannot pass vacuously)"
  echo "sent.jsonl lines (payload the grep runs over): $SENT_NONEMPTY (must be >0)"
  echo "token traces in log/state/decisions/sent: $LEAKS (must be 0)"
  echo "token traces in committed files under runtime/claude/telegram/: $COMMITTED_LEAKS (must be 0)"
  echo "token traces in harness transcripts: $TRANSCRIPT_LEAKS (must be 0)"
} >> "$T"
if [[ $AUTH_USED -eq 1 && "$SENT_NONEMPTY" -gt 0 && "$LEAKS" -eq 0 && "$COMMITTED_LEAKS" -eq 0 && "$TRANSCRIPT_LEAKS" -eq 0 ]]; then
  record "11-secrets" PASS "token flowed through every API call (stub-verified) yet appears nowhere: log, state, records, sent payloads, committed files, transcripts all clean"
else
  record "11-secrets" FAIL "used=$AUTH_USED sent=$SENT_NONEMPTY leaks=$LEAKS committed=$COMMITTED_LEAKS transcripts=$TRANSCRIPT_LEAKS"
fi

# ============================================================================
# SCENARIO 12 — M1: long button label — 64-BYTE callback_data cap, verbatim
# label resolved from the registry. The stub now models the real API's
# rejection, so the pre-fix chars-truncation code CANNOT pass this scenario.
# ============================================================================
T="$ATOM_WS/scenario-12-long-label.txt"
{ echo "Scenario 12 — long-label gate (verify M1)"; echo "Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)"; } > "$T"
LONG_LABEL="Вернуть на доработку с подробным комментарием по всем пунктам замечаний"
OLD_CD_BYTES=$(printf '%s' "GATE-LL|$LONG_LABEL" | wc -c | tr -d ' ')
# the stub's cap enforcement is itself proven live: an oversized callback_data
# sent directly must come back rejected and unrecorded
B12A=$(sent_count)
BAD_RESP="$(curl -sS "https://api.telegram.org/bot$TEST_TOKEN/sendMessage" \
  --data-urlencode "chat_id=1" --data-urlencode "text=probe" \
  --data-urlencode "reply_markup={\"inline_keyboard\":[[{\"text\":\"x\",\"callback_data\":\"GATE-LL|$LONG_LABEL\"}]]}" 2>/dev/null)"
STUB_REJECTS=$(printf '%s' "$BAD_RESP" | grep -c "BUTTON_DATA_INVALID" || true)
STUB_RECORDED=$(( $(sent_count) - B12A ))
B12=$(sent_count)
bash "$TG_DIR/send-event.sh" --kind gate --id GATE-LL \
  --text "Гейт GATE-LL: проверка длинных кнопок." --buttons "Принять|$LONG_LABEL" >> "$T" 2>&1
SENT12=$(sent_since "$B12" | grep -c '"reply_markup"' || true)
CD_STATS="$(sent_since "$B12" | /usr/bin/python3 -c '
import sys, json
max_cd = 0; label_ok = 0; want = sys.argv[1]
for line in sys.stdin:
    e = json.loads(line)
    if "reply_markup" not in e: continue
    for row in json.loads(e["reply_markup"]).get("inline_keyboard", []):
        for b in row:
            max_cd = max(max_cd, len(b["callback_data"].encode("utf-8")))
            if b["text"] == want: label_ok = 1
print(f"{max_cd} {label_ok}")' "$LONG_LABEL")"
MAX_CD_BYTES="${CD_STATS%% *}"; LABEL_INTACT="${CD_STATS##* }"
add_callback "$OWNER_CHAT" "GATE-LL|2"      # press the LONG button by index
listener >> "$T" 2>&1
LL_FILE=$(ls "$INBOX"/*-gate-answer-GATE-LL.md 2>/dev/null | head -1)
LL_VERBATIM=0; [[ -n "$LL_FILE" ]] && grep -qF "answer: $LONG_LABEL" "$LL_FILE" && LL_VERBATIM=1
bash "$TG_DIR/pickup.sh" >> "$T" 2>&1
LL_REC=0; grep -qF "> $LONG_LABEL" "$ROOT/decisions/GATE-LL-decision.md" 2>/dev/null && LL_REC=1
{
  echo ""; echo "--- assertions ---"
  echo "old label-in-callback_data scheme would need $OLD_CD_BYTES bytes (must be >64 — the scenario genuinely discriminates)"
  echo "stub rejects oversized callback_data live: $STUB_REJECTS (must be 1), recorded by stub: $STUB_RECORDED (must be 0)"
  echo "long-label gate sent with buttons: $SENT12 (must be 1 — no rejection, no queue loop)"
  echo "max callback_data bytes actually sent: $MAX_CD_BYTES (must be <=64 and >0); full label intact as button text: $LABEL_INTACT (must be 1)"
  echo "press by index -> recorded answer is the FULL label verbatim: $LL_VERBATIM; decision record carries it: $LL_REC"
} >> "$T"
if [[ "$OLD_CD_BYTES" -gt 64 && "$STUB_REJECTS" -eq 1 && "$STUB_RECORDED" -eq 0 \
      && "$SENT12" -eq 1 && "$MAX_CD_BYTES" -le 64 && "$MAX_CD_BYTES" -gt 0 \
      && "$LABEL_INTACT" -eq 1 && $LL_VERBATIM -eq 1 && $LL_REC -eq 1 ]]; then
  record "12-long-label" PASS "111-byte-class label rides as button text; callback_data <=64 bytes (stub enforces the real API cap and its rejection was proven live); recorded answer = full label verbatim via registry resolution"
else
  record "12-long-label" FAIL "old=$OLD_CD_BYTES stub=$STUB_REJECTS/$STUB_RECORDED sent=$SENT12 maxcd=$MAX_CD_BYTES label=$LABEL_INTACT verbatim=$LL_VERBATIM rec=$LL_REC"
fi

# ============================================================================
# SCENARIO 13 — M4: digest safety net — a missed/failed daily fire is retried
# by the listener pass; before DIGEST_TIME nothing fires. + M6: no
# contradictory «решений не ждём» next to real waiting items.
# ============================================================================
T="$ATOM_WS/scenario-13-digest-retry.txt"
{ echo "Scenario 13 — digest safety net (verify M4) + section coherence (M6)"; echo "Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)"; } > "$T"
rm -f "$TGH/state/digest-sent-"*        # simulate: today's fire was missed
for g in "$TGH/state/pending-gates"/*; do   # M6 setup: waiting atoms, NO pending gates
  [[ -f "$g" && "$g" != *.answered ]] && mv "$g" "$g.answered"
done
B13=$(sent_count)
QROKY_TEST_NOW_HM="20:00" bash "$TG_DIR/listener.sh" >> "$T" 2>&1   # BEFORE digest time
EARLY_SENT=$(( $(sent_count) - B13 ))
EARLY_MARKER=0; ls "$TGH/state/digest-sent-"* >/dev/null 2>&1 && EARLY_MARKER=1
B13B=$(sent_count)
QROKY_TEST_NOW_HM="21:30" bash "$TG_DIR/listener.sh" >> "$T" 2>&1   # AFTER digest time
RETRY_DIGEST="$(sent_since "$B13B")"
RETRIED=$(printf '%s' "$RETRY_DIGEST" | grep -c "Дайджест за" || true)
MARKER_AFTER=0; ls "$TGH/state/digest-sent-"* >/dev/null 2>&1 && MARKER_AFTER=1
NET_LOG=$(grep -c "digest for today missing past" "$TGH/telegram.log" || true)
HAS_WAITING=$(printf '%s' "$RETRY_DIGEST" | grep -c "ATOM-D3" || true)
CONTRADICTION=$(printf '%s' "$RETRY_DIGEST" | grep -c "решений не ждём" || true)
{
  echo ""; echo "--- assertions ---"
  echo "pass BEFORE digest time fired nothing: $EARLY_SENT sends (0), marker: $EARLY_MARKER (0)"
  echo "pass AFTER digest time delivered the missed digest: $RETRIED (must be 1), marker restored: $MARKER_AFTER (1), safety-net log line: $NET_LOG (>0)"
  echo "M6: waiting atom listed: $HAS_WAITING (>0) with NO contradictory «решений не ждём»: $CONTRADICTION (must be 0)"
} >> "$T"
if [[ "$EARLY_SENT" -eq 0 && $EARLY_MARKER -eq 0 && "$RETRIED" -eq 1 && $MARKER_AFTER -eq 1 \
      && "$NET_LOG" -gt 0 && "$HAS_WAITING" -gt 0 && "$CONTRADICTION" -eq 0 ]]; then
  record "13-digest-retry" PASS "missed daily fire recovered by the next listener pass after DIGEST_TIME (nothing before it); waiting section coherent — no «решений не ждём» beside real waiting items"
else
  record "13-digest-retry" FAIL "early=$EARLY_SENT/$EARLY_MARKER retried=$RETRIED marker=$MARKER_AFTER log=$NET_LOG wait=$HAS_WAITING contradiction=$CONTRADICTION"
fi

# ============================================================================
# SCENARIO 14 — M5: token-bearing curl stderr is masked before it reaches the
# log; the failure ladder queues the event and the next pass delivers it.
# ============================================================================
T="$ATOM_WS/scenario-14-masked-error.txt"
{ echo "Scenario 14 — masked curl errors (verify M5) + failure ladder to queue"; echo "Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)"; } > "$T"
LAST4="${TEST_TOKEN: -4}"
printf '3' > "$FAKE/fail-remaining"      # 1 try + 2 retries, ALL fail
B14=$(sent_count)
bash "$TG_DIR/send-event.sh" --kind info --id FAIL-TEST --text "Тест сетевой деградации." >> "$T" 2>&1
FAILED_SENDS=$(( $(sent_count) - B14 ))
QUEUED14=$(ls "$TGH/state/queue"/*FAIL-TEST.ev 2>/dev/null | wc -l | tr -d ' ')
MASKED=$(grep -c "bot\*\*\*\*$LAST4" "$TGH/telegram.log" || true)
RAW_IN_LOG=$(grep -c "TEST-SECRET" "$TGH/telegram.log" || true)
GAVE_UP=$(grep -c "GAVE UP after 2 retries" "$TGH/telegram.log" || true)
B14B=$(sent_count)
listener >> "$T" 2>&1                    # fail-remaining exhausted -> flush delivers
DELIVERED14=$(sent_since "$B14B" | grep -c "Тест сетевой деградации" || true)
# final sweep: raw token over the log and ALL transcripts written so far
TRANSCRIPT_RAW=$(grep -rl "TEST-SECRET" "$ATOM_WS" 2>/dev/null | grep -cv "scenario-1[14]" || true)
{
  echo ""; echo "--- assertions ---"
  echo "all 3 attempts failed (nothing sent): $FAILED_SENDS (0); event queued, not lost: $QUEUED14 (1); ladder gave up after 2 retries: $GAVE_UP (>0)"
  echo "curl stderr CONTAINED the token-bearing URL (forced); masked bot****$LAST4 lines in log: $MASKED (must be >=3 — one per attempt, proves stderr flowed through the scrub)"
  echo "raw token in telegram.log: $RAW_IN_LOG (must be 0)"
  echo "next pass delivered the queued event: $DELIVERED14 (must be 1)"
  echo "raw token across all committed transcripts: $TRANSCRIPT_RAW (must be 0)"
} >> "$T"
if [[ "$FAILED_SENDS" -eq 0 && "$QUEUED14" -eq 1 && "$GAVE_UP" -gt 0 && "$MASKED" -ge 3 \
      && "$RAW_IN_LOG" -eq 0 && "$DELIVERED14" -eq 1 && "$TRANSCRIPT_RAW" -eq 0 ]]; then
  record "14-masked-error" PASS "forced token-bearing curl errors x3: every log line masked to bot****$LAST4, zero raw-token traces; ladder queued the event and the next pass delivered it"
else
  record "14-masked-error" FAIL "failed=$FAILED_SENDS queued=$QUEUED14 gaveup=$GAVE_UP masked=$MASKED raw=$RAW_IN_LOG delivered=$DELIVERED14 transcripts=$TRANSCRIPT_RAW"
fi

# ============================================================================
# SUMMARY
# ============================================================================
{
  echo ""
  echo "Totals: $PASS passed, $FAIL failed"
  echo "Sandbox: $SB (removed on exit)"
  echo "Budget line: harness burns ~0 tokens (no LLM — stubbed), ~60s wall time, 0 network calls"
} >> "$SUMMARY"
cat "$SUMMARY"
[[ $FAIL -eq 0 ]]
