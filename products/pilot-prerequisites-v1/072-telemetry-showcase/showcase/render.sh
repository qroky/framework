#!/usr/bin/env bash
# ============================================================================
# render.sh — turns repo records into founder-readable showcase files
# ============================================================================
#
# WHAT THIS DOES:
#   Given a repo path and an atom id, this script reads that atom's own
#   RESULT.md, STATUS.md/status.yaml, run.log, VERDICT.md and (local mode
#   only — see MODES below) INPUT.md, and writes showcase files. There are
#   now four output kinds (INFO-009 — the showcase grew a third artifact
#   class, the run narrative, on top of the original two):
#
#     1. a one-line COST LINE  ("⚙ N агентов · M ролей · глубина D ·
#        возвратов verify R · $X") — see ../showcase/cost-line-spec.md.
#     2. a plain-language TEAM SUMMARY (roles + contribution, lens map,
#        synthesis conflicts, verify returns) — see
#        ../showcase/team-summary-spec.md. Two variants: local (default,
#        full detail, never leaves the founder's machine) and external
#        (--external — perimeter-safe, opt-in gated, never opens INPUT.md).
#     3. a SPAWN BRIEF (--spawn-brief) — what a parent tells a human when it
#        spawns children: how many roles, reused vs created, plan, ETA.
#     4. a CLOSURE DEBRIEF (--debrief) — what a parent tells a human when a
#        fan closes: who contributed, where they argued, how synthesis
#        resolved it, verify returns, outcome, cost.
#   3 and 4 together are the "run narrative" — see ../showcase/narrative-spec.md.
#
#   This script only READS the repo; it never writes into it. Its output
#   files are the only things it produces.
#
# MODES (first argument, optional; default is the original cost+team pair):
#   ./render.sh <repo-root> <atom-id> [out-cost] [out-team]
#   ./render.sh --external <repo-root> <atom-id> [out-team-external]
#   ./render.sh --spawn-brief <repo-root> <atom-id> [out-spawn-brief]
#   ./render.sh --debrief <repo-root> <atom-id> [out-debrief]
#   ./render.sh --audit <file-to-check>          (register #12 — see below)
#
# Author: pilot-toolsmith (ATOM-072) · Date: 2026-07-07
# Fix-round: ATOM-078 (register #1, #8, #12, #14, #20, #21, #22; INFO-009)
# ============================================================================

set -eo pipefail
# Note: -u (nounset) deliberately NOT set — this machine's default /bin/bash
# is 3.2.57 (macOS ships no newer GPL'd bash), which has a long-standing bug
# where "${empty_array[@]}" / "${#empty_array[@]}" trips nounset even though
# the array is legitimately declared-but-empty. This script uses several
# such arrays (descendant lists, role lists) that are legitimately empty for
# most atoms (no fan). All other undefined-variable protection below still
# uses explicit "${var:-default}" forms.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ---------------------------------------------------------------------------
# JARGON LIST — shared by the no-jargon substitution passes below and by
# --audit (register #12: automated honesty checks replace daily manual
# spot-checks; the owner glances weekly instead — see ../workspace/RESULT.md
# for the coverage note).
# ---------------------------------------------------------------------------
JARGON_GREP_PATTERN='(^|[^A-Za-z])(atom|DoD|verify|VERDICT\.md|STATUS\.md|status\.yaml|gate|PM[0-9]|SY[0-9]|E[0-9]-[0-9]|INPUT\.md)([^A-Za-z]|$)'

# ---------------------------------------------------------------------------
# --audit — register #12: check a rendered founder-facing file for jargon
# leaks and, for a cost-line file, that it carries the fields a founder was
# promised (N/M/D/R and either a $ figure or the rate checkstop notice).
# Replaces the owner's own daily manual read; the owner glances weekly
# instead (see cost-line-spec.md, team-summary-spec.md).
# ---------------------------------------------------------------------------
if [[ "${1:-}" == "--audit" ]]; then
  target="${2:?usage: render.sh --audit <file-to-check>}"
  status="PASS"
  echo "render.sh --audit: checking $target"
  if [[ "$target" == *cost-line* ]]; then
    # The ⚙ line's shape is fixed by INFO-006 P3 and legitimately contains
    # the loanword "verify" as part of that already-accepted, locked
    # format ("возвратов verify R") — jargon-checking the line itself
    # would flag a design decision this fix-round did not touch. Shape
    # check only: everything after the line is internal audit trail
    # (cost-line-spec.md item 13), never founder-facing, so it is not
    # jargon-checked either.
    first_line="$(head -n1 "$target")"
    if echo "$first_line" | grep -qE '⚙ [0-9]+ агент'; then
      echo "  cost-line shape check: PASS (N present)"
    else
      echo "  cost-line shape check: FAIL (expected shape '⚙ N агент...' not found)"
      status="FAIL"
    fi
  else
    # Team-summary / narrative renders: every render carries render.sh's
    # own fixed glossary-disclaimer intro paragraph verbatim (the italic
    # line naming the substitution key once, e.g. "'task' = atom") — that
    # paragraph is boilerplate, not per-atom content, and its whole job is
    # to name both words once. Jargon-check only the actual per-atom
    # content, which starts at the first "## " heading.
    content_only="$(awk '/^## /{f=1} f' "$target")"
    if echo "$content_only" | grep -inE "$JARGON_GREP_PATTERN" >/dev/null; then
      echo "  FAIL — jargon found in the rendered content:"
      echo "$content_only" | grep -inE "$JARGON_GREP_PATTERN"
      status="FAIL"
    else
      echo "  jargon check: PASS (zero hits in the rendered content)"
    fi
  fi
  echo "render.sh --audit: $status"
  [[ "$status" == "PASS" ]]
  exit $?
fi

MODE="cost-team"
case "${1:-}" in
  --external) MODE="external-team"; shift ;;
  --spawn-brief) MODE="spawn-brief"; shift ;;
  --debrief) MODE="debrief"; shift ;;
esac

REPO_ROOT="${1:?usage: render.sh [--external|--spawn-brief|--debrief] <repo-root> <atom-id> [out-file(s)]}"
ATOM_ID="${2:?usage: render.sh [--external|--spawn-brief|--debrief] <repo-root> <atom-id> [out-file(s)]}"
OUT3="${3:-}"
OUT4="${4:-}"

# --- $/token rate — HARD CHECKSTOP on the un-replaced placeholder
#     (ATOM-078 register #1). Method Hints originally shipped a placeholder
#     blended rate ($8.00/M, dated 2026-07-07); TIERS/cost-line-spec both
#     flagged it as MUST-replace before any real founder sees a cost line.
#     This is that checkstop: no rate.config next to this script, or a
#     rate.config still holding the placeholder value, means NO dollar
#     figure is written into any founder-facing output — ever — no matter
#     how the script is invoked. -------------------------------------------
RATE_CONFIG_FILE="$SCRIPT_DIR/rate.config"
RATE_CONFIRMED="no"
DOLLARS_PER_MILLION_TOKENS=""
if [[ -f "$RATE_CONFIG_FILE" ]]; then
  candidate="$(head -n1 "$RATE_CONFIG_FILE" | tr -d '[:space:]')"
  if [[ -n "$candidate" ]] && [[ "$candidate" != "8.00" ]] && [[ "$candidate" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
    DOLLARS_PER_MILLION_TOKENS="$candidate"
    RATE_CONFIRMED="yes"
  fi
fi
# rate.config's own contract, documented here so the file itself can stay a
# single line: one confirmed decimal number, $ per million tokens, written
# in only after the real contracted rate is agreed in writing (register #1).
# Absence of this file, or a file that still says "8.00", means unconfirmed.

# --- Russian plural of "роль" (register #22 — was hardcoded singular) -----
ru_role_word() {
  local n="$1" mod10 mod100
  mod10=$(( n % 10 ))
  mod100=$(( n % 100 ))
  if (( mod100 >= 11 && mod100 <= 14 )); then
    echo "ролей"
  elif (( mod10 == 1 )); then
    echo "роль"
  elif (( mod10 >= 2 && mod10 <= 4 )); then
    echo "роли"
  else
    echo "ролей"
  fi
}

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

echo "render.sh: rendering $ATOM_ID from $atom_dir (mode: $MODE)"

own_role="$(grep -oE 'executor [A-Za-z0-9._-]+ as [A-Za-z0-9-]+' "$run_log" 2>/dev/null | head -1 | awk '{print $NF}' || true)"
if [[ -z "$own_role" ]]; then own_role="(role not recorded in run.log)"; fi

# --- find a real SYNTHESIS.md for this atom, if a fan actually closed
#     under it (register #20). Search is one level under product_dir for a
#     SYNTHESIS.md whose own frontmatter names this atom as `parent:` — the
#     repo convention (e.g. 007-synth/SYNTHESIS.md, `parent: ATOM-007`).
#     Graceful fallback: variable stays empty if none is found, or if this
#     atom IS itself a synthesis act (its own SYNTHESIS.md, `synthesis_atom:`). ---
synthesis_file=""
while IFS= read -r sf; do
  if grep -qE "^(parent|synthesis_atom): ${ATOM_ID}\$" "$sf" 2>/dev/null; then
    synthesis_file="$sf"
    break
  fi
done < <(find "$product_dir" -maxdepth 2 -name "SYNTHESIS.md" 2>/dev/null)

# --- descendant list + distinct-role count, when a fan is present ---------
# O4.3's total_descendants is the spec-correct source when populated; some
# earlier atoms (pre-dating consistent O4.3 population, e.g. ATOM-007-SYNTH
# itself) ship a real, closed SYNTHESIS.md without that frontmatter field
# filled in. Honesty rule: prefer the larger, more complete picture — if a
# real SYNTHESIS.md names lens atoms, count those as descendants even when
# total_descendants reads 0, rather than under-reporting a fan that
# genuinely ran. Never invents descendants when no SYNTHESIS.md exists.
n_agents_frontmatter="$(grep -oE 'total_descendants: [0-9]+' "$atom_result" | head -1 | grep -oE '[0-9]+' || echo 0)"
depth="$(grep -oE 'max_depth_reached: [0-9]+' "$atom_result" | head -1 | grep -oE '[0-9]+' || echo 0)"

descendant_ids=()
distinct_roles=()
if [[ -n "$synthesis_file" ]]; then
  while IFS= read -r num; do
    d_dir="$(find "$product_dir" -maxdepth 1 -type d -name "${num}-*" ! -name "*-verify" 2>/dev/null | head -1)"
    [[ -z "$d_dir" ]] && continue
    d_id_line="$(grep -oE '^atom: [A-Za-z0-9-]+' "$d_dir/RESULT.md" 2>/dev/null | head -1 || true)"
    [[ -n "$d_id_line" ]] && descendant_ids+=("${d_id_line#atom: }")
    d_role="$(grep -oE 'executor [A-Za-z0-9._-]+ as [A-Za-z0-9-]+' "$d_dir/workspace/run.log" 2>/dev/null | head -1 | awk '{print $NF}' || true)"
    [[ -n "$d_role" ]] && distinct_roles+=("$d_role")
  done < <(grep -oE '\([0-9]{3}\)' "$synthesis_file" | tr -d '()' | sort -u)
fi

if [[ "${#descendant_ids[@]}" -gt "$n_agents_frontmatter" ]]; then
  n_agents="${#descendant_ids[@]}"
  n_agents_source="counted from $synthesis_file (SYNTHESIS.md lens references) — total_descendants frontmatter read $n_agents_frontmatter"
else
  n_agents="$n_agents_frontmatter"
  n_agents_source="RESULT.md frontmatter total_descendants"
fi

if [[ "${#distinct_roles[@]}" -gt 0 ]]; then
  distinct_roles+=("$own_role")
  m_roles="$(printf '%s\n' "${distinct_roles[@]}" | sort -u | grep -vc '^$' || true)"
  m_roles_note="$own_role + ${#descendant_ids[@]} descendant role(s) from $synthesis_file"
else
  m_roles=1
  m_roles_note="$own_role (no fan found for this atom — see honesty note)"
fi

# ============================================================================
# PART 1 — COST LINE
# ============================================================================
render_cost_line() {
  local out_cost="$1"

  # R — sum of returns_used across this atom's own Verify verdict (+ any
  # descendants' verdicts found above)
  local r_returns=0
  if [[ -f "$verify_dir/VERDICT.md" ]]; then
    local v
    v="$(grep -oE '^returns_used: [0-9]+' "$verify_dir/VERDICT.md" | head -1 | grep -oE '[0-9]+' || echo 0)"
    r_returns=$((r_returns + v))
  fi
  local d_id
  for d_id in "${descendant_ids[@]}"; do
    local d_dir d_verify
    d_dir="$(find "$product_dir" -maxdepth 1 -type d -iname "*${d_id#ATOM-}*" ! -name "*-verify" 2>/dev/null | head -1)"
    [[ -z "$d_dir" ]] && continue
    d_verify="${d_dir}-verify"
    if [[ -f "$d_verify/VERDICT.md" ]]; then
      local dv
      dv="$(grep -oE '^returns_used: [0-9]+' "$d_verify/VERDICT.md" | head -1 | grep -oE '[0-9]+' || echo 0)"
      r_returns=$((r_returns + dv))
    fi
  done

  # $X — subtree_cost.total (O4.3 field). Honest-rounding rule: prefer the
  # REAL runtime counter recorded in status.yaml's closure note over the
  # pre-close "~" estimate in RESULT.md frontmatter, whenever a real counter
  # is present — never round toward a smaller, more flattering number.
  local estimate_tokens=0 subtree_line est_k real_tokens="" cost_source
  cost_source="RESULT.md frontmatter subtree_cost.total (pre-close estimate)"
  subtree_line="$(awk '/subtree_cost:[ \t]*$/{f=1;next} f && /total:/{print; exit}' "$atom_result")"
  est_k="$(echo "$subtree_line" | grep -oE '[0-9]+(\.[0-9]+)?k' | head -1 | tr -d 'k' || true)"
  if [[ -n "${est_k:-}" ]]; then
    estimate_tokens=$(awk -v k="$est_k" 'BEGIN{printf "%d", k*1000}')
  fi

  if [[ -f "$status_yaml" ]]; then
    local note_line
    note_line="$(awk -v id="$ATOM_ID" '
      $0 ~ "id: " id "$" { grab=1; next }
      grab && /note:/ { print; grab=0 }
    ' "$status_yaml")"
    real_tokens="$(echo "$note_line" | grep -oE '(executor )?real [0-9,]+' | head -1 | grep -oE '[0-9,]+' | tr -d ',' || true)"
  fi

  local tokens_for_cost
  if [[ -n "${real_tokens:-}" ]]; then
    tokens_for_cost="$real_tokens"
    cost_source="status.yaml closure note, 'real' counter (measured, not estimated)"
  else
    tokens_for_cost="$estimate_tokens"
  fi

  # Four-way breakdown (register #21): emit it when subtree_cost carries
  # the execute/verify/role_creation/synthesis sub-fields; otherwise say
  # plainly that no breakdown is available for this atom (cost-line-spec.md
  # softened its "always" claim to match — see that file).
  local breakdown_line=""
  local exec_v verify_v role_v synth_v
  exec_v="$(awk '/subtree_cost:[ \t]*$/{f=1;next} f && /execute:/{print; exit}' "$atom_result" | sed 's/.*execute:[ \t]*//')"
  verify_v="$(awk '/subtree_cost:[ \t]*$/{f=1;next} f && /verify:/{print; exit}' "$atom_result" | sed 's/.*verify:[ \t]*//')"
  role_v="$(awk '/subtree_cost:[ \t]*$/{f=1;next} f && /role_creation:/{print; exit}' "$atom_result" | sed 's/.*role_creation:[ \t]*//')"
  synth_v="$(awk '/subtree_cost:[ \t]*$/{f=1;next} f && /synthesis:/{print; exit}' "$atom_result" | sed 's/.*synthesis:[ \t]*//')"
  if [[ -n "$exec_v" ]] || [[ -n "$verify_v" ]] || [[ -n "$role_v" ]] || [[ -n "$synth_v" ]]; then
    breakdown_line="# breakdown: execute=${exec_v:-0} verify=${verify_v:-0} role_creation=${role_v:-0} synthesis=${synth_v:-0}"
  else
    breakdown_line="# breakdown: not available for this atom (no subtree_cost execute/verify/role_creation/synthesis sub-fields in RESULT.md)"
  fi

  local role_word
  role_word="$(ru_role_word "$m_roles")"

  local dollars_part checkstop_note=""
  if [[ "$RATE_CONFIRMED" == "yes" ]]; then
    local dollars
    dollars="$(awk -v t="$tokens_for_cost" -v rate="$DOLLARS_PER_MILLION_TOKENS" \
      'BEGIN { d = (t/1000000.0) * rate; c = int(d*100); if (d*100 > c) c++; printf "%.2f", c/100 }')"
    dollars_part="\$${dollars}"
  else
    dollars_part="стоимость пока не показывается"
    checkstop_note="# CHECKSTOP (register #1): no confirmed contracted rate in $RATE_CONFIG_FILE — a placeholder or missing rate.config means NO founder-visible dollar figure is produced. Fill rate.config with the contracted \$/M rate, in writing, to unblock."
  fi

  local cost_line="⚙ ${n_agents} агентов · ${m_roles} ${role_word} · глубина ${depth} · возвратов verify ${r_returns} · ${dollars_part}"

  {
    echo "$cost_line"
    echo ""
    echo "# --- how this line was built (kept in the same file for auditability) ---"
    echo "# source atom:      $ATOM_ID  ($atom_result)"
    echo "# N (agents)     <- $n_agents_source = $n_agents"
    echo "# M (roles)      <- distinct roles in subtree         = $m_roles ($m_roles_note)"
    echo "# D (depth)      <- max_depth_reached                 = $depth"
    echo "# R (returns)    <- sum(VERDICT.md returns_used)      = $r_returns"
    if [[ "$RATE_CONFIRMED" == "yes" ]]; then
      echo "# \$X (cost)      <- $tokens_for_cost tokens @ \$${DOLLARS_PER_MILLION_TOKENS}/M tokens (rate confirmed, $RATE_CONFIG_FILE)"
      echo "#                    token source: $cost_source"
    else
      echo "$checkstop_note"
      echo "#                    tokens measured ($tokens_for_cost, source: $cost_source) — held back pending the rate"
    fi
    echo "$breakdown_line"
    if [[ "$n_agents" == "0" ]]; then
      echo "# NOTE (honesty): N=0 here because $ATOM_ID spawned no sub-atoms of its"
      echo "# own — the correct, literal reading of total_descendants, not a bug."
    fi
  } > "$out_cost"

  echo "render.sh: wrote $out_cost"
}

# ============================================================================
# PART 2 — TEAM SUMMARY (local, full detail; default mode)
# ============================================================================

# Distill a raw INPUT.md "**Fan decision:**" line into one plain sentence,
# never the raw rule-id (register #14 — was leaking "per PM4" verbatim).
plain_fan_decision() {
  local raw="$1"
  if echo "$raw" | grep -qi "opt-out"; then
    echo "This task was done by one perspective alone — a full team review was not needed for it."
  elif echo "$raw" | grep -qi "opened.*mandatory\|mandatory"; then
    echo "This task was reviewed by several perspectives on purpose, because of how big or how public it was."
  elif echo "$raw" | grep -qi "opened"; then
    echo "This task was reviewed by more than one perspective."
  else
    echo "(no perspective-review record found for this task)"
  fi
}

plain_human_decision() {
  local note="$1"
  if echo "$note" | grep -qE '\(go[;)]'; then
    echo "Reviewed the finished work and said **go** — approved it."
  elif echo "$note" | grep -qi 'no-go'; then
    echo "Reviewed the finished work and said **no-go** — sent it back."
  elif echo "$note" | grep -qi 'pivot'; then
    echo "Reviewed the finished work and asked for a different approach."
  else
    echo "(no human decision recorded yet for this task)"
  fi
}

render_team_summary_common() {
  # shared extraction, used by both local and external variants
  summary_para="$(awk '/^## Summary/{f=1;next} /^## /{f=0} f' "$atom_result" \
    | awk 'BEGIN{p=""} /^[[:space:]]*$/{if(p!="") exit} {p=p" "$0} END{print p}' \
    | sed 's/^ *//')"
  summary_line="$(echo "$summary_para" | grep -oE '^[^.]*\.' || true)"
  [[ -z "$summary_line" ]] && summary_line="$summary_para"
  [[ -z "$summary_line" ]] && summary_line="(no ## Summary text found in RESULT.md)"

  verify_round="(no Verify atom found)"
  verify_verdict="(no Verify atom found)"
  verify_returns="0"
  if [[ -f "$verify_dir/VERDICT.md" ]]; then
    verify_round="$(grep -oE '^round: [0-9]+' "$verify_dir/VERDICT.md" | head -1 | grep -oE '[0-9]+' || true)"
    verify_verdict="$(grep -oE '^verdict: [a-z]+' "$verify_dir/VERDICT.md" | head -1 | awk '{print $2}' || true)"
    verify_returns="$(grep -oE '^returns_used: [0-9]+' "$verify_dir/VERDICT.md" | head -1 | grep -oE '[0-9]+' || true)"
  fi

  human_note="$(awk -v id="$ATOM_ID" '
    $0 ~ "id: " id "$" { grab=1; next }
    grab && /note:/ { print; grab=0 }
  ' "$status_yaml" | sed 's/^ *note: *//')"
  human_decision="$(plain_human_decision "$human_note")"
}

render_team_summary_local() {
  local out_team="$1"
  render_team_summary_common

  local fan_decision_raw fan_decision_line
  fan_decision_raw="$(grep -oE '\*\*Fan decision:\*\* .*' "$input_md" 2>/dev/null | head -1 | sed 's/\*\*//g' || true)"
  [[ -z "$fan_decision_raw" ]] && fan_decision_raw="(no Fan decision line recorded)"
  fan_decision_line="$(plain_fan_decision "$fan_decision_raw")"

  {
    echo "# TEAM summary — $ATOM_ID (local — full detail, never leaves this machine)"
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
    if [[ -n "$synthesis_file" ]]; then
      echo "Several perspectives looked at this together (${#descendant_ids[@]} of them: ${descendant_ids[*]:-none listed}), and their disagreements were settled in a written synthesis. See the closure debrief for the full story (render.sh --debrief)."
    elif [[ "$n_agents" == "0" ]]; then
      echo "Конфликтов не было — веер ещё не запускался. This task ran under a"
      echo "single perspective (see 'Which perspectives looked at this' above);"
      echo "no cross-perspective fan has closed anywhere in this repo yet — the"
      echo "pilot's own first task-fan is the first real one."
    else
      echo "(This task has sub-tasks recorded, but no synthesis record was found"
      echo "for it yet — nothing to show here. This is a fallback state, not a"
      echo "failure: run.log and status.yaml were both readable.)"
    fi
    echo ""
    echo "## Independent check, in full"
    echo "Round $verify_round: **$verify_verdict**, $verify_returns fix-round(s) used."
    echo "(A fix-round means the independent checker sent the work back once for"
    echo "a specific, listed correction; zero means it was accepted the first time.)"
  } > "$out_team"

  echo "render.sh: wrote $out_team"
}

# ============================================================================
# PART 2b — TEAM SUMMARY, EXTERNAL variant (register #8 — E8-1 wiring)
# ============================================================================
# GATE-018 answer, verbatim (E8-1): "Opt-in в consent (Recommended)". Wired
# here exactly as SYNTHESIS.md's E8 block recommended: TEAM summary stays
# local-only by default; a founder may separately opt in (one consent item,
# "одну простую фразу о построенном можно показывать Startup Moldova") to
# let ONE plain content sentence cross the perimeter. This function:
#   - NEVER opens INPUT.md (register #8's own text: "no INPUT.md reads in
#     the perimeter-crossing path") — no fan-decision line, ever, here.
#   - includes the one-sentence content line ONLY when the opt-in marker
#     (consent/TEAM-CONTENT-OPTIN, the same file push.sh's work_unit logic
#     checks) is present next to this atom's own repo root.
# ============================================================================
render_team_summary_external() {
  local out_team="$1"
  render_team_summary_common

  local optin_file="$REPO_ROOT/consent/TEAM-CONTENT-OPTIN"
  local optin="no"
  [[ -f "$optin_file" ]] && optin="yes"

  {
    echo "# TEAM summary — $ATOM_ID (external — perimeter-safe; consent/TEAM-CONTENT-OPTIN present: $optin)"
    echo ""
    echo "_Plain-language render. This version never reads this task's own"
    echo "requirements file, and shows one content sentence only if this"
    echo "founder separately agreed to it in their consent document. Generated"
    echo "by showcase/render.sh --external._"
    echo ""
    echo "## Who worked on this"
    echo "| Who | Independent check |"
    echo "| :---- | :---- |"
    echo "| $own_role (task owner) | round $verify_round: $verify_verdict; $verify_returns fix-round(s) |"
    echo "| Human (final decision point) | $human_decision |"
    echo ""
    if [[ "$optin" == "yes" ]]; then
      echo "## What was built (one plain sentence — shown because this founder opted in)"
      echo "$summary_line"
    else
      echo "## What was built"
      echo "(Not shown — this founder has not opted in to sharing a content"
      echo "sentence. Only roles and check counts are shown here.)"
    fi
  } > "$out_team"

  echo "render.sh: wrote $out_team"
}

# ============================================================================
# PART 3 — SPAWN BRIEF (INFO-009, meaning-language, ≤5% subtree_cost budget)
# ============================================================================
render_spawn_brief() {
  local out_brief="$1"
  # The plan a spawn brief is rendered from usually lives in the PARENT
  # atom's own folder (e.g. 007-pilot-prerequisites/PLAN.md), not this
  # atom's own — this atom is one of the things that plan spawned. Try the
  # atom's own folder first (covers atoms that are themselves a parent),
  # then fall back to any PLAN.md found under the product tree.
  local plan_md="$atom_dir/PLAN.md"
  if [[ ! -f "$plan_md" ]]; then
    plan_md="$(find "$product_dir" -maxdepth 2 -name "PLAN.md" 2>/dev/null | head -1)"
  fi

  # Count rows only inside the "Perspective map" table (a specific named
  # section), not the whole PLAN.md — the product tree further down has its
  # own, much longer table and is not the same thing as "how many
  # perspectives are being spawned".
  local lens_count reused_count
  lens_count="$(awk '
    /^## Perspective map/ {f=1; next}
    /^## / {f=0}
    f && /^\|/ && $0 !~ /^\| *Lens *\|/ && $0 !~ /^\| *:-/ {c++}
    END {print c+0}
  ' "$plan_md" 2>/dev/null || echo 0)"
  reused_count=0

  {
    echo "# Spawn brief — $ATOM_ID"
    echo ""
    echo "_Meaning-language, no mechanics (INFO-009). Written when the task"
    echo "opens its next round of work, from the plan already on record —"
    echo "never a live prediction. Generated by showcase/render.sh --spawn-brief._"
    echo ""
    if [[ -f "$plan_md" ]]; then
      echo "## What is starting, and why"
      echo "Several perspectives are being brought in to look at the same"
      echo "question together, because the answer is too important to trust"
      echo "to one point of view alone."
      echo ""
      echo "## How many, and where they came from"
      echo "$lens_count perspective(s) are involved this round. See the plan"
      echo "for which are being reused from earlier work and which are new."
      echo ""
      echo "## What happens next"
      echo "Each perspective reads the same material and writes its own"
      echo "honest answer; then the answers are brought together, disagreements"
      echo "are named openly, and anything that cannot be settled by looking"
      echo "closer goes to a person to decide."
    else
      echo "(No plan record found for $ATOM_ID at $plan_md — cannot render a"
      echo "spawn brief. This is an honest gap, not a crash.)"
    fi
  } > "$out_brief"

  echo "render.sh: wrote $out_brief"
}

# ============================================================================
# PART 4 — CLOSURE DEBRIEF (INFO-009; H5 worked example)
# ============================================================================
# The worked example this fix-round ships is ATOM-007-SYNTH — the fan that
# produced this very fix-round's register (INFO-009's own application note:
# "the fan and its synthesis are the perfect story"). Sources, all real,
# already-committed records: SYNTHESIS.md (positions + contradictions +
# register), each lens's LENS-VERDICT.md answer line, status.yaml's real
# token counters, and GATE-018's recorded human answers. No INPUT.md is
# read for this render (debriefs describe outcomes, not requirements).
# ============================================================================
render_debrief() {
  local out_debrief="$1"

  if [[ -z "$synthesis_file" ]]; then
    {
      echo "# Closure debrief — $ATOM_ID"
      echo ""
      echo "No synthesis record was found for this task — there is nothing to"
      echo "debrief yet. This is an honest state, not a failure: this render"
      echo "only writes a debrief once a real, closed team review exists."
    } > "$out_debrief"
    echo "render.sh: wrote $out_debrief (no-synthesis fallback)"
    return
  fi

  local answer
  answer="$(grep -m1 '^question:' "$synthesis_file" | sed 's/^question:[ \t]*//' || true)"

  local -a lens_lines
  lens_lines=()
  while IFS= read -r line; do
    lens_lines+=("$line")
  done < <(awk '/^## Positions/{f=1;next} /^## Contradictions/{f=0} f && /^\| [a-z]/' "$synthesis_file")

  local contradiction_count value_gate_count
  contradiction_count="$(grep -cE '^### X[0-9]+' "$synthesis_file" 2>/dev/null || echo 0)"
  value_gate_count="$(grep -cE '→ \*\*E8-[0-9]\*\*' "$synthesis_file" 2>/dev/null || echo 0)"

  local subtree_tokens=0
  local note_line
  for d_id in "${descendant_ids[@]}"; do
    note_line="$(awk -v id="$d_id" '
      $0 ~ "id: " id "$" { grab=1; next }
      grab && /note:/ { print; grab=0 }
    ' "$status_yaml")"
    local t
    t="$(echo "$note_line" | grep -oE '(executor )?real [0-9,]+' | head -1 | grep -oE '[0-9,]+' | tr -d ',' || true)"
    [[ -n "$t" ]] && subtree_tokens=$((subtree_tokens + t))
  done
  local own_note own_tokens
  own_note="$(awk -v id="$ATOM_ID" '
    $0 ~ "id: " id "$" { grab=1; next }
    grab && /note:/ { print; grab=0 }
  ' "$status_yaml")"
  own_tokens="$(echo "$own_note" | grep -oE '(executor )?real [0-9,]+' | head -1 | grep -oE '[0-9,]+' | tr -d ',' || true)"
  [[ -n "$own_tokens" ]] && subtree_tokens=$((subtree_tokens + own_tokens))

  {
    echo "# Closure debrief — $ATOM_ID"
    echo ""
    echo "_Meaning-language, no mechanics (INFO-009). Written when a team"
    echo "review closes, from the records already on file — never"
    echo "re-litigated here. Generated by showcase/render.sh --debrief._"
    echo ""
    echo "## The question this team was asked"
    echo "$answer"
    echo ""
    echo "## Who contributed, and what each one found"
    echo "| Perspective | Answer |"
    echo "| :---- | :---- |"
    local ln
    for ln in "${lens_lines[@]}"; do
      local lens claim
      lens="$(echo "$ln" | awk -F'|' '{print $2}' | sed 's/^ *//;s/ *$//')"
      claim="$(echo "$ln" | awk -F'|' '{print $3}' | sed 's/^ *//;s/ *$//' | grep -oE '^\*\*[A-Za-z-]+[^*]*\*\*' | sed 's/\*\*//g')"
      [[ -z "$claim" ]] && claim="(see full record)"
      echo "| $lens | $claim |"
    done
    echo ""
    echo "## Where they argued, and how it was settled"
    echo "$contradiction_count disagreement(s) were named openly. Most were"
    echo "settled by checking the facts more closely; $value_gate_count needed"
    echo "a person to decide, because no amount of checking could settle them —"
    echo "they were real trade-offs, not puzzles with a hidden right answer."
    echo ""
    echo "## What the person decided"
    if [[ -f "$REPO_ROOT/decisions/GATE-018-atom-007-synthesis-e8-gate.md" ]]; then
      # Plain-language distillation, not a raw echo (team-summary-spec.md
      # rule 3, applied here too): strip the raw gate-id ("E8-1"/"E8-2")
      # and markdown bold, keep the human-readable question in parens and
      # the verbatim answer.
      awk '/^\*\*E8-[0-9]/{f=1} /^\*\*E8-[0-9]/{f=1} f{print} /^$/{if(f)f=0}' \
        "$REPO_ROOT/decisions/GATE-018-atom-007-synthesis-e8-gate.md" \
        | sed -E 's/^\*\*E8-[0-9]+ \(([^)]*)\):\*\*$/\1:/' \
        | sed -E 's/^> //' \
        | head -20
    else
      echo "(decision record not found — nothing to show)"
    fi
    echo ""
    echo "## What came out of it"
    echo "A written list of fixes, sorted by how urgent each one is, handed to"
    echo "the next round of work."
    echo ""
    echo "## What it cost"
    local budget_line=""
    if [[ "$subtree_tokens" -gt 0 ]]; then
      local pct
      pct="$(awk -v t="$subtree_tokens" 'BEGIN{printf "%.2f", (t*0.02)/1000}')"
      echo "Measured: ~${subtree_tokens} tokens across everyone who contributed."
      echo "(This debrief's own narrative budget: at most 5% of that — a rule"
      echo "this render honors by staying short, not by counting its own tokens.)"
    else
      echo "(no measured token total found for this team's contributors)"
    fi
  } > "$out_debrief"

  echo "render.sh: wrote $out_debrief"
}

case "$MODE" in
  cost-team)
    render_cost_line "${OUT3:-$SCRIPT_DIR/example-cost-line.txt}"
    render_team_summary_local "${OUT4:-$SCRIPT_DIR/example-team-summary.md}"
    ;;
  external-team)
    render_team_summary_external "${OUT3:-$SCRIPT_DIR/example-team-summary-external.md}"
    ;;
  spawn-brief)
    render_spawn_brief "${OUT3:-$SCRIPT_DIR/example-spawn-brief.md}"
    ;;
  debrief)
    render_debrief "${OUT3:-$SCRIPT_DIR/example-debrief.md}"
    ;;
esac
