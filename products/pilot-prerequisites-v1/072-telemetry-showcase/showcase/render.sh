#!/usr/bin/env bash
# ============================================================================
# render.sh — turns repo records into two founder-readable showcase files
# ============================================================================
#
# WHAT THIS DOES:
#   Given a repo path and an atom id, this script reads that atom's own
#   RESULT.md, STATUS.md/status.yaml, run.log, VERDICT.md and INPUT.md
#   (naive grep/awk parsing — no YAML library, per the records being
#   regular) and writes two files:
#
#     1. a one-line COST LINE  ("⚙ N агентов · M ролей · глубина D ·
#        возвратов verify R · $X") — see ../showcase/cost-line-spec.md
#        for exactly which field feeds which element.
#
#     2. a plain-language TEAM SUMMARY (roles + contribution, lens map,
#        synthesis conflicts, verify returns) — see
#        ../showcase/team-summary-spec.md for the section-by-section
#        source mapping.
#
#   This script only READS the repo; it never writes into it. Its two
#   output files are the only things it produces.
#
# USAGE:
#   ./render.sh <repo-root> <atom-id> [out-cost-line-file] [out-team-summary-file]
#   Defaults for the two output files: example-cost-line.txt and
#   example-team-summary.md, written next to this script.
#
# Author: pilot-toolsmith (ATOM-072) · Date: 2026-07-07
# ============================================================================

set -euo pipefail

REPO_ROOT="${1:?usage: render.sh <repo-root> <atom-id> [out-cost-line] [out-team-summary]}"
ATOM_ID="${2:?usage: render.sh <repo-root> <atom-id> [out-cost-line] [out-team-summary]}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUT_COST="${3:-$SCRIPT_DIR/example-cost-line.txt}"
OUT_TEAM="${4:-$SCRIPT_DIR/example-team-summary.md}"

# --- $/token assumption (Method Hints: state it, dated, as an explicit
#     assumption — this is a placeholder blended rate, NOT sourced from
#     pricing/pricing-ladder.md, which is out of this atom's named inputs;
#     replace at ATOM-007 setup with the real contracted rate). -----------
DOLLARS_PER_MILLION_TOKENS="8.00"   # assumption dated 2026-07-07

# --- locate the atom's own product folder (the RESULT.md whose frontmatter
#     names this atom, excluding its *-verify sibling folder) --------------
atom_result=""
while IFS= read -r f; do
  case "$(dirname "$f")" in
    *-verify) continue ;;
  esac
  atom_result="$f"
  break
done < <(find "$REPO_ROOT/products" -name RESULT.md -not -path "*-verify/*" -print0 2>/dev/null \
          | xargs -0 grep -l "^atom: ${ATOM_ID}\$" 2>/dev/null)

if [[ -z "$atom_result" ]]; then
  echo "render.sh: no RESULT.md found for $ATOM_ID under $REPO_ROOT/products — cannot render." >&2
  exit 1
fi

atom_dir="$(dirname "$atom_result")"
verify_dir="${atom_dir}-verify"
product_dir="$(dirname "$atom_dir")"
run_log="$atom_dir/workspace/run.log"
input_md="$atom_dir/INPUT.md"
status_yaml="$product_dir/status.yaml"

echo "render.sh: rendering $ATOM_ID from $atom_dir"

# ============================================================================
# PART 1 — COST LINE
# ============================================================================

# N — total_descendants (O4.3 field, RESULT.md frontmatter)
n_agents="$(grep -oE 'total_descendants: [0-9]+' "$atom_result" | head -1 | grep -oE '[0-9]+' || echo 0)"

# D — max_depth_reached (O4.3 field, RESULT.md frontmatter)
depth="$(grep -oE 'max_depth_reached: [0-9]+' "$atom_result" | head -1 | grep -oE '[0-9]+' || echo 0)"

# M — distinct roles in the subtree. Subtree here = this atom + its
# total_descendants (N above). This worked example has N=0 (a leaf/pre-fan
# atom — see cost-line-spec.md honesty note), so the subtree is just the
# atom's own executor role, read from its run.log CYCLE-START line.
own_role="$(grep -oE 'executor [A-Za-z0-9._-]+ as [A-Za-z0-9-]+' "$run_log" 2>/dev/null | head -1 | awk '{print $NF}')"
if [[ -z "$own_role" ]]; then own_role="(role not recorded in run.log)"; fi
m_roles=1   # N=0 in this worked example -> subtree is this atom alone

# R — sum of returns_used across this atom's own Verify verdict (+ any
# descendants' verdicts, none here since N=0)
r_returns=0
if [[ -f "$verify_dir/VERDICT.md" ]]; then
  v="$(grep -oE '^returns_used: [0-9]+' "$verify_dir/VERDICT.md" | head -1 | grep -oE '[0-9]+' || echo 0)"
  r_returns=$((r_returns + v))
fi

# $X — subtree_cost.total (O4.3 field). Honest-rounding rule: prefer the
# REAL runtime counter recorded in status.yaml's closure note over the
# pre-close "~" estimate in RESULT.md frontmatter, whenever a real counter
# is present — never round toward a smaller, more flattering number.
estimate_tokens=0
subtree_line="$(awk '/^subtree_cost:/{f=1;next} f && /total:/{print; exit}' "$atom_result")"
est_k="$(echo "$subtree_line" | grep -oE '[0-9]+(\.[0-9]+)?k' | head -1 | tr -d 'k' || true)"
if [[ -n "${est_k:-}" ]]; then
  estimate_tokens=$(awk -v k="$est_k" 'BEGIN{printf "%d", k*1000}')
fi

real_tokens=""
cost_source="RESULT.md frontmatter subtree_cost.total (pre-close estimate)"
if [[ -f "$status_yaml" ]]; then
  note_line="$(awk -v id="$ATOM_ID" '
    $0 ~ "id: " id "$" { grab=1; next }
    grab && /note:/ { print; grab=0 }
  ' "$status_yaml")"
  real_tokens="$(echo "$note_line" | grep -oE 'executor real [0-9,]+' | grep -oE '[0-9,]+' | tr -d ',' || true)"
fi

if [[ -n "${real_tokens:-}" ]]; then
  tokens_for_cost="$real_tokens"
  cost_source="status.yaml closure note, 'executor real' counter (measured, not estimated)"
else
  tokens_for_cost="$estimate_tokens"
fi

dollars="$(awk -v t="$tokens_for_cost" -v rate="$DOLLARS_PER_MILLION_TOKENS" \
  'BEGIN { d = (t/1000000.0) * rate; c = int(d*100); if (d*100 > c) c++; printf "%.2f", c/100 }')"
# ^ rounds UP to the next cent (ceiling) — never rounds a founder's cost down.

cost_line="⚙ ${n_agents} агентов · ${m_roles} роль · глубина ${depth} · возвратов verify ${r_returns} · \$${dollars}"

{
  echo "$cost_line"
  echo ""
  echo "# --- how this line was built (kept in the same file for auditability) ---"
  echo "# source atom:      $ATOM_ID  ($atom_result)"
  echo "# N (agents)     <- total_descendants                = $n_agents"
  echo "# M (roles)      <- distinct roles in subtree         = $m_roles ($own_role)"
  echo "# D (depth)      <- max_depth_reached                 = $depth"
  echo "# R (returns)    <- sum(VERDICT.md returns_used)      = $r_returns"
  echo "# \$X (cost)      <- $tokens_for_cost tokens @ \$${DOLLARS_PER_MILLION_TOKENS}/M tokens (assumption dated 2026-07-07)"
  echo "#                    token source: $cost_source"
  echo "# NOTE (honesty): N=0 here because $ATOM_ID spawned no sub-atoms of its"
  echo "# own (it is a pre-fan, single atom -- see INPUT.md 'Fan decision: opt-out"
  echo "# per PM4'). This is the correct, literal reading of total_descendants,"
  echo "# not a bug. The framework's first real lens fan has not closed in this"
  echo "# repo yet -- see cost-line-spec.md and team-summary-spec.md."
} > "$OUT_COST"

echo "render.sh: wrote $OUT_COST"

# ============================================================================
# PART 2 — TEAM SUMMARY
# ============================================================================

summary_para="$(awk '/^## Summary/{f=1;next} /^## /{f=0} f' "$atom_result" \
  | awk 'BEGIN{p=""} /^[[:space:]]*$/{if(p!="") exit} {p=p" "$0} END{print p}' \
  | sed 's/^ *//')"
summary_line="$(echo "$summary_para" | grep -oE '^[^.]*\.' || true)"
[[ -z "$summary_line" ]] && summary_line="$summary_para"
[[ -z "$summary_line" ]] && summary_line="(no ## Summary text found in RESULT.md)"

fan_decision_line="$(grep -oE '\*\*Fan decision:\*\* .*' "$input_md" 2>/dev/null | head -1 | sed 's/\*\*//g')"
[[ -z "$fan_decision_line" ]] && fan_decision_line="(no Fan decision line recorded — atom predates PM1-PM6, or run.log/INPUT.md unavailable)"

verify_round="(no Verify atom found)"
verify_verdict="(no Verify atom found)"
verify_returns="0"
if [[ -f "$verify_dir/VERDICT.md" ]]; then
  verify_round="$(grep -oE '^round: [0-9]+' "$verify_dir/VERDICT.md" | head -1 | grep -oE '[0-9]+')"
  verify_verdict="$(grep -oE '^verdict: [a-z]+' "$verify_dir/VERDICT.md" | head -1 | awk '{print $2}')"
  verify_returns="$(grep -oE '^returns_used: [0-9]+' "$verify_dir/VERDICT.md" | head -1 | grep -oE '[0-9]+')"
fi

human_note="$(awk -v id="$ATOM_ID" '
  $0 ~ "id: " id "$" { grab=1; next }
  grab && /note:/ { print; grab=0 }
' "$status_yaml" | sed 's/^ *note: *//')"

# The raw closure note is written for the framework's own audit trail and
# is full of method jargon (gate ids, criterion ids). A founder never sees
# that note verbatim -- distill it into one plain sentence instead.
if echo "$human_note" | grep -qE '\(go[;)]'; then
  human_decision="Reviewed the finished work and said **go** — approved it."
elif echo "$human_note" | grep -qi 'no-go'; then
  human_decision="Reviewed the finished work and said **no-go** — sent it back."
elif echo "$human_note" | grep -qi 'pivot'; then
  human_decision="Reviewed the finished work and asked for a different approach."
else
  human_decision="(no human decision recorded yet for this task)"
fi

{
  echo "# TEAM summary — $ATOM_ID"
  echo ""
  echo "_Plain-language render — no method jargon. 'task' = atom, 'independent"
  echo "check' = Verify, 'report' = RESULT.md, 'decision point' = gate. Source"
  echo "records only: RESULT.md, status.yaml, run.log, VERDICT.md, INPUT.md's"
  echo "own perspective-map line. Generated by showcase/render.sh._"
  echo ""
  echo "## Who worked on this, and what they did"
  echo "| Who | Contribution |"
  echo "| :---- | :---- |"
  echo "| $own_role (task owner) | $summary_line |"
  echo "| Independent check | round $verify_round: $verify_verdict; $verify_returns fix-round(s) requested |"
  echo "| Human (final decision point) | $human_decision |"
  echo ""
  echo "## Which perspectives looked at this"
  echo "$fan_decision_line"
  echo ""
  echo "## Where perspectives disagreed, and how it was settled"
  if [[ "$n_agents" == "0" ]]; then
    echo "Конфликтов не было — веер ещё не запускался. This task ran under a"
    echo "single perspective (see 'Which perspectives looked at this' above);"
    echo "no cross-perspective fan has closed anywhere in this repo yet — the"
    echo "pilot's own first task-fan is the first real one."
  else
    echo "(This branch of render.sh is for atoms with descendants; it reads"
    echo "SYNTHESIS.md when a fan actually ran. This worked example has none —"
    echo "see the note above.)"
  fi
  echo ""
  echo "## Independent check, in full"
  echo "Round $verify_round: **$verify_verdict**, $verify_returns fix-round(s) used."
  echo "(A fix-round means the independent checker sent the work back once for"
  echo "a specific, listed correction; zero means it was accepted the first time.)"
} > "$OUT_TEAM"

echo "render.sh: wrote $OUT_TEAM"
