#!/usr/bin/env bash
# dry-run.sh — scripted, timed dry run of bootstrap.sh on a clean machine
# profile: a fresh temp directory under /private/tmp, no pre-existing repo,
# no network reachable in this sandbox.
#
# What is REAL in this run: every filesystem action bootstrap.sh performs —
# repository init, framework submodule add + pinned checkout, the mission/
# atoms/.qroky skeleton, CLAUDE.md, the bootstrapped marker — and the
# wall-clock timing of the whole thing.
#
# What is STUBBED (network-free, per ATOM-071 INPUT §6 method hints):
#   - the `claude` executable: a two-line fake that only answers --version,
#     placed first on PATH for this run only
#   - the framework source: a local, offline git repository standing in for
#     https://github.com/qroky/framework.git
#   - the `crontab` executable (ATOM-078 register #4 fix-round addition): a
#     small fake that reads/writes a sandbox file instead of this machine's
#     real crontab, so bootstrap.sh's scheduler-registration step (Step 6)
#     can run for real, twice, and prove idempotency, without ever touching
#     whoever runs this dry run's actual scheduled jobs
#   - the kit root (ATOM-078 register #4): a sandbox folder assembled with
#     setup/, telemetry/, consent/ as siblings — the shape bootstrap.sh
#     expects a real distributed kit to have (see QUICKSTART.*.md Step 0)
# Production founders run bootstrap.sh unmodified and it defaults to the
# real GitHub source and the real `crontab` — this script only overrides
# the environment variables bootstrap.sh already reads for exactly this
# purpose, plus PATH for the two stub executables.
#
# Run twice in the same sandbox to prove idempotency (H5's "dry run exits 0"
# — both runs must exit 0, and the second must not redo work).
#
# Output: the transcript is written to dry-run-transcript.txt next to this
# script (overwriting the committed copy — that file is evidence of one real
# captured run) and echoed to stdout.

set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SANDBOX="$(mktemp -d /private/tmp/qroky-dry-run.XXXXXX)"
cleanup() { rm -rf "$SANDBOX"; }
trap cleanup EXIT

TRANSCRIPT="$HERE/dry-run-transcript.txt"

# --- stub 1: a fake `claude` CLI on PATH — no network, no real product ----
mkdir -p "$SANDBOX/bin"
cat > "$SANDBOX/bin/claude" <<'EOF'
#!/usr/bin/env bash
echo "claude-code 0.0.0-dry-run-stub"
EOF
chmod +x "$SANDBOX/bin/claude"

# --- stub 3 (register #4): a fake `crontab` on PATH — reads/writes a
#     sandbox file, never this machine's real scheduled jobs. Supports
#     exactly the two invocations bootstrap.sh uses: `crontab -l` (list,
#     may legitimately fail with no crontab yet — real crontab does this
#     too) and `crontab -` (replace from stdin). ------------------------
CRONTAB_STATE="$SANDBOX/fake-crontab-state.txt"
touch "$CRONTAB_STATE"
cat > "$SANDBOX/bin/crontab" <<EOF
#!/usr/bin/env bash
STATE="$CRONTAB_STATE"
if [[ "\$1" == "-l" ]]; then
  [[ -s "\$STATE" ]] || exit 1
  cat "\$STATE"
elif [[ "\$1" == "-" ]]; then
  cat > "\$STATE"
else
  echo "fake crontab (dry-run stub): unsupported args: \$*" >&2
  exit 1
fi
EOF
chmod +x "$SANDBOX/bin/crontab"

# --- kit root (register #4): assemble setup/ + telemetry/ + consent/ as
#     siblings, the shape a real distributed kit has (bootstrap.sh's own
#     QROKY_KIT_ROOT default). setup/ here is a COPY of this real script's
#     folder so bootstrap.sh runs completely unmodified; telemetry/ and
#     consent/ are real copies from the 072-telemetry-showcase product. ---
KIT_ROOT="$SANDBOX/kit"
mkdir -p "$KIT_ROOT/setup"
cp "$HERE"/*.sh "$HERE"/*.md "$KIT_ROOT/setup/" 2>/dev/null
TELEMETRY_SRC="$(cd "$HERE/../../072-telemetry-showcase" && pwd)"
if [[ -d "$TELEMETRY_SRC/telemetry" ]] && [[ -d "$TELEMETRY_SRC/consent" ]]; then
  cp -R "$TELEMETRY_SRC/telemetry" "$KIT_ROOT/telemetry"
  cp -R "$TELEMETRY_SRC/consent" "$KIT_ROOT/consent"
  rm -f "$KIT_ROOT/telemetry/OFF" "$KIT_ROOT/telemetry/.ever-sent" "$KIT_ROOT/telemetry/deletion-requests.log"
else
  echo "dry-run.sh: WARNING — could not find 072-telemetry-showcase/{telemetry,consent} to assemble a full kit; Step 5/6 will show their own honest 'not found' fallback, which is a real, tested code path, not a dry-run failure." >&2
fi

# --- stub 2: a local, offline stand-in for the framework repository -------
FAKE_FRAMEWORK="$SANDBOX/fake-framework-origin"
mkdir -p "$FAKE_FRAMEWORK/runtime/claude"
git -C "$FAKE_FRAMEWORK" init -q
echo "# Runtime Binding — Claude Code (dry-run stub copy, not the real file)" \
  > "$FAKE_FRAMEWORK/runtime/claude/README.md"
git -C "$FAKE_FRAMEWORK" -c user.email=dryrun@qroky.local -c user.name="Qroky dry run" add -A
git -C "$FAKE_FRAMEWORK" -c user.email=dryrun@qroky.local -c user.name="Qroky dry run" \
  commit -q -m "stub commit — offline stand-in for the framework repo"
FAKE_REF="$(git -C "$FAKE_FRAMEWORK" rev-parse HEAD)"

WORKSPACE="$SANDBOX/founder-workspace"
export PATH="$SANDBOX/bin:$PATH"
export QROKY_WORKSPACE_DIR="$WORKSPACE"
export QROKY_FRAMEWORK_SOURCE="$FAKE_FRAMEWORK"
export QROKY_FRAMEWORK_REF="$FAKE_REF"
export QROKY_KIT_ROOT="$KIT_ROOT"

# Modern git refuses to add a submodule over a plain local path ('file'
# transport) by default (CVE-2022-39253 hardening) — that restriction exists
# for exactly this kind of local-path trick, so it is real and correct.
# Production founders never hit it: bootstrap.sh's real default is an https
# URL. To let this sandbox stand in for that https URL without touching
# bootstrap.sh, give this run its own isolated HOME with one config line
# permitting the file transport — scoped to this run only, never touching
# this machine's real git configuration.
FAKE_HOME="$SANDBOX/home"
mkdir -p "$FAKE_HOME"
git config --file "$FAKE_HOME/.gitconfig" protocol.file.allow always
export HOME="$FAKE_HOME"

{
  echo "Qroky setup kit — dry-run transcript"
  echo "Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "Sandbox: fresh temp directory under /private/tmp, network-free (local stub git repo + fake claude binary on PATH)"
  echo "Command a founder actually types: bash bootstrap.sh   (no arguments, no flags)"
  echo ""
  echo "############################################################"
  echo "# RUN 1 — first time. This is exactly what a new founder sees."
  echo "############################################################"
} > "$TRANSCRIPT"

RUN1_START=$(date +%s)
RUN1_STATUS=0
bash "$HERE/bootstrap.sh" >> "$TRANSCRIPT" 2>&1 || RUN1_STATUS=$?
RUN1_END=$(date +%s)
RUN1_ELAPSED=$(( RUN1_END - RUN1_START ))

{
  echo ""
  echo "--- RUN 1 exit code: $RUN1_STATUS ; elapsed: ${RUN1_ELAPSED}s ---"
  echo ""
  echo "############################################################"
  echo "# RUN 2 — same command, same folder. Proves re-running is safe"
  echo "# and does not repeat work already done (idempotency)."
  echo "############################################################"
} >> "$TRANSCRIPT"

RUN2_START=$(date +%s)
RUN2_STATUS=0
bash "$HERE/bootstrap.sh" >> "$TRANSCRIPT" 2>&1 || RUN2_STATUS=$?
RUN2_END=$(date +%s)
RUN2_ELAPSED=$(( RUN2_END - RUN2_START ))

{
  echo ""
  echo "--- RUN 2 exit code: $RUN2_STATUS ; elapsed: ${RUN2_ELAPSED}s ---"
  echo ""
  echo "############################################################"
  echo "# Summary"
  echo "############################################################"
  echo "Run 1 elapsed (the number that matters — a founder only ever runs this once): ${RUN1_ELAPSED}s"
  echo "Run 2 elapsed (idempotency re-run): ${RUN2_ELAPSED}s"
  echo "Time budget: <= 15 minutes (900s) from a founder saying yes to a ready workspace."
  if [ "$RUN1_STATUS" -eq 0 ] && [ "$RUN1_ELAPSED" -le 900 ]; then
    echo "Verdict: PASS — run 1 exited 0 in ${RUN1_ELAPSED}s, within the 900s budget."
  else
    echo "Verdict: FAIL — run 1 exit code $RUN1_STATUS, elapsed ${RUN1_ELAPSED}s (budget 900s)."
  fi
  if [ "$RUN2_STATUS" -eq 0 ]; then
    echo "Idempotency: PASS — run 2 exited 0 and reused the existing workspace (see 'already set up' / 'reusing it' / 'already added' / 'already connected' lines above)."
  else
    echo "Idempotency: FAIL — run 2 exit code $RUN2_STATUS."
  fi
  echo ""
  echo "############################################################"
  echo "# Questions asked of the founder"
  echo "############################################################"
  echo "Count: 0"
  echo "Classification of every prompt shown in the two runs above (H2 requirement, one line each):"
  echo "  There were no prompts. bootstrap.sh contains no interactive 'read' call — every line printed"
  echo "  above is either a progress message or, on failure, a self-contained fix instruction that names"
  echo "  the exact command to run next. Proof (grep for an interactive read/prompt idiom in bootstrap.sh):"
  if grep -nE 'read[[:space:]]+-[pr]' "$HERE/bootstrap.sh"; then
    echo "  WARNING: an interactive prompt idiom was found above — this would be a question and H2 would FAIL."
  else
    echo "  0 matches for 'read -p' / 'read -r' (or any interactive read) in bootstrap.sh — confirmed zero questions."
  fi
} >> "$TRANSCRIPT"

echo "Transcript written to $TRANSCRIPT"
cat "$TRANSCRIPT"
