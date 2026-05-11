#!/usr/bin/env bash
# detect_modules.sh — Discover candidate modules for AGENTS.md generation
# Usage: ./detect_modules.sh [repo_root]
# Outputs JSON array of module candidates with metadata

set -euo pipefail

REPO_ROOT="${1:-.}"

# Find directories that look like modules (contain source files, not just config)
find "$REPO_ROOT" -type d \
  -not -path '*/.git/*' \
  -not -path '*/node_modules/*' \
  -not -path '*/__pycache__/*' \
  -not -path '*/.venv/*' \
  -not -path '*/venv/*' \
  -not -path '*/.eggs/*' \
  -not -path '*/.tox/*' \
  -not -path '*/dist/*' \
  -not -path '*/build/*' \
  -not -path '*/.letsbe10x/*' \
  -not -path '*/.agentic/*' | while read -r dir; do

  # Count source files
  FILE_COUNT=$(find "$dir" -maxdepth 1 -type f \( -name "*.py" -o -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" -o -name "*.go" -o -name "*.rs" -o -name "*.java" -o -name "*.rb" \) 2>/dev/null | wc -l | tr -d ' ')

  # Skip dirs with no source files
  [ "$FILE_COUNT" -eq 0 ] && continue

  # Compute depth relative to repo root
  REL_PATH="${dir#$REPO_ROOT/}"
  DEPTH=$(echo "$REL_PATH" | tr '/' '\n' | wc -l | tr -d ' ')

  # Check for indicators
  HAS_INIT=$([ -f "$dir/__init__.py" ] && echo "true" || echo "false")
  HAS_README=$([ -f "$dir/README.md" ] && echo "true" || echo "false")
  HAS_AGENTS=$([ -f "$dir/AGENTS.md" ] && echo "true" || echo "false")

  printf '{"path":"%s","depth":%d,"file_count":%d,"has_init":%s,"has_readme":%s,"has_agents_md":%s}\n' \
    "$REL_PATH" "$DEPTH" "$FILE_COUNT" "$HAS_INIT" "$HAS_README" "$HAS_AGENTS"
done | jq -s '.'
