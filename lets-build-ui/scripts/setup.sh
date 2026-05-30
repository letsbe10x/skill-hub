#!/usr/bin/env bash
# Ensure browser-evidence engine + plugin setup when the UI skill is installed alone.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DELEGATE="${ROOT}/../lets-browser-evidence/scripts/setup.sh"
STRICT="${LETS_SKILL_SETUP_STRICT:-}"

fail_or_warn() {
  local msg="$1"
  if [[ "${STRICT}" == "1" || "${STRICT}" == "true" || "${STRICT}" == "yes" ]]; then
    echo "error: ${msg}" >&2
    exit 1
  fi
  echo "warning: ${msg}" >&2
  exit 0
}

if [[ -f "${DELEGATE}" ]]; then
  exec bash "${DELEGATE}"
fi

if command -v lets >/dev/null 2>&1; then
  echo "lets-build-ui: installing lets-browser-evidence dependency..."
  PLATFORM="${LETS_SKILL_PLATFORM:-claude-code}"
  if lets skill install lets-browser-evidence --platform "${PLATFORM}"; then
    exit 0
  fi
  fail_or_warn "could not install lets-browser-evidence; run make lets-browser-evidence for browser capture."
fi

fail_or_warn "install lets-browser-evidence (make lets-browser-evidence) for Webwright setup."
