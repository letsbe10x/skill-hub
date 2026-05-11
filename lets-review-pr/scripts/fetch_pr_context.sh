#!/usr/bin/env bash
# fetch_pr_context.sh — Gather PR metadata and classification signals
# Usage: ./fetch_pr_context.sh <PR_ID>
# Outputs JSON with PR metadata, scale, risk signals, and suggested pipeline mode

set -euo pipefail

PR_ID="${1:?Usage: fetch_pr_context.sh <PR_ID>}"

# --- Fetch PR metadata ---
PR_JSON=$(gh pr view "$PR_ID" --json number,title,body,baseRefName,headRefName,additions,deletions,changedFiles,commits,labels,author 2>/dev/null)

if [ -z "$PR_JSON" ]; then
  echo "ERROR: Could not fetch PR $PR_ID" >&2
  exit 1
fi

PR_NUMBER=$(echo "$PR_JSON" | python3 -c "import sys,json; print(json.load(sys.stdin)['number'])")
PR_TITLE=$(echo "$PR_JSON" | python3 -c "import sys,json; print(json.load(sys.stdin)['title'])")
PR_BODY=$(echo "$PR_JSON" | python3 -c "import sys,json; print(json.load(sys.stdin).get('body','')[:500])")
ADDITIONS=$(echo "$PR_JSON" | python3 -c "import sys,json; print(json.load(sys.stdin)['additions'])")
DELETIONS=$(echo "$PR_JSON" | python3 -c "import sys,json; print(json.load(sys.stdin)['deletions'])")
CHANGED_FILES=$(echo "$PR_JSON" | python3 -c "import sys,json; print(json.load(sys.stdin)['changedFiles'])")
AUTHOR=$(echo "$PR_JSON" | python3 -c "import sys,json; print(json.load(sys.stdin)['author']['login'])")
BASE=$(echo "$PR_JSON" | python3 -c "import sys,json; print(json.load(sys.stdin)['baseRefName'])")
HEAD=$(echo "$PR_JSON" | python3 -c "import sys,json; print(json.load(sys.stdin)['headRefName'])")

# --- Scale ---
TOTAL_LOC=$((ADDITIONS + DELETIONS))
if [ "$TOTAL_LOC" -lt 20 ]; then
  SCALE="tiny"
elif [ "$TOTAL_LOC" -lt 100 ]; then
  SCALE="small"
elif [ "$TOTAL_LOC" -lt 300 ]; then
  SCALE="medium"
elif [ "$TOTAL_LOC" -lt 1000 ]; then
  SCALE="large"
else
  SCALE="very-large"
fi

# --- Get file list for risk signals ---
FILES_CHANGED=$(gh pr diff "$PR_ID" --name-only 2>/dev/null || echo "")

# --- Risk signals ---
RISK_SIGNALS=""
if echo "$FILES_CHANGED" | grep -qiE "(auth|token|session|permission|crypto|secret|password)"; then
  RISK_SIGNALS="${RISK_SIGNALS}auth_security,"
fi
if echo "$FILES_CHANGED" | grep -qiE "(payment|billing|charge|subscription)"; then
  RISK_SIGNALS="${RISK_SIGNALS}payment,"
fi
if echo "$FILES_CHANGED" | grep -qiE "(migration|schema|alembic|flyway)"; then
  RISK_SIGNALS="${RISK_SIGNALS}data_migration,"
fi
if echo "$FILES_CHANGED" | grep -qiE "(api/|routes/|openapi|graphql)"; then
  RISK_SIGNALS="${RISK_SIGNALS}api_contracts,"
fi
if echo "$FILES_CHANGED" | grep -qiE "(Dockerfile|\.github/|ci/|deploy/)"; then
  RISK_SIGNALS="${RISK_SIGNALS}delivery_surface,"
fi
RISK_SIGNALS=$(echo "$RISK_SIGNALS" | sed 's/,$//')

# --- Type inference ---
if echo "$PR_TITLE" | grep -qiE "^fix|bugfix|hotfix"; then
  TYPE="bugfix"
elif echo "$PR_TITLE" | grep -qiE "^feat|feature|add"; then
  TYPE="feature"
elif echo "$PR_TITLE" | grep -qiE "^refactor|cleanup"; then
  TYPE="refactor"
elif echo "$PR_TITLE" | grep -qiE "^perf"; then
  TYPE="performance"
elif echo "$PR_TITLE" | grep -qiE "^docs"; then
  TYPE="docs"
elif echo "$PR_TITLE" | grep -qiE "^test"; then
  TYPE="test"
elif echo "$PR_TITLE" | grep -qiE "^chore.*dep|bump|update.*dep"; then
  TYPE="dependency"
else
  TYPE="feature"
fi

# --- Risk level ---
if echo "$RISK_SIGNALS" | grep -qE "(auth_security|payment|data_migration)"; then
  RISK="high"
elif echo "$RISK_SIGNALS" | grep -qE "(api_contracts|delivery_surface)"; then
  RISK="medium"
else
  RISK="low"
fi

# --- Pipeline mode ---
if [ "$RISK" = "high" ] || [ "$SCALE" = "large" ] || [ "$SCALE" = "very-large" ]; then
  MODE="FULL"
elif [ "$TYPE" = "docs" ] || [ "$TYPE" = "test" ] || [ "$TYPE" = "config" ]; then
  MODE="LIGHT"
elif [ "$SCALE" = "tiny" ] && [ "$RISK" = "low" ]; then
  MODE="LIGHT"
else
  MODE="STANDARD"
fi

# --- Spec reference detection ---
SPEC_REF=$(echo "$PR_BODY" | grep -oiE "(prd|PRD|spec)[- ]?[0-9]+" | head -1 || echo "")

# --- Output ---
cat <<EOF
{
  "pr_number": $PR_NUMBER,
  "pr_title": $(python3 -c "import json; print(json.dumps('$PR_TITLE'))"),
  "author": "$AUTHOR",
  "base_branch": "$BASE",
  "head_branch": "$HEAD",
  "additions": $ADDITIONS,
  "deletions": $DELETIONS,
  "total_loc": $TOTAL_LOC,
  "changed_files": $CHANGED_FILES,
  "scale": "$SCALE",
  "type": "$TYPE",
  "risk": "$RISK",
  "risk_signals": "$RISK_SIGNALS",
  "pipeline_mode": "$MODE",
  "spec_ref": $([ -n "$SPEC_REF" ] && echo "\"$SPEC_REF\"" || echo "null")
}
EOF
