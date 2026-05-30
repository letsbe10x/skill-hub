#!/usr/bin/env bash
# Readiness check for lets-record-demo. Exits non-zero if anything required is missing.
set -uo pipefail

TOOLS_DIR="${LETS_RECORD_DEMO_HOME:-${HOME}/.letsbe10x/tools/record-demo}"
STATE_FILE="${HOME}/.letsbe10x/config/record-demo-ready.json"

ok()   { printf '\033[32m✓\033[0m %s\n' "$*"; }
warn() { printf '\033[33m!\033[0m %s\n' "$*"; }
fail() { printf '\033[31m✗\033[0m %s\n' "$*"; }

problems=0

if command -v node >/dev/null 2>&1; then
  ok "node $(node --version)"
else
  fail "node missing"; problems=$((problems+1))
fi

if command -v ffmpeg >/dev/null 2>&1; then
  ok "ffmpeg $(ffmpeg -version 2>&1 | head -n1 | awk '{print $3}')"
else
  warn "ffmpeg missing — recording will work, conversion will not"
fi

if [[ -f "${TOOLS_DIR}/node_modules/playwright/package.json" ]]; then
  v="$(node -p "require('${TOOLS_DIR}/node_modules/playwright/package.json').version" 2>/dev/null || echo unknown)"
  ok "playwright ${v} installed at ${TOOLS_DIR}"
else
  fail "playwright not installed under ${TOOLS_DIR}"
  fail "  run: bash $(dirname "$0")/setup.sh"
  problems=$((problems+1))
fi

if [[ -f "${STATE_FILE}" ]]; then
  ok "state file ${STATE_FILE}"
else
  warn "state file missing — rerun setup.sh to refresh"
fi

# Try a non-destructive playwright sanity check
if [[ -f "${TOOLS_DIR}/node_modules/playwright/package.json" ]]; then
  if ( cd "${TOOLS_DIR}" && node -e "import('playwright').then(m => { if (!m.chromium) process.exit(1); }).catch(() => process.exit(1));" 2>/dev/null ); then
    ok "playwright module loads"
  else
    fail "playwright module failed to load — rerun setup.sh"
    problems=$((problems+1))
  fi
fi

if [[ "${problems}" -gt 0 ]]; then
  exit 1
fi
echo
ok "lets-record-demo is ready"
