#!/usr/bin/env bash
# check_blast_radius.sh — Find all importers of given files to assess blast radius
# Usage: ./check_blast_radius.sh <file1> [file2] ...
# Outputs importer count and list per file

set -euo pipefail

if [ $# -eq 0 ]; then
  echo "Usage: check_blast_radius.sh <file1> [file2] ..." >&2
  exit 1
fi

echo "=== Blast Radius Analysis ==="
echo ""

for FILE in "$@"; do
  [ -z "$FILE" ] && continue
  [ ! -f "$FILE" ] && continue

  # Extract module name
  BASENAME=$(basename "$FILE")
  MODULE="${BASENAME%.*}"

  echo "--- $FILE (module: $MODULE) ---"

  # Find importers (Python)
  PY_IMPORTERS=$(grep -rl "from.*$MODULE.*import\|import.*$MODULE" --include="*.py" . 2>/dev/null | grep -v "$FILE" | grep -v __pycache__ || true)

  # Find importers (TypeScript/JavaScript)
  JS_IMPORTERS=$(grep -rl "from.*['\"].*$MODULE['\"]\\|require.*['\"].*$MODULE['\"]" --include="*.ts" --include="*.js" --include="*.tsx" . 2>/dev/null | grep -v "$FILE" | grep -v node_modules || true)

  ALL_IMPORTERS=$(echo -e "${PY_IMPORTERS}\n${JS_IMPORTERS}" | grep -v "^$" | sort -u)
  COUNT=$(echo "$ALL_IMPORTERS" | grep -c "." 2>/dev/null || echo "0")

  echo "  Importers: $COUNT"
  if [ "$COUNT" -gt 0 ]; then
    echo "$ALL_IMPORTERS" | while read -r imp; do
      echo "    - $imp"
    done
  fi

  # Risk classification
  if [ "$COUNT" -gt 5 ]; then
    echo "  Risk: HIGH (widely shared)"
  elif [ "$COUNT" -gt 2 ]; then
    echo "  Risk: MEDIUM (shared interface)"
  else
    echo "  Risk: LOW (limited blast radius)"
  fi
  echo ""
done
