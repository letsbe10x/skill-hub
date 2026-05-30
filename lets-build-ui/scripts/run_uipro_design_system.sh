#!/usr/bin/env bash
set -euo pipefail

query="${1:-}"
project_name="${2:-Project}"

if [[ -z "${query}" ]]; then
  echo "Usage: run_uipro_design_system.sh \"your query\" \"Project Name\""
  exit 2
fi

if ! command -v python3 >/dev/null 2>&1; then
  echo "python3 is required."
  exit 1
fi

search_py=""

candidate_paths=(
  "$PWD/.codex/skills/ui-ux-pro-max/scripts/search.py"
  "$PWD/.claude/skills/ui-ux-pro-max/scripts/search.py"
  "$PWD/.cursor/skills/ui-ux-pro-max/scripts/search.py"
  "$HOME/.codex/skills/ui-ux-pro-max/scripts/search.py"
  "$HOME/.claude/skills/ui-ux-pro-max/scripts/search.py"
  "$HOME/.cursor/skills/ui-ux-pro-max/scripts/search.py"
)

for candidate in "${candidate_paths[@]}"; do
  if [[ -f "${candidate}" ]]; then
    search_py="${candidate}"
    break
  fi
done

if [[ -z "${search_py}" ]]; then
  search_py="$(find "$PWD" "$HOME" -maxdepth 6 -type f -path '*/ui-ux-pro-max/scripts/search.py' 2>/dev/null | head -n 1 || true)"
fi

if [[ -z "${search_py}" ]]; then
  echo "Could not locate UI/UX Pro Max search.py."
  echo "Proceed using the fallback brainstorm prompt instead."
  exit 1
fi

python3 "${search_py}" "${query}" --design-system -p "${project_name}"
