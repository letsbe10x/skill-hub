# Postgres sandbox

Local PostgreSQL 16 via the official Alpine image. Doubles as shared
infrastructure for any other sandbox that needs a postgres backend
(`jira`, `confluence`, future Bitbucket, etc.).

## What this proves

That a local postgres is up, accepts connections, and round-trips data
(`CREATE TABLE → INSERT → SELECT`). Confirms the per-app databases
(`jiradb`, `confluencedb`) created by the init script are reachable by
their owning users.

## Prereqs

- Docker
- `psql` not required on the host — the smoke runs it inside the container.

## Ports

| Port | Purpose |
|---|---|
| 5432 | Standard postgres TCP — `psql -h localhost -U postgres -d postgres` (password `postgres`) |

## Shared docker network

This sandbox creates an external docker network called **`lets-sandbox-data`**.
Other sandboxes that depend on postgres attach to this network and reach
postgres at hostname `lets-sandbox-postgres` (or just `postgres`).

This is why postgres must be `up` **before** any app sandbox that uses it.

## Run the smoke test

```bash
./smoke.sh
```

Starts postgres, waits healthy, runs a round-trip in the default DB, confirms
`jiradb` + `confluencedb` exist and their owning users (`jira`, `confluence`)
can connect, prints `OK`. Tears down unless `KEEP_RUNNING=1`.

## Use it as shared infrastructure

```bash
# Start once
cd ~/lets/skill-hub/sandboxes/databases/postgres
KEEP_RUNNING=1 ./smoke.sh

# Then any app sandbox that wires up shared postgres
cd ~/lets/skill-hub/sandboxes/ticketing/jira && docker compose up -d
cd ~/lets/skill-hub/sandboxes/documentation/confluence && docker compose up -d
```

## Adding a new app database

If you wire a new sandbox to shared postgres, edit
[`init/00-create-app-databases.sh`](init/00-create-app-databases.sh) to add
your app's `create_app_db <name>` line. The script runs **only on first boot**
of the postgres container — to apply changes to an already-initialised
postgres, run `docker compose down -v` first to wipe the data volume.

## Default credentials

| User | Password | Database | Notes |
|---|---|---|---|
| `postgres` | `postgres` | `postgres` | Superuser; for ad-hoc use |
| `jira` | `jira` | `jiradb` | Used by the Jira sandbox |
| `confluence` | `confluence` | `confluencedb` | Used by the Confluence sandbox |

These are local-sandbox-only credentials — never use them anywhere real.
