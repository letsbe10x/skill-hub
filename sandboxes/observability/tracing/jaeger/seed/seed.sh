#!/usr/bin/env bash
# Send a sample OTLP trace to the running Jaeger collector via OTLP HTTP.
# Generates fresh IDs and timestamps each run so traces are uniquely findable.
set -euo pipefail

cd "$(dirname "$0")/.."
OTLP_URL="${OTLP_URL:-http://localhost:4318/v1/traces}"
SERVICE_NAME="${SERVICE_NAME:-lets-sandbox-demo}"

hex32() {
  # 32 hex chars (128 bits) for trace IDs
  if command -v openssl >/dev/null; then openssl rand -hex 16
  else
    head -c 16 /dev/urandom | od -An -vtx1 | tr -d ' \n'
  fi
}

hex16() {
  # 16 hex chars (64 bits) for span IDs
  if command -v openssl >/dev/null; then openssl rand -hex 8
  else
    head -c 8 /dev/urandom | od -An -vtx1 | tr -d ' \n'
  fi
}

TRACE_ID="$(hex32)"
SPAN_ID="$(hex16)"

# OTLP wants nanoseconds since epoch
now_ns="$(date +%s)000000000"
START_NS="$now_ns"
END_NS="$((now_ns + 1000000))"  # 1ms later

payload=$(cat <<EOF
{
  "resourceSpans": [
    {
      "resource": {
        "attributes": [
          {"key": "service.name", "value": {"stringValue": "${SERVICE_NAME}"}},
          {"key": "service.version", "value": {"stringValue": "0.1.0"}}
        ]
      },
      "scopeSpans": [
        {
          "scope": {"name": "lets-sandbox", "version": "0.1.0"},
          "spans": [
            {
              "traceId": "${TRACE_ID}",
              "spanId": "${SPAN_ID}",
              "name": "demo-operation",
              "kind": 1,
              "startTimeUnixNano": "${START_NS}",
              "endTimeUnixNano": "${END_NS}",
              "attributes": [
                {"key": "demo.attribute", "value": {"stringValue": "hello"}},
                {"key": "demo.count", "value": {"intValue": 42}}
              ],
              "status": {"code": 1}
            }
          ]
        }
      ]
    }
  ]
}
EOF
)

response=$(curl -fsS \
  -X POST "${OTLP_URL}" \
  -H "Content-Type: application/json" \
  -d "$payload")

echo "✓ posted OTLP trace traceId=${TRACE_ID} spanId=${SPAN_ID} service=${SERVICE_NAME}"
[ -n "$response" ] && echo "  response: $response"
