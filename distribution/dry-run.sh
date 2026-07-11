#!/usr/bin/env bash
# dry-run.sh — sandbox harness for distribution/install.sh
#
# Author: pilot-toolsmith (ATOM-101, Distribution Kit v1) · Date: 2026-07-10
# Pattern: 071-setup-kit/setup/dry-run.sh (proven: PATH-shadow stubs + a
# local offline git repo standing in for the framework remote + isolated
# HOME so a real, unmodified install.sh runs for real against fakes).
#
# What is REAL in every scenario below: every filesystem action install.sh
# performs (workspace creation, git init, framework vendoring + pinned
# checkout, install-state.json / install.log / decisions/ writes, the
# heartbeat file generation, the token file with its real mode-600
# permission) and the wall-clock timing of the full-clean-run scenario.
#
# What is STUBBED, and how (all sandbox-only, zero effect on a real
# install.sh — see its own header comment for the in-script test hooks,
# QROKY_TEST_STUBS, QROKY_TEST_DELAY_* and QROKY_TEST_START_WAIT):
#   - `claude`      — a two-line fake answering only --version (071 pattern)
#   - `curl`        — a fake answering Telegram's getMe, getUpdates and
#                     sendMessage endpoints (the only external calls the
#                     v0.2 install.sh makes — same modelling approach as
#                     the Telegram head's own harness stub); GOODTOKEN* is
#                     accepted, anything else rejected exactly like the real
#                     Bot API; getUpdates returns the owner's /start press
#                     (update_id 111, chat 424242) only while
#                     QROKY_STUB_TG_START=1 AND the requested offset has not
#                     advanced past it — so the offset handoff to the head's
#                     listener is proven for real, not simulated; every
#                     sendMessage is appended to a sent-log the scenarios
#                     assert against (the actual hello, not a claim)
#   - `launchctl`   — a fake that logs bootout/bootstrap calls to a sandbox
#                     file instead of touching this machine's real launchd
#                     (a real near-miss during manual smoke-testing is what
#                     surfaced the need for this — see run.log)
#   - framework source — a real, local, offline git repository (tags
#                     included) standing in for https://github.com/qroky/
#                     framework.git, via the same QROKY_FRAMEWORK_SOURCE
#                     override install.sh already reads for exactly this
#   - HOME          — an isolated sandbox HOME (git config allowing the
#                     local file:// transport — a hardening default that
#                     only matters for this local-path trick, never for a
#                     real founder's https default; see 071's dry-run.sh)
#
# Transcripts are written next to this comment's sibling folder
# (v0.2 / ATOM-104 — records live in the CURRENT atom's workspace):
#   products/distribution-kit-v1/104-installation-journey/workspace/
#   scenario-1-full-clean-run.txt
#   scenario-2-kill-mid-install.txt
#   scenario-3-healthy-rerun.txt
#   scenario-4-broken-dependency.txt
#   scenario-5-idempotency-diff.txt
#   scenario-6-secrets-negative-grep.txt
#   scenario-7-self-update.txt
#   scenario-8-heartbeat-both-branches.txt
#   scenario-9-backup-optin-optout.txt
#   scenario-10-gesture-wiring.txt
#   scenario-11-telegram-journey.txt
#   scenario-12-machinewide-both-branches.txt
#   SUMMARY.txt
#
# Usage: ./dry-run.sh   (no arguments; self-contained; safe to re-run)

set -uo pipefail   # NOT -e: scenarios intentionally capture non-zero exits

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ATOM_WORKSPACE="$(cd "$HERE/../products/distribution-kit-v1/131-qroky-command/workspace" && pwd)"
SANDBOX="$(mktemp -d /private/tmp/qroky-install-dry-run.XXXXXX)"
cleanup() { rm -rf "$SANDBOX"; }
trap cleanup EXIT

PASS_COUNT=0
FAIL_COUNT=0
SUMMARY_LINES=()

record() {
  # $1 = scenario name, $2 = PASS|FAIL, $3.. = one-line reason
  if [[ "$2" == "PASS" ]]; then PASS_COUNT=$((PASS_COUNT + 1)); else FAIL_COUNT=$((FAIL_COUNT + 1)); fi
  SUMMARY_LINES+=("$2 — $1: $3")
}

# ---------------------------------------------------------------------------
# Shared sandbox scaffolding (built once, reused by every scenario)
# ---------------------------------------------------------------------------
KIT="$SANDBOX/kit"
mkdir -p "$KIT/lang"
cp "$HERE/install.sh" "$KIT/install.sh"
cp "$HERE"/lang/*.sh "$KIT/lang/"
chmod +x "$KIT/install.sh"
INSTALL="$KIT/install.sh"

BIN="$SANDBOX/bin"
mkdir -p "$BIN"

cat > "$BIN/claude" <<'EOF'
#!/usr/bin/env bash
echo "claude-code 0.0.0-dry-run-stub"
EOF
chmod +x "$BIN/claude"

CURL_REAL="$(command -v curl)"
TG_SENT_LOG="$SANDBOX/tg-sent.log"
touch "$TG_SENT_LOG"
cat > "$BIN/curl" <<EOF
#!/usr/bin/env bash
# Fake Bot API (v0.2): getMe + getUpdates + sendMessage — the only external
# calls install.sh makes. Reuses the modelling approach of the Telegram
# head's harness stub: token checked like the real API, /start delivered as
# a real update only while QROKY_STUB_TG_START=1 and the requested offset
# has not advanced past update_id 111, every sendMessage recorded verbatim.
SENT_LOG="$TG_SENT_LOG"
URL=""; DATA=(); prev=""
for a in "\$@"; do
  case "\$a" in *api.telegram.org*) URL="\$a" ;; esac
  [[ "\$prev" == "--data-urlencode" ]] && DATA+=("\$a")
  prev="\$a"
done
tg_token_from_url() { printf '%s' "\$URL" | sed -E 's#.*/bot([^/]*)/(getMe|getUpdates|sendMessage).*#\1#'; }
case "\$URL" in
  *api.telegram.org/bot*/getMe*)
    case "\$(tg_token_from_url)" in
      GOODTOKEN*) echo '{"ok":true,"result":{"id":123456789,"username":"qroky_test_bot","first_name":"Qroky Test"}}' ;;
      *) echo '{"ok":false,"error_code":401,"description":"Unauthorized"}' ;;
    esac
    exit 0 ;;
  *api.telegram.org/bot*/getUpdates*)
    case "\$(tg_token_from_url)" in
      GOODTOKEN*) : ;;
      *) echo '{"ok":false,"error_code":401,"description":"Unauthorized"}'; exit 0 ;;
    esac
    offset=""
    for d in "\${DATA[@]:-}"; do case "\$d" in offset=*) offset="\${d#offset=}" ;; esac; done
    [[ "\$URL" == *offset=* ]] && offset="\$(printf '%s' "\$URL" | sed -E 's/.*offset=([0-9]+).*/\1/')"
    if [[ "\${QROKY_STUB_TG_START:-0}" == "1" ]] && { [[ -z "\$offset" ]] || (( offset <= 111 )); }; then
      echo '{"ok":true,"result":[{"update_id":111,"message":{"message_id":1,"from":{"id":424242,"is_bot":false,"first_name":"Owner"},"chat":{"id":424242,"type":"private"},"date":1770000000,"text":"/start"}}]}'
    else
      echo '{"ok":true,"result":[]}'
    fi
    exit 0 ;;
  *api.telegram.org/bot*/sendMessage*)
    case "\$(tg_token_from_url)" in
      GOODTOKEN*) : ;;
      *) echo '{"ok":false,"error_code":401,"description":"Unauthorized"}'; exit 0 ;;
    esac
    chat=""; text=""
    for d in "\${DATA[@]:-}"; do
      case "\$d" in
        chat_id=*) chat="\${d#chat_id=}" ;;
        text=*) text="\${d#text=}" ;;
      esac
    done
    printf 'sendMessage chat_id=%s text=%s\n' "\$chat" "\$text" >> "\$SENT_LOG"
    echo '{"ok":true,"result":{"message_id":42}}'
    exit 0 ;;
esac
exec "$CURL_REAL" "\$@"
EOF
chmod +x "$BIN/curl"

LAUNCHCTL_STATE="$SANDBOX/fake-launchctl.log"
touch "$LAUNCHCTL_STATE"
cat > "$BIN/launchctl" <<EOF
#!/usr/bin/env bash
STATE="$LAUNCHCTL_STATE"
echo "fake-launchctl \$*" >> "\$STATE"
case "\$1" in
  bootout) exit 0 ;;
  bootstrap) exit 0 ;;
  list) exit 0 ;;
  *) echo "fake launchctl (dry-run stub): unsupported args: \$*" >&2; exit 1 ;;
esac
EOF
chmod +x "$BIN/launchctl"

# --- stub gh (v0.1.1, ATOM-102): GitHub's CLI, faked for the backup step.
# `auth status` fails until `auth login` writes an auth marker (so the
# walkthrough path is genuinely exercised); `repo create --source --push`
# creates a REAL local bare repo under fake-github/ and performs a REAL
# `git push` into it — the backup scenario's negative grep therefore runs
# over an actually-pushed payload, not a simulation. --------------------
FAKE_GH_STATE="$SANDBOX/fake-gh"
FAKE_GITHUB="$SANDBOX/fake-github"
mkdir -p "$FAKE_GH_STATE" "$FAKE_GITHUB"
cat > "$BIN/gh" <<EOF
#!/usr/bin/env bash
STATE_DIR="$FAKE_GH_STATE"
GITHUB_DIR="$FAKE_GITHUB"
case "\$1 \$2" in
  "auth status")
    [[ -f "\$STATE_DIR/authed" ]] || { echo "You are not logged into any GitHub hosts." >&2; exit 1; }
    exit 0 ;;
  "auth login")
    touch "\$STATE_DIR/authed"
    echo "fake-gh: logged in (dry-run stub)"
    exit 0 ;;
  "repo create")
    name="\$3"; shift 3
    src=""; remote_name="origin"; want_push=0
    while [[ \$# -gt 0 ]]; do
      case "\$1" in
        --source) src="\$2"; shift 2 ;;
        --remote) remote_name="\$2"; shift 2 ;;
        --push) want_push=1; shift ;;
        --private) shift ;;
        *) shift ;;
      esac
    done
    bare="\$GITHUB_DIR/\$name.git"
    [[ -d "\$bare" ]] || git init -q --bare "\$bare"
    if [[ -n "\$src" ]]; then
      git -C "\$src" remote add "\$remote_name" "\$bare" 2>/dev/null \\
        || git -C "\$src" remote set-url "\$remote_name" "\$bare"
      if [[ \$want_push -eq 1 ]]; then
        git -C "\$src" push -q "\$remote_name" HEAD || exit 1
      fi
    fi
    echo "https://github.com/dry-run-user/\$name (fake)"
    exit 0 ;;
esac
echo "fake gh (dry-run stub): unsupported args: \$*" >&2
exit 1
EOF
chmod +x "$BIN/gh"

# --- offline framework origin, real git repo, with a real release tag -----
FAKE_FW="$SANDBOX/fake-framework-origin"
mkdir -p "$FAKE_FW"
git -C "$FAKE_FW" init -q
echo "# stub framework — dry-run only, not the real rulebook" > "$FAKE_FW/README.md"
# v0.1.2 (ATOM-103): the framework repo now ships the gesture file that
# step_gesture vendors into the workspace — the fake origin carries the
# REAL vendored file from this repo, so scenario 10's "workdir copy matches
# vendored source" diff compares against the genuine article, not a stub.
VENDORED_SKILL="$HERE/../runtime/claude/skill/qroky/SKILL.md"
mkdir -p "$FAKE_FW/runtime/claude/skill/qroky"
cp "$VENDORED_SKILL" "$FAKE_FW/runtime/claude/skill/qroky/SKILL.md"
# v0.2 (ATOM-104): the framework repo also ships the reviewed Telegram head
# that question 5 deploys — again the REAL files from this repo (listener,
# digest, lib, send-event, handler, pickup, record-decision, plist
# templates), so scenario 11's deploy + listener health pass runs the
# genuine head, byte-identical, against the stubbed Bot API.
cp -R "$HERE/../runtime/claude/telegram" "$FAKE_FW/runtime/claude/telegram"
rm -rf "$FAKE_FW/runtime/claude/telegram/state" "$FAKE_FW/runtime/claude/telegram/telegram.log" 2>/dev/null || true
# v0.4 (ATOM-130): the fake origin carries BOTH the real dist-manifest (so
# every install in this harness exercises sparse vendoring) AND the
# factory's junk it must never ship — the sparse/freeze negative asserts
# in scenario 19 are therefore non-vacuous by construction.
mkdir -p "$FAKE_FW/distribution" "$FAKE_FW/products/some-product" "$FAKE_FW/decisions"
cp "$HERE/dist-manifest" "$FAKE_FW/distribution/dist-manifest"
cp "$HERE/verify.sh" "$FAKE_FW/distribution/verify.sh"
# v0.4.1 (ATOM-131): the real framework repo ships the FULL kit inside
# distribution/ plus qroky.sh at the root — the fake origin now does too,
# so the vendored copy inside every instance can act as the OFFLINE
# uninstaller (scenario 22 round 2 resolves through exactly that path).
cp "$HERE/install.sh" "$FAKE_FW/distribution/install.sh"
cp -R "$HERE/lang" "$FAKE_FW/distribution/lang"
cp "$HERE/../qroky.sh" "$FAKE_FW/qroky.sh"
echo "factory history — must NEVER reach an instance" > "$FAKE_FW/products/some-product/RESULT.md"
echo "factory decision — must NEVER reach an instance" > "$FAKE_FW/decisions/GATE-000-stub.md"
echo "factory backlog — must NEVER reach an instance" > "$FAKE_FW/TASKS.md"
echo "factory launch file — must NEVER reach an instance" > "$FAKE_FW/ATOM-999-LAUNCH.md"
git -C "$FAKE_FW" -c user.email=dryrun@qroky.local -c user.name="Qroky dry run" add -A
git -C "$FAKE_FW" -c user.email=dryrun@qroky.local -c user.name="Qroky dry run" commit -q -m "stub commit 1"
git -C "$FAKE_FW" -c user.email=dryrun@qroky.local -c user.name="Qroky dry run" \
  tag -a v1.0.0 -m "v1.0.0

first stub release
nothing behavioral, dry-run fixture only
baseline for idempotency + self-update scenarios"

FAKE_HOME="$SANDBOX/home"
mkdir -p "$FAKE_HOME"
git config --file "$FAKE_HOME/.gitconfig" protocol.file.allow always
git config --file "$FAKE_HOME/.gitconfig" user.email "dryrun@qroky.local"
git config --file "$FAKE_HOME/.gitconfig" user.name "Qroky dry run"

export PATH="$BIN:$PATH"
export HOME="$FAKE_HOME"
export QROKY_FRAMEWORK_SOURCE="$FAKE_FW"
export QROKY_TEST_STUBS=1
# v0.2: by default the fake owner presses Start (the stub delivers the
# /start update), and the honest ~60 s wait is shrunk to 4 s — scenario 11's
# no-Start branch overrides both in its own subshell.
export QROKY_STUB_TG_START=1
export QROKY_TEST_START_WAIT=4

run_install() {
  # $1 = workdir, $2 = stdin content (answers, one per line), $3.. = extra
  # args to install.sh (e.g. --check-update). A subshell with a real
  # `export` is required here — `VAR=val cmd | cmd2` only sets VAR for the
  # FIRST stage of a pipeline in bash, never for the stage after the pipe,
  # so the naive one-liner would silently install.sh fall back to its
  # pointer-file/default workdir instead of the sandbox path. (Caught by
  # actually running this harness — see run.log for the real stray
  # directory this produced under distribution/ before the fix.)
  local workdir="$1" stdin_content="$2"; shift 2
  # ATOM-111: each workdir is its own "machine" — its own project registry.
  # Without this, one scenario's telegram deploy registers itself as the
  # machine primary and every LATER scenario's question 5 short-circuits
  # through the router join path, misaligning its stdin feed (caught live:
  # scenarios 9 and 11 broke exactly this way). Scenario 13 shares ONE
  # registry across two workdirs deliberately, via QROKY_DRYRUN_REGISTRY.
  ( export QROKY_WORKSPACE_DIR="$workdir"; \
    export QROKY_REGISTRY="${QROKY_DRYRUN_REGISTRY:-$SANDBOX/registries/$(basename "$workdir").registry}"; \
    printf '%s' "$stdin_content" | "$INSTALL" "$@" ) 2>&1
}

# ---------------------------------------------------------------------------
# SCENARIO 1 — full clean run, timed, zero questions outside the interview
# ---------------------------------------------------------------------------
T1="$ATOM_WORKSPACE/scenario-1-full-clean-run.txt"
W1="$SANDBOX/w1"
{
  echo "Scenario 1 — full clean run (H6 baseline, H2 question inventory; v0.3.2 = 8 answers, INFO-042)"
  echo "Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "Command a founder actually types: bash install.sh   (no arguments)"
  echo "Answers fed (stdin, in order): en / <accept suggested folder> / y (telegram) /"
  echo "GOODTOKEN123 / n (sharing) / y (digest) / n (backup); the machine-wide"
  echo "phrase is set up WITHOUT a question since INFO-042 — the trace replaces it;"
  echo "the fake owner presses Start (QROKY_STUB_TG_START=1), so this run also"
  echo "walks the full bind+hello+deploy path inside question 5."
  echo ""
} > "$T1"
START1=$(date +%s)
OUT1="$(run_install "$W1" $'en\n\ny\nGOODTOKEN123\nn\ny\nn\n')"
STATUS1=$?
END1=$(date +%s)
ELAPSED1=$((END1 - START1))
{
  echo "$OUT1"
  echo ""
  echo "--- exit code: $STATUS1 ; elapsed: ${ELAPSED1}s (budget: 900s / 15min) ---"
} >> "$T1"

if [[ $STATUS1 -eq 0 && $ELAPSED1 -le 900 ]]; then
  record "1-full-clean-run" PASS "exit 0 in ${ELAPSED1}s"
else
  record "1-full-clean-run" FAIL "exit $STATUS1, elapsed ${ELAPSED1}s"
fi

# --- v0.2 journey checks (GATE-027 findings 2-3): the map, the numbered
# headers, and the finale copy-paste block with the REAL workdir path
# substituted (not a placeholder). Each greps the actual founder-facing
# output; each fails on the v0.1.2 build by construction. ------------------
MAP_SHOWN1=$(printf '%s' "$OUT1" | grep -c "Here is the whole road" || true)
MAP_SAYS_9=$(printf '%s' "$OUT1" | grep -c "8 questions" || true)
HDR_5OF9=$(printf '%s' "$OUT1" | grep -c "Step 5 of 8" || true)
HDR_9OF9=$(printf '%s' "$OUT1" | grep -c "Step 8 of 8" || true)
HDR_OF8_LEFTOVER=$(printf '%s' "$OUT1" | grep -c "of 9 —" || true)
FINALE_CMD1=$(printf '%s' "$OUT1" | grep -cF "cd $W1 && claude" || true)
FINALE_PHRASE1=$(printf '%s' "$OUT1" | grep -c "qroky start" || true)
FINALE_VSCODE1=$(printf '%s' "$OUT1" | grep -c "Open Folder" || true)
FINALE_FIRSTRUN1=$(printf '%s' "$OUT1" | grep -c "color theme" || true)
{
  echo ""
  echo "--- v0.2 journey checks ---"
  echo "journey map shown on the fresh install: $([[ "$MAP_SHOWN1" -gt 0 ]] && echo yes || echo NO-DEFECT)"
  echo "map names 8 questions (INFO-042): $([[ "$MAP_SAYS_9" -gt 0 ]] && echo yes || echo NO-DEFECT)"
  echo "headers say 'of 8' (step 5 seen: $HDR_5OF9, step 8 seen: $HDR_9OF9); leftover 'of 9' headers (must be 0): $HDR_OF8_LEFTOVER"
  echo "finale copy-paste block carries the REAL workdir path (cd $W1 && claude): $([[ "$FINALE_CMD1" -gt 0 ]] && echo yes || echo NO-DEFECT)"
  echo "finale says the phrase (qroky start): $([[ "$FINALE_PHRASE1" -gt 0 ]] && echo yes || echo NO-DEFECT)"
  echo "finale carries the VS Code line: $([[ "$FINALE_VSCODE1" -gt 0 ]] && echo yes || echo NO-DEFECT)"
  echo "finale warns about claude's own first-run questions: $([[ "$FINALE_FIRSTRUN1" -gt 0 ]] && echo yes || echo NO-DEFECT)"
} >> "$T1"
if [[ "$MAP_SHOWN1" -gt 0 && "$MAP_SAYS_9" -gt 0 && "$HDR_5OF9" -gt 0 && "$HDR_9OF9" -gt 0 \
      && "$HDR_OF8_LEFTOVER" -eq 0 && "$FINALE_CMD1" -gt 0 && "$FINALE_PHRASE1" -gt 0 \
      && "$FINALE_VSCODE1" -gt 0 && "$FINALE_FIRSTRUN1" -gt 0 ]]; then
  record "1-journey-map-and-finale" PASS "map up front, 'N of 8' headers (no 'of 9' leftovers), finale = real-path copy-paste block + VS Code + first-run honesty"
else
  record "1-journey-map-and-finale" FAIL "map=$MAP_SHOWN1 says9=$MAP_SAYS_9 hdr5=$HDR_5OF9 hdr9=$HDR_9OF9 of8=$HDR_OF8_LEFTOVER cmd=$FINALE_CMD1 phrase=$FINALE_PHRASE1 vscode=$FINALE_VSCODE1 firstrun=$FINALE_FIRSTRUN1"
fi

# Question inventory (H2, v0.1.1: EIGHT points): every interactive read in
# the eight step functions is tagged; count call sites vs tags — must match
# exactly, AND point 8 must actually be present (the amendment's own check
# cannot pass on the old seven-point build). The --apply-update
# confirmation (cmd_apply_update) is deliberately outside this count: it is
# a separate, explicitly-invoked maintenance command the founder runs
# later, not part of the eight-point interview (main_interview).
{
  echo ""
  echo "--- Question inventory check (H2: zero questions outside the interview; v0.3.2 = exactly 8 points — q9 REMOVED by INFO-042, NEVER 9+) ---"
  STEP_BLOCK="$(awk '/^step_language\(\)/,/^cmd_enable_heartbeat\(\)/' "$INSTALL")"
  READ_SITES=$(printf '%s' "$STEP_BLOCK" | grep -cE 'read_answer' || true)
  TAGGED_SITES=$(printf '%s' "$STEP_BLOCK" | grep -cE '# IV-POINT:' || true)
  echo "read_answer call sites inside the interview step functions (incl. the shared telegram connect flow): $READ_SITES"
  echo "of those, tagged with # IV-POINT\\:<n>\\:<name>: $TAGGED_SITES"
  DISTINCT_POINTS="$(printf '%s' "$STEP_BLOCK" | grep -oE 'IV-POINT:[0-9]+' | sort -u | tr '\n' ' ')"
  echo "distinct interview points referenced: $DISTINCT_POINTS(closed list is 1..8)"
  HAS_POINT8=$(printf '%s' "$STEP_BLOCK" | grep -c 'IV-POINT:8:backup_optin' || true)
  HAS_POINT9=$(printf '%s' "$STEP_BLOCK" | grep -c 'IV-POINT:9' || true)
  MAX_POINT="$(printf '%s' "$STEP_BLOCK" | grep -oE 'IV-POINT:[0-9]+' | sed 's/IV-POINT://' | sort -n | tail -1)"
  echo "point 8 (backup) present: $([[ "$HAS_POINT8" -gt 0 ]] && echo yes || echo no); point 9 remnants (must be 0 — INFO-042): $HAS_POINT9; highest point referenced: $MAX_POINT (must be 8, never 9+)"
  if [[ "$READ_SITES" -eq "$TAGGED_SITES" && "$HAS_POINT8" -gt 0 && "$HAS_POINT9" -eq 0 && "$MAX_POINT" == "8" ]]; then
    echo "PASS — every interactive prompt in the interview is accounted for in the closed list of 8 (INFO-042)."
    record "1-question-inventory" PASS "$READ_SITES/$READ_SITES prompts tagged, all within points 1-8, point 8 = backup present, q9 gone, none beyond 8"
  else
    echo "FAIL — an untagged prompt exists, point 8 is missing, a q9 remnant survives, or a point beyond 8 was found."
    record "1-question-inventory" FAIL "$TAGGED_SITES/$READ_SITES prompts tagged, point8=$HAS_POINT8, point9_remnant=$HAS_POINT9, max=$MAX_POINT"
  fi
} >> "$T1"

# ---------------------------------------------------------------------------
# SCENARIO 2 — kill mid-install, rerun completes (H6a, H9 happy-path q1)
# ---------------------------------------------------------------------------
T2="$ATOM_WORKSPACE/scenario-2-kill-mid-install.txt"
W2="$SANDBOX/w2"
{
  echo "Scenario 2 — kill the install mid-way, rerun completes to the end"
  echo "Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "Mechanism (round-2 fix, verify F1): RUN A opts INTO Telegram (y +"
  echo "GOODTOKEN456) so the QROKY_TEST_DELAY_STEP=telegram hook — which sits"
  echo "AFTER the token is stored but BEFORE the telegram step's state commit"
  echo "— is guaranteed to be reached; the process is SIGKILLed inside that"
  echo "5-second window, after workdir+claude_code+framework+subscription have"
  echo "already committed 'done' for real. The round-1 feed opted OUT of"
  echo "Telegram, whose branch returns before the hook, so nothing was ever"
  echo "killed — this scenario now FAILS unless the kill verifiably landed"
  echo "mid-flight (kill confirmed + post-kill state shows telegram NOT done)."
  echo ""
  echo "--- RUN A (will be killed mid-step) ---"
} > "$T2"
(
  export QROKY_WORKSPACE_DIR="$W2"
  export QROKY_TEST_DELAY_STEP="telegram"
  export QROKY_TEST_DELAY_SECONDS="15"
  printf 'en\n\ny\nGOODTOKEN456\nn\ny\nn\n' | "$INSTALL" >> "$T2" 2>&1 &
  echo $! > "$SANDBOX/killpid"
)
sleep 4
KILL_LANDED=0
KILLPID="$(cat "$SANDBOX/killpid" 2>/dev/null || true)"
if [[ -n "$KILLPID" ]] && kill -0 "$KILLPID" 2>/dev/null; then
  kill -9 "$KILLPID" 2>/dev/null || true
  KILL_LANDED=1
  echo "(process $KILLPID SIGKILLed mid-step, as intended)" >> "$T2"
else
  echo "(FAIL: process already exited before the kill — the kill never landed; this scenario's evidence is void)" >> "$T2"
fi
wait 2>/dev/null
STATE_AFTER_KILL=""
[[ -f "$W2/install-state.json" ]] && STATE_AFTER_KILL="$(cat "$W2/install-state.json")"
# The kill is only meaningful if the state file PROVES a mid-flight stop:
# earlier steps committed done, telegram (the step hosting the delay) NOT.
TELEGRAM_DONE_AT_KILL=$(printf '%s' "$STATE_AFTER_KILL" | grep -c '"step_telegram": "done"' || true)
WORKDIR_DONE_AT_KILL=$(printf '%s' "$STATE_AFTER_KILL" | grep -c '"step_workdir": "done"' || true)
{
  echo ""
  echo "--- state file immediately after the kill ---"
  echo "${STATE_AFTER_KILL:-<no state file — kill happened before the first commit>}"
  echo ""
  echo "mid-flight proof: kill landed on a live process: $([[ $KILL_LANDED -eq 1 ]] && echo yes || echo no);"
  echo "  step_workdir committed done before the kill: $([[ "$WORKDIR_DONE_AT_KILL" -gt 0 ]] && echo yes || echo no);"
  echo "  step_telegram NOT yet done at the kill: $([[ "$TELEGRAM_DONE_AT_KILL" -eq 0 ]] && echo yes || echo no)"
  echo ""
  echo "--- RUN B (rerun; language/workdir must NOT be re-asked — telegram, cut down mid-flight, is asked again) ---"
} >> "$T2"
OUT2B="$(run_install "$W2" $'n\nn\ny\nn\n')"
STATUS2B=$?
{
  echo "$OUT2B"
  echo ""
  echo "--- RUN B exit code: $STATUS2B ---"
} >> "$T2"
FINAL_STATE2="$(cat "$W2/install-state.json" 2>/dev/null || echo "MISSING")"
ALL_DONE2=$(printf '%s' "$FINAL_STATE2" | grep -c '"pending"\|"failed"' || true)
REASKED_LANG2=$(printf '%s' "$OUT2B" | grep -c "Which language do you want to use?" || true)
{
  echo ""
  echo "--- final state file ---"
  echo "$FINAL_STATE2"
  echo ""
  echo "language question re-asked in RUN B (must be no): $([[ "$REASKED_LANG2" -eq 0 ]] && echo no || echo YES-DEFECT)"
} >> "$T2"
if [[ $KILL_LANDED -eq 1 && "$TELEGRAM_DONE_AT_KILL" -eq 0 && "$WORKDIR_DONE_AT_KILL" -gt 0 \
      && $STATUS2B -eq 0 && "$ALL_DONE2" -eq 0 && "$REASKED_LANG2" -eq 0 ]]; then
  record "2-kill-mid-install" PASS "SIGKILL landed mid-telegram (state: prior steps done, telegram not), rerun resumed without re-asking and completed all-done"
else
  record "2-kill-mid-install" FAIL "kill_landed=$KILL_LANDED telegram_done_at_kill=$TELEGRAM_DONE_AT_KILL workdir_done=$WORKDIR_DONE_AT_KILL rerun_exit=$STATUS2B remaining=$ALL_DONE2 lang_reasked=$REASKED_LANG2"
fi

# ---------------------------------------------------------------------------
# SCENARIO 3 — rerun over a COMPLETE install = the reinstall dialog, case (a)
# of ATOM-106 (INFO-040): framework/ + live data -> [reinstall/update/cancel].
# All three answers exercised against Scenario-1's workspace. Before ATOM-106
# this was the silent healthy-rerun walkthrough; the dialog IS the new
# contract, so every assert here fails on the pre-fix build by construction
# (mutation-ready, INFO-037).
# ---------------------------------------------------------------------------
T3="$ATOM_WORKSPACE/scenario-3-reinstall-dialog.txt"
BEFORE_TREE="$(find "$W1" -type f ! -name 'install.log' ! -path '*/.git/*' -exec sh -c 'echo "$1  $(md5 -q "$1" 2>/dev/null || md5sum "$1" | cut -d" " -f1)"' _ {} \; | sort)"
BEFORE_STATE_NO_TS="$(grep -v generated_at "$W1/install-state.json")"
{
  echo "Scenario 3 — rerun over the complete Scenario-1 install: the (a) dialog"
  echo "Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo ""
  echo "--- answer 'cancel': leaves without a trace ---"
} > "$T3"
OUT3C="$(run_install "$W1" $'cancel\n')"
STATUS3C=$?
echo "$OUT3C" >> "$T3"
AFTER_TREE_C="$(find "$W1" -type f ! -name 'install.log' ! -path '*/.git/*' -exec sh -c 'echo "$1  $(md5 -q "$1" 2>/dev/null || md5sum "$1" | cut -d" " -f1)"' _ {} \; | sort)"
AFTER_STATE_C="$(grep -v generated_at "$W1/install-state.json")"
TREE_DIFF_C="$(diff <(printf '%s' "$BEFORE_TREE") <(printf '%s' "$AFTER_TREE_C"))"
STATE_DIFF_C="$(diff <(printf '%s' "$BEFORE_STATE_NO_TS") <(printf '%s' "$AFTER_STATE_C"))"
DIALOG_C=$(printf '%s' "$OUT3C" | grep -c "already carries a Qroky install" || true)
CANCEL_SAID=$(printf '%s' "$OUT3C" | grep -c "Cancelled. Nothing was changed." || true)
MAP_ON_RERUN3=$(printf '%s' "$OUT3C" | grep -c "Here is the whole road" || true)

{ echo ""; echo "--- answer 'update': routes to the self-update path (still at the newest tag here) ---"; } >> "$T3"
OUT3U="$(run_install "$W1" $'update\n')"
STATUS3U=$?
echo "$OUT3U" >> "$T3"
ROUTE_SAID=$(printf '%s' "$OUT3U" | grep -c "Routing to the update path" || true)
UPDATE_REACHED=$(printf '%s' "$OUT3U" | grep -c "no update available\|Apply this update now" || true)

{ echo ""; echo "--- answer 'reinstall' (as '1'): framework recreated fresh, live data untouched ---"; } >> "$T3"
echo "old copy — must vanish on reinstall" > "$W1/framework/OLD-COPY-MARKER"
TOKEN_MTIME_BEFORE="$(stat -f %m "$W1/.qroky/telegram.token" 2>/dev/null || stat -c %Y "$W1/.qroky/telegram.token" 2>/dev/null)"
PROFILE_MD5_BEFORE="$( (md5 -q "$W1/.qroky/telegram/profile.conf" 2>/dev/null || md5sum "$W1/.qroky/telegram/profile.conf" 2>/dev/null | cut -d' ' -f1) || true)"
OUT3R="$(run_install "$W1" $'1\n')"
STATUS3R=$?
echo "$OUT3R" >> "$T3"
TOKEN_MTIME_AFTER="$(stat -f %m "$W1/.qroky/telegram.token" 2>/dev/null || stat -c %Y "$W1/.qroky/telegram.token" 2>/dev/null)"
PROFILE_MD5_AFTER="$( (md5 -q "$W1/.qroky/telegram/profile.conf" 2>/dev/null || md5sum "$W1/.qroky/telegram/profile.conf" 2>/dev/null | cut -d' ' -f1) || true)"
AFTER_STATE_R="$(grep -v generated_at "$W1/install-state.json")"
STATE_DIFF_R="$(diff <(printf '%s' "$BEFORE_STATE_NO_TS") <(printf '%s' "$AFTER_STATE_R"))"
DIALOG_R=$(printf '%s' "$OUT3R" | grep -c "already carries a Qroky install" || true)
START_SAID=$(printf '%s' "$OUT3R" | grep -c "Recreating framework/" || true)
MARKER_GONE=1; [[ -f "$W1/framework/OLD-COPY-MARKER" ]] && MARKER_GONE=0
PROV_FRESH=0; [[ -f "$W1/framework/PROVENANCE.md" ]] && PROV_FRESH=1
FW_GIT_OK=0; [[ -e "$W1/framework/.git" ]] && FW_GIT_OK=1
REASKED3=$(printf '%s' "$OUT3R" | grep -c "Which language do you want to use?" || true)
FINALE3=$(printf '%s' "$OUT3R" | grep -c "qroky start" || true)
RAW_FATAL3=$(printf '%s' "$OUT3R" | grep -c "fatal:" || true)
{
  echo ""
  echo "--- assertions ---"
  echo "cancel: exit $STATUS3C (0), dialog shown: $DIALOG_C (>=1), cancel line: $CANCEL_SAID (1), tree diff empty: $([[ -z "$TREE_DIFF_C" ]] && echo yes || echo NO-DEFECT), state diff empty: $([[ -z "$STATE_DIFF_C" ]] && echo yes || echo NO-DEFECT), map on rerun: $MAP_ON_RERUN3 (0)"
  echo "update: exit $STATUS3U (0), route line: $ROUTE_SAID (1), update path reached: $UPDATE_REACHED (>=1)"
  echo "reinstall: exit $STATUS3R (0), dialog: $DIALOG_R (>=1), start line: $START_SAID (1), planted marker gone (fresh clone): $MARKER_GONE (1), PROVENANCE present: $PROV_FRESH (1), framework/.git present: $FW_GIT_OK (1)"
  echo "live data untouched: token mtime stable: $([[ -n "$TOKEN_MTIME_BEFORE" && "$TOKEN_MTIME_BEFORE" == "$TOKEN_MTIME_AFTER" ]] && echo yes || echo NO-DEFECT), profile md5 stable: $([[ -n "$PROFILE_MD5_BEFORE" && "$PROFILE_MD5_BEFORE" == "$PROFILE_MD5_AFTER" ]] && echo yes || echo NO-DEFECT)"
  echo "state answers preserved byte-for-byte (excl. generated_at): $([[ -z "$STATE_DIFF_R" ]] && echo yes || echo NO-DEFECT)"
  [[ -n "$STATE_DIFF_R" ]] && { echo "--- state diff ---"; echo "$STATE_DIFF_R"; }
  echo "zero questions re-asked: $REASKED3 (0); finale shown again: $FINALE3 (>=1); raw git fatal on screen: $RAW_FATAL3 (0)"
} >> "$T3"
if [[ $STATUS3C -eq 0 && "$DIALOG_C" -ge 1 && "$CANCEL_SAID" -eq 1 && -z "$TREE_DIFF_C" && -z "$STATE_DIFF_C" && "$MAP_ON_RERUN3" -eq 0 \
      && $STATUS3U -eq 0 && "$ROUTE_SAID" -eq 1 && "$UPDATE_REACHED" -ge 1 \
      && $STATUS3R -eq 0 && "$DIALOG_R" -ge 1 && "$START_SAID" -eq 1 && $MARKER_GONE -eq 1 && $PROV_FRESH -eq 1 && $FW_GIT_OK -eq 1 \
      && -n "$TOKEN_MTIME_BEFORE" && "$TOKEN_MTIME_BEFORE" == "$TOKEN_MTIME_AFTER" \
      && -n "$PROFILE_MD5_BEFORE" && "$PROFILE_MD5_BEFORE" == "$PROFILE_MD5_AFTER" \
      && -z "$STATE_DIFF_R" && "$REASKED3" -eq 0 && "$FINALE3" -ge 1 && "$RAW_FATAL3" -eq 0 ]]; then
  record "3-reinstall-dialog" PASS "(a) x3: cancel = no trace; update = routed; reinstall = fresh framework (marker gone, PROVENANCE), live data untouched (token mtime + profile md5 stable), state preserved, zero re-asks, no raw git fatal"
else
  record "3-reinstall-dialog" FAIL "cancel=$STATUS3C/$DIALOG_C/$CANCEL_SAID/tree$([[ -z "$TREE_DIFF_C" ]] && echo ok || echo DIFF)/state$([[ -z "$STATE_DIFF_C" ]] && echo ok || echo DIFF) update=$STATUS3U/$ROUTE_SAID/$UPDATE_REACHED reinstall=$STATUS3R/$DIALOG_R/$START_SAID/marker$MARKER_GONE/prov$PROV_FRESH/git$FW_GIT_OK token=$TOKEN_MTIME_BEFORE/$TOKEN_MTIME_AFTER profile_stable=$([[ "$PROFILE_MD5_BEFORE" == "$PROFILE_MD5_AFTER" ]] && echo yes || echo no) statediff=$([[ -z "$STATE_DIFF_R" ]] && echo empty || echo DIFF) reasked=$REASKED3 finale=$FINALE3 fatal=$RAW_FATAL3"
fi

# ---------------------------------------------------------------------------
# SCENARIO 4 — broken dependency -> concrete human instruction (H6c, H9)
# ---------------------------------------------------------------------------
T4="$ATOM_WORKSPACE/scenario-4-broken-dependency.txt"
W4="$SANDBOX/w4"
{
  echo "Scenario 4 — broken dependency (framework source unreachable)"
  echo "Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "QROKY_FRAMEWORK_SOURCE points at a path that does not exist — the"
  echo "network/dependency failure a founder would see as 'can't reach it'."
  echo ""
} > "$T4"
OUT4="$( ( export QROKY_WORKSPACE_DIR="$W4"; export QROKY_FRAMEWORK_SOURCE="/private/tmp/qroky-nonexistent-source-$$"; \
  printf 'en\n\n' | "$INSTALL" ) 2>&1)"
STATUS4=$?
{
  echo "$OUT4"
  echo ""
  echo "--- exit code: $STATUS4 (non-zero expected — setup stopped) ---"
} >> "$T4"
RETRY_COUNT4=$(printf '%s' "$OUT4" | grep -c "trying again automatically" || true)
HAS_HUMAN_MSG4=$(printf '%s' "$OUT4" | grep -c "Could not download the assistant's rulebook" || true)
# Round-2 checks (verify F7): the failure must NOT be attributed to the
# Claude Code check, and no raw git noise (fatal:, error:) may reach the
# founder's screen — it belongs in install.log. Attribution is correct
# when (a) the Claude check visibly SUCCEEDED on its own line before the
# failure ("Claude Code — found"), and (b) the failure block itself names
# the rulebook download, not the assistant.
UNDER_CLAUDE_HEADER4=1
CLAUDE_OK_LINE4=$(printf '%s' "$OUT4" | grep -c "Claude Code — found" || true)
FAIL_NAMES_CLAUDE4=$(printf '%s' "$OUT4" | sed -n '/SETUP STOPPED/,$p' | grep -c "Claude Code" || true)
if [[ "$CLAUDE_OK_LINE4" -gt 0 && "$FAIL_NAMES_CLAUDE4" -eq 0 ]]; then
  UNDER_CLAUDE_HEADER4=0
fi
RAW_GIT_SPEW4=$(printf '%s' "$OUT4" | grep -c "^fatal:\|^error:" || true)
GIT_NOISE_IN_LOG4=$(grep -c "fatal:" "$W4/install.log" 2>/dev/null || true)
STATE4="$(cat "$W4/install-state.json" 2>/dev/null || echo "MISSING")"
{
  echo ""
  echo "--- state file after the failure (workdir stays done, framework marked failed) ---"
  echo "$STATE4"
  echo ""
  echo "auto-retry lines seen: $RETRY_COUNT4 (ladder cap is 2, harness-checklist point 3)"
  echo "concrete human instruction present (rulebook download named, not the Claude check): $([[ $HAS_HUMAN_MSG4 -gt 0 ]] && echo yes || echo no)"
  echo "failure mis-attributed under the Claude Code header (must be no): $([[ $UNDER_CLAUDE_HEADER4 -eq 0 ]] && echo no || echo YES-DEFECT)"
  echo "raw git fatal:/error: lines on the founder's screen (must be 0): $RAW_GIT_SPEW4"
  echo "git technical details preserved in install.log (for support): $([[ "$GIT_NOISE_IN_LOG4" -gt 0 ]] && echo yes || echo no)"
} >> "$T4"
if [[ $STATUS4 -ne 0 && "$RETRY_COUNT4" -eq 2 && "$HAS_HUMAN_MSG4" -gt 0 \
      && "$UNDER_CLAUDE_HEADER4" -eq 0 && "$RAW_GIT_SPEW4" -eq 0 ]] \
   && printf '%s' "$STATE4" | grep -q '"step_workdir": "done"' \
   && printf '%s' "$STATE4" | grep -q '"step_framework": "failed"'; then
  record "4-broken-dependency" PASS "2 auto-retries then a concrete human instruction under the correct step, no raw git spew on screen, exit $STATUS4, prior steps' state preserved"
else
  record "4-broken-dependency" FAIL "retries=$RETRY_COUNT4 human_msg=$HAS_HUMAN_MSG4 misattributed=$UNDER_CLAUDE_HEADER4 raw_git=$RAW_GIT_SPEW4 exit=$STATUS4"
fi

# ---------------------------------------------------------------------------
# SCENARIO 5 — double-run idempotency diff (H3)
# ---------------------------------------------------------------------------
T5="$ATOM_WORKSPACE/scenario-5-idempotency-diff.txt"
W5="$SANDBOX/w5"
{
  echo "Scenario 5 — run the installer twice over the same folder; the second"
  echo "run goes through the ATOM-106 reinstall dialog and answers 'reinstall'."
  echo "Diff the state file (structural fields only, excluding the commit"
  echo "timestamp) and the workspace file listing (git internals excluded —"
  echo "the fresh clone's plumbing differs harmlessly) between the two runs:"
  echo "a reinstall must be user-invisible on an unchanged origin."
  echo "Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo ""
  echo "--- RUN 1 ---"
} > "$T5"
OUT5A="$(run_install "$W5" $'en\n\nn\nn\ny\nn\n')"; STATUS5A=$?
LIST5A="$(find "$W5" -type f ! -path '*/.git/*' ! -name '.gitmodules' | sed "s|$W5/||" | sort)"
STATE5A="$(grep -v generated_at "$W5/install-state.json")"
{
  echo "$OUT5A"
  echo "--- RUN 1 exit: $STATUS5A ---"
  echo ""
  echo "--- RUN 2 (reinstall dialog -> 'reinstall') ---"
} >> "$T5"
OUT5B="$(run_install "$W5" $'reinstall\n')"; STATUS5B=$?
LIST5B="$(find "$W5" -type f ! -path '*/.git/*' ! -name '.gitmodules' | sed "s|$W5/||" | sort)"
STATE5B="$(grep -v generated_at "$W5/install-state.json")"
{
  echo "$OUT5B"
  echo "--- RUN 2 exit: $STATUS5B ---"
  echo ""
  echo "--- file listing diff (run 1 vs run 2) ---"
  diff <(printf '%s' "$LIST5A") <(printf '%s' "$LIST5B") && echo "(identical file listing — no duplicates, nothing destroyed)"
  echo ""
  echo "--- state field diff (run 1 vs run 2, excluding generated_at) ---"
  diff <(printf '%s' "$STATE5A") <(printf '%s' "$STATE5B") && echo "(identical structural state)"
} >> "$T5"
LIST_DIFF5="$(diff <(printf '%s' "$LIST5A") <(printf '%s' "$LIST5B"))"
STATE_DIFF5="$(diff <(printf '%s' "$STATE5A") <(printf '%s' "$STATE5B"))"
if [[ $STATUS5A -eq 0 && $STATUS5B -eq 0 && -z "$LIST_DIFF5" && -z "$STATE_DIFF5" ]]; then
  record "5-idempotency-diff" PASS "identical file listing and state across install + reinstall (git internals excluded)"
else
  record "5-idempotency-diff" FAIL "run1=$STATUS5A run2=$STATUS5B list_diff_empty=$([[ -z "$LIST_DIFF5" ]] && echo yes || echo no) state_diff_empty=$([[ -z "$STATE_DIFF5" ]] && echo yes || echo no)"
fi

# ---------------------------------------------------------------------------
# SCENARIO 6 — secrets negative grep (H4)
# ---------------------------------------------------------------------------
T6="$ATOM_WORKSPACE/scenario-6-secrets-negative-grep.txt"
TOKEN_PLAINTEXT="GOODTOKEN123"
{
  echo "Scenario 6 — secrets negative grep, against Scenario-1's workspace"
  echo "(which opted into Telegram with token '$TOKEN_PLAINTEXT')"
  echo "Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo ""
  echo "Checked (must be EMPTY of the raw token):"
  echo "  - install-state.json"
  echo "  - install.log"
  echo "  - telemetry/ (whole directory)"
  echo "  - git status / git-tracked content (framework/ + workspace repo)"
  echo ""
} > "$T6"
LEAK_STATE=$(grep -c "$TOKEN_PLAINTEXT" "$W1/install-state.json" 2>/dev/null || true)
LEAK_LOG=$(grep -c "$TOKEN_PLAINTEXT" "$W1/install.log" 2>/dev/null || true)
LEAK_TELEMETRY=$(grep -rc "$TOKEN_PLAINTEXT" "$W1/telemetry" 2>/dev/null | awk -F: '{s+=$2} END{print s+0}')
# v0.2: the deployed Telegram head's home (profile.conf, wrappers, plists,
# state, its own telegram.log) must hold the token PATH only, never the
# token — this dir did not exist before v0.2, so the check is new surface.
LEAK_TGHOME=$(grep -rc "$TOKEN_PLAINTEXT" "$W1/.qroky/telegram" 2>/dev/null | awk -F: '{s+=$2} END{print s+0}')
TGHOME_NONEMPTY=$(find "$W1/.qroky/telegram" -type f 2>/dev/null | wc -l | tr -d ' ')
LEAK_GIT=$( (cd "$W1" && git grep -c "$TOKEN_PLAINTEXT" $(git rev-list --all 2>/dev/null) 2>/dev/null; cd "$W1/framework" && git grep -c "$TOKEN_PLAINTEXT" $(git rev-list --all 2>/dev/null) 2>/dev/null) | awk -F: '{s+=$NF} END{print s+0}')
TOKEN_FILE_PERMS="$(stat -f '%Lp' "$W1/.qroky/telegram.token" 2>/dev/null || stat -c '%a' "$W1/.qroky/telegram.token" 2>/dev/null)"
TOKEN_FILE_CONTENT="$(cat "$W1/.qroky/telegram.token" 2>/dev/null)"
# Round-2 fix (verify F4): the masked confirmation is now WRITTEN to
# install.log by install.sh ("telegram TOKEN-STORED masked=****..."), so
# this is a hard requirement, not an informational line — redaction must
# be auditable from the log alone while the raw-token grep stays empty.
MASKED_IN_LOG=$(grep -c "TOKEN-STORED masked=\*\*\*\*" "$W1/install.log" 2>/dev/null || true)
{
  echo "grep hits in install-state.json: ${LEAK_STATE:-0}"
  echo "grep hits in install.log: ${LEAK_LOG:-0}"
  echo "grep hits in telemetry/: ${LEAK_TELEMETRY:-0}"
  echo "grep hits in the deployed head's home .qroky/telegram/ (v0.2; must be 0): ${LEAK_TGHOME:-0} (files checked: $TGHOME_NONEMPTY — non-vacuous)"
  echo "grep hits across all git history (workspace + framework): ${LEAK_GIT:-0}"
  echo ""
  echo "masked-token confirmation line present in install.log (REQUIRED): $([[ "$MASKED_IN_LOG" -gt 0 ]] && echo yes || echo no)"
  echo "token file mode: ${TOKEN_FILE_PERMS:-MISSING} (must be 600)"
  echo "token file contains the real token (expected — this is the ONE sanctioned place): $([[ "$TOKEN_FILE_CONTENT" == "$TOKEN_PLAINTEXT" ]] && echo yes || echo no)"
} >> "$T6"
if [[ "${LEAK_STATE:-0}" -eq 0 && "${LEAK_LOG:-0}" -eq 0 && "${LEAK_TELEMETRY:-0}" -eq 0 && "${LEAK_GIT:-0}" -eq 0 \
      && "${LEAK_TGHOME:-0}" -eq 0 && "$TGHOME_NONEMPTY" -gt 0 \
      && "$MASKED_IN_LOG" -gt 0 \
      && "$TOKEN_FILE_PERMS" == "600" && "$TOKEN_FILE_CONTENT" == "$TOKEN_PLAINTEXT" ]]; then
  record "6-secrets-negative-grep" PASS "zero raw-token leaks across state/log/telemetry/git AND the deployed head's home ($TGHOME_NONEMPTY files, non-vacuous); masked line in log; token file mode 600"
else
  record "6-secrets-negative-grep" FAIL "state=$LEAK_STATE log=$LEAK_LOG telemetry=$LEAK_TELEMETRY tghome=$LEAK_TGHOME/$TGHOME_NONEMPTY git=$LEAK_GIT masked_in_log=$MASKED_IN_LOG perms=$TOKEN_FILE_PERMS"
fi

# ---------------------------------------------------------------------------
# SCENARIO 7 — self-update: tag N -> N+1, local edit, conflict shown,
# apply only on explicit yes, decisions record written (H11)
# ---------------------------------------------------------------------------
T7="$ATOM_WORKSPACE/scenario-7-self-update.txt"
{
  echo "Scenario 7 — self-update channel, against Scenario-1's workspace"
  echo "(already installed and pinned to v1.0.0)"
  echo "Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo ""
} > "$T7"

# publish v1.1.0 on the fake origin
git -C "$FAKE_FW" -c user.email=dryrun@qroky.local -c user.name="Qroky dry run" \
  commit -q --allow-empty -m "stub commit 2"
git -C "$FAKE_FW" -c user.email=dryrun@qroky.local -c user.name="Qroky dry run" \
  tag -a v1.1.0 -m "v1.1.0

fixes the stub thing
improves the other stub thing
adds a third stub improvement"

# plant a local edit inside the user's own framework/ copy — this is the
# conflict the update must SHOW, never silently overwrite
echo "-- founder's own note, must not be silently discarded --" >> "$W1/framework/README.md"

{
  echo "--- check-update (read-only) ---"
} >> "$T7"
OUT7A="$(run_install "$W1" '' --check-update)"
{
  echo "$OUT7A"
} >> "$T7"
HAS_DIGEST=$(printf '%s' "$OUT7A" | grep -c "v1.0.0 -> v1.1.0" || true)
# Round-2 fix (verify F2): the digest must carry ALL THREE changelog body
# lines — the round-1 extraction wasted the head -3 budget on the tag
# subject + blank separator, silently dropping two of them.
CHANGELOG_LINES_OK=0
if printf '%s' "$OUT7A" | grep -q "fixes the stub thing" \
   && printf '%s' "$OUT7A" | grep -q "improves the other stub thing" \
   && printf '%s' "$OUT7A" | grep -q "adds a third stub improvement"; then
  CHANGELOG_LINES_OK=1
fi

# Round-2 check (verify F5): the "нет" cancel MUST be exercised while the
# update is genuinely pending — BEFORE the "да" apply, not after it.
{
  echo ""
  echo "--- apply-update with the update PENDING, answering 'нет' (must cancel, tag must stay v1.0.0) ---"
} >> "$T7"
OUT7N="$(run_install "$W1" $'нет\n' --apply-update)"
echo "$OUT7N" >> "$T7"
STATE7N="$(cat "$W1/install-state.json")"
TAG_STILL_OLD=$(printf '%s' "$STATE7N" | grep -c '"framework_tag": "v1.0.0"' || true)
CANCELLED_SHOWN=$(printf '%s' "$OUT7N" | grep -ci "cancelled\|anulat\|отменено" || true)
REACHED_PROMPT_N=$(printf '%s' "$OUT7N" | grep -c "Apply this update now\|Aplici această actualizare\|Применить это обновление" || true)
{
  echo ""
  echo "cancel check: confirm prompt reached: $([[ "$REACHED_PROMPT_N" -gt 0 ]] && echo yes || echo no); cancelled message shown: $([[ "$CANCELLED_SHOWN" -gt 0 ]] && echo yes || echo no); framework_tag still v1.0.0: $([[ "$TAG_STILL_OLD" -gt 0 ]] && echo yes || echo no)"
} >> "$T7"

{
  echo ""
  echo "--- apply-update, answering 'да' (yes) ---"
} >> "$T7"
OUT7B="$(run_install "$W1" $'да\n' --apply-update)"
{
  echo "$OUT7B"
} >> "$T7"
HAS_CONFLICT_SHOWN=$(printf '%s' "$OUT7B" | grep -c "README.md" || true)
# Round-2 check (verify F3): the conflict display must show ONLY the real
# founder edit (M README.md), never the installer's own PROVENANCE.md —
# an untouched install must not cry "local changes".
PROVENANCE_FALSE_ALARM=$( (printf '%s\n%s' "$OUT7N" "$OUT7B") | grep -c "PROVENANCE" || true)
STATE7="$(cat "$W1/install-state.json")"
DECISION_FILE="$(ls "$W1"/decisions/UPDATE-*.md 2>/dev/null | head -1)"
{
  echo ""
  echo "--- state after apply ---"
  echo "$STATE7"
  echo ""
  echo "--- decisions record ---"
  [[ -n "$DECISION_FILE" ]] && cat "$DECISION_FILE" || echo "MISSING"
  echo ""
  echo "all 3 changelog lines reached the digest: $([[ "$CHANGELOG_LINES_OK" -eq 1 ]] && echo yes || echo no)"
  echo "PROVENANCE.md false-alarm lines in conflict displays (must be 0): $PROVENANCE_FALSE_ALARM"
} >> "$T7"
TAG_UPDATED=$(printf '%s' "$STATE7" | grep -c '"framework_tag": "v1.1.0"' || true)
if [[ "$HAS_DIGEST" -gt 0 && "$CHANGELOG_LINES_OK" -eq 1 \
      && "$REACHED_PROMPT_N" -gt 0 && "$CANCELLED_SHOWN" -gt 0 && "$TAG_STILL_OLD" -gt 0 \
      && "$HAS_CONFLICT_SHOWN" -gt 0 && "$PROVENANCE_FALSE_ALARM" -eq 0 \
      && "$TAG_UPDATED" -gt 0 && -n "$DECISION_FILE" ]]; then
  record "7-self-update" PASS "3-line changelog in digest; нет cancelled a genuinely pending update (tag stayed v1.0.0); conflict shown (README.md only, no PROVENANCE false alarm); да applied to v1.1.0; decisions record written"
else
  record "7-self-update" FAIL "digest=$HAS_DIGEST changelog3=$CHANGELOG_LINES_OK cancel_prompt=$REACHED_PROMPT_N cancelled=$CANCELLED_SHOWN tag_stayed=$TAG_STILL_OLD conflict_shown=$HAS_CONFLICT_SHOWN provenance_alarm=$PROVENANCE_FALSE_ALARM tag_updated=$TAG_UPDATED decision_file=${DECISION_FILE:-none}"
fi

# ---------------------------------------------------------------------------
# SCENARIO 8 — heartbeat consent, BOTH branches (H10 explicitly requires
# both exercised in this harness; "no" leaves no running agent).
# ---------------------------------------------------------------------------
T8="$ATOM_WORKSPACE/scenario-8-heartbeat-both-branches.txt"
W8YES="$SANDBOX/w8yes"
W8NO="$SANDBOX/w8no"
{
  echo "Scenario 8 — heartbeat consent, both branches (H10)"
  echo "Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo ""
  echo "--- fresh install answering 'y' at the heartbeat question ---"
} > "$T8"
: > "$LAUNCHCTL_STATE"
OUT8Y="$(run_install "$W8YES" $'en\n\nn\nn\ny\nn\n')"
echo "$OUT8Y" >> "$T8"
LABEL8Y="$(basename "$(ls "$W8YES"/.qroky/launchd/*.plist 2>/dev/null | head -1)" .plist)"
BOOTSTRAPPED_Y=$(grep -c "bootstrap.*$LABEL8Y" "$LAUNCHCTL_STATE" 2>/dev/null || true)
{
  echo ""
  echo "plist generated: $([[ -n "$LABEL8Y" ]] && echo yes || echo no) ($LABEL8Y)"
  echo "fake-launchctl saw a bootstrap call for it: $([[ "$BOOTSTRAPPED_Y" -gt 0 ]] && echo yes || echo no)"
  echo ""
  echo "--- fresh install answering 'n' at the heartbeat question ---"
} >> "$T8"
: > "$LAUNCHCTL_STATE"
OUT8N="$(run_install "$W8NO" $'en\n\nn\nn\nn\nn\n')"
echo "$OUT8N" >> "$T8"
LABEL8N="$(basename "$(ls "$W8NO"/.qroky/launchd/*.plist 2>/dev/null | head -1)" .plist)"
BOOTSTRAPPED_N=$(grep -c "bootstrap" "$LAUNCHCTL_STATE" 2>/dev/null || true)
HAS_ENABLE_INSTR=$(printf '%s' "$OUT8N" | grep -c -- "--enable-heartbeat" || true)
{
  echo ""
  echo "plist generated (installed, but not loaded): $([[ -n "$LABEL8N" ]] && echo yes || echo no) ($LABEL8N)"
  echo "fake-launchctl saw ANY bootstrap call during this run: $([[ "$BOOTSTRAPPED_N" -gt 0 ]] && echo yes || echo no) (must be no)"
  echo "one-command enable instruction printed: $([[ "$HAS_ENABLE_INSTR" -gt 0 ]] && echo yes || echo no)"
} >> "$T8"
if [[ -n "$LABEL8Y" && "$BOOTSTRAPPED_Y" -gt 0 && -n "$LABEL8N" && "$BOOTSTRAPPED_N" -eq 0 && "$HAS_ENABLE_INSTR" -gt 0 ]]; then
  record "8-heartbeat-both-branches" PASS "yes branch bootstraps + enables, no branch installs disabled with a one-command enable instruction, no agent registered"
else
  record "8-heartbeat-both-branches" FAIL "label_y=$LABEL8Y bootstrapped_y=$BOOTSTRAPPED_Y label_n=$LABEL8N bootstrapped_n=$BOOTSTRAPPED_N enable_instr=$HAS_ENABLE_INSTR"
fi

# ---------------------------------------------------------------------------
# SCENARIO 9 — backup opt-in + opt-out (v0.1.1, ATOM-102, INFO-030 p.3).
# Opt-in branch: fresh install WITH a Telegram token in the workspace (so
# the secrets-exclusion proof cannot pass vacuously), backup = yes; the gh
# stub walks auth (status fails until login), creates a real local bare
# repo and REALLY pushes into it. Assertions: state step done + optin yes,
# negative grep for the raw token over the pushed history EMPTY, the token
# FILENAME absent from the pushed tree, the pushed tree non-empty
# (install-state.json present), the restore command printed, and the auth
# walkthrough actually shown.
# Opt-out branch: state records the choice, the enable-later command is
# printed, and NO new repo appears on the fake GitHub.
# ---------------------------------------------------------------------------
T9="$ATOM_WORKSPACE/scenario-9-backup-optin-optout.txt"
W9A="$SANDBOX/w9a"
W9B="$SANDBOX/w9b"
BACKUP_TOKEN="GOODTOKEN789"
rm -f "$FAKE_GH_STATE/authed"   # start un-authed so the walkthrough path runs
{
  echo "Scenario 9 — backup opt-in + opt-out (v0.1.1, interview point 8)"
  echo "Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "gh stub: auth status fails until auth login; repo create --push does a"
  echo "REAL git push into a local bare repo (fake-github/) — the negative grep"
  echo "below runs over an actually-pushed payload."
  echo ""
  echo "--- OPT-IN branch: fresh install, Telegram token $BACKUP_TOKEN stored, backup = yes ---"
} > "$T9"
OUT9A="$(run_install "$W9A" $'en\n\ny\nGOODTOKEN789\nn\nn\ny\n')"
STATUS9A=$?
echo "$OUT9A" >> "$T9"
STATE9A="$(cat "$W9A/install-state.json" 2>/dev/null || echo MISSING)"
BACKUP_DONE9=$(printf '%s' "$STATE9A" | grep -c '"step_backup": "done"' || true)
BACKUP_OPTIN9=$(printf '%s' "$STATE9A" | grep -c '"answer_backup_optin": "yes"' || true)
WALKTHROUGH_SHOWN9=$(printf '%s' "$OUT9A" | grep -c "Login with a web browser" || true)
RESTORE_SHOWN9=$(printf '%s' "$OUT9A" | grep -c "gh repo clone qroky-backup" || true)
BARE9="$FAKE_GITHUB/qroky-backup.git"
PUSHED_LEAK9=1; PUSHED_TOKENFILE9=1; PUSHED_NONEMPTY9=0
if [[ -d "$BARE9" ]]; then
  PUSHED_LEAK9=$(git -C "$BARE9" grep -c "$BACKUP_TOKEN" $(git -C "$BARE9" rev-list --all 2>/dev/null) 2>/dev/null | awk -F: '{s+=$NF} END{print s+0}')
  PUSHED_TOKENFILE9=$(git -C "$BARE9" ls-tree -r --name-only HEAD 2>/dev/null | grep -c "telegram.token" || true)
  PUSHED_NONEMPTY9=$(git -C "$BARE9" ls-tree -r --name-only HEAD 2>/dev/null | grep -c "install-state.json" || true)
fi
{
  echo ""
  echo "--- opt-in assertions ---"
  echo "exit code: $STATUS9A"
  echo "state: step_backup done: $([[ $BACKUP_DONE9 -gt 0 ]] && echo yes || echo no); answer_backup_optin=yes: $([[ $BACKUP_OPTIN9 -gt 0 ]] && echo yes || echo no)"
  echo "gh auth walkthrough shown (numbered steps): $([[ $WALKTHROUGH_SHOWN9 -gt 0 ]] && echo yes || echo no)"
  echo "restore command printed (gh repo clone qroky-backup): $([[ $RESTORE_SHOWN9 -gt 0 ]] && echo yes || echo no)"
  echo "pushed bare repo exists: $([[ -d "$BARE9" ]] && echo yes || echo no)"
  echo "raw token grep over PUSHED history (must be 0): $PUSHED_LEAK9"
  echo "token FILENAME in pushed tree (must be 0): $PUSHED_TOKENFILE9"
  echo "pushed tree non-empty (install-state.json present — the grep cannot pass vacuously): $([[ $PUSHED_NONEMPTY9 -gt 0 ]] && echo yes || echo no)"
  echo ""
  echo "--- pushed tree listing (for the record) ---"
  git -C "$BARE9" ls-tree -r --name-only HEAD 2>/dev/null || echo "(missing)"
} >> "$T9"

{
  echo ""
  echo "--- OPT-OUT branch: fresh install, backup = no ---"
} >> "$T9"
REPOS_BEFORE9B=$(ls -d "$FAKE_GITHUB"/*.git 2>/dev/null | wc -l | tr -d ' ')
OUT9B="$(run_install "$W9B" $'en\n\nn\nn\nn\nn\n')"
STATUS9B=$?
echo "$OUT9B" >> "$T9"
REPOS_AFTER9B=$(ls -d "$FAKE_GITHUB"/*.git 2>/dev/null | wc -l | tr -d ' ')
STATE9B="$(cat "$W9B/install-state.json" 2>/dev/null || echo MISSING)"
OPTOUT_RECORDED9=$(printf '%s' "$STATE9B" | grep -c '"answer_backup_optin": "no"' || true)
OPTOUT_STEP_DONE9=$(printf '%s' "$STATE9B" | grep -c '"step_backup": "done"' || true)
ENABLE_LATER_SHOWN9=$(printf '%s' "$OUT9B" | grep -c -- "--enable-backup" || true)
{
  echo ""
  echo "--- opt-out assertions ---"
  echo "exit code: $STATUS9B"
  echo "state: answer_backup_optin=no recorded: $([[ $OPTOUT_RECORDED9 -gt 0 ]] && echo yes || echo no); step done (never re-asked): $([[ $OPTOUT_STEP_DONE9 -gt 0 ]] && echo yes || echo no)"
  echo "enable-later command printed: $([[ $ENABLE_LATER_SHOWN9 -gt 0 ]] && echo yes || echo no)"
  echo "repos on fake GitHub before/after opt-out run: $REPOS_BEFORE9B/$REPOS_AFTER9B (must be equal — nothing pushed)"
} >> "$T9"

if [[ $STATUS9A -eq 0 && $BACKUP_DONE9 -gt 0 && $BACKUP_OPTIN9 -gt 0 \
      && $WALKTHROUGH_SHOWN9 -gt 0 && $RESTORE_SHOWN9 -gt 0 \
      && -d "$BARE9" && "$PUSHED_LEAK9" -eq 0 && "$PUSHED_TOKENFILE9" -eq 0 && "$PUSHED_NONEMPTY9" -gt 0 \
      && $STATUS9B -eq 0 && $OPTOUT_RECORDED9 -gt 0 && $OPTOUT_STEP_DONE9 -gt 0 \
      && $ENABLE_LATER_SHOWN9 -gt 0 && "$REPOS_BEFORE9B" == "$REPOS_AFTER9B" ]]; then
  record "9-backup-optin-optout" PASS "opt-in: auth walkthrough shown, real push, zero token leaks in pushed history, token file excluded, tree non-empty, restore command printed; opt-out: choice recorded, enable-later shown, nothing pushed"
else
  record "9-backup-optin-optout" FAIL "a_exit=$STATUS9A done=$BACKUP_DONE9 optin=$BACKUP_OPTIN9 walk=$WALKTHROUGH_SHOWN9 restore=$RESTORE_SHOWN9 bare=$([[ -d "$BARE9" ]] && echo 1 || echo 0) leak=$PUSHED_LEAK9 tokenfile=$PUSHED_TOKENFILE9 nonempty=$PUSHED_NONEMPTY9 b_exit=$STATUS9B recorded=$OPTOUT_RECORDED9 stepdone=$OPTOUT_STEP_DONE9 enable=$ENABLE_LATER_SHOWN9 repos=$REPOS_BEFORE9B/$REPOS_AFTER9B"
fi

# ---------------------------------------------------------------------------
# SCENARIO 10 — gesture wiring (v0.1.2, ATOM-103, first G2 dry-run BLOCKING
# finding: the finale promised "qroky start" but neither the skill file nor
# any trigger ever reached the target machine). Fresh install in W10, then a
# re-run. Asserts (each negative-able — all four fail on the v0.1.1 build):
#   a) <workdir>/.claude/skills/qroky/SKILL.md exists and is NON-EMPTY
#   b) <workdir>/CLAUDE.md contains the trigger block (start marker present)
#   c) after the re-run, CLAUDE.md contains exactly ONE start marker
#      (idempotency — no duplicate blocks) and the skill file is unchanged
#   d) the workdir copy is byte-identical to the vendored source
#      (runtime/claude/skill/qroky/SKILL.md in this repo — the same file the
#      fake framework origin ships)
# Plus the M1 fold-in assert: install.sh's default workdir suggestion is
# $HOME/qroky-work — OUTSIDE the kit clone (the old "./qroky" default landed
# the workspace inside distribution/).
# ---------------------------------------------------------------------------
T10="$ATOM_WORKSPACE/scenario-10-gesture-wiring.txt"
W10="$SANDBOX/w10"
{
  echo "Scenario 10 — gesture wiring (v0.1.2): the 'qroky start' promise is kept on the TARGET machine"
  echo "Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo ""
  echo "--- RUN 1 (fresh install) ---"
} > "$T10"
OUT10A="$(run_install "$W10" $'en\n\nn\nn\ny\nn\n')"
STATUS10A=$?
{
  echo "$OUT10A"
  echo "--- RUN 1 exit: $STATUS10A ---"
} >> "$T10"
SKILL10="$W10/.claude/skills/qroky/SKILL.md"
SKILL_EXISTS10=0; [[ -s "$SKILL10" ]] && SKILL_EXISTS10=1
MARKERS_RUN1=$(grep -cF '<!-- qroky-gesture:start -->' "$W10/CLAUDE.md" 2>/dev/null || true)
SKILL_MD5_RUN1="$( (md5 -q "$SKILL10" 2>/dev/null || md5sum "$SKILL10" 2>/dev/null | cut -d' ' -f1) || true)"
{
  echo ""
  echo "--- RUN 2 (re-run through the ATOM-106 dialog, answer 'reinstall' —"
  echo "the full walkthrough must not duplicate the trigger block) ---"
} >> "$T10"
OUT10B="$(run_install "$W10" $'reinstall\n')"
STATUS10B=$?
{
  echo "$OUT10B"
  echo "--- RUN 2 exit: $STATUS10B ---"
} >> "$T10"
MARKERS_RUN2=$(grep -cF '<!-- qroky-gesture:start -->' "$W10/CLAUDE.md" 2>/dev/null || true)
SKILL_MD5_RUN2="$( (md5 -q "$SKILL10" 2>/dev/null || md5sum "$SKILL10" 2>/dev/null | cut -d' ' -f1) || true)"
VENDOR_DIFF10="$(diff "$VENDORED_SKILL" "$SKILL10" 2>&1)"
DEFAULT_OUTSIDE10=$(grep -cF 'printf '"'"'%s'"'"' "$HOME/qroky-work"' "$INSTALL" || true)
TRIGGER_MENTIONS_SKILL10=$(grep -cF '.claude/skills/qroky/SKILL.md' "$W10/CLAUDE.md" 2>/dev/null || true)
{
  echo ""
  echo "--- assertions ---"
  echo "a) skill file exists and is non-empty: $([[ $SKILL_EXISTS10 -eq 1 ]] && echo yes || echo NO-DEFECT) ($SKILL10)"
  echo "b) CLAUDE.md trigger block present after RUN 1: $([[ "$MARKERS_RUN1" -eq 1 ]] && echo yes || echo NO-DEFECT) (start markers: $MARKERS_RUN1)"
  echo "   trigger block points at the skill file: $([[ "$TRIGGER_MENTIONS_SKILL10" -gt 0 ]] && echo yes || echo NO-DEFECT)"
  echo "c) exactly ONE start marker after the re-run (must be 1): $MARKERS_RUN2"
  echo "   skill file unchanged across the re-run: $([[ -n "$SKILL_MD5_RUN1" && "$SKILL_MD5_RUN1" == "$SKILL_MD5_RUN2" ]] && echo yes || echo NO-DEFECT)"
  echo "d) workdir copy byte-identical to the vendored source: $([[ -z "$VENDOR_DIFF10" ]] && echo yes || echo NO-DEFECT)"
  [[ -n "$VENDOR_DIFF10" ]] && { echo "--- diff (vendored vs workdir) ---"; echo "$VENDOR_DIFF10"; }
  echo "M1) default workdir suggestion is \$HOME/qroky-work (outside the clone): $([[ "$DEFAULT_OUTSIDE10" -gt 0 ]] && echo yes || echo NO-DEFECT)"
  echo ""
  echo "--- CLAUDE.md as landed (for the record) ---"
  cat "$W10/CLAUDE.md" 2>/dev/null || echo "(missing)"
} >> "$T10"
if [[ $STATUS10A -eq 0 && $STATUS10B -eq 0 && $SKILL_EXISTS10 -eq 1 \
      && "$MARKERS_RUN1" -eq 1 && "$MARKERS_RUN2" -eq 1 \
      && "$TRIGGER_MENTIONS_SKILL10" -gt 0 \
      && -n "$SKILL_MD5_RUN1" && "$SKILL_MD5_RUN1" == "$SKILL_MD5_RUN2" \
      && -z "$VENDOR_DIFF10" && "$DEFAULT_OUTSIDE10" -gt 0 ]]; then
  record "10-gesture-wiring" PASS "skill file landed non-empty, ONE trigger block after re-run, workdir copy identical to vendored source, default workdir outside the clone"
else
  record "10-gesture-wiring" FAIL "exit_a=$STATUS10A exit_b=$STATUS10B skill=$SKILL_EXISTS10 markers_run1=$MARKERS_RUN1 markers_run2=$MARKERS_RUN2 trigger_ref=$TRIGGER_MENTIONS_SKILL10 md5_stable=$([[ "$SKILL_MD5_RUN1" == "$SKILL_MD5_RUN2" ]] && echo yes || echo no) vendor_diff_empty=$([[ -z "$VENDOR_DIFF10" ]] && echo yes || echo no) default_outside=$DEFAULT_OUTSIDE10"
fi

# ---------------------------------------------------------------------------
# SCENARIO 11 — the Telegram journey (v0.2, ATOM-104, GATE-027 finding 1:
# «дал ключ, но ничего не произошло»). Two branches.
# Branch A (Start pressed): token accepted -> installer catches the /start
# press from the stub -> chat_id BOUND in the head's own state file ->
# offset handed off past the consumed update -> the hello ACTUALLY sent
# (asserted in the stub's sent-log, not claimed) -> head deployed:
# profile.conf points at the kit's token file, wrappers + BOTH plists
# rendered and bootstrapped, one listener pass healthy.
# Branch B (Start never pressed): honest timeout -> token stays stored,
# head NOT deployed, install CONTINUES to a green finish -> then the
# documented one command (--enable-telegram) genuinely completes the whole
# loop end-to-end. Every assertion fails on the v0.1.2 build by construction.
# ---------------------------------------------------------------------------
T11="$ATOM_WORKSPACE/scenario-11-telegram-journey.txt"
W11A="$SANDBOX/w11a"
W11B="$SANDBOX/w11b"
{
  echo "Scenario 11 — Telegram journey (v0.2): «дал ключ — бот пнул», both branches"
  echo "Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "Stub: getUpdates delivers the owner's /start (update_id 111, chat 424242)"
  echo "only while QROKY_STUB_TG_START=1 and offset <= 111; every sendMessage is"
  echo "recorded verbatim in tg-sent.log. QROKY_TEST_START_WAIT=4 shrinks the"
  echo "honest 60 s wait for the harness."
  echo ""
  echo "--- BRANCH A: token + Start pressed ---"
} > "$T11"
: > "$LAUNCHCTL_STATE"
SENT_BEFORE_A=$(wc -l < "$TG_SENT_LOG" | tr -d ' ')
OUT11A="$(run_install "$W11A" $'en\n\ny\nGOODTOKEN111\nn\nn\nn\n')"
STATUS11A=$?
SENT_AFTER_A=$(wc -l < "$TG_SENT_LOG" | tr -d ' ')
SENT_DURING_A=$((SENT_AFTER_A - SENT_BEFORE_A))
echo "$OUT11A" >> "$T11"
TGH11="$W11A/.qroky/telegram"
CHATID11="$(cat "$TGH11/state/chat_id" 2>/dev/null || echo MISSING)"
OFFSET11="$(cat "$TGH11/state/offset" 2>/dev/null || echo MISSING)"
HELLO_LOGGED11=0
if [[ "$SENT_DURING_A" -gt 0 ]]; then
  HELLO_LOGGED11=$(tail -n "$SENT_DURING_A" "$TG_SENT_LOG" 2>/dev/null | grep -c "chat_id=424242 text=I am connected" || true)
fi
PROFILE_TOKENPATH11=$(grep -c "TOKEN_FILE=\"$W11A/.qroky/telegram.token\"" "$TGH11/profile.conf" 2>/dev/null || true)
PROFILE_DIGEST11=$(grep -c 'DIGEST_TIME="09:05"' "$TGH11/profile.conf" 2>/dev/null || true)
PROFILE_QUIET11=$(grep -c 'QUIET_START="23:00"' "$TGH11/profile.conf" 2>/dev/null || true)
WRAPPERS11=0
[[ -x "$TGH11/run-listener.sh" && -x "$TGH11/run-digest.sh" ]] && WRAPPERS11=1
PLISTS11=$(ls "$TGH11"/launchd/md.qroky.telegram.*.plist 2>/dev/null | wc -l | tr -d ' ')
BOOT_LISTENER11=$(grep -c "bootstrap.*md.qroky.telegram.listener" "$LAUNCHCTL_STATE" 2>/dev/null || true)
BOOT_DIGEST11=$(grep -c "bootstrap.*md.qroky.telegram.digest" "$LAUNCHCTL_STATE" 2>/dev/null || true)
LISTENER_OK11=$(grep -c "LISTENER-PASS-OK" "$W11A/install.log" 2>/dev/null || true)
PRESS_PROMPT11=$(printf '%s' "$OUT11A" | grep -c "press Start" || true)
BOT_NAMED11=$(printf '%s' "$OUT11A" | grep -c "@qroky_test_bot" || true)
DIGEST_PREMARK11=$(ls "$TGH11"/state/digest-sent-* 2>/dev/null | wc -l | tr -d ' ')
{
  echo ""
  echo "--- branch A assertions ---"
  echo "exit code: $STATUS11A"
  echo "press-Start prompt shown, bot named: prompt=$PRESS_PROMPT11 named=$BOT_NAMED11"
  echo "chat_id bound in the HEAD's state file (must be 424242): $CHATID11"
  echo "offset handed off past the consumed /start (must be 111): $OFFSET11"
  echo "hello ACTUALLY sent (stub sent-log, this run): $HELLO_LOGGED11 (sends during run: $SENT_DURING_A — must be exactly 1: the hello, and nothing else)"
  echo "profile.conf points at the kit's token file: $PROFILE_TOKENPATH11; digest 09:05: $PROFILE_DIGEST11; quiet 23:00: $PROFILE_QUIET11"
  echo "wrapper scripts present + executable: $([[ $WRAPPERS11 -eq 1 ]] && echo yes || echo NO-DEFECT)"
  echo "plists rendered (must be 2): $PLISTS11; bootstrapped: listener=$BOOT_LISTENER11 digest=$BOOT_DIGEST11"
  echo "one listener pass health-checked OK (install.log): $LISTENER_OK11"
  echo "today's digest pre-marked (first digest arrives next morning, as the hello says): $DIGEST_PREMARK11"
  echo ""
  echo "--- BRANCH B: token given, Start NEVER pressed (stub delivers nothing) ---"
} >> "$T11"
: > "$LAUNCHCTL_STATE"
OUT11B="$( ( export QROKY_STUB_TG_START=0; run_install "$W11B" $'en\n\ny\nGOODTOKEN222\nn\nn\nn\n' ) )"
STATUS11B=$?
echo "$OUT11B" >> "$T11"
HONEST11B=$(printf '%s' "$OUT11B" | grep -c "nobody pressed Start" || true)
ENABLE_LATER11B=$(printf '%s' "$OUT11B" | grep -c -- "--enable-telegram" || true)
TOKEN_KEPT11B=0; [[ -s "$W11B/.qroky/telegram.token" ]] && TOKEN_KEPT11B=1
DEPLOYED11B=0; [[ -f "$W11B/.qroky/telegram/profile.conf" ]] && DEPLOYED11B=1
BOOT11B=$(grep -c "bootstrap.*md.qroky.telegram" "$LAUNCHCTL_STATE" 2>/dev/null || true)
BOUND11B=$(grep -c '"answer_telegram_bound": "no"' "$W11B/install-state.json" 2>/dev/null || true)
FINALE11B=$(printf '%s' "$OUT11B" | grep -cF "cd $W11B && claude" || true)
{
  echo ""
  echo "--- branch B assertions (timeout path) ---"
  echo "exit code (install must CONTINUE to green): $STATUS11B"
  echo "honest no-Start line shown: $HONEST11B; enable-later command named: $ENABLE_LATER11B"
  echo "token kept for later: $TOKEN_KEPT11B; state records bound=no: $BOUND11B"
  echo "head NOT deployed (no half-alive unbound listener): profile.conf absent: $([[ $DEPLOYED11B -eq 0 ]] && echo yes || echo NO-DEFECT); telegram bootstraps this run (must be 0): $BOOT11B"
  echo "finale still reached with the real path: $FINALE11B"
  echo ""
  echo "--- BRANCH B part 2: bash install.sh --enable-telegram (Start pressed now) completes the loop ---"
} >> "$T11"
SENT_BEFORE_B2=$(wc -l < "$TG_SENT_LOG" | tr -d ' ')
OUT11B2="$(run_install "$W11B" '' --enable-telegram)"
STATUS11B2=$?
SENT_AFTER_B2=$(wc -l < "$TG_SENT_LOG" | tr -d ' ')
SENT_DURING_B2=$((SENT_AFTER_B2 - SENT_BEFORE_B2))
echo "$OUT11B2" >> "$T11"
CHATID11B2="$(cat "$W11B/.qroky/telegram/state/chat_id" 2>/dev/null || echo MISSING)"
DEPLOYED11B2=0; [[ -f "$W11B/.qroky/telegram/profile.conf" ]] && DEPLOYED11B2=1
HELLO11B2=0
if [[ "$SENT_DURING_B2" -gt 0 ]]; then
  HELLO11B2=$(tail -n "$SENT_DURING_B2" "$TG_SENT_LOG" 2>/dev/null | grep -c "chat_id=424242 text=I am connected" || true)
fi
REASKED_TOKEN11B2=$(printf '%s' "$OUT11B2" | grep -c "Paste the token here" || true)
{
  echo ""
  echo "--- branch B part 2 assertions ---"
  echo "exit code: $STATUS11B2"
  echo "stored token REUSED, not re-asked: $([[ $REASKED_TOKEN11B2 -eq 0 ]] && echo yes || echo NO-DEFECT)"
  echo "chat_id now bound: $CHATID11B2; head now deployed: $DEPLOYED11B2; hello sent: $HELLO11B2"
} >> "$T11"

if [[ $STATUS11A -eq 0 && "$CHATID11" == "424242" && "$OFFSET11" == "111" \
      && "$HELLO_LOGGED11" -eq 1 && "$SENT_DURING_A" -eq 1 \
      && "$PRESS_PROMPT11" -gt 0 && "$BOT_NAMED11" -gt 0 \
      && "$PROFILE_TOKENPATH11" -gt 0 && "$PROFILE_DIGEST11" -gt 0 && "$PROFILE_QUIET11" -gt 0 \
      && $WRAPPERS11 -eq 1 && "$PLISTS11" == "2" \
      && "$BOOT_LISTENER11" -gt 0 && "$BOOT_DIGEST11" -gt 0 \
      && "$LISTENER_OK11" -gt 0 && "$DIGEST_PREMARK11" -gt 0 \
      && $STATUS11B -eq 0 && "$HONEST11B" -gt 0 && "$ENABLE_LATER11B" -gt 0 \
      && $TOKEN_KEPT11B -eq 1 && "$BOUND11B" -gt 0 && $DEPLOYED11B -eq 0 && "$BOOT11B" -eq 0 \
      && "$FINALE11B" -gt 0 \
      && $STATUS11B2 -eq 0 && "$CHATID11B2" == "424242" && $DEPLOYED11B2 -eq 1 \
      && "$HELLO11B2" -eq 1 && "$REASKED_TOKEN11B2" -eq 0 ]]; then
  record "11-telegram-journey" PASS "A: Start caught, bound 424242, offset 111, hello really sent (exactly 1 send), head deployed (profile+wrappers+2 plists+bootstrap), listener pass OK, digest pre-marked; B: honest timeout, no deploy, install green, --enable-telegram then completes bind+hello+deploy reusing the stored token"
else
  record "11-telegram-journey" FAIL "a_exit=$STATUS11A chat=$CHATID11 off=$OFFSET11 hello=$HELLO_LOGGED11 sends=$SENT_DURING_A prompt=$PRESS_PROMPT11 named=$BOT_NAMED11 prof=$PROFILE_TOKENPATH11/$PROFILE_DIGEST11/$PROFILE_QUIET11 wrap=$WRAPPERS11 plists=$PLISTS11 boot=$BOOT_LISTENER11/$BOOT_DIGEST11 pass=$LISTENER_OK11 premark=$DIGEST_PREMARK11 b_exit=$STATUS11B honest=$HONEST11B later=$ENABLE_LATER11B tok=$TOKEN_KEPT11B bound_no=$BOUND11B dep=$DEPLOYED11B boot_b=$BOOT11B finale=$FINALE11B b2_exit=$STATUS11B2 b2_chat=$CHATID11B2 b2_dep=$DEPLOYED11B2 b2_hello=$HELLO11B2 b2_reask=$REASKED_TOKEN11B2"
fi

# ---------------------------------------------------------------------------
# SCENARIO 12 — machine-wide gesture, ALWAYS-ON (INFO-042, supersedes the
# GATE-028 q9 opt-in — lex posterior). A DEFAULT install, with NO question
# asked, writes EXACTLY two files under fake-HOME/.claude — the skill copy
# (byte-identical to the vendored source, which must carry the AMENDED I3
# exception: GATE-028 + INFO-042) and CLAUDE.md with exactly ONE marker
# block; the removal paths are still named; the finale carries the TRACE
# line (what was set up + the one-command removal) — the trace replaces the
# question. A re-run (through the reinstall dialog) changes nothing. A
# PRE-EXISTING user CLAUDE.md is appended to, never clobbered. The q9
# question text is gone from the interview. Mutation-ready: on the q9
# build a default (Enter-through) install left HOME untouched — every
# always-on assert here fails there.
# ---------------------------------------------------------------------------
T12="$ATOM_WORKSPACE/scenario-12-machinewide-always-on.txt"
W12A="$SANDBOX/w12a"
W12B="$SANDBOX/w12b"
HOME_C="$SANDBOX/home-mw-default"
HOME_D="$SANDBOX/home-mw-preexisting"
for h in "$HOME_C" "$HOME_D"; do
  mkdir -p "$h"
  git config --file "$h/.gitconfig" protocol.file.allow always
  git config --file "$h/.gitconfig" user.email "dryrun@qroky.local"
  git config --file "$h/.gitconfig" user.name "Qroky dry run"
done
{
  echo "Scenario 12 — machine-wide gesture always-on (INFO-042: question 9 removed)"
  echo "Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "Each leg gets its own fake HOME; the '~-writes' are proven by"
  echo "exhaustively listing every file under it."
  echo ""
  echo "--- default install (fake HOME: $HOME_C; NO machine-wide answer in the feed) ---"
} > "$T12"
OUT12A="$( ( export HOME="$HOME_C"; run_install "$W12A" $'en\n\nn\nn\nn\nn\n' ) )"
STATUS12A=$?
echo "$OUT12A" >> "$T12"
MW_SKILL="$HOME_C/.claude/skills/qroky/SKILL.md"
MW_CLAUDEMD="$HOME_C/.claude/CLAUDE.md"
FILES_UNDER_CLAUDE_A=$(find "$HOME_C/.claude" -type f 2>/dev/null | wc -l | tr -d ' ')
FILES_UNDER_HOME_A=$(find "$HOME_C" -type f 2>/dev/null | wc -l | tr -d ' ')
# v0.4 (ATOM-130): the machine trace ~/.qroky/workdir is a NEW sanctioned
# ~-write — the exhaustive listing expects exactly it and nothing else new
MW_POINTER_OK=0; [[ "$(cat "$HOME_C/.qroky/workdir" 2>/dev/null)" == "$W12A" ]] && MW_POINTER_OK=1
# v0.4.1 (ATOM-131, INFO-044): TWO more sanctioned ~-writes — the qroky
# launcher (executable, OUR provenance line) and exactly ONE PATH marker
# block in the shell profile install.sh actually targets (fake HOME has no
# ~/.local/bin on PATH, so the line is always needed here)
case "${SHELL:-}" in */zsh) PROF12="$HOME_C/.zshrc";; */bash) PROF12="$HOME_C/.bashrc";; *) PROF12="$HOME_C/.profile";; esac
LAUNCHER12_OK=0
[[ -x "$HOME_C/.local/bin/qroky" ]] && grep -qF "INFO-044" "$HOME_C/.local/bin/qroky" && LAUNCHER12_OK=1
PATH_MARKERS12_A1=$(cat "$HOME_C/.zshrc" "$HOME_C/.zprofile" "$HOME_C/.bashrc" "$HOME_C/.bash_profile" "$HOME_C/.profile" 2>/dev/null | grep -cF '>>> qroky command' || true)
MARKERS_A1=$(grep -cF '<!-- qroky-machinewide:start -->' "$MW_CLAUDEMD" 2>/dev/null || true)
SKILL_DIFF12="$(diff "$VENDORED_SKILL" "$MW_SKILL" 2>&1)"
I3_EXCEPTION12=$(grep -c "GATE-028" "$MW_SKILL" 2>/dev/null || true)
I3_AMENDED12=$(grep -c "INFO-042" "$MW_SKILL" 2>/dev/null || true)
# ATOM-131: the skill's I3 exception must also carry the INFO-044 amendment
# (third machine-wide file: the launcher + its PATH line)
I3_AMENDED44_12=$(grep -c "INFO-044" "$MW_SKILL" 2>/dev/null || true)
REMOVAL_NAMED12=$(printf '%s' "$OUT12A" | grep -c "to remove, delete them" || true)
Q9_ASKED12=$(printf '%s' "$OUT12A" | grep -c "Type y for machine-wide" || true)
TRACE_FINALE12=$(printf '%s' "$OUT12A" | grep -c "ANY Claude Code session" || true)
TRACE_UNINSTALL_CMD12=$(printf '%s' "$OUT12A" | grep -c "qroky uninstall" || true)
SKILL_MD5_A1="$( (md5 -q "$MW_SKILL" 2>/dev/null || md5sum "$MW_SKILL" 2>/dev/null | cut -d' ' -f1) || true)"
{
  echo ""
  echo "--- re-run (ATOM-106 dialog -> 'reinstall'; idempotency: still exactly two files, ONE marker) ---"
} >> "$T12"
OUT12A2="$( ( export HOME="$HOME_C"; run_install "$W12A" $'reinstall\n' ) )"
STATUS12A2=$?
echo "$OUT12A2" >> "$T12"
MARKERS_A2=$(grep -cF '<!-- qroky-machinewide:start -->' "$MW_CLAUDEMD" 2>/dev/null || true)
FILES_UNDER_CLAUDE_A2=$(find "$HOME_C/.claude" -type f 2>/dev/null | wc -l | tr -d ' ')
SKILL_MD5_A2="$( (md5 -q "$MW_SKILL" 2>/dev/null || md5sum "$MW_SKILL" 2>/dev/null | cut -d' ' -f1) || true)"
# ATOM-131 idempotency: the re-run must NOT duplicate the PATH marker block
PATH_MARKERS12_A2=$(cat "$HOME_C/.zshrc" "$HOME_C/.zprofile" "$HOME_C/.bashrc" "$HOME_C/.bash_profile" "$HOME_C/.profile" 2>/dev/null | grep -cF '>>> qroky command' || true)
FILES_UNDER_HOME_A2=$(find "$HOME_C" -type f 2>/dev/null | wc -l | tr -d ' ')
{
  echo ""
  echo "--- default-install assertions ---"
  echo "exit codes: run1=$STATUS12A rerun=$STATUS12A2"
  echo "q9 question asked (must be 0 — INFO-042 removed it): $Q9_ASKED12"
  echo "files under fake-HOME/.claude after run 1 (must be EXACTLY 2): $FILES_UNDER_CLAUDE_A"
  echo "total files under fake HOME (must be 6: .gitconfig + the two ~/.claude files + the ATOM-130 machine pointer ~/.qroky/workdir + the ATOM-131 launcher ~/.local/bin/qroky + the profile with the PATH block): $FILES_UNDER_HOME_A; pointer content correct: $MW_POINTER_OK (1)"
  echo "launcher executable with OUR provenance (INFO-044): $LAUNCHER12_OK (1); PATH marker blocks across ALL profiles after run 1 (must be 1): $PATH_MARKERS12_A1; after re-run (must STILL be 1): $PATH_MARKERS12_A2; files under HOME after re-run (must still be 6): $FILES_UNDER_HOME_A2"
  echo "full listing of every file under the fake HOME:"
  find "$HOME_C" -type f | sed "s|$HOME_C|~|"
  echo "marker blocks in ~/.claude/CLAUDE.md after run 1 (must be 1): $MARKERS_A1; after re-run (must still be 1): $MARKERS_A2"
  echo "files under .claude after re-run (must still be 2): $FILES_UNDER_CLAUDE_A2"
  echo "skill copy byte-identical to the vendored source: $([[ -z "$SKILL_DIFF12" ]] && echo yes || echo NO-DEFECT)"
  echo "skill copy carries the recorded I3 exception (GATE-028): $I3_EXCEPTION12, its INFO-042 amendment: $I3_AMENDED12, and the INFO-044 launcher amendment: $I3_AMENDED44_12"
  echo "removal paths named to the human: $REMOVAL_NAMED12"
  echo "finale carries the trace (works in ANY session + one-command removal): $TRACE_FINALE12 (>=1) / $TRACE_UNINSTALL_CMD12 (>=1)"
  echo "skill hash stable across the re-run: $([[ -n "$SKILL_MD5_A1" && "$SKILL_MD5_A1" == "$SKILL_MD5_A2" ]] && echo yes || echo NO-DEFECT)"
  echo ""
  echo "--- pre-existing user CLAUDE.md is appended to, never clobbered (fake HOME: $HOME_D) ---"
} >> "$T12"
mkdir -p "$HOME_D/.claude"
printf '# my own machine rules — must survive the install untouched\n' > "$HOME_D/.claude/CLAUDE.md"
OUT12B="$( ( export HOME="$HOME_D"; run_install "$W12B" $'en\n\nn\nn\nn\nn\n' ) )"
STATUS12B=$?
echo "$OUT12B" >> "$T12"
USER_LINE_KEPT=$(grep -c "my own machine rules" "$HOME_D/.claude/CLAUDE.md" 2>/dev/null || true)
MARKERS_B=$(grep -cF '<!-- qroky-machinewide:start -->' "$HOME_D/.claude/CLAUDE.md" 2>/dev/null || true)
SKILL_B=0; [[ -s "$HOME_D/.claude/skills/qroky/SKILL.md" ]] && SKILL_B=1
# README trace: the uninstall doc names the machine-wide undo in all 3 locales
TRACE_README_EN=$(grep -c "machine-wide setup is removed" "$HERE/README.en.md" || true)
TRACE_README_RU=$(grep -c "удаляется целиком этой одной командой" "$HERE/README.ru.md" || true)
TRACE_README_RO=$(grep -c "este eliminată complet de această singură comandă" "$HERE/README.ro.md" || true)
{
  echo ""
  echo "--- pre-existing CLAUDE.md assertions ---"
  echo "exit code: $STATUS12B"
  echo "the user's own line survived: $USER_LINE_KEPT (1); marker appended exactly once: $MARKERS_B (1); skill copy landed: $SKILL_B (1)"
  echo "README uninstall doc carries the machine-wide trace: en=$TRACE_README_EN ru=$TRACE_README_RU ro=$TRACE_README_RO (each >=1)"
} >> "$T12"
if [[ $STATUS12A -eq 0 && $STATUS12A2 -eq 0 && "$Q9_ASKED12" -eq 0 \
      && "$FILES_UNDER_CLAUDE_A" == "2" && "$FILES_UNDER_HOME_A" == "6" && $MW_POINTER_OK -eq 1 \
      && $LAUNCHER12_OK -eq 1 && "$PATH_MARKERS12_A1" -eq 1 && "$PATH_MARKERS12_A2" -eq 1 \
      && "$FILES_UNDER_HOME_A2" == "6" \
      && "$MARKERS_A1" -eq 1 && "$MARKERS_A2" -eq 1 && "$FILES_UNDER_CLAUDE_A2" == "2" \
      && -z "$SKILL_DIFF12" && "$I3_EXCEPTION12" -gt 0 && "$I3_AMENDED12" -gt 0 && "$I3_AMENDED44_12" -gt 0 && "$REMOVAL_NAMED12" -gt 0 \
      && "$TRACE_FINALE12" -ge 1 && "$TRACE_UNINSTALL_CMD12" -ge 1 \
      && -n "$SKILL_MD5_A1" && "$SKILL_MD5_A1" == "$SKILL_MD5_A2" \
      && $STATUS12B -eq 0 && "$USER_LINE_KEPT" -eq 1 && "$MARKERS_B" -eq 1 && $SKILL_B -eq 1 \
      && "$TRACE_README_EN" -ge 1 && "$TRACE_README_RU" -ge 1 && "$TRACE_README_RO" -ge 1 ]]; then
  record "12-machinewide-always-on" PASS "no question asked; default install wrote exactly 2 files under ~/.claude (skill = vendored source with the GATE-028+INFO-042+INFO-044 amended exception) + the qroky launcher with provenance + ONE PATH block (still one after re-run, 6 HOME files total), one marker after re-run, removal named, finale + README carry the trace in 3 locales; a pre-existing CLAUDE.md survived untouched"
else
  record "12-machinewide-always-on" FAIL "a=$STATUS12A a2=$STATUS12A2 q9=$Q9_ASKED12 claude_files=$FILES_UNDER_CLAUDE_A/$FILES_UNDER_CLAUDE_A2 home_files=$FILES_UNDER_HOME_A/$FILES_UNDER_HOME_A2 launcher=$LAUNCHER12_OK pathblocks=$PATH_MARKERS12_A1/$PATH_MARKERS12_A2 markers=$MARKERS_A1/$MARKERS_A2 diff_empty=$([[ -z "$SKILL_DIFF12" ]] && echo yes || echo no) i3=$I3_EXCEPTION12/$I3_AMENDED12 removal=$REMOVAL_NAMED12 trace=$TRACE_FINALE12/$TRACE_UNINSTALL_CMD12 md5=$([[ "$SKILL_MD5_A1" == "$SKILL_MD5_A2" ]] && echo stable || echo CHANGED) b=$STATUS12B/$USER_LINE_KEPT/$MARKERS_B/$SKILL_B readme=$TRACE_README_EN/$TRACE_README_RU/$TRACE_README_RO"
fi

# ---------------------------------------------------------------------------
# SCENARIO 13 — ATOM-111 router hooks in the kit: (a) a telegram deploy
# registers its workspace in the machine registry; (b) a SECOND workspace on
# the same machine only JOINS — no second token ask, no second launchd pair,
# no token file of its own; (c) --apply-update auto-completes the recorded
# «токен есть, головы нет» defect when token+binding exist, and (d) names
# the one finishing command when the binding is missing (nothing deployed).
# ---------------------------------------------------------------------------
T13="$ATOM_WORKSPACE/scenario-13-router-hooks.txt"
W13A="$SANDBOX/w13a"; W13B="$SANDBOX/w13b"; W13C="$SANDBOX/w13c"; W13D="$SANDBOX/w13d"
REG13="$SANDBOX/registries/machine13.registry"
{
  echo "Scenario 13 — kit router hooks (ATOM-111, GATE-029)"
  echo "Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo ""
  echo "--- (a) first workspace: full telegram journey on machine13 ---"
} > "$T13"
OUT13A="$(QROKY_DRYRUN_REGISTRY="$REG13" run_install "$W13A" $'en\n\ny\nGOODTOKEN123\nn\ny\nn\n')"
STATUS13A=$?
echo "$OUT13A" >> "$T13"
REG13_LINE1=""; [[ -f "$REG13" ]] && REG13_LINE1="$(head -1 "$REG13")"
REG13_COUNT=$(grep -c . "$REG13" 2>/dev/null || true)
REG13_LOGGED=$(grep -c "telegram REGISTERED workspace" "$W13A/install.log" 2>/dev/null || true)

{
  echo ""
  echo "--- (b) second workspace, SAME machine registry: join only ---"
} >> "$T13"
BOOTS_BEFORE_B=$(grep -c "bootstrap.*md.qroky.telegram" "$LAUNCHCTL_STATE" 2>/dev/null || true)
SENT_BEFORE_13B=$(wc -l < "$TG_SENT_LOG" | tr -d ' ')
OUT13B="$(QROKY_DRYRUN_REGISTRY="$REG13" run_install "$W13B" $'en\n\ny\nn\nn\nn\n')"
STATUS13B=$?
echo "$OUT13B" >> "$T13"
BOOTS_AFTER_B=$(grep -c "bootstrap.*md.qroky.telegram" "$LAUNCHCTL_STATE" 2>/dev/null || true)
SENT_AFTER_13B=$(wc -l < "$TG_SENT_LOG" | tr -d ' ')
JOINED13=$(printf '%s' "$OUT13B" | grep -c "just JOINED" || true)
BOTFATHER13B=$(printf '%s' "$OUT13B" | grep -c "BotFather" || true)
REG13_COUNT_B=$(grep -c . "$REG13" 2>/dev/null || true)
REG13_FIRST_B="$(head -1 "$REG13" 2>/dev/null)"
TOKEN13B=0; [[ -s "$W13B/.qroky/telegram.token" ]] && TOKEN13B=1
BOUND13B=$(grep -c '"answer_telegram_bound": "yes"' "$W13B/install-state.json" 2>/dev/null || true)

{
  echo ""
  echo "--- (c) apply-update auto-complete: token+binding present, head undeployed ---"
} >> "$T13"
OUT13C="$(QROKY_DRYRUN_REGISTRY="$SANDBOX/registries/machine13c.registry" run_install "$W13C" $'en\n\nn\nn\nn\nn\n')"
STATUS13C=$?
# plant the recorded-defect shape: v1-era token + captured binding, no head
mkdir -p "$W13C/.qroky/telegram/state"
printf 'GOODTOKEN123' > "$W13C/.qroky/telegram.token"; chmod 600 "$W13C/.qroky/telegram.token"
printf '424242' > "$W13C/.qroky/telegram/state/chat_id"
printf '111' > "$W13C/.qroky/telegram/state/offset"
git -C "$FAKE_FW" -c user.email=dryrun@qroky.local -c user.name="Qroky dry run" \
  commit -q --allow-empty -m "stub commit 3"
git -C "$FAKE_FW" -c user.email=dryrun@qroky.local -c user.name="Qroky dry run" \
  tag -a v1.2.0 -m "v1.2.0

brings the telegram head
to installs that predate it
so half-connects finish themselves"
SENT_BEFORE_13C=$(wc -l < "$TG_SENT_LOG" | tr -d ' ')
OUT13C2="$(QROKY_DRYRUN_REGISTRY="$SANDBOX/registries/machine13c.registry" run_install "$W13C" $'y\n' --apply-update)"
STATUS13C2=$?
echo "$OUT13C2" >> "$T13"
SENT_AFTER_13C=$(wc -l < "$TG_SENT_LOG" | tr -d ' ')
AUTOCOMPLETE13=$(grep -c "telegram AUTO-COMPLETE" "$W13C/install.log" 2>/dev/null || true)
WRAP13C=0; [[ -x "$W13C/.qroky/telegram/run-listener.sh" ]] && WRAP13C=1
PLISTS13C=$(ls "$W13C/.qroky/telegram/launchd/"md.qroky.telegram.*.plist 2>/dev/null | wc -l | tr -d ' ')
BOUND13C=$(grep -c '"answer_telegram_bound": "yes"' "$W13C/install-state.json" 2>/dev/null || true)
HELLO_DELTA_13C=$(( SENT_AFTER_13C - SENT_BEFORE_13C ))   # H5: no second hello

{
  echo ""
  echo "--- (d) apply-update with token but NO binding: hint only, no deploy ---"
} >> "$T13"
OUT13D="$(QROKY_DRYRUN_REGISTRY="$SANDBOX/registries/machine13d.registry" run_install "$W13D" $'en\n\nn\nn\nn\nn\n')"
mkdir -p "$W13D/.qroky"
printf 'GOODTOKEN123' > "$W13D/.qroky/telegram.token"; chmod 600 "$W13D/.qroky/telegram.token"
git -C "$FAKE_FW" -c user.email=dryrun@qroky.local -c user.name="Qroky dry run" \
  commit -q --allow-empty -m "stub commit 4"
git -C "$FAKE_FW" -c user.email=dryrun@qroky.local -c user.name="Qroky dry run" \
  tag -a v1.3.0 -m "v1.3.0

another stub line
and another
and a third"
OUT13D2="$(QROKY_DRYRUN_REGISTRY="$SANDBOX/registries/machine13d.registry" run_install "$W13D" $'y\n' --apply-update)"
STATUS13D2=$?
echo "$OUT13D2" >> "$T13"
HINT13D=$(printf '%s' "$OUT13D2" | grep -c -- "--enable-telegram" || true)
NOBIND_LOG13D=$(grep -c "TOKEN-WITHOUT-BINDING" "$W13D/install.log" 2>/dev/null || true)
WRAP13D=0; [[ -f "$W13D/.qroky/telegram/run-listener.sh" ]] && WRAP13D=1

{
  echo ""
  echo "--- assertions ---"
  echo "(a) exit: $STATUS13A (0); registry: $REG13_COUNT line(s) (1), line1 == workdir: $([[ "$REG13_LINE1" == "$W13A" ]] && echo yes || echo NO-DEFECT); REGISTERED log line: $REG13_LOGGED (>0)"
  echo "(b) exit: $STATUS13B (0); JOINED message: $JOINED13 (>0); BotFather walkthrough shown: $BOTFATHER13B (must be 0)"
  echo "(b) registry: $REG13_COUNT_B lines (2), primary unchanged: $([[ "$REG13_FIRST_B" == "$W13A" ]] && echo yes || echo NO-DEFECT)"
  echo "(b) second launchd pair bootstrapped: $((BOOTS_AFTER_B - BOOTS_BEFORE_B)) (must be 0); own token file: $TOKEN13B (0); sends during join: $((SENT_AFTER_13B - SENT_BEFORE_13B)) (0 — no second hello); state bound: $BOUND13B (1)"
  echo "(c) skip-install exit: $STATUS13C (0); apply exit: $STATUS13C2 (0); AUTO-COMPLETE log: $AUTOCOMPLETE13 (>0)"
  echo "(c) wrapper deployed: $WRAP13C (1); plists rendered: $PLISTS13C (2); state bound: $BOUND13C (1); sends during auto-complete: $HELLO_DELTA_13C (must be 0 — no second hello, H5)"
  echo "(d) apply exit: $STATUS13D2 (0); finishing command named: $HINT13D (>0); log: $NOBIND_LOG13D (>0); deployed anyway: $WRAP13D (must be 0 — no half-alive unbound listener)"
} >> "$T13"
if [[ $STATUS13A -eq 0 && "$REG13_COUNT" -eq 1 && "$REG13_LINE1" == "$W13A" && "$REG13_LOGGED" -gt 0 \
      && $STATUS13B -eq 0 && "$JOINED13" -gt 0 && "$BOTFATHER13B" -eq 0 \
      && "$REG13_COUNT_B" -eq 2 && "$REG13_FIRST_B" == "$W13A" \
      && $((BOOTS_AFTER_B - BOOTS_BEFORE_B)) -eq 0 && $TOKEN13B -eq 0 \
      && $((SENT_AFTER_13B - SENT_BEFORE_13B)) -eq 0 && "$BOUND13B" -eq 1 \
      && $STATUS13C -eq 0 && $STATUS13C2 -eq 0 && "$AUTOCOMPLETE13" -gt 0 \
      && $WRAP13C -eq 1 && "$PLISTS13C" == "2" && "$BOUND13C" -eq 1 && $HELLO_DELTA_13C -eq 0 \
      && $STATUS13D2 -eq 0 && "$HINT13D" -gt 0 && "$NOBIND_LOG13D" -gt 0 && $WRAP13D -eq 0 ]]; then
  record "13-router-hooks" PASS "deploy registers the workspace; second workspace joins (registry 2 lines, primary first) with zero token/hello/launchd of its own; apply-update auto-completed the «токен есть, головы нет» half-connect with no second hello (H5) and only HINTED when the binding was missing"
else
  record "13-router-hooks" FAIL "a=$STATUS13A/$REG13_COUNT/$([[ "$REG13_LINE1" == "$W13A" ]] && echo ok || echo mism)/$REG13_LOGGED b=$STATUS13B/$JOINED13/$BOTFATHER13B/$REG13_COUNT_B/$((BOOTS_AFTER_B - BOOTS_BEFORE_B))/$TOKEN13B/$((SENT_AFTER_13B - SENT_BEFORE_13B))/$BOUND13B c=$STATUS13C/$STATUS13C2/$AUTOCOMPLETE13/$WRAP13C/$PLISTS13C/$BOUND13C/$HELLO_DELTA_13C d=$STATUS13D2/$HINT13D/$NOBIND_LOG13D/$WRAP13D"
fi

# ---------------------------------------------------------------------------
# SCENARIO 14 — ATOM-105 language integrity: the question-1 answer governs
# EVERY later user-visible line. (a) ru install: ru bot hello, LANGUAGE="ru"
# in the head profile; (b) --apply-update prompt in Russian, «да» accepted;
# (c) a SECOND update accepted with English «yes» on the ru path (the word
# must never break it); locale survives both updates with no re-ask;
# (d) unrecognized q1 answers -> an HONEST trilingual fallback line, then a
# green EN install (the recorded «EN-финал» class made visible).
# ---------------------------------------------------------------------------
T14="$ATOM_WORKSPACE/scenario-14-language-integrity.txt"
W14="$SANDBOX/w14"; W14B="$SANDBOX/w14b"
{
  echo "Scenario 14 — language integrity end-to-end (ATOM-105 DoD 1)"
  echo "Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo ""
  echo "--- (a) ru install with telegram ---"
} > "$T14"
SENT_BEFORE_14=$(wc -l < "$TG_SENT_LOG" | tr -d ' ')
OUT14A="$(run_install "$W14" $'ru\n\ny\nGOODTOKEN123\nn\nn\nn\n')"
STATUS14A=$?
echo "$OUT14A" >> "$T14"
HELLO_RU=$(tail -n "+$((SENT_BEFORE_14 + 1))" "$TG_SENT_LOG" | grep -c "Я на связи. Завтра утром пришлю ваш первый дайджест" || true)
PROFILE_LANG_RU=$(grep -c '^LANGUAGE="ru"$' "$W14/.qroky/telegram/profile.conf" 2>/dev/null || true)
STATE_LANG_RU=$(grep -c '"answer_language": "ru"' "$W14/install-state.json" 2>/dev/null || true)

{ echo ""; echo "--- (b) apply-update: prompt RU, «нет» cancels, «да» applies ---"; } >> "$T14"
git -C "$FAKE_FW" -c user.email=dryrun@qroky.local -c user.name="Qroky dry run" \
  commit -q --allow-empty -m "stub commit 5"
git -C "$FAKE_FW" -c user.email=dryrun@qroky.local -c user.name="Qroky dry run" \
  tag -a v1.4.0 -m $'v1.4.0\n\nстрока раз\nстрока два\nстрока три'
OUT14N="$(run_install "$W14" $'нет\n' --apply-update)"
echo "$OUT14N" >> "$T14"
PROMPT_RU=$(printf '%s' "$OUT14N" | grep -c "Применить это обновление сейчас" || true)
PROMPT_EN_LEAK=$(printf '%s' "$OUT14N" | grep -c "Apply this update now" || true)
CANCEL_RU=$(printf '%s' "$OUT14N" | grep -c "обновление отменено — ничего не изменилось" || true)
OUT14D="$(run_install "$W14" $'да\n' --apply-update)"
echo "$OUT14D" >> "$T14"
DA_APPLIED=$(grep -c '"framework_tag": "v1.4.0"' "$W14/install-state.json" || true)
APPLIED_RU=$(printf '%s' "$OUT14D" | grep -c "обновление применено: " || true)

{ echo ""; echo "--- (c) second update: English «yes» on the ru path ---"; } >> "$T14"
git -C "$FAKE_FW" -c user.email=dryrun@qroky.local -c user.name="Qroky dry run" \
  commit -q --allow-empty -m "stub commit 6"
git -C "$FAKE_FW" -c user.email=dryrun@qroky.local -c user.name="Qroky dry run" \
  tag -a v1.5.0 -m $'v1.5.0\n\nещё раз\nещё два\nещё три'
OUT14Y="$(run_install "$W14" $'yes\n' --apply-update)"
echo "$OUT14Y" >> "$T14"
YES_APPLIED=$(grep -c '"framework_tag": "v1.5.0"' "$W14/install-state.json" || true)
YES_PROMPT_RU=$(printf '%s' "$OUT14Y" | grep -c "Применить это обновление сейчас" || true)
LOCALE_SURVIVED=$(grep -c '"answer_language": "ru"' "$W14/install-state.json" || true)
REASKED_LANG=$(printf '%s\n%s\n%s' "$OUT14N" "$OUT14D" "$OUT14Y" | grep -c "1) English  2) Română  3) Русский" || true)

{ echo ""; echo "--- (d) unrecognized q1 answers -> honest trilingual fallback ---"; } >> "$T14"
OUT14B="$(run_install "$W14B" $'xx\nyy\nzz\nqq\nww\n\nn\nn\nn\nn\n')"
STATUS14B=$?
echo "$OUT14B" >> "$T14"
FALLBACK_HONEST=$(printf '%s' "$OUT14B" | grep -c "ответ не распознан — продолжаю по-английски" || true)
FALLBACK_CONTINUED=$(printf '%s' "$OUT14B" | grep -c "Step 8 of 8" || true)
{
  echo ""; echo "--- assertions ---"
  echo "(a) exit: $STATUS14A (0); ru hello really sent: $HELLO_RU (1); head profile LANGUAGE=ru: $PROFILE_LANG_RU (1); state language ru: $STATE_LANG_RU (1)"
  echo "(b) apply prompt in Russian: $PROMPT_RU (>0), EN prompt leak: $PROMPT_EN_LEAK (0); «нет» cancelled in Russian: $CANCEL_RU (1); «да» applied: $DA_APPLIED (1), applied line ru: $APPLIED_RU (1)"
  echo "(c) «yes» on ru path applied v1.5.0: $YES_APPLIED (1) with the prompt still Russian: $YES_PROMPT_RU (>0)"
  echo "locale survived both updates: $LOCALE_SURVIVED (1); language question re-asked by subcommands: $REASKED_LANG (must be 0)"
  echo "(d) honest trilingual fallback line: $FALLBACK_HONEST (1); install continued green in EN: $FALLBACK_CONTINUED (>0), exit $STATUS14B (0)"
} >> "$T14"
if [[ $STATUS14A -eq 0 && "$HELLO_RU" -eq 1 && "$PROFILE_LANG_RU" -eq 1 && "$STATE_LANG_RU" -eq 1 \
      && "$PROMPT_RU" -gt 0 && "$PROMPT_EN_LEAK" -eq 0 && "$CANCEL_RU" -eq 1 \
      && "$DA_APPLIED" -eq 1 && "$APPLIED_RU" -eq 1 \
      && "$YES_APPLIED" -eq 1 && "$YES_PROMPT_RU" -gt 0 \
      && "$LOCALE_SURVIVED" -eq 1 && "$REASKED_LANG" -eq 0 \
      && "$FALLBACK_HONEST" -eq 1 && "$FALLBACK_CONTINUED" -gt 0 && $STATUS14B -eq 0 ]]; then
  record "14-language-integrity" PASS "ru q1 governs everything: ru hello, LANGUAGE=ru in the head profile, RUSSIAN apply-update prompt, «да» AND English «yes» both accepted, locale survives two updates with zero re-asks; unrecognized q1 answers now produce an HONEST trilingual line before the EN fallback"
else
  record "14-language-integrity" FAIL "a=$STATUS14A/$HELLO_RU/$PROFILE_LANG_RU/$STATE_LANG_RU b=$PROMPT_RU/$PROMPT_EN_LEAK/$CANCEL_RU/$DA_APPLIED/$APPLIED_RU c=$YES_APPLIED/$YES_PROMPT_RU locale=$LOCALE_SURVIVED/$REASKED_LANG d=$FALLBACK_HONEST/$FALLBACK_CONTINUED/$STATUS14B"
fi

# ---------------------------------------------------------------------------
# SCENARIO 15 — ATOM-105 clean slate: full install (telegram + heartbeat +
# machine-wide) -> --uninstall removes the MACHINE side (launchd, gesture
# files with our provenance, registry, token with a warning, install-state),
# keeps the workdir and prints its path; reinstall then passes AS A FIRST
# RUN (journey map, all 9, a fresh hello). A foreign skill at our path is
# left alone. Uninstall on a clean machine = polite no-op, rc 0.
# ---------------------------------------------------------------------------
T15="$ATOM_WORKSPACE/scenario-15-clean-slate.txt"
W15="$SANDBOX/w15"; W15X="$SANDBOX/w15x"
HOME_E="$SANDBOX/home-e"; HOME_F="$SANDBOX/home-f"
mkdir -p "$HOME_E" "$HOME_F"
cp "$FAKE_HOME/.gitconfig" "$HOME_E/" 2>/dev/null || true
cp "$FAKE_HOME/.gitconfig" "$HOME_F/" 2>/dev/null || true
{
  echo "Scenario 15 — clean slate: --uninstall -> reinstall as first (ATOM-105 DoD 2/3)"
  echo "Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo ""
  echo "--- full install (telegram y, heartbeat y; machine-wide is automatic since INFO-042) ---"
} > "$T15"
OUT15A="$( ( export HOME="$HOME_E"; run_install "$W15" $'en\n\ny\nGOODTOKEN123\nn\ny\nn\n' ) )"
STATUS15A=$?
echo "$OUT15A" >> "$T15"
PRE_PLISTS=$(ls "$HOME_E/Library/LaunchAgents"/md.qroky.*.plist 2>/dev/null | wc -l | tr -d ' ')
PRE_SKILL=0; [[ -f "$HOME_E/.claude/skills/qroky/SKILL.md" ]] && PRE_SKILL=1
PRE_MARKER=$(grep -c "qroky-machinewide:start" "$HOME_E/.claude/CLAUDE.md" 2>/dev/null || true)
REG15="$SANDBOX/registries/w15.registry"
PRE_REG=0; [[ -f "$REG15" ]] && PRE_REG=1

{ echo ""; echo "--- --uninstall ---"; } >> "$T15"
BOOTOUTS_BEFORE=$(grep -c "bootout" "$LAUNCHCTL_STATE" 2>/dev/null || true)
OUT15U="$( ( export HOME="$HOME_E"; run_install "$W15" '' --uninstall ) )"
STATUS15U=$?
echo "$OUT15U" >> "$T15"
BOOTOUTS_AFTER=$(grep -c "bootout" "$LAUNCHCTL_STATE" 2>/dev/null || true)
POST_PLISTS=$(ls "$HOME_E/Library/LaunchAgents"/md.qroky.*.plist 2>/dev/null | wc -l | tr -d ' ')
POST_SKILL=0; [[ -f "$HOME_E/.claude/skills/qroky/SKILL.md" ]] && POST_SKILL=1
POST_MARKER=$(grep -c "qroky-machinewide:start" "$HOME_E/.claude/CLAUDE.md" 2>/dev/null || true)
POST_REG=0; [[ -f "$REG15" ]] && POST_REG=1
POST_TOKEN=0; [[ -f "$W15/.qroky/telegram.token" ]] && POST_TOKEN=1
POST_STATE=0; [[ -f "$W15/install-state.json" ]] && POST_STATE=1
WORKDIR_KEPT=0; [[ -d "$W15/decisions" ]] && WORKDIR_KEPT=1
STEPS_ANNOUNCED=$(printf '%s' "$OUT15U" | grep -c "removing: " || true)
TOKEN_WARNED=$(printf '%s' "$OUT15U" | grep -c "about to DELETE the bot token file" || true)
PATH_PRINTED=$(printf '%s' "$OUT15U" | grep -cF "Your data stayed here: $W15" || true)
SUMMARY_SHOWN=$(printf '%s' "$OUT15U" | grep -c "Done. Removed:" || true)

{ echo ""; echo "--- foreign skill at our path is NOT ours to delete ---"; } >> "$T15"
mkdir -p "$HOME_E/.claude/skills/qroky"
printf '# somebody else wrote this — no kit provenance\n' > "$HOME_E/.claude/skills/qroky/SKILL.md"
OUT15F="$( ( export HOME="$HOME_E"; run_install "$W15" '' --uninstall ) )"
echo "$OUT15F" >> "$T15"
FOREIGN_KEPT=0; [[ -f "$HOME_E/.claude/skills/qroky/SKILL.md" ]] && FOREIGN_KEPT=1
FOREIGN_SAID=$(printf '%s' "$OUT15F" | grep -c "provenance marker" || true)
rm -f "$HOME_E/.claude/skills/qroky/SKILL.md"

{ echo ""; echo "--- reinstall passes as a FIRST run (post-uninstall the workdir still holds"
  echo "framework/ + live data, so the ATOM-106 dialog fires — answered '1' = reinstall;"
  echo "this is the CEO's exact journey from INFO-040, minus the raw git fatal) ---"; } >> "$T15"
SENT_BEFORE_15=$(wc -l < "$TG_SENT_LOG" | tr -d ' ')
OUT15R="$( ( export HOME="$HOME_E"; run_install "$W15" $'en\n\n1\ny\nGOODTOKEN123\nn\ny\nn\n' ) )"
STATUS15R=$?
echo "$OUT15R" >> "$T15"
MAP_AGAIN=$(printf '%s' "$OUT15R" | grep -c "Here is the whole road" || true)
ALL9_AGAIN=$(printf '%s' "$OUT15R" | grep -c "Step 8 of 8" || true)
HELLO_AGAIN=$(tail -n "+$((SENT_BEFORE_15 + 1))" "$TG_SENT_LOG" | grep -c "chat_id=424242 text=I am connected" || true)
# ATOM-106: the dialog fired (no state -> the 'update' option is refused
# honestly if chosen; here reinstall is chosen as '1'), and no raw git
# fatal ever reaches the founder's screen on the reinstall-over-occupied run.
DIALOG_15R=$(printf '%s' "$OUT15R" | grep -c "already carries a Qroky install" || true)
RAW_FATAL_15R=$(printf '%s' "$OUT15R" | grep -c "fatal:\|already exists" || true)
# ATOM-131: the reinstall hint is now the clone-less one command
HINT_15U=$(printf '%s' "$OUT15U" | grep -c "raw.githubusercontent.com/qroky/framework/main/qroky.sh" || true)

{ echo ""; echo "--- uninstall on a clean machine: polite no-op ---"; } >> "$T15"
OUT15N="$( ( export HOME="$HOME_F"; run_install "$W15X" '' --uninstall ) )"
STATUS15N=$?
echo "$OUT15N" >> "$T15"
NOOP_POLITE=$(printf '%s' "$OUT15N" | grep -c "Nothing to remove" || true)
{
  echo ""; echo "--- assertions ---"
  echo "install exit: $STATUS15A (0); before uninstall: plists=$PRE_PLISTS (>=3), skill=$PRE_SKILL (1), marker=$PRE_MARKER (1), registry=$PRE_REG (1) — the negative asserts below are non-vacuous"
  echo "uninstall exit: $STATUS15U (0); bootout calls fired: $((BOOTOUTS_AFTER - BOOTOUTS_BEFORE)) (>=3)"
  echo "after: plists=$POST_PLISTS (0), skill=$POST_SKILL (0), marker=$POST_MARKER (0), registry=$POST_REG (0), token=$POST_TOKEN (0), state=$POST_STATE (0)"
  echo "workdir kept: $WORKDIR_KEPT (1); steps announced: $STEPS_ANNOUNCED (>=5); token warned BEFORE deletion: $TOKEN_WARNED (1); path printed: $PATH_PRINTED (1); summary list: $SUMMARY_SHOWN (1)"
  echo "foreign skill kept: $FOREIGN_KEPT (1) and said so: $FOREIGN_SAID (1)"
  echo "uninstall finale points at the reinstall path (ATOM-106): $HINT_15U (>=1)"
  echo "reinstall: exit $STATUS15R (0), dialog fired on the occupied folder: $DIALOG_15R (>=1), raw git fatal on screen: $RAW_FATAL_15R (0), journey map again: $MAP_AGAIN (1), all 8 again: $ALL9_AGAIN (>0), fresh hello really sent: $HELLO_AGAIN (1)"
  echo "clean machine no-op: exit $STATUS15N (0), polite line: $NOOP_POLITE (1)"
} >> "$T15"
if [[ $STATUS15A -eq 0 && "$PRE_PLISTS" -ge 3 && $PRE_SKILL -eq 1 && "$PRE_MARKER" -eq 1 && $PRE_REG -eq 1 \
      && $STATUS15U -eq 0 && $((BOOTOUTS_AFTER - BOOTOUTS_BEFORE)) -ge 3 \
      && "$POST_PLISTS" -eq 0 && $POST_SKILL -eq 0 && "$POST_MARKER" -eq 0 && $POST_REG -eq 0 \
      && $POST_TOKEN -eq 0 && $POST_STATE -eq 0 && $WORKDIR_KEPT -eq 1 \
      && "$STEPS_ANNOUNCED" -ge 5 && "$TOKEN_WARNED" -eq 1 && "$PATH_PRINTED" -eq 1 && "$SUMMARY_SHOWN" -eq 1 \
      && "$HINT_15U" -ge 1 \
      && $FOREIGN_KEPT -eq 1 && "$FOREIGN_SAID" -eq 1 \
      && $STATUS15R -eq 0 && "$DIALOG_15R" -ge 1 && "$RAW_FATAL_15R" -eq 0 \
      && "$MAP_AGAIN" -eq 1 && "$ALL9_AGAIN" -gt 0 && "$HELLO_AGAIN" -eq 1 \
      && $STATUS15N -eq 0 && "$NOOP_POLITE" -eq 1 ]]; then
  record "15-clean-slate" PASS "uninstall removed launchd/gesture/registry/token/state (each announced first, token warned, summary listed, workdir kept + path printed + reinstall hint), left a FOREIGN skill alone; reinstall over the occupied workdir = dialog, then a genuine first run (map, all 8, fresh hello, zero raw git fatals); clean machine = polite no-op rc 0"
else
  record "15-clean-slate" FAIL "inst=$STATUS15A pre=$PRE_PLISTS/$PRE_SKILL/$PRE_MARKER/$PRE_REG un=$STATUS15U/$((BOOTOUTS_AFTER - BOOTOUTS_BEFORE)) post=$POST_PLISTS/$POST_SKILL/$POST_MARKER/$POST_REG/$POST_TOKEN/$POST_STATE kept=$WORKDIR_KEPT ui=$STEPS_ANNOUNCED/$TOKEN_WARNED/$PATH_PRINTED/$SUMMARY_SHOWN hint=$HINT_15U foreign=$FOREIGN_KEPT/$FOREIGN_SAID re=$STATUS15R/$DIALOG_15R/$RAW_FATAL_15R/$MAP_AGAIN/$ALL9_AGAIN/$HELLO_AGAIN noop=$STATUS15N/$NOOP_POLITE"
fi

# ---------------------------------------------------------------------------
# SCENARIO 16 — ATOM-106 case (b): an orphaned framework/ clone (no data next
# to it) gets the "recreate?" question, both branches; plus the case (c)
# parity assert (a clean-folder install never sees any reinstall dialog) and
# the three-locale completeness of every new string. Mutation-ready
# (INFO-037): the pre-fix build shows no orphan question at all.
# ---------------------------------------------------------------------------
T16="$ATOM_WORKSPACE/scenario-16-orphan-clone.txt"
W16="$SANDBOX/w16"
mkdir -p "$W16"
git clone -q "$FAKE_FW" "$W16/framework"
echo "stale clone — must vanish on recreate" > "$W16/framework/OLD-CLONE-MARKER"
LIST16_BEFORE="$(find "$W16" -type f ! -path '*/.git/*' | sort)"
{
  echo "Scenario 16 — orphaned clone: framework/ with no data next to it (ATOM-106 case b)"
  echo "Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "Setup: a bare 'git clone' of the framework into an otherwise empty folder"
  echo "(the raw-git entry a founder can produce by hand), plus a planted marker"
  echo "file that must survive 'no' and vanish on 'da'."
  echo ""
  echo "--- branch NO: leaves without a trace ---"
} > "$T16"
OUT16N="$(run_install "$W16" $'en\n\nno\n')"
STATUS16N=$?
echo "$OUT16N" >> "$T16"
LIST16_AFTER_N="$(find "$W16" -type f ! -path '*/.git/*' | sort)"
LIST16_DIFF_N="$(diff <(printf '%s' "$LIST16_BEFORE") <(printf '%s' "$LIST16_AFTER_N"))"
ORPHAN_ASKED_N=$(printf '%s' "$OUT16N" | grep -c "looks like an orphaned clone" || true)
DECLINED_SAID=$(printf '%s' "$OUT16N" | grep -c "leaving everything as it is" || true)
NO_STATE_AFTER_N=0; [[ -f "$W16/install-state.json" ]] || NO_STATE_AFTER_N=1
MARKER_KEPT_N=0; [[ -f "$W16/framework/OLD-CLONE-MARKER" ]] && MARKER_KEPT_N=1

{ echo ""; echo "--- branch YES (answered 'da' — the ru/ro yes must work on the en path): recreate + clean install ---"; } >> "$T16"
OUT16Y="$(run_install "$W16" $'en\n\nda\nn\nn\ny\nn\n')"
STATUS16Y=$?
echo "$OUT16Y" >> "$T16"
ORPHAN_ASKED_Y=$(printf '%s' "$OUT16Y" | grep -c "looks like an orphaned clone" || true)
MARKER_GONE_16=1; [[ -f "$W16/framework/OLD-CLONE-MARKER" ]] && MARKER_GONE_16=0
PROV_16=0; [[ -f "$W16/framework/PROVENANCE.md" ]] && PROV_16=1
STATE_DONE_16=$(grep -c '"step_machinewide": "done"' "$W16/install-state.json" 2>/dev/null || true)
MAP_16=$(printf '%s' "$OUT16Y" | grep -c "Here is the whole road" || true)
RAW_FATAL_16=$(printf '%s' "$OUT16Y" | grep -c "fatal:" || true)

# case (c) parity: Scenario 1's CLEAN run never met any reinstall/orphan
# dialog — non-vacuous because the very same phrases matched >0 above and
# in scenario 3.
PARITY_CLEAN=$(printf '%s' "$OUT1" | grep -c "already carries a Qroky install\|looks like an orphaned clone" || true)

# three-locale completeness: every new L_ function exists once per lang file
LANG_PARITY_OK=1
for fn in L_REINSTALL_FOUND L_REINSTALL_ASK L_REINSTALL_START L_REINSTALL_UPDATE_ROUTE \
          L_REINSTALL_UPDATE_NEEDS_STATE L_REINSTALL_CANCELLED L_ORPHAN_FOUND \
          L_ORPHAN_ASK L_ORPHAN_DECLINED L_UNINSTALL_REINSTALL_HINT \
          L_FINALE_NEW_SESSION_NOTE L_MARKER_SESSION_NOTE \
          L_FINALE_MACHINEWIDE_TRACE L_MACHINEWIDE_WIRING L_MACHINEWIDE_ALREADY; do
  for lf in en ru ro; do
    n=$(grep -c "^${fn}()" "$HERE/lang/$lf.sh" || true)
    [[ "$n" -eq 1 ]] || { LANG_PARITY_OK=0; echo "MISSING/DUP: $fn in lang/$lf.sh (count=$n)" >> "$T16"; }
  done
done
{
  echo ""
  echo "--- assertions ---"
  echo "NO branch: exit $STATUS16N (0), orphan question asked: $ORPHAN_ASKED_N (>=1), declined line: $DECLINED_SAID (1), folder untouched: $([[ -z "$LIST16_DIFF_N" ]] && echo yes || echo NO-DEFECT), marker kept: $MARKER_KEPT_N (1), no install-state created: $NO_STATE_AFTER_N (1)"
  echo "YES branch ('da'): exit $STATUS16Y (0), question asked: $ORPHAN_ASKED_Y (>=1), stale marker gone (fresh clone): $MARKER_GONE_16 (1), PROVENANCE present: $PROV_16 (1), install completed: $STATE_DONE_16 (1), journey map (a genuine first run): $MAP_16 (1), raw git fatal: $RAW_FATAL_16 (0)"
  echo "case (c) parity: reinstall/orphan dialog lines in Scenario 1's CLEAN run: $PARITY_CLEAN (0; non-vacuous — the same phrases matched above)"
  echo "three-locale completeness of the 15 new strings (incl. INFO-041 visibility notes + INFO-042 trace/wiring): $([[ $LANG_PARITY_OK -eq 1 ]] && echo yes || echo NO-DEFECT)"
} >> "$T16"
if [[ $STATUS16N -eq 0 && "$ORPHAN_ASKED_N" -ge 1 && "$DECLINED_SAID" -eq 1 && -z "$LIST16_DIFF_N" \
      && $MARKER_KEPT_N -eq 1 && $NO_STATE_AFTER_N -eq 1 \
      && $STATUS16Y -eq 0 && "$ORPHAN_ASKED_Y" -ge 1 && $MARKER_GONE_16 -eq 1 && $PROV_16 -eq 1 \
      && "$STATE_DONE_16" -eq 1 && "$MAP_16" -eq 1 && "$RAW_FATAL_16" -eq 0 \
      && "$PARITY_CLEAN" -eq 0 && $LANG_PARITY_OK -eq 1 ]]; then
  record "16-orphan-clone" PASS "(b) no = polite exit, folder byte-untouched; (b) 'da' = stale clone recreated + full clean install (marker gone, PROVENANCE, map, no raw fatal); (c) parity: clean run saw no dialog; all 15 new strings present x3 locales"
else
  record "16-orphan-clone" FAIL "no=$STATUS16N/$ORPHAN_ASKED_N/$DECLINED_SAID/diff$([[ -z "$LIST16_DIFF_N" ]] && echo ok || echo CHANGED)/marker$MARKER_KEPT_N/state$NO_STATE_AFTER_N yes=$STATUS16Y/$ORPHAN_ASKED_Y/gone$MARKER_GONE_16/prov$PROV_16/done$STATE_DONE_16/map$MAP_16/fatal$RAW_FATAL_16 parity=$PARITY_CLEAN lang=$LANG_PARITY_OK"
fi

# ---------------------------------------------------------------------------
# SCENARIO 17 — ATOM-106 recovery semantics (DoD 3): a framework/ broken by
# an interrupted self-update (folder deleted, git submodule slot still held —
# exactly the half-state whose re-add used to die with the raw
# "destination path 'framework' already exists" fatal) recovers through the
# (a) dialog to a WORKING state with zero loss of the live data. Plus the
# ru-locale leg of the dialog against Scenario-14's Russian install.
# Mutation-ready: on the pre-fix build this run dies at the framework step.
# ---------------------------------------------------------------------------
T17="$ATOM_WORKSPACE/scenario-17-broken-framework-recovery.txt"
W17="$SANDBOX/w17"
{
  echo "Scenario 17 — recovery of a broken framework/ after an interrupted self-update"
  echo "Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo ""
  echo "--- full install first ---"
} > "$T17"
OUT17A="$(run_install "$W17" $'en\n\nn\nn\ny\nn\n')"
STATUS17A=$?
echo "$OUT17A" >> "$T17"
echo "the founder's own note" > "$W17/mission/note.md"
STATE17_BEFORE="$(grep -v generated_at "$W17/install-state.json" | grep '"answer_')"
# break it: the folder goes, the submodule slot stays — the CEO-fatal shape
rm -rf "$W17/framework"
HALFSTATE_OK=0; [[ -d "$W17/.git/modules/framework" ]] && HALFSTATE_OK=1
{
  echo ""
  echo "--- broken: framework/ deleted, .git/modules/framework left ($([[ $HALFSTATE_OK -eq 1 ]] && echo present || echo MISSING — setup void)) ---"
  echo ""
  echo "--- recovery run: dialog -> 'переустановить' (ru word on the en path) ---"
} >> "$T17"
OUT17R="$(run_install "$W17" $'переустановить\n')"
STATUS17R=$?
echo "$OUT17R" >> "$T17"
DIALOG_17=$(printf '%s' "$OUT17R" | grep -c "already carries a Qroky install" || true)
FW_BACK=0; [[ -e "$W17/framework/.git" && -f "$W17/framework/PROVENANCE.md" ]] && FW_BACK=1
NOTE_KEPT=0; [[ -f "$W17/mission/note.md" ]] && NOTE_KEPT=1
STATE17_AFTER="$(grep -v generated_at "$W17/install-state.json" | grep '"answer_')"
ANSWERS_DIFF17="$(diff <(printf '%s' "$STATE17_BEFORE") <(printf '%s' "$STATE17_AFTER"))"
REASKED17=$(printf '%s' "$OUT17R" | grep -c "Which language do you want to use?" || true)
FINALE17=$(printf '%s' "$OUT17R" | grep -c "qroky start" || true)
RAW_FATAL17=$(printf '%s' "$OUT17R" | grep -c "fatal:\|already exists" || true)
# and the update channel works again after recovery (the framework is a
# healthy checkout, not a husk): --check-update runs clean
OUT17U="$(run_install "$W17" '' --check-update)"
STATUS17U=$?
{ echo ""; echo "--- --check-update after recovery ---"; echo "$OUT17U"; } >> "$T17"

{ echo ""; echo "--- ru-locale dialog leg (Scenario-14's Russian install, answer «отмена») ---"; } >> "$T17"
OUT17RU="$(run_install "$W14" $'отмена\n')"
STATUS17RU=$?
echo "$OUT17RU" >> "$T17"
RU_DIALOG=$(printf '%s' "$OUT17RU" | grep -c "уже есть установка Qroky" || true)
RU_CANCEL=$(printf '%s' "$OUT17RU" | grep -c "Отменено. Ничего не изменено." || true)
RU_EN_LEAK=$(printf '%s' "$OUT17RU" | grep -c "already carries a Qroky install\|Cancelled. Nothing was changed." || true)
{
  echo ""
  echo "--- assertions ---"
  echo "install: exit $STATUS17A (0); half-state planted for real: $HALFSTATE_OK (1 — non-vacuous)"
  echo "recovery: exit $STATUS17R (0), dialog: $DIALOG_17 (>=1), framework healthy again (.git + PROVENANCE): $FW_BACK (1)"
  echo "live data intact: mission note kept: $NOTE_KEPT (1); answers preserved: $([[ -z "$ANSWERS_DIFF17" ]] && echo yes || echo NO-DEFECT)"
  echo "zero re-asks: $REASKED17 (0); finale: $FINALE17 (>=1); raw git fatal on screen: $RAW_FATAL17 (0)"
  echo "update channel alive after recovery: exit $STATUS17U (0)"
  echo "ru dialog: exit $STATUS17RU (0), ru text: $RU_DIALOG (>=1), ru cancel: $RU_CANCEL (1), en leak: $RU_EN_LEAK (0)"
} >> "$T17"
if [[ $STATUS17A -eq 0 && $HALFSTATE_OK -eq 1 \
      && $STATUS17R -eq 0 && "$DIALOG_17" -ge 1 && $FW_BACK -eq 1 && $NOTE_KEPT -eq 1 \
      && -z "$ANSWERS_DIFF17" && "$REASKED17" -eq 0 && "$FINALE17" -ge 1 && "$RAW_FATAL17" -eq 0 \
      && $STATUS17U -eq 0 \
      && $STATUS17RU -eq 0 && "$RU_DIALOG" -ge 1 && "$RU_CANCEL" -eq 1 && "$RU_EN_LEAK" -eq 0 ]]; then
  record "17-broken-framework-recovery" PASS "half-state after an interrupted self-update (non-vacuous) recovered via the dialog to a working install: framework healthy, mission note + answers intact, zero re-asks, no raw fatal, update channel alive; ru dialog speaks Russian and «отмена» works"
else
  record "17-broken-framework-recovery" FAIL "inst=$STATUS17A half=$HALFSTATE_OK rec=$STATUS17R/$DIALOG_17/fw$FW_BACK/note$NOTE_KEPT answers=$([[ -z "$ANSWERS_DIFF17" ]] && echo ok || echo DIFF) reask=$REASKED17 finale=$FINALE17 fatal=$RAW_FATAL17 upd=$STATUS17U ru=$STATUS17RU/$RU_DIALOG/$RU_CANCEL/leak$RU_EN_LEAK"
fi

# ---------------------------------------------------------------------------
# SCENARIO 18 — ATOM-106 DoD 6 (INFO-041): the environment reads context at
# session START, so a freshly installed gesture is invisible to windows
# opened before the install. The kit must say so at THREE touch points:
# the installer finale, the Telegram hello, and the CLAUDE.md marker blocks
# (BOTH copies — workdir and machine-wide). Checked against artifacts the
# earlier scenarios already produced (en: scenarios 1/12/15; ru: scenario
# 14), so the asserts run over real founder-facing output — every grep
# fails on the pre-INFO-041 build by construction.
# ---------------------------------------------------------------------------
T18="$ATOM_WORKSPACE/scenario-18-fresh-gesture-visibility.txt"
{
  echo "Scenario 18 — fresh-gesture visibility notes at all three touch points (INFO-041)"
  echo "Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo ""
} > "$T18"
# (1) finale — en (Scenario 1's full run) and ru (Scenario 14's install)
FIN_EN=$(printf '%s' "$OUT1" | grep -c "only NEW Claude Code chats see" || true)
FIN_RU=$(printf '%s' "$OUT14A" | grep -c "видят только НОВЫЕ чаты Claude Code" || true)
# INFO-042: the machine-wide TRACE line is in the ru finale too (en is
# asserted in scenario 12 against the same real output)
TRACE_RU=$(printf '%s' "$OUT14A" | grep -c "ЛЮБОЙ сессии Claude Code" || true)
# (2) Telegram hello — the literal route (new chat -> folder -> phrase),
# with the REAL workdir path substituted, in the actually-sent payload
HELLO_EN_ROUTE=$(grep -c "open a new Claude Code chat in $W1 and say «qroky start»" "$TG_SENT_LOG" || true)
HELLO_RU_ROUTE=$(grep -c "откройте новый чат Claude Code в папке $W14 и скажите «qroky start»" "$TG_SENT_LOG" || true)
# (3) marker blocks — BOTH copies: the workdir CLAUDE.md (scenario 1's W1)
# and the machine-wide ~/.claude/CLAUDE.md (scenario 12's YES branch HOME_C)
MARK_WORKDIR=$(grep -c "installed AFTER this session started" "$W1/CLAUDE.md" 2>/dev/null || true)
MARK_MACHINE=$(grep -c "installed AFTER this session started" "$HOME_C/.claude/CLAUDE.md" 2>/dev/null || true)
# the note sits INSIDE the marker fences, so the uninstall strip removes it
MARK_IN_FENCE=$(awk '/qroky-machinewide:start/,/qroky-machinewide:end/' "$HOME_C/.claude/CLAUDE.md" 2>/dev/null | grep -c "installed AFTER this session started" || true)
# ru marker (scenario 14's workdir CLAUDE.md was written under ru locale)
MARK_RU=$(grep -c "установлен ПОСЛЕ старта" "$W14/CLAUDE.md" 2>/dev/null || true)
{
  echo "--- assertions (all against real output of earlier scenarios) ---"
  echo "finale note, en (scenario 1): $FIN_EN (>=1); ru (scenario 14): $FIN_RU (>=1)"
  echo "hello carries the literal route with the real path, en: $HELLO_EN_ROUTE (>=1); ru: $HELLO_RU_ROUTE (>=1)"
  echo "marker note in the WORKDIR copy (en, $W1/CLAUDE.md): $MARK_WORKDIR (1)"
  echo "marker note in the MACHINE-WIDE copy ($HOME_C/.claude/CLAUDE.md): $MARK_MACHINE (1), inside the strip fences: $MARK_IN_FENCE (1)"
  echo "marker note in the ru workdir copy ($W14/CLAUDE.md): $MARK_RU (1)"
  echo "machine-wide trace line in the ru finale (INFO-042): $TRACE_RU (>=1)"
} >> "$T18"
if [[ "$FIN_EN" -ge 1 && "$FIN_RU" -ge 1 && "$HELLO_EN_ROUTE" -ge 1 && "$HELLO_RU_ROUTE" -ge 1 \
      && "$MARK_WORKDIR" -eq 1 && "$MARK_MACHINE" -eq 1 && "$MARK_IN_FENCE" -eq 1 && "$MARK_RU" -eq 1 \
      && "$TRACE_RU" -ge 1 ]]; then
  record "18-fresh-gesture-visibility" PASS "the new-session note is at all three touch points (finale en+ru, hello with the literal route + real path en+ru, marker blocks in BOTH copies incl. inside the uninstall fences)"
else
  record "18-fresh-gesture-visibility" FAIL "finale=$FIN_EN/$FIN_RU hello=$HELLO_EN_ROUTE/$HELLO_RU_ROUTE marker=$MARK_WORKDIR/$MARK_MACHINE/fence$MARK_IN_FENCE/ru$MARK_RU trace_ru=$TRACE_RU"
fi

# ---------------------------------------------------------------------------
# SCENARIO 19 — ATOM-130 sparse vendoring + freeze check: a fresh install's
# framework/ materializes ONLY dist-manifest paths — the factory's junk
# (products/, decisions/, TASKS.md, launch files) is IN the origin's tree
# (proven, non-vacuous) but NEVER in the instance. verify.sh passes on the
# clean tree and fails loudly on one planted non-manifest file. On the
# pre-130 build there is no manifest, no sparse, no verify.sh — every
# assert here fails (mutation-ready, INFO-037).
# ---------------------------------------------------------------------------
T19="$ATOM_WORKSPACE/scenario-19-sparse-and-freeze.txt"
{
  echo "Scenario 19 — sparse vendoring + freeze check, against Scenario-1's instance"
  echo "Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo ""
} > "$T19"
# non-vacuity: the junk IS in the checked-out tag's TREE...
TREE_HAS_JUNK=$(git -C "$W1/framework" ls-tree -r HEAD --name-only 2>/dev/null | grep -c "^products/\|^decisions/\|^TASKS.md\|^ATOM-999" || true)
# ...but NOT in the worktree
WT_JUNK=$(find "$W1/framework" \( -path '*/products/*' -o -path '*/decisions/*' -o -name 'TASKS.md' -o -name 'ATOM-999-LAUNCH.md' \) -type f ! -path '*/.git/*' 2>/dev/null | wc -l | tr -d ' ')
WT_RUNTIME=0; [[ -f "$W1/framework/runtime/claude/telegram/listener.sh" ]] && WT_RUNTIME=1
WT_MANIFEST=0; [[ -f "$W1/framework/distribution/dist-manifest" ]] && WT_MANIFEST=1
SPARSE_ON=$(git -C "$W1/framework" sparse-checkout list 2>/dev/null | wc -l | tr -d ' ')
{
  echo "junk paths in the checked-out TREE (must be >0 — non-vacuous): $TREE_HAS_JUNK"
  echo "junk files in the WORKTREE (must be 0 — sparse): $WT_JUNK"
  echo "runtime materialized: $WT_RUNTIME (1); manifest materialized: $WT_MANIFEST (1); sparse patterns active: $SPARSE_ON (>0)"
  echo ""
  echo "--- freeze check on the clean tree ---"
} >> "$T19"
OUT19V="$(bash "$HERE/verify.sh" "$W1/framework" 2>&1)"; STATUS19V=$?
echo "$OUT19V" >> "$T19"
{ echo ""; echo "--- freeze check with ONE planted non-manifest file (must FAIL) ---"; } >> "$T19"
mkdir -p "$W1/framework/products"
echo "smuggled" > "$W1/framework/products/evil.md"
OUT19F="$(bash "$HERE/verify.sh" "$W1/framework" 2>&1)"; STATUS19F=$?
echo "$OUT19F" >> "$T19"
NAMED_OFFENDER=$(printf '%s' "$OUT19F" | grep -c "NOT IN MANIFEST: products/evil.md" || true)
rm -f "$W1/framework/products/evil.md"; rmdir "$W1/framework/products" 2>/dev/null || true
{
  echo ""
  echo "--- assertions ---"
  echo "clean tree: verify exit $STATUS19V (0); planted file: verify exit $STATUS19F (1), offender named: $NAMED_OFFENDER (1)"
} >> "$T19"
if [[ "$TREE_HAS_JUNK" -gt 0 && "$WT_JUNK" -eq 0 && $WT_RUNTIME -eq 1 && $WT_MANIFEST -eq 1 && "$SPARSE_ON" -gt 0 \
      && $STATUS19V -eq 0 && $STATUS19F -eq 1 && "$NAMED_OFFENDER" -eq 1 ]]; then
  record "19-sparse-and-freeze" PASS "origin tree carries factory junk (non-vacuous) yet the instance worktree has none; runtime/manifest materialized; verify.sh green on clean, red with the offender NAMED on one planted file"
else
  record "19-sparse-and-freeze" FAIL "tree_junk=$TREE_HAS_JUNK wt_junk=$WT_JUNK runtime=$WT_RUNTIME manifest=$WT_MANIFEST sparse=$SPARSE_ON verify=$STATUS19V/$STATUS19F/$NAMED_OFFENDER"
fi

# ---------------------------------------------------------------------------
# SCENARIO 20 — ATOM-130 silent migration of a LIVE v0.3.x instance: an old
# origin WITHOUT dist-manifest vendors whole (the faithful fat instance,
# proven), then the next tag brings the manifest — --apply-update sheds the
# factory history silently: zero extra questions, telegram binding/profile/
# token byte-intact, runtime alive, freeze check green afterwards.
# ---------------------------------------------------------------------------
T20="$ATOM_WORKSPACE/scenario-20-silent-migration.txt"
W20="$SANDBOX/w20"
OLDFW="$SANDBOX/old-framework-origin"
mkdir -p "$OLDFW/runtime/claude"
echo "# old stub framework" > "$OLDFW/README.md"
mkdir -p "$OLDFW/runtime/claude/skill/qroky"
cp "$VENDORED_SKILL" "$OLDFW/runtime/claude/skill/qroky/SKILL.md"
cp -R "$HERE/../runtime/claude/telegram" "$OLDFW/runtime/claude/telegram"
rm -rf "$OLDFW/runtime/claude/telegram/state" "$OLDFW/runtime/claude/telegram/telegram.log" 2>/dev/null || true
mkdir -p "$OLDFW/products/old-product"
echo "old factory junk" > "$OLDFW/products/old-product/RESULT.md"
echo "old factory backlog" > "$OLDFW/TASKS.md"
git -C "$OLDFW" init -q
git -C "$OLDFW" -c user.email=dryrun@qroky.local -c user.name="Qroky dry run" add -A
git -C "$OLDFW" -c user.email=dryrun@qroky.local -c user.name="Qroky dry run" commit -q -m "pre-manifest era"
git -C "$OLDFW" -c user.email=dryrun@qroky.local -c user.name="Qroky dry run" tag -a v0.3.9 -m $'v0.3.9\n\nold fat release'
{
  echo "Scenario 20 — live v0.3.x instance updates to a manifest release SILENTLY"
  echo "Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo ""
  echo "--- install against the OLD (manifest-less) origin, telegram on ---"
} > "$T20"
OUT20A="$( ( export QROKY_FRAMEWORK_SOURCE="$OLDFW"; run_install "$W20" $'en\n\ny\nGOODTOKEN123\nn\nn\nn\n' ) )"
STATUS20A=$?
echo "$OUT20A" >> "$T20"
FAT_BEFORE=0; [[ -f "$W20/framework/TASKS.md" && -f "$W20/framework/products/old-product/RESULT.md" ]] && FAT_BEFORE=1
CHAT20_BEFORE="$(cat "$W20/.qroky/telegram/state/chat_id" 2>/dev/null || true)"
PROFILE20_BEFORE="$( (md5 -q "$W20/.qroky/telegram/profile.conf" 2>/dev/null || md5sum "$W20/.qroky/telegram/profile.conf" 2>/dev/null | cut -d' ' -f1) || true)"
TOKEN20_MTIME_BEFORE="$(stat -f %m "$W20/.qroky/telegram.token" 2>/dev/null || stat -c %Y "$W20/.qroky/telegram.token" 2>/dev/null)"

{ echo ""; echo "--- the next tag brings dist-manifest; --apply-update («да») ---"; } >> "$T20"
mkdir -p "$OLDFW/distribution"
cp "$HERE/dist-manifest" "$OLDFW/distribution/dist-manifest"
cp "$HERE/verify.sh" "$OLDFW/distribution/verify.sh"
git -C "$OLDFW" -c user.email=dryrun@qroky.local -c user.name="Qroky dry run" add -A
git -C "$OLDFW" -c user.email=dryrun@qroky.local -c user.name="Qroky dry run" commit -q -m "the manifest era begins"
git -C "$OLDFW" -c user.email=dryrun@qroky.local -c user.name="Qroky dry run" tag -a v0.4.0 -m $'v0.4.0\n\nsparse era\nfactory history stops shipping\nnothing else changes'
SENT_BEFORE_20=$(wc -l < "$TG_SENT_LOG" | tr -d ' ')
OUT20U="$(run_install "$W20" $'да\n' --apply-update)"
STATUS20U=$?
echo "$OUT20U" >> "$T20"
SENT_AFTER_20=$(wc -l < "$TG_SENT_LOG" | tr -d ' ')
TAG20=$(grep -c '"framework_tag": "v0.4.0"' "$W20/install-state.json" || true)
FAT_AFTER=$(find "$W20/framework" \( -name 'TASKS.md' -o -path '*/products/*' \) -type f ! -path '*/.git/*' 2>/dev/null | wc -l | tr -d ' ')
RUNTIME20=0; [[ -f "$W20/framework/runtime/claude/telegram/listener.sh" ]] && RUNTIME20=1
CHAT20_AFTER="$(cat "$W20/.qroky/telegram/state/chat_id" 2>/dev/null || true)"
PROFILE20_AFTER="$( (md5 -q "$W20/.qroky/telegram/profile.conf" 2>/dev/null || md5sum "$W20/.qroky/telegram/profile.conf" 2>/dev/null | cut -d' ' -f1) || true)"
TOKEN20_MTIME_AFTER="$(stat -f %m "$W20/.qroky/telegram.token" 2>/dev/null || stat -c %Y "$W20/.qroky/telegram.token" 2>/dev/null)"
REASKED20=$(printf '%s' "$OUT20U" | grep -c "Which language do you want to use?\|Step . of" || true)
OUT20V="$(bash "$HERE/verify.sh" "$W20/framework" 2>&1)"; STATUS20V=$?
{ echo ""; echo "--- freeze check after migration ---"; echo "$OUT20V"; } >> "$T20"
{
  echo ""
  echo "--- assertions ---"
  echo "old install: exit $STATUS20A (0); fat instance proven (junk vendored, non-vacuous): $FAT_BEFORE (1); bound chat: ${CHAT20_BEFORE:-none}"
  echo "update: exit $STATUS20U (0), tag now v0.4.0: $TAG20 (1); junk left in framework after update (must be 0): $FAT_AFTER; runtime alive: $RUNTIME20 (1)"
  echo "binding intact: chat $([[ -n "$CHAT20_BEFORE" && "$CHAT20_BEFORE" == "$CHAT20_AFTER" ]] && echo stable || echo BROKEN); profile md5 $([[ -n "$PROFILE20_BEFORE" && "$PROFILE20_BEFORE" == "$PROFILE20_AFTER" ]] && echo stable || echo BROKEN); token mtime $([[ -n "$TOKEN20_MTIME_BEFORE" && "$TOKEN20_MTIME_BEFORE" == "$TOKEN20_MTIME_AFTER" ]] && echo stable || echo BROKEN)"
  echo "silent: interview lines in the update output (must be 0): $REASKED20; extra telegram sends during update (must be 0): $((SENT_AFTER_20 - SENT_BEFORE_20))"
  echo "freeze check after migration: exit $STATUS20V (0)"
} >> "$T20"
if [[ $STATUS20A -eq 0 && $FAT_BEFORE -eq 1 && -n "$CHAT20_BEFORE" \
      && $STATUS20U -eq 0 && "$TAG20" -eq 1 && "$FAT_AFTER" -eq 0 && $RUNTIME20 -eq 1 \
      && "$CHAT20_BEFORE" == "$CHAT20_AFTER" && "$PROFILE20_BEFORE" == "$PROFILE20_AFTER" \
      && "$TOKEN20_MTIME_BEFORE" == "$TOKEN20_MTIME_AFTER" \
      && "$REASKED20" -eq 0 && $((SENT_AFTER_20 - SENT_BEFORE_20)) -eq 0 && $STATUS20V -eq 0 ]]; then
  record "20-silent-migration" PASS "fat v0.3.x instance (junk vendored, non-vacuous) updated to the manifest release with one «да»: factory history shed, runtime alive, chat binding + profile + token byte-stable, zero interview lines, zero extra sends, freeze check green"
else
  record "20-silent-migration" FAIL "inst=$STATUS20A fat=$FAT_BEFORE chat=$CHAT20_BEFORE upd=$STATUS20U tag=$TAG20 fat_after=$FAT_AFTER runtime=$RUNTIME20 chat_stable=$([[ "$CHAT20_BEFORE" == "$CHAT20_AFTER" ]] && echo y || echo N) profile=$([[ "$PROFILE20_BEFORE" == "$PROFILE20_AFTER" ]] && echo y || echo N) token=$([[ "$TOKEN20_MTIME_BEFORE" == "$TOKEN20_MTIME_AFTER" ]] && echo y || echo N) reask=$REASKED20 sends=$((SENT_AFTER_20 - SENT_BEFORE_20)) freeze=$STATUS20V"
fi

# ---------------------------------------------------------------------------
# SCENARIO 21 — ATOM-130 bootstrap: qroky.sh install | update | uninstall,
# each run from a DIFFERENT arbitrary folder, never from a clone. Install
# keeps its own kit copy under ~/.qroky/kit; uninstall finds the install by
# the MACHINE TRACE (~/.qroky/workdir), with no env hint and no clone path.
# Own fake HOME (uninstall removes ~/.qroky wholesale). Pre-130: qroky.sh
# does not exist — the whole scenario fails.
# ---------------------------------------------------------------------------
T21="$ATOM_WORKSPACE/scenario-21-bootstrap.txt"
W21="$SANDBOX/w21"
HOME_G="$SANDBOX/home-g"; mkdir -p "$HOME_G"
cp "$FAKE_HOME/.gitconfig" "$HOME_G/" 2>/dev/null || true
KITFW="$SANDBOX/fake-kit-origin"
mkdir -p "$KITFW/distribution"
cp "$HERE/../qroky.sh" "$KITFW/qroky.sh"
cp "$HERE/install.sh" "$HERE/dist-manifest" "$HERE/verify.sh" "$KITFW/distribution/"
cp -R "$HERE/lang" "$KITFW/distribution/lang"
git -C "$KITFW" init -q
git -C "$KITFW" -c user.email=dryrun@qroky.local -c user.name="Qroky dry run" add -A
git -C "$KITFW" -c user.email=dryrun@qroky.local -c user.name="Qroky dry run" commit -q -m "kit stub"
git -C "$KITFW" -c user.email=dryrun@qroky.local -c user.name="Qroky dry run" tag -a v0.4.0 -m "kit v0.4.0"
DOWNLOADED="$SANDBOX/downloads/qroky.sh"
mkdir -p "$SANDBOX/downloads" "$SANDBOX/neutral-a" "$SANDBOX/neutral-b" "$SANDBOX/neutral-c"
cp "$HERE/../qroky.sh" "$DOWNLOADED"   # simulates «curl -O qroky.sh»
{
  echo "Scenario 21 — bootstrap qroky.sh: install/update/uninstall from anywhere"
  echo "Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo ""
  echo "--- install (run from a neutral folder, script only «downloaded») ---"
} > "$T21"
OUT21A="$( ( cd "$SANDBOX/neutral-a" && export HOME="$HOME_G" QROKY_KIT_SOURCE="$KITFW" QROKY_WORKSPACE_DIR="$W21"; \
  printf 'en\n\nn\nn\nn\nn\n' | bash "$DOWNLOADED" install ) 2>&1)"
STATUS21A=$?
echo "$OUT21A" >> "$T21"
KIT_CLONED=0; [[ -f "$HOME_G/.qroky/kit/distribution/install.sh" ]] && KIT_CLONED=1
KIT_AT_TAG="$(git -C "$HOME_G/.qroky/kit" describe --tags 2>/dev/null || true)"
STATE21=$(grep -c '"step_machinewide": "done"' "$W21/install-state.json" 2>/dev/null || true)
TRACE21="$(cat "$HOME_G/.qroky/workdir" 2>/dev/null || true)"
SPARSE21=$(find "$W21/framework" \( -name 'TASKS.md' -o -path '*/products/*' \) -type f ! -path '*/.git/*' 2>/dev/null | wc -l | tr -d ' ')

{ echo ""; echo "--- update (new framework tag; run from a second neutral folder, NO workdir env) ---"; } >> "$T21"
git -C "$FAKE_FW" -c user.email=dryrun@qroky.local -c user.name="Qroky dry run" commit -q --allow-empty -m "stub commit 7"
git -C "$FAKE_FW" -c user.email=dryrun@qroky.local -c user.name="Qroky dry run" tag -a v1.6.0 -m $'v1.6.0\n\nbootstrap-era stub\nsecond line\nthird line'
OUT21U="$( ( cd "$SANDBOX/neutral-b" && export HOME="$HOME_G" QROKY_KIT_SOURCE="$KITFW"; \
  printf 'да\n' | bash "$DOWNLOADED" update ) 2>&1)"
STATUS21U=$?
echo "$OUT21U" >> "$T21"
TAG21=$(grep -c '"framework_tag": "v1.6.0"' "$W21/install-state.json" 2>/dev/null || true)

{ echo ""; echo "--- uninstall (third neutral folder, machine trace ONLY — no env, no clone path) ---"; } >> "$T21"
# force the machine-trace path: kill the kit clone's own pointer first, as
# if the kit copy were fresh — resolution MUST go through ~/.qroky/workdir
rm -f "$HOME_G/.qroky/kit/distribution/.qroky-workdir-pointer"
OUT21X="$( ( cd "$SANDBOX/neutral-c" && export HOME="$HOME_G" QROKY_KIT_SOURCE="$KITFW"; \
  bash "$DOWNLOADED" uninstall ) 2>&1)"
STATUS21X=$?
echo "$OUT21X" >> "$T21"
STATE21_GONE=0; [[ -f "$W21/install-state.json" ]] || STATE21_GONE=1
QROKY_DIR_GONE=0; [[ -d "$HOME_G/.qroky" ]] || QROKY_DIR_GONE=1
WORKDIR_KEPT21=0; [[ -d "$W21/decisions" ]] && WORKDIR_KEPT21=1
UNSUMMARY21=$(printf '%s' "$OUT21X" | grep -c "Done. Removed:" || true)

{ echo ""; echo "--- uninstall again on the clean machine (polite no-op) ---"; } >> "$T21"
OUT21N="$( ( cd "$SANDBOX/neutral-c" && export HOME="$HOME_G" QROKY_KIT_SOURCE="$KITFW"; \
  bash "$DOWNLOADED" uninstall ) 2>&1)"
STATUS21N=$?
echo "$OUT21N" >> "$T21"
NOOP21=$(printf '%s' "$OUT21N" | grep -c "Nothing to remove" || true)
{
  echo ""
  echo "--- assertions ---"
  echo "install: exit $STATUS21A (0); kit copy cloned: $KIT_CLONED (1) at tag: ${KIT_AT_TAG:-none} (v0.4.0); install complete: $STATE21 (1); machine trace -> $TRACE21 (== $W21); sparse (junk files): $SPARSE21 (0)"
  echo "update: exit $STATUS21U (0); framework now v1.6.0: $TAG21 (1)"
  echo "uninstall: exit $STATUS21X (0); state gone: $STATE21_GONE (1); ~/.qroky gone: $QROKY_DIR_GONE (1); workdir kept: $WORKDIR_KEPT21 (1); summary shown: $UNSUMMARY21 (1)"
  echo "clean-machine uninstall: exit $STATUS21N (0), polite: $NOOP21 (1)"
} >> "$T21"
if [[ $STATUS21A -eq 0 && $KIT_CLONED -eq 1 && "$KIT_AT_TAG" == "v0.4.0" && "$STATE21" -eq 1 \
      && "$TRACE21" == "$W21" && "$SPARSE21" -eq 0 \
      && $STATUS21U -eq 0 && "$TAG21" -eq 1 \
      && $STATUS21X -eq 0 && $STATE21_GONE -eq 1 && $QROKY_DIR_GONE -eq 1 && $WORKDIR_KEPT21 -eq 1 && "$UNSUMMARY21" -eq 1 \
      && $STATUS21N -eq 0 && "$NOOP21" -eq 1 ]]; then
  record "21-bootstrap" PASS "qroky.sh from arbitrary folders: install cloned the kit to ~/.qroky/kit at the release tag and completed sparse; update applied the new tag with no workdir hint; uninstall found the install by the machine trace alone, removed the machine side, kept the workdir; second uninstall = polite no-op"
else
  record "21-bootstrap" FAIL "inst=$STATUS21A/$KIT_CLONED/$KIT_AT_TAG/$STATE21 trace=$TRACE21 sparse=$SPARSE21 upd=$STATUS21U/$TAG21 un=$STATUS21X/$STATE21_GONE/$QROKY_DIR_GONE/$WORKDIR_KEPT21/$UNSUMMARY21 noop=$STATUS21N/$NOOP21"
fi

# ---------------------------------------------------------------------------
# SCENARIO 22 — ATOM-131 (INFO-044): the `qroky` command on PATH.
# (a) CURL-MODE install: qroky.sh runs through PROCESS SUBSTITUTION (no
#     file path, $0=/dev/fd/N, empty neutral cwd, no clone anywhere near) —
#     the launcher lands at ~/.local/bin/qroky (executable, OUR provenance)
#     with exactly ONE PATH marker block, and the finale names both plus
#     the new-terminal honesty line;
# (b) the launcher itself relays to the kit's qroky.sh;
# (c) DoD 6 backfill: a «pre-131» machine (launcher + PATH block stripped)
#     gets both back on its next `update`, announced;
# (d) uninstall honors provenance: a FOREIGN file at ~/.local/bin/qroky
#     stays (and is said to be foreign) while the marker block goes and a
#     foreign profile line survives; OUR launcher is removed (round 2, via
#     the workdir's VENDORED installer — kit copy already gone); a third
#     uninstall with no launcher at all is a polite no-op.
# Mutation-falsifiable: pre-131 code writes no launcher — (a) fails whole;
# with a broken kit resolve the relay (b) fails; without the apply-update
# hook (c) fails; without provenance checks (d) fails.
# ---------------------------------------------------------------------------
T22="$ATOM_WORKSPACE/scenario-22-qroky-command.txt"
W22="$SANDBOX/w22"
HOME_H="$SANDBOX/home-h"; mkdir -p "$HOME_H" "$SANDBOX/neutral-d"
cp "$FAKE_HOME/.gitconfig" "$HOME_H/" 2>/dev/null || true
case "${SHELL:-}" in */zsh) PROF22="$HOME_H/.zshrc";; */bash) PROF22="$HOME_H/.bashrc";; *) PROF22="$HOME_H/.profile";; esac
LAUNCHER22="$HOME_H/.local/bin/qroky"
{
  echo "Scenario 22 — the qroky command on PATH (ATOM-131, INFO-044)"
  echo "Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo ""
  echo "--- (a) curl-mode install: bash <(cat qroky.sh) install, neutral cwd, no clone ---"
} > "$T22"
OUT22A="$( ( cd "$SANDBOX/neutral-d" && export HOME="$HOME_H" QROKY_KIT_SOURCE="$KITFW" QROKY_WORKSPACE_DIR="$W22"; \
  printf 'en\n\nn\nn\nn\nn\n' | bash <(cat "$DOWNLOADED") install ) 2>&1)"
STATUS22A=$?
echo "$OUT22A" >> "$T22"
LAUNCHER22_OK=0; [[ -x "$LAUNCHER22" ]] && grep -qF "INFO-044" "$LAUNCHER22" && LAUNCHER22_OK=1
PATHBLOCKS22_A=$(cat "$HOME_H/.zshrc" "$HOME_H/.zprofile" "$HOME_H/.bashrc" "$HOME_H/.bash_profile" "$HOME_H/.profile" 2>/dev/null | grep -cF '>>> qroky command' || true)
FINALE_NAMES22=$(printf '%s' "$OUT22A" | grep -c ".local/bin/qroky" || true)
FINALE_NEWTERM22=$(printf '%s' "$OUT22A" | grep -c "NEW terminal" || true)
FINALE_WORD22=$(printf '%s' "$OUT22A" | grep -c "qroky update" || true)

{ echo ""; echo "--- (b) the installed launcher relays to the kit's qroky.sh ---"; } >> "$T22"
OUT22B="$( ( cd "$SANDBOX/neutral-d" && export HOME="$HOME_H"; "$LAUNCHER22" ) 2>&1)"
STATUS22B=$?
echo "$OUT22B" >> "$T22"
RELAY22=$(printf '%s' "$OUT22B" | grep -c "one command for the whole journey" || true)

{ echo ""; echo "--- (c) DoD 6 backfill: strip launcher+PATH block (pre-131 machine), then update ---"; } >> "$T22"
rm -f "$LAUNCHER22"
grep -vF "qroky command" "$PROF22" > "$PROF22.tmp" && mv "$PROF22.tmp" "$PROF22"
git -C "$FAKE_FW" -c user.email=dryrun@qroky.local -c user.name="Qroky dry run" commit -q --allow-empty -m "stub commit 8"
git -C "$FAKE_FW" -c user.email=dryrun@qroky.local -c user.name="Qroky dry run" tag -a v1.7.0 -m $'v1.7.0\n\nlauncher-era stub\nsecond line\nthird line'
OUT22C="$( ( cd "$SANDBOX/neutral-d" && export HOME="$HOME_H" QROKY_KIT_SOURCE="$KITFW"; \
  printf 'yes\n' | bash "$DOWNLOADED" update ) 2>&1)"
STATUS22C=$?
echo "$OUT22C" >> "$T22"
BACKFILL22_OK=0; [[ -x "$LAUNCHER22" ]] && grep -qF "INFO-044" "$LAUNCHER22" && BACKFILL22_OK=1
PATHBLOCKS22_C=$(cat "$HOME_H/.zshrc" "$HOME_H/.zprofile" "$HOME_H/.bashrc" "$HOME_H/.bash_profile" "$HOME_H/.profile" 2>/dev/null | grep -cF '>>> qroky command' || true)
ANNOUNCED22=$(printf '%s' "$OUT22C" | grep -c "one word works from anywhere" || true)
TAG22=$(grep -c '"framework_tag": "v1.7.0"' "$W22/install-state.json" 2>/dev/null || true)
cp "$LAUNCHER22" "$SANDBOX/saved-launcher-22"

{ echo ""; echo "--- (d) round 1: FOREIGN launcher + foreign profile line survive the uninstall ---"; } >> "$T22"
printf 'export MY_OWN_LINE=1  # user rule, must survive\n' >> "$PROF22"
printf '#!/bin/sh\n# somebody else installed a different qroky — no kit provenance\nexit 0\n' > "$LAUNCHER22"
chmod +x "$LAUNCHER22"
OUT22D="$( ( cd "$SANDBOX/neutral-d" && export HOME="$HOME_H" QROKY_KIT_SOURCE="$KITFW"; \
  bash "$DOWNLOADED" uninstall ) 2>&1)"
STATUS22D=$?
echo "$OUT22D" >> "$T22"
FOREIGN22_KEPT=0; [[ -f "$LAUNCHER22" ]] && grep -q "somebody else" "$LAUNCHER22" && FOREIGN22_KEPT=1
FOREIGN22_SAID=$(printf '%s' "$OUT22D" | grep -c "not ours to delete" || true)
PATHBLOCKS22_D=$(cat "$HOME_H/.zshrc" "$HOME_H/.zprofile" "$HOME_H/.bashrc" "$HOME_H/.bash_profile" "$HOME_H/.profile" 2>/dev/null | grep -cF '>>> qroky command' || true)
USERLINE22=$(grep -c "MY_OWN_LINE" "$PROF22" 2>/dev/null || true)
STATE22_GONE=0; [[ -f "$W22/install-state.json" ]] || STATE22_GONE=1

{ echo ""; echo "--- (d) round 2: OUR launcher back, marker block back — removed via the VENDORED installer (kit copy is gone) ---"; } >> "$T22"
cp "$SANDBOX/saved-launcher-22" "$LAUNCHER22"; chmod +x "$LAUNCHER22"
{ printf '\n# >>> qroky command (added by the Qroky installer, INFO-044; removed by `qroky uninstall`) >>>\n'
  printf 'export PATH="$HOME/.local/bin:$PATH"\n'
  printf '# <<< qroky command <<<\n'; } >> "$PROF22"
OUT22E="$( ( cd "$SANDBOX/neutral-d" && export HOME="$HOME_H" QROKY_KIT_SOURCE="$KITFW" QROKY_WORKSPACE_DIR="$W22"; \
  bash "$DOWNLOADED" uninstall ) 2>&1)"
STATUS22E=$?
echo "$OUT22E" >> "$T22"
OURS22_GONE=0; [[ -f "$LAUNCHER22" ]] || OURS22_GONE=1
PATHBLOCKS22_E=$(cat "$HOME_H/.zshrc" "$HOME_H/.zprofile" "$HOME_H/.bashrc" "$HOME_H/.bash_profile" "$HOME_H/.profile" 2>/dev/null | grep -cF '>>> qroky command' || true)
USERLINE22_E=$(grep -c "MY_OWN_LINE" "$PROF22" 2>/dev/null || true)
REMOVAL22_LISTED=$(printf '%s' "$OUT22E" | grep -c ".local/bin/qroky" || true)

{ echo ""; echo "--- (d) round 3: no launcher at all — polite no-op ---"; } >> "$T22"
OUT22F="$( ( cd "$SANDBOX/neutral-d" && export HOME="$HOME_H" QROKY_KIT_SOURCE="$KITFW" QROKY_WORKSPACE_DIR="$W22"; \
  bash "$DOWNLOADED" uninstall ) 2>&1)"
STATUS22F=$?
echo "$OUT22F" >> "$T22"
NOOP22=$(printf '%s' "$OUT22F" | grep -c "Nothing to remove" || true)
{
  echo ""
  echo "--- assertions ---"
  echo "(a) curl-mode install: exit $STATUS22A (0); launcher executable+provenance: $LAUNCHER22_OK (1); PATH blocks: $PATHBLOCKS22_A (1); finale names ~/.local/bin/qroky: $FINALE_NAMES22 (>=1), NEW-terminal honesty: $FINALE_NEWTERM22 (>=1), the word itself: $FINALE_WORD22 (>=1)"
  echo "(b) relay: exit $STATUS22B (2 = help), kit qroky.sh spoke: $RELAY22 (>=1)"
  echo "(c) backfill on update: exit $STATUS22C (0); launcher back: $BACKFILL22_OK (1); PATH blocks: $PATHBLOCKS22_C (1); announced: $ANNOUNCED22 (>=1); tag v1.7.0: $TAG22 (1)"
  echo "(d1) foreign launcher kept: $FOREIGN22_KEPT (1), said foreign: $FOREIGN22_SAID (>=1); PATH blocks after uninstall: $PATHBLOCKS22_D (0); user profile line kept: $USERLINE22 (1); state gone: $STATE22_GONE (1); exit $STATUS22D (0)"
  echo "(d2) OUR launcher removed via vendored installer: $OURS22_GONE (1); PATH blocks: $PATHBLOCKS22_E (0); user line still kept: $USERLINE22_E (1); removal listed the launcher: $REMOVAL22_LISTED (>=1); exit $STATUS22E (0)"
  echo "(d3) no-launcher uninstall: exit $STATUS22F (0), polite no-op: $NOOP22 (>=1)"
} >> "$T22"
if [[ $STATUS22A -eq 0 && $LAUNCHER22_OK -eq 1 && "$PATHBLOCKS22_A" -eq 1 \
      && "$FINALE_NAMES22" -ge 1 && "$FINALE_NEWTERM22" -ge 1 && "$FINALE_WORD22" -ge 1 \
      && $STATUS22B -eq 2 && "$RELAY22" -ge 1 \
      && $STATUS22C -eq 0 && $BACKFILL22_OK -eq 1 && "$PATHBLOCKS22_C" -eq 1 && "$ANNOUNCED22" -ge 1 && "$TAG22" -eq 1 \
      && $STATUS22D -eq 0 && $FOREIGN22_KEPT -eq 1 && "$FOREIGN22_SAID" -ge 1 && "$PATHBLOCKS22_D" -eq 0 && "$USERLINE22" -eq 1 && $STATE22_GONE -eq 1 \
      && $STATUS22E -eq 0 && $OURS22_GONE -eq 1 && "$PATHBLOCKS22_E" -eq 0 && "$USERLINE22_E" -eq 1 && "$REMOVAL22_LISTED" -ge 1 \
      && $STATUS22F -eq 0 && "$NOOP22" -ge 1 ]]; then
  record "22-qroky-command" PASS "curl-mode (process substitution, neutral cwd) install put the qroky command on PATH (launcher with provenance + exactly one marker block, finale names both + new-terminal honesty); the launcher relays to the kit; a pre-131 machine got it back on its next update, announced; uninstall kept a FOREIGN launcher and a user profile line, removed OURS (via the vendored installer, kit copy gone) and the marker block; no-launcher uninstall = polite no-op"
else
  record "22-qroky-command" FAIL "a=$STATUS22A/$LAUNCHER22_OK/$PATHBLOCKS22_A finale=$FINALE_NAMES22/$FINALE_NEWTERM22/$FINALE_WORD22 relay=$STATUS22B/$RELAY22 c=$STATUS22C/$BACKFILL22_OK/$PATHBLOCKS22_C/$ANNOUNCED22/$TAG22 d1=$STATUS22D/$FOREIGN22_KEPT/$FOREIGN22_SAID/$PATHBLOCKS22_D/$USERLINE22/$STATE22_GONE d2=$STATUS22E/$OURS22_GONE/$PATHBLOCKS22_E/$USERLINE22_E/$REMOVAL22_LISTED d3=$STATUS22F/$NOOP22"
fi

# ---------------------------------------------------------------------------
# SUMMARY
# ---------------------------------------------------------------------------
SUMMARY="$ATOM_WORKSPACE/SUMMARY.txt"
{
  echo "dry-run.sh — summary of all scenarios"
  echo "Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "Sandbox: $SANDBOX (removed on exit)"
  echo ""
  for line in "${SUMMARY_LINES[@]}"; do echo "$line"; done
  echo ""
  echo "Totals: $PASS_COUNT passed, $FAIL_COUNT failed"
} > "$SUMMARY"

cat "$SUMMARY"
if [[ "$FAIL_COUNT" -gt 0 ]]; then
  exit 1
fi
exit 0
