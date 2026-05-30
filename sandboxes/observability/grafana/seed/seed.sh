#!/usr/bin/env bash
# Seed a sample dashboard into the running Grafana via the HTTP API.
set -euo pipefail

cd "$(dirname "$0")/.."
GRAFANA_URL="${GRAFANA_URL:-http://localhost:3000}"
GRAFANA_USER="${GRAFANA_USER:-admin}"
GRAFANA_PASSWORD="${GRAFANA_PASSWORD:-admin}"

if [ ! -f seed/sample-dashboard.json ]; then
  echo "✗ seed/sample-dashboard.json missing" >&2
  exit 1
fi

response=$(curl -fsS \
  -u "${GRAFANA_USER}:${GRAFANA_PASSWORD}" \
  -H "Content-Type: application/json" \
  -X POST "${GRAFANA_URL}/api/dashboards/db" \
  -d @seed/sample-dashboard.json)

uid=$(echo "$response" | jq -r '.uid')
url=$(echo "$response" | jq -r '.url')
echo "✓ created dashboard uid=$uid → ${GRAFANA_URL}${url}"
