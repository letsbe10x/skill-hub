#!/usr/bin/env bash
# assess_determinism.sh — Assess determinism & reproducibility pillar
# Usage: ./assess_determinism.sh [repo_root]
# Outputs JSON with check results for determinism pillar

set -euo pipefail

REPO_ROOT="${1:-.}"

# --- Check: lockfile_present ---
LOCKFILE_PRESENT="false"
LOCKFILE_NAME="none"
for f in uv.lock poetry.lock Pipfile.lock package-lock.json pnpm-lock.yaml yarn.lock bun.lockb go.sum Cargo.lock Gemfile.lock composer.lock; do
  if [ -f "$REPO_ROOT/$f" ]; then
    LOCKFILE_PRESENT="true"
    LOCKFILE_NAME="$f"
    break
  fi
done

# --- Check: lockfile_committed (not in .gitignore) ---
LOCKFILE_COMMITTED="unknown"
if [ "$LOCKFILE_PRESENT" = "true" ] && [ -f "$REPO_ROOT/.gitignore" ]; then
  if grep -qF "$LOCKFILE_NAME" "$REPO_ROOT/.gitignore" 2>/dev/null; then
    LOCKFILE_COMMITTED="false"
  else
    LOCKFILE_COMMITTED="true"
  fi
elif [ "$LOCKFILE_PRESENT" = "true" ]; then
  LOCKFILE_COMMITTED="true"
fi

# --- Check: env_documented ---
ENV_DOCUMENTED="false"
for f in .env.example .env.sample .env.template env.example; do
  if [ -f "$REPO_ROOT/$f" ]; then
    ENV_DOCUMENTED="true"
    break
  fi
done
# Also check if there's no .env usage at all (doesn't need documentation)
if [ "$ENV_DOCUMENTED" = "false" ]; then
  ENV_REFS=$(grep -r "\.env\|dotenv\|load_dotenv\|config()" "$REPO_ROOT" --include="*.py" --include="*.ts" --include="*.js" --include="*.go" -l 2>/dev/null | grep -v node_modules | grep -v .git | wc -l | tr -d ' ')
  if [ "$ENV_REFS" -eq 0 ]; then
    ENV_DOCUMENTED="true"  # No .env usage, so no documentation needed
  fi
fi

# --- Check: test_isolation (heuristic) ---
TEST_ISOLATION="unknown"
ISOLATION_CONFIDENCE="0.5"

# Look for shared mutable state patterns in test files
SHARED_STATE_SIGNALS=0
if find "$REPO_ROOT" -name "*test*" -name "*.py" -not -path "*node_modules*" -not -path "*/.git/*" -exec grep -l "global\|shared_state\|class.*setUp" {} \; 2>/dev/null | head -5 | grep -q .; then
  SHARED_STATE_SIGNALS=$((SHARED_STATE_SIGNALS + 1))
fi

# Check for test isolation config
if grep -q "forked\|isolated\|parallel" "$REPO_ROOT/pyproject.toml" 2>/dev/null || \
   grep -q "\"--runInBand\"\|isolatedModules\|threads" "$REPO_ROOT/package.json" 2>/dev/null; then
  TEST_ISOLATION="true"
  ISOLATION_CONFIDENCE="0.8"
elif [ "$SHARED_STATE_SIGNALS" -gt 0 ]; then
  TEST_ISOLATION="false"
  ISOLATION_CONFIDENCE="0.6"
fi

# --- Check: no_network_in_tests (heuristic) ---
NETWORK_IN_TESTS="unknown"
NETWORK_CONFIDENCE="0.5"

# Look for unmocked HTTP calls in test files
NETWORK_PATTERNS=0
while IFS= read -r test_file; do
  if grep -qE "requests\.(get|post|put)|fetch\(|http\.Get|axios\." "$test_file" 2>/dev/null; then
    # Check if there's a mock/stub import in the same file
    if ! grep -qE "mock|Mock|patch|stub|nock|msw|httptest" "$test_file" 2>/dev/null; then
      NETWORK_PATTERNS=$((NETWORK_PATTERNS + 1))
    fi
  fi
done < <(find "$REPO_ROOT" -type f \( -name "*test*.py" -o -name "*test*.ts" -o -name "*test*.js" -o -name "*_test.go" \) \
  -not -path "*node_modules*" -not -path "*/.git/*" 2>/dev/null | head -50)

if [ "$NETWORK_PATTERNS" -eq 0 ]; then
  NETWORK_IN_TESTS="true"
  NETWORK_CONFIDENCE="0.7"
elif [ "$NETWORK_PATTERNS" -gt 3 ]; then
  NETWORK_IN_TESTS="false"
  NETWORK_CONFIDENCE="0.8"
else
  NETWORK_IN_TESTS="false"
  NETWORK_CONFIDENCE="0.6"
fi

cat <<EOF
{
  "pillar": "determinism",
  "checks": {
    "lockfile_present": {
      "status": "$LOCKFILE_PRESENT",
      "evidence": "lockfile: $LOCKFILE_NAME"
    },
    "lockfile_committed": {
      "status": "$LOCKFILE_COMMITTED",
      "evidence": "not in .gitignore"
    },
    "env_documented": {
      "status": "$ENV_DOCUMENTED",
      "evidence": ".env.example or no .env usage detected"
    },
    "test_isolation": {
      "status": "$TEST_ISOLATION",
      "confidence": $ISOLATION_CONFIDENCE,
      "evidence": "shared state signals: $SHARED_STATE_SIGNALS"
    },
    "no_network_in_tests": {
      "status": "$NETWORK_IN_TESTS",
      "confidence": $NETWORK_CONFIDENCE,
      "evidence": "unmocked network patterns: $NETWORK_PATTERNS"
    }
  }
}
EOF
