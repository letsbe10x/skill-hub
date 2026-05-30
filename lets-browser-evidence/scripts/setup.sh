#!/usr/bin/env bash
# Canonical post-install entrypoint (invoked by `lets skill install` and make targets).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
exec bash "${ROOT}/scripts/setup_webwright.sh"
