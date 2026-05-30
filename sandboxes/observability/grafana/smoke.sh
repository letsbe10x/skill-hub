#!/usr/bin/env bash
# Grafana sandbox smoke test:
#   start → wait healthy → seed dashboard → fetch by UID → assert title → teardown
set -euo pipefail

cd "$(dirname "$0")"
GRAFANA_URL="http://localhost:3000"
GRAFANA_USER="admin"
GRAFANA_PASSWORD="admin"
EXPECTED_TITLE="lets-sandbox-demo"
KEEP_RUNNING="${KEEP_RUNNING:-0}"

cleanup() {
  if [ "${KEEP_RUNNING}" = "0" ]; then
    echo "→ tearing down (set KEEP_RUNNING=1 to skip)"
    docker compose down -v >/dev/null 2>&1 || true
  fi
}
trap cleanup EXIT

echo "→ starting Grafana"
docker compose up -d --quiet-pull >/dev/null

echo "→ waiting for Grafana healthcheck"
deadline=$(($(date +%s) + 90))
while true; do
  status=$(docker inspect -f '{{.State.Health.Status}}' lets-sandbox-grafana 2>/dev/null || echo "starting")
  if [ "$status" = "healthy" ]; then echo "✓ Grafana healthy"; break; fi
  if [ "$(date +%s)" -gt "$deadline" ]; then
    echo "✗ Grafana did not become healthy in 90s (last: $status)" >&2
    docker compose logs --tail 30 grafana >&2
    exit 1
  fi
  sleep 2
done

echo "→ seeding dashboard"
./seed/seed.sh

echo "→ fetching dashboard by UID"
title=$(curl -fsS -u "${GRAFANA_USER}:${GRAFANA_PASSWORD}" \
  "${GRAFANA_URL}/api/dashboards/uid/${EXPECTED_TITLE}" \
  | jq -r '.dashboard.title')

echo "  title returned: $title"
if [ "$title" != "$EXPECTED_TITLE" ]; then
  echo "✗ expected title '$EXPECTED_TITLE', got '$title'" >&2
  exit 1
fi

echo ""
echo "OK — Grafana sandbox round-trip succeeded (dashboard created + fetched by UID)"
