#!/usr/bin/env bash
# classify_risk.sh — Scan target files for risk signals
# Usage: ./classify_risk.sh [file1] [file2] ... or pipe file list
# Outputs risk assessment JSON

set -euo pipefail

# Accept files as args or from stdin
if [ $# -gt 0 ]; then
  FILES=("$@")
else
  mapfile -t FILES < <(cat)
fi

if [ ${#FILES[@]} -eq 0 ]; then
  echo "Usage: classify_risk.sh file1 [file2 ...]" >&2
  echo "  or: git diff --name-only | classify_risk.sh" >&2
  exit 1
fi

# --- Risk signal detection ---
SIGNALS=""
RISK_LEVEL="low"
CRITICAL_FILES=""

for FILE in "${FILES[@]}"; do
  [ -z "$FILE" ] && continue

  # Check for critical path markers in file content
  if [ -f "$FILE" ]; then
    if grep -qiE "CRITICAL|DO NOT MODIFY|security review required" "$FILE" 2>/dev/null; then
      SIGNALS="${SIGNALS}critical_path_marker:$FILE,"
      CRITICAL_FILES="${CRITICAL_FILES}$FILE,"
      RISK_LEVEL="high"
    fi
  fi

  # Check file path patterns
  if echo "$FILE" | grep -qiE "(auth|security|crypto|permission|secret|password)"; then
    SIGNALS="${SIGNALS}security_code:$FILE,"
    RISK_LEVEL="high"
  fi

  if echo "$FILE" | grep -qiE "(migration|schema|alembic|flyway)"; then
    SIGNALS="${SIGNALS}database_migration:$FILE,"
    RISK_LEVEL="high"
  fi

  if echo "$FILE" | grep -qiE "(api/|routes/|handlers/|controllers/|openapi)"; then
    SIGNALS="${SIGNALS}api_surface:$FILE,"
    [ "$RISK_LEVEL" != "high" ] && RISK_LEVEL="medium"
  fi

  if echo "$FILE" | grep -qiE "(utils/|common/|shared/|lib/)"; then
    SIGNALS="${SIGNALS}shared_utility:$FILE,"
    [ "$RISK_LEVEL" != "high" ] && RISK_LEVEL="medium"
  fi

  if echo "$FILE" | grep -qiE "(Dockerfile|\.github/|ci/|deploy/|infra/)"; then
    SIGNALS="${SIGNALS}infrastructure:$FILE,"
    [ "$RISK_LEVEL" != "high" ] && RISK_LEVEL="medium"
  fi

  # Check for irreversible operations in file content
  if [ -f "$FILE" ]; then
    if grep -qiE "DROP TABLE|DELETE FROM|rm -rf|shutil.rmtree|os.remove" "$FILE" 2>/dev/null; then
      SIGNALS="${SIGNALS}irreversible_operation:$FILE,"
      RISK_LEVEL="critical"
    fi
  fi
done

# Check importer count for shared files (blast radius)
SHARED_FILES=""
for FILE in "${FILES[@]}"; do
  [ -z "$FILE" ] && continue
  [ ! -f "$FILE" ] && continue

  MODULE=$(basename "$FILE" .py | sed 's/.ts$//' | sed 's/.js$//')
  IMPORTER_COUNT=$(grep -rl "$MODULE" --include="*.py" --include="*.ts" --include="*.js" . 2>/dev/null | wc -l | tr -d ' ')

  if [ "$IMPORTER_COUNT" -gt 3 ]; then
    SHARED_FILES="${SHARED_FILES}$FILE:$IMPORTER_COUNT,"
    [ "$RISK_LEVEL" = "low" ] && RISK_LEVEL="medium"
    SIGNALS="${SIGNALS}shared_interface(${IMPORTER_COUNT}_importers):$FILE,"
  fi
done

# Clean trailing commas
SIGNALS=$(echo "$SIGNALS" | sed 's/,$//')
CRITICAL_FILES=$(echo "$CRITICAL_FILES" | sed 's/,$//')
SHARED_FILES=$(echo "$SHARED_FILES" | sed 's/,$//')

# --- Determine rigor ---
FILE_COUNT=${#FILES[@]}
if [ "$RISK_LEVEL" = "critical" ] || [ "$FILE_COUNT" -gt 10 ]; then
  RIGOR="FULL"
elif [ "$RISK_LEVEL" = "high" ] || [ "$FILE_COUNT" -gt 5 ]; then
  RIGOR="ELEVATED"
elif [ "$FILE_COUNT" -le 2 ] && [ "$RISK_LEVEL" = "low" ]; then
  RIGOR="MINIMAL"
else
  RIGOR="STANDARD"
fi

# --- Output ---
cat <<EOF
{
  "file_count": $FILE_COUNT,
  "risk_level": "$RISK_LEVEL",
  "rigor": "$RIGOR",
  "signals": "$(echo "$SIGNALS" | tr ',' '\n' | head -10 | tr '\n' ',' | sed 's/,$//')",
  "critical_path_files": "$(echo "$CRITICAL_FILES")",
  "shared_interfaces": "$(echo "$SHARED_FILES")",
  "design_checkpoint_required": $([ "$RIGOR" = "ELEVATED" ] || [ "$RIGOR" = "FULL" ] && echo "true" || echo "false")
}
EOF
