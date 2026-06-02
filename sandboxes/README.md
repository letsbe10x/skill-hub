# Sandboxes

Self-contained local environments for the external tools the skills in this
repo integrate with. Each sandbox spins up a real instance via Docker, seeds
it with sample data, and ships a smoke script that proves the integration
works end-to-end. Their primary purpose is to validate the matching adapter
under `../adapters/<tool>/` before pointing it at a real production backend.

These are throwaway. Every sandbox has a `teardown` path that removes the
container and any volumes it created.

## Layout

```
sandboxes/
├── observability/    splunk, prometheus, jaeger, grafana
├── ticketing/        jira
├── documentation/    confluence
├── databases/        postgres
└── communication/    (placeholder — chatops/messaging)
```

Each tool sits directly under its vertical (`sandboxes/observability/splunk/`,
`sandboxes/databases/postgres/`). Categorization (logging vs monitoring,
relational vs NoSQL) lives as metadata in the tool's README, not as extra
directory levels. Many tools span categories — Splunk does logging AND
monitoring, Grafana spans dashboards AND alerting — and forcing a single
category created false choices.

## How each sandbox is structured

```
sandboxes/<vertical>/<tool>/
├── README.md                # what this proves, prereqs, ports used
├── docker-compose.yml       # the local stack
├── seed/
│   ├── seed.sh              # idempotent: inserts sample data
│   └── sample-*.{json,yml}  # the fixture data
└── smoke.sh                 # end-to-end: up → wait → seed → query → assert → done
```

Every sandbox follows the same contract:

| Script | What it does | Exit code |
|---|---|---|
| `docker compose up -d` | start the stack | 0 on success |
| `./seed/seed.sh` | insert sample data | 0 on success |
| `./smoke.sh` | run the full lifecycle (start → seed → query → teardown) | 0 if the integration works, non-zero otherwise |

## Requirements

- **Docker** (or Docker Desktop / Colima / OrbStack)
- **`curl`** for HTTP calls
- **`jq`** for JSON parsing in shell scripts
- That's it. No language-specific runtimes unless a specific sandbox calls them out.

## Running a sandbox

```bash
cd sandboxes/observability/splunk
./smoke.sh
# → starts Splunk, waits until healthy, ingests sample events,
#   queries them back, asserts the count, prints OK or fails
```

To leave the stack running for manual exploration:

```bash
docker compose up -d
./seed/seed.sh
# poke around at the URL listed in this folder's README
docker compose down -v   # clean up when done
```

## Adding a new sandbox

1. Pick the right vertical folder (or open an issue if none fits).
2. Create `sandboxes/<vertical>/<tool>/` with the four required pieces.
3. Use an officially supported Docker image (free tier or community edition).
4. Make `smoke.sh` exit non-zero on any failure; succeed only on a real round-trip.
5. Update the vertical's `README.md` table.
