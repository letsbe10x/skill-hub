#!/usr/bin/env bash
# check_staleness.sh — Check AGENTS.md files for staleness signals
# Usage: ./check_staleness.sh [repo_root]
# Outputs JSON array of stale AGENTS.md files with reasons

set -euo pipefail

REPO_ROOT="${1:-.}"

find "$REPO_ROOT" -name "AGENTS.md" -not -path '*/.git/*' | while read -r agents_file; do
  DIR=$(dirname "$agents_file")
  REL_PATH="${agents_file#$REPO_ROOT/}"
  REASONS=""

  # Check age (> 90 days since last modified)
  if [ "$(uname)" = "Darwin" ]; then
    LAST_MOD=$(stat -f %m "$agents_file")
  else
    LAST_MOD=$(stat -c %Y "$agents_file")
  fi
  NOW=$(date +%s)
  AGE_DAYS=$(( (NOW - LAST_MOD) / 86400 ))
  if [ "$AGE_DAYS" -gt 90 ]; then
    REASONS="${REASONS}age_${AGE_DAYS}d,"
  fi

  # Check for dead path references
  DEAD_PATHS=0
  grep -oE '`[a-zA-Z_/][a-zA-Z0-9_/./-]+\.(py|ts|js|go|rs|java|rb)`' "$agents_file" 2>/dev/null | tr -d '`' | while read -r ref_path; do
    if [ ! -f "$REPO_ROOT/$ref_path" ] && [ ! -f "$DIR/$ref_path" ]; then
      DEAD_PATHS=$((DEAD_PATHS + 1))
    fi
  done
  if [ "$DEAD_PATHS" -gt 0 ] 2>/dev/null; then
    REASONS="${REASONS}dead_paths_${DEAD_PATHS},"
  fi

  # Check frontmatter date
  COMPILED_DATE=$(grep -m1 'last_compiled_date' "$agents_file" 2>/dev/null | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}' || echo "")
  if [ -z "$COMPILED_DATE" ]; then
    REASONS="${REASONS}no_frontmatter,"
  fi

  # Only output if stale
  if [ -n "$REASONS" ]; then
    printf '{"file":"%s","age_days":%d,"reasons":"%s"}\n' \
      "$REL_PATH" "$AGE_DAYS" "$(echo "$REASONS" | sed 's/,$//')"
  fi
done | jq -s '.'
