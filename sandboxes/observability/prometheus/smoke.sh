#!/usr/bin/env bash
# Prometheus sandbox smoke test:
#   start → wait healthy → query `up` metric → assert ≥1 series → teardown
set -euo pipefail

cd "$(dirname "$0")"
PROM_URL="http://localhost:9090"
KEEP_RUNNING="${KEEP_RUNNING:-0}"

cleanup() {
  if [ "${KEEP_RUNNING}" = "0" ]; then
    echo "→ tearing down (set KEEP_RUNNING=1 to skip)"
    docker compose down -v >/dev/null 2>&1 || true
  fi
}
trap cleanup EXIT

echo "→ starting Prometheus"
docker compose up -d --quiet-pull >/dev/null

echo "→ waiting for Prometheus healthcheck"
deadline=$(($(date +%s) + 60))
while true; do
  status=$(docker inspect -f '{{.State.Health.Status}}' lets-sandbox-prometheus 2>/dev/null || echo "starting")
  if [ "$status" = "healthy" ]; then echo "✓ Prometheus healthy"; break; fi
  if [ "$(date +%s)" -gt "$deadline" ]; then
    echo "✗ Prometheus did not become healthy in 60s (last: $status)" >&2
    docker compose logs --tail 30 prometheus >&2
    exit 1
  fi
  sleep 2
done

echo "→ waiting for the first scrape cycle"
sleep 6

echo "→ querying the 'up' metric"
response=$(curl -fsS "${PROM_URL}/api/v1/query?query=up")
series_count=$(echo "$response" | jq -r '.data.result | length')
up_count=$(echo "$response" | jq -r '[.data.result[] | select(.value[1] == "1")] | length')

echo "  series returned: $series_count"
echo "  up=1 series:     $up_count"

if [ -z "$series_count" ] || [ "$series_count" -lt 1 ]; then
  echo "✗ expected ≥1 'up' series, got $series_count" >&2
  exit 1
fi
if [ "$up_count" -lt 1 ]; then
  echo "✗ expected ≥1 target reporting up=1, got $up_count" >&2
  exit 1
fi

echo ""
echo "OK — Prometheus sandbox round-trip succeeded ($up_count target(s) up)"
