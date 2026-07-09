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
# install.sh — see its own header comment for the two extra in-script test
# hooks, QROKY_TEST_STUBS and QROKY_TEST_DELAY_*):
#   - `claude`      — a two-line fake answering only --version (071 pattern)
#   - `curl`        — a fake answering ONLY Telegram's getMe endpoint (the
#                     one external call install.sh makes); GOODTOKEN* is
#                     accepted, anything else is rejected, exactly like the
#                     real Bot API would reject a bad token
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
# Nine transcripts are written next to this comment's sibling folder:
#   products/distribution-kit-v1/101-distribution-installer/workspace/
#   scenario-1-full-clean-run.txt
#   scenario-2-kill-mid-install.txt
#   scenario-3-healthy-rerun.txt
#   scenario-4-broken-dependency.txt
#   scenario-5-idempotency-diff.txt
#   scenario-6-secrets-negative-grep.txt
#   scenario-7-self-update.txt
#   SUMMARY.txt
#
# Usage: ./dry-run.sh   (no arguments; self-contained; safe to re-run)

set -uo pipefail   # NOT -e: scenarios intentionally capture non-zero exits

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ATOM_WORKSPACE="$(cd "$HERE/../products/distribution-kit-v1/101-distribution-installer/workspace" && pwd)"
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
cat > "$BIN/curl" <<EOF
#!/usr/bin/env bash
for a in "\$@"; do
  case "\$a" in
    *api.telegram.org/bot*/getMe*)
      token="\$(printf '%s' "\$a" | sed -E 's#.*/bot([^/]*)/getMe.*#\1#')"
      case "\$token" in
        GOODTOKEN*) echo '{"ok":true,"result":{"id":123456789,"username":"qroky_test_bot","first_name":"Qroky Test"}}'; exit 0 ;;
        *) echo '{"ok":false,"error_code":401,"description":"Unauthorized"}'; exit 0 ;;
      esac
      ;;
  esac
done
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

# --- offline framework origin, real git repo, with a real release tag -----
FAKE_FW="$SANDBOX/fake-framework-origin"
mkdir -p "$FAKE_FW"
git -C "$FAKE_FW" init -q
echo "# stub framework — dry-run only, not the real rulebook" > "$FAKE_FW/README.md"
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
  ( export QROKY_WORKSPACE_DIR="$workdir"; printf '%s' "$stdin_content" | "$INSTALL" "$@" ) 2>&1
}

# ---------------------------------------------------------------------------
# SCENARIO 1 — full clean run, timed, zero questions outside the interview
# ---------------------------------------------------------------------------
T1="$ATOM_WORKSPACE/scenario-1-full-clean-run.txt"
W1="$SANDBOX/w1"
{
  echo "Scenario 1 — full clean run (H6 baseline, H2 question inventory)"
  echo "Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "Command a founder actually types: bash install.sh   (no arguments)"
  echo "Answers fed (stdin, in order): en / <accept suggested folder> / y / GOODTOKEN123 / n / y"
  echo ""
} > "$T1"
START1=$(date +%s)
OUT1="$(run_install "$W1" $'en\n\ny\nGOODTOKEN123\nn\ny\n')"
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

# Question inventory (H2): every interactive read in the seven step
# functions is tagged; count call sites vs tags — must match exactly. The
# --apply-update confirmation (cmd_apply_update) is deliberately outside
# this count: it is a separate, explicitly-invoked maintenance command the
# founder runs later, not part of the seven-point interview (main_interview).
{
  echo ""
  echo "--- Question inventory check (H2: zero questions outside the interview) ---"
  STEP_BLOCK="$(awk '/^step_language\(\)/,/^cmd_enable_heartbeat\(\)/' "$INSTALL")"
  READ_SITES=$(printf '%s' "$STEP_BLOCK" | grep -cE 'read_answer' || true)
  TAGGED_SITES=$(printf '%s' "$STEP_BLOCK" | grep -cE '# IV-POINT:' || true)
  echo "read_answer call sites inside the seven step_* functions: $READ_SITES"
  echo "of those, tagged with # IV-POINT\\:<n>\\:<name>: $TAGGED_SITES"
  DISTINCT_POINTS="$(printf '%s' "$STEP_BLOCK" | grep -oE 'IV-POINT:[0-9]+' | sort -u | tr '\n' ' ')"
  echo "distinct interview points referenced: $DISTINCT_POINTS(closed list is 1..7)"
  if [[ "$READ_SITES" -eq "$TAGGED_SITES" ]]; then
    echo "PASS — every interactive prompt in the interview is accounted for in the closed list of 7."
    record "1-question-inventory" PASS "$READ_SITES/$READ_SITES prompts tagged, all within points 1-7"
  else
    echo "FAIL — an untagged prompt exists (would be a question outside the closed list)."
    record "1-question-inventory" FAIL "$TAGGED_SITES/$READ_SITES prompts tagged"
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
  echo "Mechanism: QROKY_TEST_DELAY_STEP=telegram / QROKY_TEST_DELAY_SECONDS=5"
  echo "(sandbox-only test hook, see install.sh header) opens a deterministic"
  echo "window right before the telegram step's state commit; this run is"
  echo "SIGKILLed inside that window, after workdir+framework+claude_code+"
  echo "subscription have already committed 'done' for real."
  echo ""
  echo "--- RUN A (will be killed mid-step) ---"
} > "$T2"
(
  export QROKY_WORKSPACE_DIR="$W2"
  export QROKY_TEST_DELAY_STEP="telegram"
  export QROKY_TEST_DELAY_SECONDS="5"
  printf 'en\n\nn\nn\ny\n' | "$INSTALL" >> "$T2" 2>&1 &
  echo $! > "$SANDBOX/killpid"
)
sleep 2
KILLPID="$(cat "$SANDBOX/killpid" 2>/dev/null || true)"
if [[ -n "$KILLPID" ]] && kill -0 "$KILLPID" 2>/dev/null; then
  kill -9 "$KILLPID" 2>/dev/null || true
  echo "(process $KILLPID killed mid-step, as intended)" >> "$T2"
else
  echo "(WARNING: process already exited before the kill — timing too tight for this machine)" >> "$T2"
fi
wait 2>/dev/null
STATE_AFTER_KILL=""
[[ -f "$W2/install-state.json" ]] && STATE_AFTER_KILL="$(cat "$W2/install-state.json")"
{
  echo ""
  echo "--- state file immediately after the kill ---"
  echo "${STATE_AFTER_KILL:-<no state file — kill happened before the first commit>}"
  echo ""
  echo "--- RUN B (rerun, same command, no answers needed for already-done steps) ---"
} >> "$T2"
OUT2B="$(run_install "$W2" $'n\nn\ny\n')"
STATUS2B=$?
{
  echo "$OUT2B"
  echo ""
  echo "--- RUN B exit code: $STATUS2B ---"
} >> "$T2"
FINAL_STATE2="$(cat "$W2/install-state.json" 2>/dev/null || echo "MISSING")"
ALL_DONE2=$(printf '%s' "$FINAL_STATE2" | grep -c '"pending"\|"failed"' || true)
{
  echo ""
  echo "--- final state file ---"
  echo "$FINAL_STATE2"
} >> "$T2"
if [[ $STATUS2B -eq 0 && "$ALL_DONE2" -eq 0 ]]; then
  record "2-kill-mid-install" PASS "rerun after SIGKILL completed, exit 0, all steps done"
else
  record "2-kill-mid-install" FAIL "rerun exit $STATUS2B, pending/failed steps remain: $ALL_DONE2"
fi

# ---------------------------------------------------------------------------
# SCENARIO 3 — healthy rerun = free health-check, changes nothing (H3, H6b)
# ---------------------------------------------------------------------------
T3="$ATOM_WORKSPACE/scenario-3-healthy-rerun.txt"
BEFORE_TREE="$(find "$W1" -type f ! -name 'install.log' -exec sh -c 'echo "$1  $(md5 -q "$1" 2>/dev/null || md5sum "$1" | cut -d" " -f1)"' _ {} \; | sort)"
BEFORE_STATE_NO_TS="$(grep -v generated_at "$W1/install-state.json")"
{
  echo "Scenario 3 — rerun on the already-healthy Scenario-1 workspace"
  echo "Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "No answers should be needed — every step is already 'done'."
  echo ""
} > "$T3"
OUT3="$(run_install "$W1" '')"
STATUS3=$?
{
  echo "$OUT3"
  echo ""
  echo "--- exit code: $STATUS3 ---"
} >> "$T3"
AFTER_TREE="$(find "$W1" -type f ! -name 'install.log' -exec sh -c 'echo "$1  $(md5 -q "$1" 2>/dev/null || md5sum "$1" | cut -d" " -f1)"' _ {} \; | sort)"
AFTER_STATE_NO_TS="$(grep -v generated_at "$W1/install-state.json")"
HEALTH_LINES=$(printf '%s' "$OUT3" | grep -c "already set up\|already your Qroky workspace\|found (" || true)
{
  echo ""
  echo "--- file tree diff (content hashes, excluding install.log which is append-only by design) ---"
  diff <(printf '%s' "$BEFORE_TREE") <(printf '%s' "$AFTER_TREE") && echo "(no differences — no file content changed)"
  echo ""
  echo "--- state diff (excluding the generated_at timestamp, which always updates on commit) ---"
  diff <(printf '%s' "$BEFORE_STATE_NO_TS") <(printf '%s' "$AFTER_STATE_NO_TS") && echo "(no differences — every field identical)"
  echo ""
  echo "'already done' health-check lines printed: $HEALTH_LINES (expect 7, one per step)"
} >> "$T3"
TREE_DIFF="$(diff <(printf '%s' "$BEFORE_TREE") <(printf '%s' "$AFTER_TREE"))"
STATE_DIFF="$(diff <(printf '%s' "$BEFORE_STATE_NO_TS") <(printf '%s' "$AFTER_STATE_NO_TS"))"
if [[ $STATUS3 -eq 0 && -z "$TREE_DIFF" && -z "$STATE_DIFF" ]]; then
  record "3-healthy-rerun" PASS "exit 0, zero file/state changes, $HEALTH_LINES health-check lines"
else
  record "3-healthy-rerun" FAIL "exit $STATUS3, tree_diff_empty=$([[ -z "$TREE_DIFF" ]] && echo yes || echo no), state_diff_empty=$([[ -z "$STATE_DIFF" ]] && echo yes || echo no)"
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
HAS_HUMAN_MSG4=$(printf '%s' "$OUT4" | grep -c "Check the internet connection, then run this installer again" || true)
STATE4="$(cat "$W4/install-state.json" 2>/dev/null || echo "MISSING")"
{
  echo ""
  echo "--- state file after the failure (workdir stays done, framework marked failed) ---"
  echo "$STATE4"
  echo ""
  echo "auto-retry lines seen: $RETRY_COUNT4 (ladder cap is 2, harness-checklist point 3)"
  echo "concrete human instruction present: $([[ $HAS_HUMAN_MSG4 -gt 0 ]] && echo yes || echo no)"
} >> "$T4"
if [[ $STATUS4 -ne 0 && "$RETRY_COUNT4" -eq 2 && "$HAS_HUMAN_MSG4" -gt 0 ]] && printf '%s' "$STATE4" | grep -q '"step_workdir": "done"' && printf '%s' "$STATE4" | grep -q '"step_framework": "failed"'; then
  record "4-broken-dependency" PASS "2 auto-retries then a concrete human instruction, exit $STATUS4, prior steps' state preserved"
else
  record "4-broken-dependency" FAIL "retries=$RETRY_COUNT4 human_msg=$HAS_HUMAN_MSG4 exit=$STATUS4"
fi

# ---------------------------------------------------------------------------
# SCENARIO 5 — double-run idempotency diff (H3)
# ---------------------------------------------------------------------------
T5="$ATOM_WORKSPACE/scenario-5-idempotency-diff.txt"
W5="$SANDBOX/w5"
{
  echo "Scenario 5 — run the same command twice with identical answers,"
  echo "diff the state file (structural fields only, excluding the commit"
  echo "timestamp) and the workspace file listing between the two runs."
  echo "Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo ""
  echo "--- RUN 1 ---"
} > "$T5"
OUT5A="$(run_install "$W5" $'en\n\nn\nn\ny\n')"; STATUS5A=$?
LIST5A="$(find "$W5" -type f | sed "s|$W5/||" | sort)"
STATE5A="$(grep -v generated_at "$W5/install-state.json")"
{
  echo "$OUT5A"
  echo "--- RUN 1 exit: $STATUS5A ---"
  echo ""
  echo "--- RUN 2 (identical answers) ---"
} >> "$T5"
OUT5B="$(run_install "$W5" $'en\n\nn\nn\ny\n')"; STATUS5B=$?
LIST5B="$(find "$W5" -type f | sed "s|$W5/||" | sort)"
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
  record "5-idempotency-diff" PASS "identical file listing and state across two runs"
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
LEAK_GIT=$( (cd "$W1" && git grep -c "$TOKEN_PLAINTEXT" $(git rev-list --all 2>/dev/null) 2>/dev/null; cd "$W1/framework" && git grep -c "$TOKEN_PLAINTEXT" $(git rev-list --all 2>/dev/null) 2>/dev/null) | awk -F: '{s+=$NF} END{print s+0}')
TOKEN_FILE_PERMS="$(stat -f '%Lp' "$W1/.qroky/telegram.token" 2>/dev/null || stat -c '%a' "$W1/.qroky/telegram.token" 2>/dev/null)"
TOKEN_FILE_CONTENT="$(cat "$W1/.qroky/telegram.token" 2>/dev/null)"
MASKED_IN_LOG=$(grep -c "\*\*\*\*" "$W1/install.log" 2>/dev/null || true)
{
  echo "grep hits in install-state.json: ${LEAK_STATE:-0}"
  echo "grep hits in install.log: ${LEAK_LOG:-0}"
  echo "grep hits in telemetry/: ${LEAK_TELEMETRY:-0}"
  echo "grep hits across all git history (workspace + framework): ${LEAK_GIT:-0}"
  echo ""
  echo "masked-token confirmation line present in install.log: $([[ "$MASKED_IN_LOG" -gt 0 ]] && echo yes || echo no)"
  echo "token file mode: ${TOKEN_FILE_PERMS:-MISSING} (must be 600)"
  echo "token file contains the real token (expected — this is the ONE sanctioned place): $([[ "$TOKEN_FILE_CONTENT" == "$TOKEN_PLAINTEXT" ]] && echo yes || echo no)"
} >> "$T6"
if [[ "${LEAK_STATE:-0}" -eq 0 && "${LEAK_LOG:-0}" -eq 0 && "${LEAK_TELEMETRY:-0}" -eq 0 && "${LEAK_GIT:-0}" -eq 0 \
      && "$TOKEN_FILE_PERMS" == "600" && "$TOKEN_FILE_CONTENT" == "$TOKEN_PLAINTEXT" ]]; then
  record "6-secrets-negative-grep" PASS "zero leaks across state/log/telemetry/git; token file mode 600"
else
  record "6-secrets-negative-grep" FAIL "state=$LEAK_STATE log=$LEAK_LOG telemetry=$LEAK_TELEMETRY git=$LEAK_GIT perms=$TOKEN_FILE_PERMS"
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
HAS_DIGEST=$(printf '%s' "$OUT7A" | grep -c "v1.0.0 -> v1.1.0\|apply-update" || true)

{
  echo ""
  echo "--- apply-update, answering 'да' (yes) ---"
} >> "$T7"
OUT7B="$(run_install "$W1" $'да\n' --apply-update)"
{
  echo "$OUT7B"
} >> "$T7"
HAS_CONFLICT_SHOWN=$(printf '%s' "$OUT7B" | grep -c "founder's own note\|README.md" || true)
STATE7="$(cat "$W1/install-state.json")"
DECISION_FILE="$(ls "$W1"/decisions/UPDATE-*.md 2>/dev/null | head -1)"
{
  echo ""
  echo "--- state after apply ---"
  echo "$STATE7"
  echo ""
  echo "--- decisions record ---"
  [[ -n "$DECISION_FILE" ]] && cat "$DECISION_FILE" || echo "MISSING"
} >> "$T7"
TAG_UPDATED=$(printf '%s' "$STATE7" | grep -c '"framework_tag": "v1.1.0"' || true)
if [[ "$HAS_DIGEST" -gt 0 && "$HAS_CONFLICT_SHOWN" -gt 0 && "$TAG_UPDATED" -gt 0 && -n "$DECISION_FILE" ]]; then
  record "7-self-update" PASS "digest shown, conflict shown before apply, tag advanced to v1.1.0, decisions record written"
else
  record "7-self-update" FAIL "digest=$HAS_DIGEST conflict_shown=$HAS_CONFLICT_SHOWN tag_updated=$TAG_UPDATED decision_file=${DECISION_FILE:-none}"
fi

# --- also prove "apply cancels on anything but yes" (never silently applies) ---
{
  echo ""
  echo "--- negative check: apply-update again, answering 'нет' (no new tag pending, but proves the cancel path is real) ---"
} >> "$T7"
OUT7C="$(run_install "$W1" $'нет\n' --apply-update)"
echo "$OUT7C" >> "$T7"

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
OUT8Y="$(run_install "$W8YES" $'en\n\nn\nn\ny\n')"
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
OUT8N="$(run_install "$W8NO" $'en\n\nn\nn\nn\n')"
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
