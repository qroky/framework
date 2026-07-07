#!/usr/bin/env bash
# ============================================================================
# negative-test.sh — proves push.sh's whitelist and OFF switch actually work
# ============================================================================
#
# WHAT THIS PROVES (two tests, run in order):
#
#   TEST 1 — deny-by-default: builds a throwaway fake repo in a sandbox
#   under /private/tmp containing BOTH whitelisted files (STATUS.md,
#   RESULT.md, run.log, status.yaml, VERDICT.md) AND two planted files that
#   must NEVER be sent: a fake INPUT.md and a secret.txt. Runs push.sh
#   against the sandbox, then checks the staging output does not contain
#   either planted file's content anywhere.
#
#   TEST 2 — OFF switch: temporarily places telemetry/OFF next to push.sh,
#   runs push.sh again, and checks it staged and pushed nothing at all
#   (exit 0, loud message, zero files touched). The marker is removed again
#   at the end regardless of outcome, so the kit ships with telemetry ON
#   by default.
#
#   TEST 3 (ATOM-078 register #3) — filtered content mode: runs push.sh with
#   QROKY_TELEMETRY_FILTER_MODE=filtered against a VERDICT.md whose Findings
#   body contains a planted business-descriptive sentence, and checks that
#   sentence is stripped from the staged copy (only frontmatter survives).
#
#   TEST 4 (ATOM-078 register #5) — deletion on revocation: runs push.sh
#   once for real (staging something, which writes the .ever-sent marker),
#   then plants OFF and runs again, and checks a deletion request was
#   logged to deletion-requests.log.
#
# No network calls are made anywhere in this test (push.sh's own push step
# is a stub — see push.sh's push_to_remote()). Nothing outside /private/tmp
# and this script's own directory is written to (this script also cleans up
# push.sh's own state files — .ever-sent, deletion-requests.log — that
# TEST 4 deliberately causes push.sh to write next to it).
#
# Usage: ./negative-test.sh   (no arguments; self-contained)
# Author: pilot-toolsmith (ATOM-072) · Date: 2026-07-07
# Fix-round: ATOM-078 (register #3, #5) — 2026-07-07
# ============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PUSH_SH="$SCRIPT_DIR/push.sh"
OFF_FILE="$SCRIPT_DIR/OFF"
EVER_SENT_FILE="$SCRIPT_DIR/.ever-sent"
DELETION_LOG="$SCRIPT_DIR/deletion-requests.log"

SANDBOX="$(mktemp -d /private/tmp/qroky-telemetry-negtest.XXXXXX)"
FAKE_REPO="$SANDBOX/repo"
STAGING="$SANDBOX/staging"

cleanup() {
  rm -f "$OFF_FILE"          # always leave telemetry ON by default afterwards
  rm -f "$EVER_SENT_FILE" "$DELETION_LOG"   # this test's own side effects, not part of the shipped kit
  rm -rf "$SANDBOX"
}
trap cleanup EXIT

fail() {
  echo "NEGATIVE TEST FAILED: $1" >&2
  exit 1
}

echo "###################################################################"
echo "# TEST 1 — deny-by-default (planted non-whitelisted files rejected)"
echo "###################################################################"

mkdir -p "$FAKE_REPO/products/demo-product/001-demo-atom/workspace"
mkdir -p "$FAKE_REPO/products/demo-product/001-demo-atom-verify"

# --- legitimate, whitelisted files ----------------------------------------
cat > "$FAKE_REPO/products/demo-product/001-demo-atom/STATUS.md" <<'EOF'
# STATUS — ATOM-DEMO-001
2026-07-07T09:00:00Z delivered demo atom for negative-test sandbox
EOF

cat > "$FAKE_REPO/products/demo-product/001-demo-atom/RESULT.md" <<'EOF'
---
atom: ATOM-DEMO-001
product: Demo product (sandbox only)
status: delivered
maturity_claimed: draft
cost:
  units_in: 1000
  units_out: 200
  unit: tokens
  wall_time: 1m
  executor: sandbox-model
  sub_atoms_spawned: 0
---

# RESULT — ATOM-DEMO-001

## Summary
SECRET-PRODUCT-DESCRIPTION-MUST-NOT-LEAVE-THE-MACHINE: this text describes
the founder's confidential product and must NEVER appear in staged output.

## Deliverables
| File | Purpose |
| :---- | :---- |
| secret-feature.md | the founder's confidential deliverable |
EOF

cat > "$FAKE_REPO/products/demo-product/001-demo-atom/workspace/run.log" <<'EOF'
2026-07-07T09:00:00Z CYCLE-START demo atom; executor sandbox-model as demo-role
EOF

cat > "$FAKE_REPO/products/demo-product/status.yaml" <<'EOF'
product: demo-product
atoms:
  - id: ATOM-DEMO-001
    state: delivered
EOF

cat > "$FAKE_REPO/products/demo-product/001-demo-atom-verify/VERDICT.md" <<'EOF'
---
verify_atom: ATOM-DEMO-001-VERIFY
target_atom: ATOM-DEMO-001
round: 1
returns_used: 0
verdict: accept
---
# VERDICT — ATOM-DEMO-001, round 1: accept
EOF

# --- planted, non-whitelisted files (must be rejected) --------------------
cat > "$FAKE_REPO/products/demo-product/001-demo-atom/INPUT.md" <<'EOF'
PLANTED-SECRET-INPUT-TOKEN-4f9c2e: this is the founder's confidential
requirements text. If this string appears anywhere under the staging
directory, the whitelist has failed.
EOF

cat > "$FAKE_REPO/products/demo-product/001-demo-atom/secret.txt" <<'EOF'
PLANTED-SECRET-TXT-TOKEN-a17bd3: an arbitrary non-whitelisted file that
must never be read for content, let alone copied.
EOF

echo "--- running push.sh against the sandbox repo ---"
"$PUSH_SH" "$FAKE_REPO" "$STAGING"

echo ""
echo "--- checking staged output for leaked planted content ---"
leak_found=0
if grep -R "PLANTED-SECRET-INPUT-TOKEN-4f9c2e" "$STAGING" >/dev/null 2>&1; then
  echo "LEAK: planted INPUT.md content found in staging output!"
  leak_found=1
fi
if grep -R "PLANTED-SECRET-TXT-TOKEN-a17bd3" "$STAGING" >/dev/null 2>&1; then
  echo "LEAK: planted secret.txt content found in staging output!"
  leak_found=1
fi
if find "$STAGING" -name "*INPUT*" -o -name "*secret*" | grep -q .; then
  echo "LEAK: a file named after a planted file exists in staging output!"
  leak_found=1
fi
if grep -R "SECRET-PRODUCT-DESCRIPTION-MUST-NOT-LEAVE-THE-MACHINE" "$STAGING" >/dev/null 2>&1; then
  echo "LEAK: RESULT.md Summary text (business content) found in staging output — cost-block-only extraction failed!"
  leak_found=1
fi

if [[ "$leak_found" -eq 1 ]]; then
  fail "TEST 1 — one or more planted / non-whitelisted contents were found in staged output"
fi

echo "TEST 1 PASSED — no planted file, and no RESULT.md business content, reached staging."
echo ""
echo "--- staging directory contents (for the record) ---"
find "$STAGING" -type f | sed "s|$STAGING/||"

echo ""
echo "###################################################################"
echo "# TEST 2 — OFF switch (telemetry/OFF stops the script cold)"
echo "###################################################################"

OFF_STAGING="$SANDBOX/staging-off-test"
touch "$OFF_FILE"
echo "--- planted telemetry/OFF at: $OFF_FILE ---"
echo "--- running push.sh again (should do nothing) ---"

set +e
off_output="$("$PUSH_SH" "$FAKE_REPO" "$OFF_STAGING" 2>&1)"
off_exit=$?
set -e
echo "$off_output"

if [[ $off_exit -ne 0 ]]; then
  fail "TEST 2 — push.sh exited non-zero ($off_exit) while OFF; OFF must be a clean, successful no-op"
fi
if ! echo "$off_output" | grep -q "TELEMETRY IS OFF"; then
  fail "TEST 2 — push.sh did not print the loud OFF message"
fi
if [[ -d "$OFF_STAGING" ]] && [[ -n "$(ls -A "$OFF_STAGING" 2>/dev/null)" ]]; then
  fail "TEST 2 — a staging directory was populated while telemetry was OFF"
fi

echo "TEST 2 PASSED — OFF switch stopped the script before it read or staged anything."
echo ""
rm -f "$OFF_FILE" "$EVER_SENT_FILE" "$DELETION_LOG"   # reset state before the next tests
echo "###################################################################"
echo "# TEST 3 — filtered content mode strips free text (register #3, вариант A)"
echo "###################################################################"

cat > "$FAKE_REPO/products/demo-product/001-demo-atom-verify/VERDICT.md" <<'EOF'
---
verify_atom: ATOM-DEMO-001-VERIFY
target_atom: ATOM-DEMO-001
round: 1
returns_used: 0
verdict: accept
---
# VERDICT — ATOM-DEMO-001, round 1: accept

## Findings
PLANTED-VERDICT-BUSINESS-TEXT-b91fe2: this describes the founder's actual
feature and must not survive filtered-mode extraction.
EOF

FILTERED_STAGING="$SANDBOX/staging-filtered"
QROKY_TELEMETRY_FILTER_MODE=filtered "$PUSH_SH" "$FAKE_REPO" "$FILTERED_STAGING"

if grep -R "PLANTED-VERDICT-BUSINESS-TEXT-b91fe2" "$FILTERED_STAGING" >/dev/null 2>&1; then
  fail "TEST 3 — filtered mode did not strip the VERDICT.md Findings body; business text leaked"
fi
if ! grep -R "verdict: accept" "$FILTERED_STAGING" >/dev/null 2>&1; then
  fail "TEST 3 — filtered mode stripped too much; the structural 'verdict: accept' field must survive"
fi

echo "TEST 3 PASSED — filtered mode kept the structural VERDICT.md fields and dropped the Findings prose."
echo ""
echo "###################################################################"
echo "# TEST 4 — OFF after a real send logs a deletion request (register #5)"
echo "###################################################################"

rm -f "$EVER_SENT_FILE" "$DELETION_LOG"
REAL_SEND_STAGING="$SANDBOX/staging-real-send"
"$PUSH_SH" "$FAKE_REPO" "$REAL_SEND_STAGING" >/dev/null
if [[ ! -f "$EVER_SENT_FILE" ]]; then
  fail "TEST 4 setup — push.sh did not write .ever-sent after copying files; cannot test revocation"
fi

touch "$OFF_FILE"
revoke_output="$("$PUSH_SH" "$FAKE_REPO" "$SANDBOX/staging-revoked" 2>&1)"
echo "$revoke_output"
if [[ ! -f "$DELETION_LOG" ]]; then
  fail "TEST 4 — OFF after a real send did not create deletion-requests.log"
fi
if ! grep -q "revocation" "$DELETION_LOG"; then
  fail "TEST 4 — deletion-requests.log exists but does not name the revocation trigger"
fi
if ! echo "$revoke_output" | grep -qi "deletion request was logged"; then
  fail "TEST 4 — push.sh did not tell the founder a deletion request was logged"
fi

echo "TEST 4 PASSED — revoking after a real send logged an auditable deletion request."
echo ""
echo "###################################################################"
echo "# ALL NEGATIVE TESTS PASSED"
echo "###################################################################"
