#!/usr/bin/env bash
# Idempotent install of Playwright + headless Chromium under
# ~/.letsbe10x/tools/record-demo/, plus an ffmpeg presence check.
# Skip in CI / air-gapped: LETS_SKIP_RECORD_DEMO_SETUP=1
set -euo pipefail

TOOLS_DIR="${LETS_RECORD_DEMO_HOME:-${HOME}/.letsbe10x/tools/record-demo}"
STATE_DIR="${HOME}/.letsbe10x/config"
STATE_FILE="${STATE_DIR}/record-demo-ready.json"
PLAYWRIGHT_VERSION="${LETS_RECORD_DEMO_PLAYWRIGHT_VERSION:-1.60.0}"
SKIP="${LETS_SKIP_RECORD_DEMO_SETUP:-}"

mkdir -p "${TOOLS_DIR}" "${STATE_DIR}"

note() { printf '  %s\n' "$*"; }
ok()   { printf '\033[32m✓\033[0m %s\n' "$*"; }
warn() { printf '\033[33m!\033[0m %s\n' "$*" >&2; }
fail() { printf '\033[31m✗\033[0m %s\n' "$*" >&2; exit 1; }

check_node() {
  if ! command -v node >/dev/null 2>&1; then
    fail "node not found. Install Node.js 18+ from https://nodejs.org or your package manager."
  fi
  local major
  major="$(node -p 'process.versions.node.split(".")[0]')"
  if [[ "${major}" -lt 18 ]]; then
    fail "node ${major}.x detected — need >= 18. Upgrade Node.js."
  fi
  ok "node $(node --version)"
}

check_ffmpeg() {
  if ! command -v ffmpeg >/dev/null 2>&1; then
    warn "ffmpeg not found on PATH. Install one of:"
    note "  macOS:   brew install ffmpeg"
    note "  Debian:  sudo apt install ffmpeg"
    note "  Fedora:  sudo dnf install ffmpeg"
    note "  Windows: choco install ffmpeg  (or: winget install ffmpeg)"
    note "Recording will still work; conversion to .mov/.mp4/.gif will fail until ffmpeg is installed."
    return 1
  fi
  ok "ffmpeg $(ffmpeg -version 2>&1 | head -n1 | awk '{print $3}')"
}

install_playwright() {
  if [[ "${SKIP}" == "1" ]]; then
    warn "LETS_SKIP_RECORD_DEMO_SETUP=1 — skipping Playwright install."
    return 0
  fi
  if [[ -f "${TOOLS_DIR}/node_modules/playwright/package.json" ]]; then
    local installed
    installed="$(node -p "require('${TOOLS_DIR}/node_modules/playwright/package.json').version" 2>/dev/null || echo unknown)"
    if [[ "${installed}" == "${PLAYWRIGHT_VERSION}" ]]; then
      ok "playwright ${installed} (already installed)"
      return 0
    fi
    note "playwright ${installed} → ${PLAYWRIGHT_VERSION}, reinstalling"
  fi

  # Create a minimal package.json so npm has somewhere to anchor.
  if [[ ! -f "${TOOLS_DIR}/package.json" ]]; then
    cat > "${TOOLS_DIR}/package.json" <<JSON
{
  "name": "letsbe10x-record-demo-tools",
  "private": true,
  "version": "0.1.0",
  "type": "module"
}
JSON
  fi

  ( cd "${TOOLS_DIR}" && npm install --silent --no-fund --no-audit "playwright@${PLAYWRIGHT_VERSION}" )
  ok "installed playwright@${PLAYWRIGHT_VERSION}"
}

install_chromium() {
  if [[ "${SKIP}" == "1" ]]; then
    warn "LETS_SKIP_RECORD_DEMO_SETUP=1 — skipping Chromium download."
    return 0
  fi
  # `npx playwright install chromium` is idempotent and prints "is already installed" if so.
  ( cd "${TOOLS_DIR}" && npx --yes playwright install chromium )
  ok "chromium ready"
}

write_state() {
  local now
  now="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  node -e '
    const fs = require("fs");
    const state = {
      tool: "letsbe10x/lets-record-demo",
      tools_dir: process.argv[1],
      playwright_version: process.argv[2],
      ffmpeg_present: process.argv[3] === "1",
      installed_at: process.argv[4],
    };
    fs.writeFileSync(process.argv[5], JSON.stringify(state, null, 2) + "\n");
  ' "${TOOLS_DIR}" "${PLAYWRIGHT_VERSION}" "${HAS_FFMPEG:-0}" "${now}" "${STATE_FILE}"
  ok "wrote ${STATE_FILE}"
}

echo "▲ lets-record-demo setup"
echo

HAS_FFMPEG=0
check_node
if check_ffmpeg; then HAS_FFMPEG=1; fi
install_playwright
install_chromium
write_state

echo
ok "Ready. Verify any time with:"
note "  bash $(dirname "$0")/doctor.sh"
echo
ok "Record a demo:"
note "  node $(dirname "$0")/record.mjs --flow <flow.json> --out <out.mov>"
