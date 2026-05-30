# Prometheus sandbox

Spins up Prometheus locally via the official Docker image, configured to scrape
itself out of the box. Verifies the integration by querying the `up` metric via
the HTTP API.

## What this proves

That an integration which expects to query metrics via Prometheus's HTTP API
(`/api/v1/query`, `/api/v1/query_range`) works end-to-end against a real
Prometheus instance with at least one healthy scrape target.

## Prereqs

- Docker
- `curl`, `jq`

## Ports

| Port | Purpose |
|---|---|
| 9090 | Web UI + HTTP API — `http://localhost:9090` |

## Run the smoke test

```bash
./smoke.sh
```

Starts Prometheus, waits until ready, queries the `up` metric (which reports
the health of each scrape target), asserts at least one target is up (itself),
prints `OK`.

## Leave it running

```bash
docker compose up -d
open http://localhost:9090   # explore in the web UI
docker compose down -v
```

## Scrape config

This sandbox ships a minimal [`prometheus.yml`](prometheus.yml) that scrapes
Prometheus itself every 5s. Add more scrape targets there if you want to test
integrations against richer metric data.

## Seeding extra metrics

For most integration tests, the self-scrape is enough — there are always
metrics flowing. To push custom metrics, either add a node-exporter or
pushgateway service to `docker-compose.yml`, or use the `seed/` directory
(currently empty by design).
