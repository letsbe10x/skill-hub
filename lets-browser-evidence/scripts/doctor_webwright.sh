#!/usr/bin/env bash
# Quick readiness check for Webwright engine + Playwright browsers.
set -euo pipefail

WEBWRIGHT_HOME="${LETS_WEBWRIGHT_HOME:-${HOME}/.letsbe10x/tools/Webwright}"
STATE_FILE="${HOME}/.letsbe10x/config/webwright-ready.json"
ok=0
fail=0

check() {
  if "$@"; then
    echo "  ok: $*"
    ok=$((ok + 1))
  else
    echo "  FAIL: $*" >&2
    fail=$((fail + 1))
  fi
}

echo "lets-browser-evidence doctor"
echo ""

check test -f "${STATE_FILE}"
check test -d "${WEBWRIGHT_HOME}"
check test -d "${WEBWRIGHT_HOME}/src/webwright"
check python3 -c "import webwright" 2>/dev/null
check python3 -c "import playwright" 2>/dev/null

if command -v playwright >/dev/null 2>&1; then
  check playwright install --dry-run chromium
fi

if command -v claude >/dev/null 2>&1; then
  if claude plugin list 2>/dev/null | grep -qE 'webwright@webwright'; then
    echo "  ok: claude plugin webwright@webwright installed"
    ok=$((ok + 1))
  else
    echo "  optional: claude plugin webwright@webwright not installed (run make lets-browser-evidence again)" >&2
  fi
fi

echo ""
if [[ "${fail}" -gt 0 ]]; then
  echo "Not ready. Run: make lets-browser-evidence"
  exit 1
fi
echo "Ready (${ok} checks passed)."
