#!/usr/bin/env bash
# Jira sandbox smoke test:
#   start → wait healthy → check wizard done → seed project+issue → search → assert → teardown
#
# Notes:
# - First boot takes 3–5 min on Apple Silicon (Rosetta emulation)
# - The setup wizard MUST be completed manually once (see README.md). The
#   smoke script detects an incomplete setup and tells the user what to do.
# - Subsequent boots are fast (~30s) as long as the jira_data volume persists.
set -euo pipefail

cd "$(dirname "$0")"
[ -f .env ] && set -a && . ./.env && set +a
JIRA_URL="${JIRA_URL:-http://localhost:8080}"
JIRA_USER="${JIRA_USER:-admin}"
JIRA_PASSWORD="${JIRA_PASSWORD:-admin}"
JIRA_PROJECT_KEY="${JIRA_PROJECT_KEY:-LSB}"
KEEP_RUNNING="${KEEP_RUNNING:-0}"

cleanup() {
  if [ "${KEEP_RUNNING}" = "0" ]; then
    echo "→ tearing down (set KEEP_RUNNING=1 to skip)"
    docker compose down -v >/dev/null 2>&1 || true
  else
    echo "→ stack left running (KEEP_RUNNING=1)"
  fi
}
trap cleanup EXIT

echo "→ starting Jira"
docker compose up -d --quiet-pull >/dev/null

echo "→ waiting for Jira healthcheck (5 min on first run; ~30s on warm restart)"
deadline=$(($(date +%s) + 400))
while true; do
  status=$(docker inspect -f '{{.State.Health.Status}}' lets-sandbox-jira 2>/dev/null || echo "starting")
  if [ "$status" = "healthy" ]; then echo "✓ Jira responding"; break; fi
  if [ "$(date +%s)" -gt "$deadline" ]; then
    echo "✗ Jira did not become healthy in 6.5 min (last: $status)" >&2
    docker compose logs --tail 40 jira >&2
    exit 1
  fi
  sleep 10
done

echo "→ checking if setup wizard has been completed"
status_body=$(curl -fsS "${JIRA_URL}/status" 2>&1 || true)
jira_state=$(echo "$status_body" | jq -r '.state // "UNKNOWN"' 2>/dev/null || echo "UNKNOWN")
echo "  Jira state: $jira_state"

if [ "$jira_state" = "FIRST_RUN" ]; then
  echo ""
  echo "⚠ Jira is in FIRST_RUN state — the setup wizard hasn't been completed."
  echo ""
  echo "  Open ${JIRA_URL} in your browser and walk through the wizard:"
  echo "    1. (Database step is auto-skipped — postgres is pre-configured)"
  echo "    2. License → 'Get an evaluation license' (free 30-day server trial)"
  echo "    3. Application Properties → defaults are fine"
  echo "    4. Admin account → ${JIRA_USER} / ${JIRA_PASSWORD}"
  echo "    5. Skip email"
  echo ""
  echo "  Then re-run ./smoke.sh (the jira_data volume persists across restarts)."
  echo ""
  KEEP_RUNNING=1
  exit 1
fi

echo "→ seeding sample project + issue"
./seed/seed.sh

echo "→ waiting for indexing (3s)"
sleep 3

echo "→ searching for the issue via REST API"
result=$(curl -fsS -u "${JIRA_USER}:${JIRA_PASSWORD}" \
  "${JIRA_URL}/rest/api/2/search?jql=project=${JIRA_PROJECT_KEY}&fields=summary,status")

total=$(echo "$result" | jq -r '.total')
echo "  issues found in ${JIRA_PROJECT_KEY}: $total"

if [ -z "$total" ] || [ "$total" -lt 1 ]; then
  echo "✗ expected ≥1 issue in project ${JIRA_PROJECT_KEY}, got $total" >&2
  echo "  raw response: $result" >&2
  exit 1
fi

echo ""
echo "OK — Jira sandbox round-trip succeeded ($total issue(s) in ${JIRA_PROJECT_KEY})"
