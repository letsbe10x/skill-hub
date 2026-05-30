#!/usr/bin/env bash
# Jaeger sandbox smoke test:
#   start → wait healthy → send OTLP trace → query by service → assert ≥1 trace → teardown
set -euo pipefail

cd "$(dirname "$0")"
JAEGER_URL="http://localhost:16686"
SERVICE_NAME="lets-sandbox-demo"
KEEP_RUNNING="${KEEP_RUNNING:-0}"

cleanup() {
  if [ "${KEEP_RUNNING}" = "0" ]; then
    echo "→ tearing down (set KEEP_RUNNING=1 to skip)"
    docker compose down -v >/dev/null 2>&1 || true
  fi
}
trap cleanup EXIT

echo "→ starting Jaeger"
docker compose up -d --quiet-pull >/dev/null

echo "→ waiting for Jaeger healthcheck"
deadline=$(($(date +%s) + 60))
while true; do
  status=$(docker inspect -f '{{.State.Health.Status}}' lets-sandbox-jaeger 2>/dev/null || echo "starting")
  if [ "$status" = "healthy" ]; then echo "✓ Jaeger healthy"; break; fi
  if [ "$(date +%s)" -gt "$deadline" ]; then
    echo "✗ Jaeger did not become healthy in 60s (last: $status)" >&2
    docker compose logs --tail 30 jaeger >&2
    exit 1
  fi
  sleep 2
done

echo "→ sending sample OTLP trace"
SERVICE_NAME="$SERVICE_NAME" ./seed/seed.sh

echo "→ waiting for trace propagation (3s)"
sleep 3

echo "→ querying Jaeger for the service"
response=$(curl -fsS "${JAEGER_URL}/api/traces?service=${SERVICE_NAME}&limit=10")
trace_count=$(echo "$response" | jq -r '.data | length')

echo "  traces returned: $trace_count"
if [ -z "$trace_count" ] || [ "$trace_count" -lt 1 ]; then
  echo "✗ expected ≥1 traces for service '${SERVICE_NAME}', got $trace_count" >&2
  echo "  response: $response" >&2
  exit 1
fi

echo ""
echo "OK — Jaeger sandbox round-trip succeeded ($trace_count trace(s) for service '${SERVICE_NAME}')"
