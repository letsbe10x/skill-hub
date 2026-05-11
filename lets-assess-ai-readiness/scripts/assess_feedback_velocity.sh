#!/usr/bin/env bash
# assess_feedback_velocity.sh — Assess feedback velocity pillar
# Usage: ./assess_feedback_velocity.sh [repo_root]
# Outputs JSON with check results for feedback velocity pillar

set -euo pipefail

REPO_ROOT="${1:-.}"

# --- Check: test_runner_discoverable ---
TEST_CMD_FOUND="false"
TEST_CMD=""

# Check Makefile
if [ -f "$REPO_ROOT/Makefile" ]; then
  if grep -qE "^test[^a-zA-Z]|^test:" "$REPO_ROOT/Makefile" 2>/dev/null; then
    TEST_CMD_FOUND="true"
    TEST_CMD="make test"
  fi
fi

# Check package.json
if [ "$TEST_CMD_FOUND" = "false" ] && [ -f "$REPO_ROOT/package.json" ]; then
  if grep -q '"test"' "$REPO_ROOT/package.json" 2>/dev/null; then
    TEST_CMD_FOUND="true"
    TEST_CMD="npm test"
  fi
fi

# Check pyproject.toml
if [ "$TEST_CMD_FOUND" = "false" ] && [ -f "$REPO_ROOT/pyproject.toml" ]; then
  if grep -q "pytest\|unittest" "$REPO_ROOT/pyproject.toml" 2>/dev/null; then
    TEST_CMD_FOUND="true"
    TEST_CMD="pytest"
  fi
fi

# --- Check: scoped_execution ---
SCOPED_EXEC="false"
# Most test runners support path arguments by default
if [ "$TEST_CMD_FOUND" = "true" ]; then
  # pytest, jest, vitest, go test all support path args
  if echo "$TEST_CMD" | grep -qE "pytest|jest|vitest|go test|mocha"; then
    SCOPED_EXEC="true"
  fi
  # Check for test path in Makefile targets
  if grep -qE "^test-unit|^test-.*:" "$REPO_ROOT/Makefile" 2>/dev/null; then
    SCOPED_EXEC="true"
  fi
fi

# --- Check: test_convention_consistent ---
CONVENTION_CONSISTENT="unknown"
CONVENTION_RATIO="0"

# Count test files and check naming convention
TEST_FILES_TOTAL=0
TEST_FILES_PREFIX=0
TEST_FILES_SUFFIX=0
TEST_FILES_COLOCATED=0
TEST_FILES_SEPARATED=0

while IFS= read -r f; do
  TEST_FILES_TOTAL=$((TEST_FILES_TOTAL + 1))
  base=$(basename "$f")
  dir=$(dirname "$f")
  if echo "$base" | grep -qE "^test_|^test\."; then
    TEST_FILES_PREFIX=$((TEST_FILES_PREFIX + 1))
  elif echo "$base" | grep -qE "_test\.|\.test\.|\.spec\."; then
    TEST_FILES_SUFFIX=$((TEST_FILES_SUFFIX + 1))
  fi
  if echo "$dir" | grep -qE "tests?/|__tests__/|spec/"; then
    TEST_FILES_SEPARATED=$((TEST_FILES_SEPARATED + 1))
  else
    TEST_FILES_COLOCATED=$((TEST_FILES_COLOCATED + 1))
  fi
done < <(find "$REPO_ROOT" -type f \( -name "*test*" -o -name "*spec*" \) \
  -not -path "*node_modules*" -not -path "*/.git/*" -not -path "*venv*" \
  -not -path "*__pycache__*" -not -path "*dist/*" -not -path "*build/*" 2>/dev/null | head -100)

if [ "$TEST_FILES_TOTAL" -gt 0 ]; then
  # Check if >80% follow one convention
  MAX_CONVENTION=$TEST_FILES_PREFIX
  [ "$TEST_FILES_SUFFIX" -gt "$MAX_CONVENTION" ] && MAX_CONVENTION=$TEST_FILES_SUFFIX
  CONVENTION_RATIO=$(( (MAX_CONVENTION * 100) / TEST_FILES_TOTAL ))
  if [ "$CONVENTION_RATIO" -ge 80 ]; then
    CONVENTION_CONSISTENT="true"
  else
    CONVENTION_CONSISTENT="false"
  fi
fi

# --- Check: fast_target_exists ---
FAST_TARGET="false"
if [ -f "$REPO_ROOT/Makefile" ]; then
  if grep -qE "^(test-unit|test-fast|unit|smoke|quick)" "$REPO_ROOT/Makefile" 2>/dev/null; then
    FAST_TARGET="true"
  fi
fi
if [ -f "$REPO_ROOT/package.json" ]; then
  if grep -qE '"(test:unit|test:fast|unit|smoke)"' "$REPO_ROOT/package.json" 2>/dev/null; then
    FAST_TARGET="true"
  fi
fi

# --- Check: layered_validation ---
LAYERED="false"
LAYER_COUNT=0
if [ -f "$REPO_ROOT/Makefile" ]; then
  grep -cE "^test-(unit|integration|e2e|acceptance)" "$REPO_ROOT/Makefile" 2>/dev/null && \
    LAYER_COUNT=$(grep -cE "^test-(unit|integration|e2e|acceptance)" "$REPO_ROOT/Makefile" 2>/dev/null || echo "0")
fi
if [ -f "$REPO_ROOT/package.json" ]; then
  PKG_LAYERS=$(grep -cE '"test:(unit|integration|e2e|acceptance)"' "$REPO_ROOT/package.json" 2>/dev/null || echo "0")
  LAYER_COUNT=$((LAYER_COUNT + PKG_LAYERS))
fi
[ "$LAYER_COUNT" -ge 2 ] && LAYERED="true"

cat <<EOF
{
  "pillar": "feedback_velocity",
  "checks": {
    "test_runner_discoverable": {
      "status": "$TEST_CMD_FOUND",
      "evidence": "command: $TEST_CMD"
    },
    "scoped_execution": {
      "status": "$SCOPED_EXEC",
      "evidence": "path filtering supported"
    },
    "test_convention_consistent": {
      "status": "$CONVENTION_CONSISTENT",
      "evidence": "ratio: ${CONVENTION_RATIO}% (${TEST_FILES_TOTAL} test files)"
    },
    "fast_target_exists": {
      "status": "$FAST_TARGET",
      "evidence": "distinct fast/unit target in build surface"
    },
    "layered_validation": {
      "status": "$LAYERED",
      "evidence": "${LAYER_COUNT} distinct test layers"
    }
  }
}
EOF
