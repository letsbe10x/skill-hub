#!/usr/bin/env bash
# Postgres sandbox smoke test:
#   start → wait healthy → connect → create table → insert → select → assert → teardown
#
# Exit codes:
#   0  postgres is up and round-trips data
#   1  anything failed
set -euo pipefail

cd "$(dirname "$0")"
KEEP_RUNNING="${KEEP_RUNNING:-0}"

cleanup() {
  if [ "${KEEP_RUNNING}" = "0" ]; then
    echo "→ tearing down (set KEEP_RUNNING=1 to skip)"
    docker compose down -v >/dev/null 2>&1 || true
  else
    echo "→ stack left running (KEEP_RUNNING=1) — shared on network lets-sandbox-data"
  fi
}
trap cleanup EXIT

echo "→ starting postgres"
docker compose up -d --quiet-pull >/dev/null

echo "→ waiting for postgres healthcheck"
deadline=$(($(date +%s) + 60))
while true; do
  status=$(docker inspect -f '{{.State.Health.Status}}' lets-sandbox-postgres 2>/dev/null || echo "starting")
  if [ "$status" = "healthy" ]; then echo "✓ postgres healthy"; break; fi
  if [ "$(date +%s)" -gt "$deadline" ]; then
    echo "✗ postgres did not become healthy in 60s (last: $status)" >&2
    docker compose logs --tail 30 postgres >&2
    exit 1
  fi
  sleep 2
done

echo "→ confirming default postgres user round-trip"
docker exec -i lets-sandbox-postgres psql -U postgres -d postgres -v ON_ERROR_STOP=1 -q <<'SQL'
CREATE TABLE IF NOT EXISTS sandbox_smoke (id serial PRIMARY KEY, note text);
INSERT INTO sandbox_smoke (note) VALUES ('lets-sandbox smoke test');
SQL

count=$(docker exec lets-sandbox-postgres psql -U postgres -d postgres -tAc "SELECT count(*) FROM sandbox_smoke WHERE note = 'lets-sandbox smoke test';")
echo "  rows matching the smoke note: $count"
[ "$count" -ge 1 ] || { echo "✗ expected ≥1 row, got $count" >&2; exit 1; }

echo "→ confirming app databases were created by init script"
for app in jira confluence; do
  exists=$(docker exec lets-sandbox-postgres psql -U postgres -tAc "SELECT 1 FROM pg_database WHERE datname = '${app}db';")
  if [ "$exists" = "1" ]; then
    echo "  ✓ ${app}db present (owner ${app})"
  else
    echo "  ✗ ${app}db missing — init script failed" >&2
    exit 1
  fi
done

echo "→ confirming app users can connect to their own database"
for app in jira confluence; do
  ok=$(docker exec lets-sandbox-postgres psql -U "$app" -d "${app}db" -tAc "SELECT 'OK';" 2>&1 | tr -d ' ')
  if [ "$ok" = "OK" ]; then
    echo "  ✓ ${app} can connect to ${app}db"
  else
    echo "  ✗ ${app} cannot connect: $ok" >&2
    exit 1
  fi
done

echo ""
echo "OK — postgres sandbox round-trip succeeded"
echo "  default postgres DB: round-trip verified"
echo "  app databases ready: jiradb, confluencedb"
echo "  shared on docker network: lets-sandbox-data"
