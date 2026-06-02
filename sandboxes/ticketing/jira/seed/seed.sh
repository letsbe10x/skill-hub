#!/usr/bin/env bash
# Create a project + issue in the running Jira via REST API.
# Idempotent: project creation skips if the project already exists.
set -euo pipefail

cd "$(dirname "$0")/.."

JIRA_URL="${JIRA_URL:-http://localhost:8080}"
JIRA_USER="${JIRA_USER:-admin}"
JIRA_PASSWORD="${JIRA_PASSWORD:-admin}"
JIRA_PROJECT_KEY="${JIRA_PROJECT_KEY:-LSB}"
JIRA_PROJECT_NAME="${JIRA_PROJECT_NAME:-Lets Sandbox}"

# Confirm Jira's setup wizard has been completed
serverinfo=$(curl -fsS -u "${JIRA_USER}:${JIRA_PASSWORD}" "${JIRA_URL}/rest/api/2/serverInfo" 2>&1 || true)
if ! echo "$serverinfo" | jq -e '.version' >/dev/null 2>&1; then
  echo "✗ Jira REST API is not responding to authenticated requests." >&2
  echo "  Likely cause: the setup wizard hasn't been completed yet." >&2
  echo "  Open ${JIRA_URL} in a browser and walk through the wizard, then re-run." >&2
  echo "  See ./README.md for the full setup steps." >&2
  exit 1
fi

echo "  Jira version: $(echo "$serverinfo" | jq -r '.version')"

# Discover the admin account ID (Jira needs an accountId, not a username)
admin_account=$(curl -fsS -u "${JIRA_USER}:${JIRA_PASSWORD}" \
  "${JIRA_URL}/rest/api/2/myself" | jq -r '.accountId // .key // .name')

if [ -z "$admin_account" ] || [ "$admin_account" = "null" ]; then
  echo "✗ Could not resolve admin account ID" >&2
  exit 1
fi
echo "  admin account: $admin_account"

# Create project (idempotent — skip if exists)
existing=$(curl -s -o /dev/null -w "%{http_code}" -u "${JIRA_USER}:${JIRA_PASSWORD}" \
  "${JIRA_URL}/rest/api/2/project/${JIRA_PROJECT_KEY}")
if [ "$existing" = "200" ]; then
  echo "✓ project ${JIRA_PROJECT_KEY} already exists (skipping creation)"
else
  echo "→ creating project ${JIRA_PROJECT_KEY}"
  payload=$(jq -n \
    --arg key "$JIRA_PROJECT_KEY" \
    --arg name "$JIRA_PROJECT_NAME" \
    --arg lead "$admin_account" \
    '{
      key: $key,
      name: $name,
      projectTypeKey: "software",
      projectTemplateKey: "com.pyxis.greenhopper.jira:gh-scrum-template",
      leadAccountId: $lead,
      assigneeType: "PROJECT_LEAD"
    }')

  resp=$(curl -fsS -u "${JIRA_USER}:${JIRA_PASSWORD}" \
    -X POST "${JIRA_URL}/rest/api/2/project" \
    -H "Content-Type: application/json" \
    -d "$payload" 2>&1) || {
    echo "✗ project creation failed:" >&2
    echo "$resp" >&2
    exit 1
  }
  echo "  ✓ created project"
fi

# Create an issue
echo "→ creating sample issue"
issue_payload=$(jq -n \
  --arg key "$JIRA_PROJECT_KEY" \
  '{
    fields: {
      project: {key: $key},
      summary: "Sandbox smoke issue",
      description: "Created by the lets-sandbox smoke test. Safe to delete.",
      issuetype: {name: "Task"}
    }
  }')

issue_resp=$(curl -fsS -u "${JIRA_USER}:${JIRA_PASSWORD}" \
  -X POST "${JIRA_URL}/rest/api/2/issue" \
  -H "Content-Type: application/json" \
  -d "$issue_payload")

issue_key=$(echo "$issue_resp" | jq -r '.key')
echo "✓ created issue ${issue_key}"
