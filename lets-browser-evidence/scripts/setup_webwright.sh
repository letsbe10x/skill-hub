#!/usr/bin/env bash
# Idempotent install of Microsoft Webwright (engine) under ~/.letsbe10x/tools/Webwright.
# Uses the active python3 interpreter (prefer a dedicated venv if you need isolation).
# Invoked by: scripts/setup.sh (lets skill install post-install or make lets-browser-evidence).
set -euo pipefail

WEBWRIGHT_HOME="${LETS_WEBWRIGHT_HOME:-${HOME}/.letsbe10x/tools/Webwright}"
STATE_DIR="${HOME}/.letsbe10x/config"
STATE_FILE="${STATE_DIR}/webwright-ready.json"
REPO_URL="https://github.com/microsoft/Webwright.git"
# Pin with LETS_WEBWRIGHT_GIT_REF (branch or tag). Override to lock supply chain in CI.
WEBWRIGHT_GIT_REF="${LETS_WEBWRIGHT_GIT_REF:-main}"
SKIP="${LETS_SKIP_WEBWRIGHT_SETUP:-}"

mkdir -p "${STATE_DIR}" "${HOME}/.letsbe10x/tools"

python_ok() {
  python3 -c 'import sys; raise SystemExit(0 if sys.version_info >= (3, 10) else 1)' 2>/dev/null
}

install_claude_webwright_plugin() {
  if ! command -v claude >/dev/null 2>&1; then
    echo ""
    echo "Claude CLI not found — skip host plugin (Cursor/Codex: use workspace contract or IDE browser MCP)."
    return 0
  fi
  if claude plugin list 2>/dev/null | grep -qE 'webwright@webwright'; then
    echo ""
    echo "Webwright Claude plugin already installed (restart Claude Code after first install)."
    return 0
  fi
  echo ""
  echo "Installing Webwright host plugin for Claude Code..."
  if ! claude plugin marketplace list 2>/dev/null | grep -qE 'webwright|Webwright'; then
    claude plugin marketplace add microsoft/Webwright || {
      echo "warning: could not add Webwright marketplace (install manually if needed)" >&2
      return 0
    }
  fi
  if claude plugin install webwright@webwright; then
    echo "Webwright plugin installed. Restart Claude Code so slash commands load."
  else
    echo "warning: plugin install failed — run manually:" >&2
    echo "  claude plugin marketplace add microsoft/Webwright" >&2
    echo "  claude plugin install webwright@webwright" >&2
  fi
}

engine_ready() {
  [[ -f "${STATE_FILE}" ]] && [[ -d "${WEBWRIGHT_HOME}/src/webwright" ]]
}

if [[ "${SKIP}" == "1" ]]; then
  echo "LETS_SKIP_WEBWRIGHT_SETUP=1 — skipping Webwright engine setup."
  install_claude_webwright_plugin
  exit 0
fi

if ! command -v python3 >/dev/null 2>&1 || ! python_ok; then
  echo "error: Python 3.10+ is required for Webwright. Install python3 and run make lets-browser-evidence again." >&2
  exit 1
fi

if engine_ready; then
  echo "Webwright engine already installed at ${WEBWRIGHT_HOME} (see ${STATE_FILE})."
else
  if [[ ! -d "${WEBWRIGHT_HOME}/.git" ]]; then
    echo "Cloning Webwright (${WEBWRIGHT_GIT_REF}) into ${WEBWRIGHT_HOME} ..."
    git clone --depth 1 --branch "${WEBWRIGHT_GIT_REF}" "${REPO_URL}" "${WEBWRIGHT_HOME}"
  fi

  echo "Installing Webwright Python package (editable) ..."
  (
    cd "${WEBWRIGHT_HOME}"
    python3 -m pip install -e . --quiet
  )

  echo "Installing Playwright browsers (chromium) ..."
  (
    cd "${WEBWRIGHT_HOME}"
    python3 -m playwright install chromium
  )

  installed_at="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  python3 - <<PY
import json
from pathlib import Path
state = {
    "engine": "microsoft-webwright",
    "home": "${WEBWRIGHT_HOME}",
    "git_ref": "${WEBWRIGHT_GIT_REF}",
    "installed_at": "${installed_at}",
    "cli_example": "python3 -m webwright.run.cli -c base.yaml -c model_openai.yaml",
}
Path("${STATE_FILE}").write_text(json.dumps(state, indent=2) + "\n")
PY

  echo "Wrote ${STATE_FILE}"
  echo ""
  echo "Webwright engine is ready at ${WEBWRIGHT_HOME}."
fi

install_claude_webwright_plugin

echo ""
echo "Standalone Webwright CLI runs need provider API keys in your environment (see Webwright README)."
echo "Codex plugin: codex plugin marketplace add microsoft/Webwright, then install from /plugins."
echo "Run doctor: make doctor-browser-evidence"
