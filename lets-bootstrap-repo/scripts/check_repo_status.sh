#!/usr/bin/env bash
# check_repo_status.sh — Detect existing context artifacts and their state
# Usage: ./check_repo_status.sh [repo_root]
# Outputs JSON with presence/staleness info for each artifact type

set -euo pipefail

REPO_ROOT="${1:-.}"

check_artifact() {
  local path="$1"
  local name="$2"
  local full_path="$REPO_ROOT/$path"

  if [ -f "$full_path" ]; then
    if [ "$(uname)" = "Darwin" ]; then
      LAST_MOD=$(stat -f %m "$full_path")
    else
      LAST_MOD=$(stat -c %Y "$full_path")
    fi
    NOW=$(date +%s)
    AGE_DAYS=$(( (NOW - LAST_MOD) / 86400 ))
    STALE="false"
    [ "$AGE_DAYS" -gt 90 ] && STALE="true"
    printf '"%s":{"present":true,"age_days":%d,"stale":%s}' "$name" "$AGE_DAYS" "$STALE"
  else
    printf '"%s":{"present":false,"age_days":null,"stale":null}' "$name"
  fi
}

# Check for letsbe10x artifacts
SERVICE=$(check_artifact ".letsbe10x/context/sources/service.yaml" "service")
ENGINEERING=$(check_artifact ".letsbe10x/context/sources/engineering.yaml" "engineering")
DELIVERY=$(check_artifact ".letsbe10x/context/sources/delivery.yaml" "delivery")
OBSERVABILITY=$(check_artifact ".letsbe10x/context/sources/observability.yaml" "observability")

# Check for standard repo artifacts
AGENTS=$(check_artifact "AGENTS.md" "agents_md")
CLAUDE=$(check_artifact "CLAUDE.md" "claude_md")

# Check for CI
CI="false"
[ -d "$REPO_ROOT/.github/workflows" ] && CI="true"
[ -f "$REPO_ROOT/.gitlab-ci.yml" ] && CI="true"
[ -f "$REPO_ROOT/Jenkinsfile" ] && CI="true"

# Check for build surface
MAKEFILE="false"
[ -f "$REPO_ROOT/Makefile" ] && MAKEFILE="true"
PYPROJECT="false"
[ -f "$REPO_ROOT/pyproject.toml" ] && PYPROJECT="true"
PACKAGE_JSON="false"
[ -f "$REPO_ROOT/package.json" ] && PACKAGE_JSON="true"

cat <<EOF
{
  "repo_root": "$REPO_ROOT",
  "artifacts": {$SERVICE,$ENGINEERING,$DELIVERY,$OBSERVABILITY,$AGENTS,$CLAUDE},
  "ci_present": $CI,
  "build_surface": {"makefile":$MAKEFILE,"pyproject":$PYPROJECT,"package_json":$PACKAGE_JSON}
}
EOF
