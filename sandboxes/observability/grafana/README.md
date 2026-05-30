# Grafana sandbox

Spins up Grafana OSS locally via the official Docker image, seeds a sample
dashboard via the HTTP API, and verifies it via a round-trip API fetch.

## What this proves

That an integration which expects to create / read dashboards via Grafana's
HTTP API (`/api/dashboards/db`, `/api/dashboards/uid/<uid>`) works end-to-end
against a real Grafana instance.

## Prereqs

- Docker
- `curl`, `jq`

## Ports

| Port | Purpose |
|---|---|
| 3000 | Web UI + HTTP API — `http://localhost:3000` (login `admin` / `admin`) |

## Run the smoke test

```bash
./smoke.sh
```

Starts Grafana, waits until it's serving on `:3000`, creates a sample dashboard
via the API, reads it back by UID, asserts the title matches, prints `OK`.

## Leave it running

```bash
docker compose up -d
./seed/seed.sh
open http://localhost:3000   # admin / admin
docker compose down -v
```

## What gets seeded

One sample dashboard titled "lets-sandbox-demo" with a single time-series panel
querying Prometheus (or whatever the user wires later). See
[`seed/sample-dashboard.json`](seed/sample-dashboard.json).
