#!/usr/bin/env bash
# lets-graphify-code — tiered code-query harness.
#
# Usage:
#   ./run-query.sh <repo-path> "<question>" [--force-tier=1|2] [--backend=anthropic|gemini|openai|local]
#
# Emits a structured block (Tier 1 or Tier 2 shape per SKILL.md) to stdout.

set -euo pipefail

REPO=""
QUESTION=""
FORCE_TIER=""
BACKEND="${GRAPHIFY_BACKEND:-anthropic}"
RG_BIN="${RG_BIN:-rg}"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --force-tier=*) FORCE_TIER="${1#*=}"; shift ;;
    --backend=*) BACKEND="${1#*=}"; shift ;;
    --help|-h)
      sed -n '2,8p' "$0" | sed 's/^# \?//'; exit 0 ;;
    *)
      if [[ -z "$REPO" ]]; then REPO="$1";
      elif [[ -z "$QUESTION" ]]; then QUESTION="$1";
      else echo "unexpected arg: $1" >&2; exit 64; fi
      shift ;;
  esac
done

if [[ -z "$REPO" || -z "$QUESTION" ]]; then
  echo "usage: $0 <repo-path> \"<question>\" [--force-tier=1|2] [--backend=...]" >&2
  exit 64
fi
if [[ ! -d "$REPO" ]]; then
  echo "repo not found: $REPO" >&2; exit 66
fi

cd "$REPO"

START_TOTAL=$(date +%s)

# -------- Tier 1: grep --------
tier1() {
  local hits=0
  local calls=0
  local out=""
  for pat in "$QUESTION" "${QUESTION// /.*}"; do
    calls=$((calls + 1))
    if line=$("$RG_BIN" -n --no-heading --max-count=20 "$pat" 2>/dev/null | head -40); then
      if [[ -n "$line" ]]; then
        out+="$line"$'\n'
        hits=$((hits + $(printf "%s" "$line" | wc -l)))
      fi
    fi
  done
  echo "$calls" > /tmp/lgc.grep_calls
  echo "$hits" > /tmp/lgc.grep_hits
  printf "%s" "$out"
}

# -------- Tier 2: graphify --------
ensure_graphify() {
  if command -v graphify >/dev/null 2>&1; then return 0; fi
  if ! command -v uv >/dev/null 2>&1; then
    echo "uv not on PATH; cannot install graphify" >&2; return 1
  fi
  uv tool install graphifyy >/dev/null 2>&1 || return 1
}

build_or_reuse_graph() {
  local dir="graphify-out"
  local sha
  sha=$(git rev-parse HEAD 2>/dev/null || echo "no-git-$(date +%s)")
  if [[ -f "$dir/.commit" && "$(cat "$dir/.commit")" == "$sha" ]]; then
    echo "0"  # reused, build_s=0
    return 0
  fi
  local s_start=$(date +%s)
  graphify extract . --output "$dir" --backend "$BACKEND" \
    --ignore vendor/ --ignore node_modules/ --ignore dist/ --ignore .venv/ >/dev/null
  echo "$sha" > "$dir/.commit"
  local s_end=$(date +%s)
  echo "$((s_end - s_start))"
}

tier2() {
  ensure_graphify || { echo "TIER2_UNAVAILABLE"; return 1; }
  local build_s
  build_s=$(build_or_reuse_graph)
  local q_start=$(date +%s)
  local answer
  answer=$(graphify query "$QUESTION" --token-budget "${GRAPHIFY_MAX_OUTPUT_TOKENS:-900}" 2>/dev/null || echo "(graphify query returned no result)")
  local q_end=$(date +%s)
  echo "$build_s" > /tmp/lgc.build_s
  echo "$((q_end - q_start))" > /tmp/lgc.query_s
  printf "%s" "$answer"
}

# -------- Pick tier --------
USE_TIER=1
if [[ "$FORCE_TIER" == "2" ]]; then
  USE_TIER=2
elif [[ "$FORCE_TIER" == "1" ]]; then
  USE_TIER=1
else
  T1=$(tier1)
  # Escalate if grep returned nothing useful, OR question shape demands a trace.
  if [[ "$(cat /tmp/lgc.grep_hits)" -lt 2 ]] || echo "$QUESTION" | grep -qiE "trace|flow|blast.radius|depends on|path from|connects?"; then
    USE_TIER=2
  fi
fi

END_TOTAL=$(date +%s)
WALL=$((END_TOTAL - START_TOTAL))

if [[ "$USE_TIER" == "1" ]]; then
  T1="${T1:-$(tier1)}"
  cat <<EOF
tier: 1 (grep)
question: $QUESTION
grep_calls: $(cat /tmp/lgc.grep_calls)
grep_hits: $(cat /tmp/lgc.grep_hits)
wall_s: $WALL
tokens_estimated: ~0 (grep only)
answer: |
$(printf '%s' "$T1" | sed 's/^/  /')
EOF
else
  T2=$(tier2)
  cat <<EOF
tier: 2 (graphify)
question: $QUESTION
backend: $BACKEND
graph_build_s: $(cat /tmp/lgc.build_s 2>/dev/null || echo 0)
query_s: $(cat /tmp/lgc.query_s 2>/dev/null || echo 0)
wall_s: $WALL
tokens_estimated: ~$(( ${GRAPHIFY_MAX_OUTPUT_TOKENS:-900} )) (graphify query response cap)
graph_path: ./graphify-out/
answer: |
$(printf '%s' "$T2" | sed 's/^/  /')
EOF
fi
