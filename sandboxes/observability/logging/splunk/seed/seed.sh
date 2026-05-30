#!/usr/bin/env bash
# Seed the running Splunk container with sample events via HEC.
# Idempotent: re-running just appends another batch.
set -euo pipefail

cd "$(dirname "$0")/.."
HEC_URL="${HEC_URL:-https://localhost:8088}"
HEC_TOKEN="${SPLUNK_HEC_TOKEN:-00000000-0000-0000-0000-000000000000}"

if [ ! -f seed/sample-events.jsonl ]; then
  echo "✗ seed/sample-events.jsonl missing" >&2
  exit 1
fi

count=0
while IFS= read -r line; do
  [ -z "$line" ] && continue
  curl -sk \
    -X POST \
    -H "Authorization: Splunk ${HEC_TOKEN}" \
    -H "Content-Type: application/json" \
    "${HEC_URL}/services/collector/event" \
    -d "${line}" \
    -o /dev/null \
    -w "" \
    --fail-with-body
  count=$((count + 1))
done < seed/sample-events.jsonl

echo "✓ posted ${count} events to Splunk HEC at ${HEC_URL}"
