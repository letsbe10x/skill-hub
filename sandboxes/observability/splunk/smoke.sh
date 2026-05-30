#!/usr/bin/env bash
# End-to-end smoke test:
#   start Splunk → wait until healthy → seed sample events → search → assert → teardown
#
# Exit codes:
#   0  full round-trip works
#   1  anything failed (start, healthcheck, seed, query, assertion)
set -euo pipefail

cd "$(dirname "$0")"
SPLUNK_PASSWORD="${SPLUNK_PASSWORD:-Changeme123!}"
MGMT_URL="https://localhost:8089"
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

echo "→ starting Splunk stack"
docker compose up -d --quiet-pull >/dev/null

echo "→ waiting for Splunk healthcheck (up to 5 min on first run)"
deadline=$(($(date +%s) + 300))
while true; do
  status=$(docker inspect -f '{{.State.Health.Status}}' lets-sandbox-splunk 2>/dev/null || echo "starting")
  if [ "$status" = "healthy" ]; then
    echo "✓ Splunk healthy"
    break
  fi
  if [ "$(date +%s)" -gt "$deadline" ]; then
    echo "✗ Splunk did not become healthy in 5 min (last status: $status)" >&2
    docker compose logs --tail 30 splunk >&2
    exit 1
  fi
  sleep 5
done

echo "→ seeding sample events via HEC"
./seed/seed.sh

echo "→ waiting for index propagation (5s)"
sleep 5

echo "→ creating a search job via REST"
sid=$(curl -sk -u "admin:${SPLUNK_PASSWORD}" \
  -d "search=search index=main sourcetype=access_combined" \
  -d "exec_mode=blocking" \
  -d "output_mode=json" \
  "${MGMT_URL}/services/search/jobs" \
  | jq -r '.sid')

if [ -z "$sid" ] || [ "$sid" = "null" ]; then
  echo "✗ search job create returned no SID" >&2
  exit 1
fi
echo "  sid=$sid"

echo "→ fetching results"
result_count=$(curl -sk -u "admin:${SPLUNK_PASSWORD}" \
  "${MGMT_URL}/services/search/jobs/${sid}/results?output_mode=json&count=100" \
  | jq -r '.results | length')

echo "  events returned: $result_count"

if [ -z "$result_count" ] || [ "$result_count" -lt 1 ]; then
  echo "✗ expected ≥1 events, got $result_count" >&2
  exit 1
fi

echo ""
echo "OK — Splunk sandbox round-trip succeeded ($result_count events ingested + queried)"
