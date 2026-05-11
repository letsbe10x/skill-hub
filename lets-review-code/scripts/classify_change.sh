#!/usr/bin/env bash
# classify_change.sh — Gather metrics for PR/commit classification
# Usage: ./classify_change.sh [base_ref] [head_ref]
# Outputs JSON classification data to stdout

set -euo pipefail

BASE_REF="${1:-HEAD~1}"
HEAD_REF="${2:-HEAD}"

# --- Metrics ---
LOC_STATS=$(git diff --numstat "$BASE_REF".."$HEAD_REF" | awk '{added+=$1; removed+=$2} END {printf "{\"added\":%d,\"removed\":%d}", added+0, removed+0}')
FILE_COUNT=$(git diff --name-only "$BASE_REF".."$HEAD_REF" | wc -l | tr -d ' ')
FILES_CHANGED=$(git diff --name-only "$BASE_REF".."$HEAD_REF")

# --- Scale ---
LOC_ADDED=$(echo "$LOC_STATS" | python3 -c "import sys,json; print(json.load(sys.stdin)['added'])" 2>/dev/null || echo "0")
if [ "$LOC_ADDED" -lt 20 ]; then
  SCALE="tiny"
elif [ "$LOC_ADDED" -lt 100 ]; then
  SCALE="small"
elif [ "$LOC_ADDED" -lt 300 ]; then
  SCALE="medium"
elif [ "$LOC_ADDED" -lt 1000 ]; then
  SCALE="large"
else
  SCALE="massive"
fi

# --- Risk signals ---
RISK_SIGNALS=""

if echo "$FILES_CHANGED" | grep -qiE "(auth|token|session|permission|crypto|secret|password)"; then
  RISK_SIGNALS="${RISK_SIGNALS}auth_security,"
fi

if echo "$FILES_CHANGED" | grep -qiE "(payment|billing|charge|subscription|invoice)"; then
  RISK_SIGNALS="${RISK_SIGNALS}payment,"
fi

if echo "$FILES_CHANGED" | grep -qiE "(migration|schema|alembic|flyway)"; then
  RISK_SIGNALS="${RISK_SIGNALS}data_migration,"
fi

if echo "$FILES_CHANGED" | grep -qiE "(utils/|common/|shared/|lib/)"; then
  RISK_SIGNALS="${RISK_SIGNALS}shared_utilities,"
fi

if echo "$FILES_CHANGED" | grep -qiE "(api/|routes/|openapi|graphql|schema\.)"; then
  RISK_SIGNALS="${RISK_SIGNALS}api_contracts,"
fi

# --- Type inference ---
ONLY_TESTS=$(echo "$FILES_CHANGED" | grep -cviE "(test|spec|__test__|_test\.)" || true)
ONLY_DOCS=$(echo "$FILES_CHANGED" | grep -cviE "\.(md|rst|txt|adoc)$" || true)
ONLY_CONFIG=$(echo "$FILES_CHANGED" | grep -cviE "\.(toml|yaml|yml|json|ini|cfg|env)$" || true)

if [ "$ONLY_TESTS" -eq 0 ] 2>/dev/null; then
  TYPE="test"
elif [ "$ONLY_DOCS" -eq 0 ] 2>/dev/null; then
  TYPE="docs"
elif [ "$ONLY_CONFIG" -eq 0 ] 2>/dev/null; then
  TYPE="config"
else
  # Check commit message for type hints
  COMMIT_MSG=$(git log --format="%B" -1 "$HEAD_REF" 2>/dev/null || echo "")
  if echo "$COMMIT_MSG" | grep -qiE "^fix|bugfix|hotfix"; then
    TYPE="bugfix"
  elif echo "$COMMIT_MSG" | grep -qiE "^feat|feature|add"; then
    TYPE="feature"
  elif echo "$COMMIT_MSG" | grep -qiE "^refactor|cleanup|reorganize"; then
    TYPE="refactor"
  else
    TYPE="feature"
  fi
fi

# --- Risk level ---
if echo "$RISK_SIGNALS" | grep -qE "(auth_security|payment|data_migration)"; then
  RISK="high"
elif echo "$RISK_SIGNALS" | grep -qE "(shared_utilities|api_contracts)"; then
  RISK="medium"
else
  RISK="low"
fi

# --- Depth decision ---
if [ "$RISK" = "high" ] || [ "$SCALE" = "large" ] || [ "$SCALE" = "massive" ]; then
  DEPTH="FULL"
elif [ "$TYPE" = "test" ] || [ "$TYPE" = "docs" ] || [ "$TYPE" = "config" ]; then
  DEPTH="LIGHT"
elif [ "$SCALE" = "tiny" ] && [ "$RISK" = "low" ]; then
  DEPTH="LIGHT"
else
  DEPTH="STANDARD"
fi

# --- Output ---
cat <<EOF
{
  "base_ref": "$BASE_REF",
  "head_ref": "$HEAD_REF",
  "loc": $LOC_STATS,
  "file_count": $FILE_COUNT,
  "scale": "$SCALE",
  "type": "$TYPE",
  "risk": "$RISK",
  "risk_signals": "$(echo "$RISK_SIGNALS" | sed 's/,$//')",
  "depth": "$DEPTH"
}
EOF
