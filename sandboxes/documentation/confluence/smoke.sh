#!/usr/bin/env bash
# Confluence sandbox smoke test:
#   start → wait healthy → check wizard done → seed space+page → search → assert → teardown
set -euo pipefail

cd "$(dirname "$0")"
[ -f .env ] && set -a && . ./.env && set +a
CONFLUENCE_URL="${CONFLUENCE_URL:-http://localhost:8090}"
CONFLUENCE_USER="${CONFLUENCE_USER:-admin}"
CONFLUENCE_PASSWORD="${CONFLUENCE_PASSWORD:-admin}"
CONFLUENCE_SPACE_KEY="${CONFLUENCE_SPACE_KEY:-LSB}"
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

echo "→ starting Confluence"
docker compose up -d --quiet-pull >/dev/null

echo "→ waiting for Confluence healthcheck (5 min on first run; ~30s on warm restart)"
deadline=$(($(date +%s) + 400))
while true; do
  status=$(docker inspect -f '{{.State.Health.Status}}' lets-sandbox-confluence 2>/dev/null || echo "starting")
  if [ "$status" = "healthy" ]; then echo "✓ Confluence responding"; break; fi
  if [ "$(date +%s)" -gt "$deadline" ]; then
    echo "✗ Confluence did not become healthy in 6.5 min (last: $status)" >&2
    docker compose logs --tail 40 confluence >&2
    exit 1
  fi
  sleep 10
done

echo "→ checking if setup wizard has been completed"
status_body=$(curl -fsS "${CONFLUENCE_URL}/status" 2>&1 || true)
conf_state=$(echo "$status_body" | jq -r '.state // "UNKNOWN"' 2>/dev/null || echo "UNKNOWN")
echo "  Confluence state: $conf_state"

if [ "$conf_state" = "FIRST_RUN" ]; then
  echo ""
  echo "⚠ Confluence is in FIRST_RUN state — the setup wizard hasn't been completed."
  echo ""
  echo "  Open ${CONFLUENCE_URL} in your browser and walk through the wizard:"
  echo "    1. Production Installation"
  echo "    2. License → 'Get a Confluence trial license' (30-day, free)"
  echo "    3. Database → Built-in (H2)"
  echo "    4. Load Content → Empty Site"
  echo "    5. User Management → Manage within Confluence"
  echo "    6. Admin → ${CONFLUENCE_USER} / ${CONFLUENCE_PASSWORD}"
  echo ""
  echo "  Then re-run ./smoke.sh (the data volume persists across restarts)."
  echo ""
  KEEP_RUNNING=1
  exit 1
fi

echo "→ seeding sample space + page"
./seed/seed.sh

echo "→ waiting for indexing (3s)"
sleep 3

echo "→ searching for the page via REST API"
result=$(curl -fsS -u "${CONFLUENCE_USER}:${CONFLUENCE_PASSWORD}" \
  "${CONFLUENCE_URL}/rest/api/content?spaceKey=${CONFLUENCE_SPACE_KEY}&type=page&limit=10")

count=$(echo "$result" | jq -r '.size // (.results | length) // 0')
echo "  pages found in ${CONFLUENCE_SPACE_KEY}: $count"

if [ -z "$count" ] || [ "$count" -lt 1 ]; then
  echo "✗ expected ≥1 page in space ${CONFLUENCE_SPACE_KEY}, got $count" >&2
  echo "  raw response: $result" >&2
  exit 1
fi

echo ""
echo "OK — Confluence sandbox round-trip succeeded ($count page(s) in ${CONFLUENCE_SPACE_KEY})"
