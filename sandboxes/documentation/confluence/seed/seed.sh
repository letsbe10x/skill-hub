#!/usr/bin/env bash
# Create a space + page in the running Confluence via REST API.
# Idempotent: space creation skips if it already exists.
set -euo pipefail

cd "$(dirname "$0")/.."

CONFLUENCE_URL="${CONFLUENCE_URL:-http://localhost:8090}"
CONFLUENCE_USER="${CONFLUENCE_USER:-admin}"
CONFLUENCE_PASSWORD="${CONFLUENCE_PASSWORD:-admin}"
CONFLUENCE_SPACE_KEY="${CONFLUENCE_SPACE_KEY:-LSB}"
CONFLUENCE_SPACE_NAME="${CONFLUENCE_SPACE_NAME:-Lets Sandbox}"

# Confirm setup is complete by checking serverInfo
serverinfo=$(curl -fsS -u "${CONFLUENCE_USER}:${CONFLUENCE_PASSWORD}" \
  "${CONFLUENCE_URL}/rest/applinks/1.0/manifest" 2>&1 || true)
if ! echo "$serverinfo" | grep -q "<application-type>" 2>/dev/null; then
  # Fallback check via the user API
  if ! curl -fsS -u "${CONFLUENCE_USER}:${CONFLUENCE_PASSWORD}" \
       "${CONFLUENCE_URL}/rest/api/user/current" 2>&1 | jq -e '.username // .displayName' >/dev/null 2>&1; then
    echo "✗ Confluence REST API is not responding to authenticated requests." >&2
    echo "  Likely cause: the setup wizard hasn't been completed yet." >&2
    echo "  Open ${CONFLUENCE_URL} in a browser and walk through the wizard, then re-run." >&2
    echo "  See ./README.md for the full setup steps." >&2
    exit 1
  fi
fi

echo "  Confluence user: $(curl -fsS -u "${CONFLUENCE_USER}:${CONFLUENCE_PASSWORD}" "${CONFLUENCE_URL}/rest/api/user/current" | jq -r '.username // .displayName // "(unknown)"')"

# Create space (idempotent — skip if exists)
existing=$(curl -s -o /dev/null -w "%{http_code}" -u "${CONFLUENCE_USER}:${CONFLUENCE_PASSWORD}" \
  "${CONFLUENCE_URL}/rest/api/space/${CONFLUENCE_SPACE_KEY}")
if [ "$existing" = "200" ]; then
  echo "✓ space ${CONFLUENCE_SPACE_KEY} already exists (skipping creation)"
else
  echo "→ creating space ${CONFLUENCE_SPACE_KEY}"
  space_payload=$(jq -n \
    --arg key "$CONFLUENCE_SPACE_KEY" \
    --arg name "$CONFLUENCE_SPACE_NAME" \
    '{
      key: $key,
      name: $name,
      description: {
        plain: {
          value: "Demo space for the lets-sandbox smoke test. Safe to delete.",
          representation: "plain"
        }
      }
    }')

  resp=$(curl -fsS -u "${CONFLUENCE_USER}:${CONFLUENCE_PASSWORD}" \
    -X POST "${CONFLUENCE_URL}/rest/api/space" \
    -H "Content-Type: application/json" \
    -d "$space_payload") || {
    echo "✗ space creation failed: $resp" >&2
    exit 1
  }
  echo "  ✓ created space"
fi

# Create a page
echo "→ creating sample page"
page_payload=$(jq -n \
  --arg key "$CONFLUENCE_SPACE_KEY" \
  '{
    type: "page",
    title: "Sandbox smoke page",
    space: {key: $key},
    body: {
      storage: {
        value: "<p>Created by the lets-sandbox smoke test. Safe to delete.</p>",
        representation: "storage"
      }
    }
  }')

page_resp=$(curl -fsS -u "${CONFLUENCE_USER}:${CONFLUENCE_PASSWORD}" \
  -X POST "${CONFLUENCE_URL}/rest/api/content" \
  -H "Content-Type: application/json" \
  -d "$page_payload")

page_id=$(echo "$page_resp" | jq -r '.id // empty')
if [ -z "$page_id" ]; then
  # Page may already exist with same title — that's fine
  echo "  (page may already exist with the same title; continuing)"
else
  echo "✓ created page id=${page_id}"
fi
