# Splunk sandbox

Spins up Splunk Enterprise locally via the official Docker image (free 60-day
trial, no signup required), enables the HTTP Event Collector (HEC), ingests a
handful of sample events, and queries them back via the REST API.

## What this proves

That an integration which expects to push events to Splunk via HEC and read
them back via `services/search/jobs` can be tested end-to-end against a real
Splunk instance — no hosted account, no SAML, no PAT.

## Prereqs

- Docker
- `curl`, `jq`

## Ports

| Port | Purpose |
|---|---|
| 8000 | Web UI — `http://localhost:8000` (login `admin` / the password in `.env`) |
| 8088 | HTTP Event Collector (HEC) endpoint |
| 8089 | Splunk management / REST API |

## Run the smoke test

```bash
./smoke.sh
```

This starts the stack, waits for Splunk to become healthy (~60s on first run),
seeds 10 sample events into the `main` index via HEC, runs a search via the
REST API, asserts the events are returned, and prints `OK` on success.

## Leave it running

```bash
docker compose up -d
./seed/seed.sh
open http://localhost:8000   # admin / <SPLUNK_PASSWORD from .env>
docker compose down -v       # clean up
```

## What gets seeded

10 JSON-formatted log events (web access logs) into `index=main`,
`sourcetype=access_combined`. See [`seed/sample-events.jsonl`](seed/sample-events.jsonl).
