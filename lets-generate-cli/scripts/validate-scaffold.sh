#!/usr/bin/env bash
# Deterministic checks for a generated CLI scaffold.
# Usage: validate-scaffold.sh <scaffold-dir>
#
# Exit codes:
#   0  all checks passed
#   1  one or more checks failed
#   2  invalid invocation

set -e

if [ -z "${1:-}" ]; then
  echo "usage: validate-scaffold.sh <scaffold-dir>" >&2
  exit 2
fi

SCAFFOLD="$1"
if [ ! -d "$SCAFFOLD" ]; then
  echo "✗ not a directory: $SCAFFOLD" >&2
  exit 2
fi

cd "$SCAFFOLD"

fail=0
pass() { echo "✓ $1"; }
warn() { echo "⚠ $1"; }
fail() { echo "✗ $1" >&2; fail=$((fail + 1)); }

# Required top-level files
for f in pyproject.toml README.md; do
  if [ -f "$f" ]; then pass "$f present"; else fail "$f missing"; fi
done

# Optional blueprint
if [ -f "cligen.blueprint.json" ]; then
  pass "cligen.blueprint.json present"
  if command -v python3 >/dev/null && ! python3 -c "import json; json.load(open('cligen.blueprint.json'))" 2>/dev/null; then
    fail "cligen.blueprint.json is not valid JSON"
  fi
else
  warn "cligen.blueprint.json missing (optional but recommended)"
fi

# Source package
if ls src/*/cli.py >/dev/null 2>&1; then
  pass "src/<package>/cli.py present"
else
  fail "src/<package>/cli.py missing"
fi

if ls src/*/__init__.py >/dev/null 2>&1; then
  pass "src/<package>/__init__.py present"
else
  fail "src/<package>/__init__.py missing"
fi

# Tests
if [ -d "tests" ]; then
  pass "tests/ directory present"
  test_count=$(find tests -name "test_*.py" | wc -l | tr -d ' ')
  if [ "$test_count" -lt 2 ]; then
    fail "only $test_count test file(s); expected at least 2 (contract + one of request-plan/fixture)"
  else
    pass "$test_count test file(s) present"
  fi
else
  fail "tests/ directory missing"
fi

# Anti-pattern scan in source files
if find src tests -name "*.py" -print0 2>/dev/null | xargs -0 grep -l "shell=True" >/dev/null 2>&1; then
  fail "shell=True found in generated code (anti-pattern)"
else
  pass "no shell=True in generated code"
fi

if find src tests -name "*.py" -print0 2>/dev/null | xargs -0 grep -l "os.system" >/dev/null 2>&1; then
  fail "os.system() found in generated code (anti-pattern)"
else
  pass "no os.system() in generated code"
fi

# Every command should support --json
if grep -rE "@app\.command|@.*_app\.command" src --include "*.py" >/dev/null 2>&1; then
  cmd_count=$(grep -rE "@app\.command|@.*_app\.command" src --include "*.py" | wc -l | tr -d ' ')
  json_count=$(grep -rE "json_output|--json" src --include "*.py" | wc -l | tr -d ' ')
  if [ "$json_count" -ge "$cmd_count" ]; then
    pass "$cmd_count commands declared; --json wired"
  else
    warn "$cmd_count commands but only $json_count --json hits; verify every command supports --json"
  fi
fi

echo ""
if [ "$fail" -gt 0 ]; then
  echo "$fail check(s) failed."
  exit 1
fi
echo "all checks passed."
