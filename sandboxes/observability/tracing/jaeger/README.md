# Jaeger sandbox

Spins up Jaeger's all-in-one image (collector + query + UI in one container),
sends a sample trace via the OTLP HTTP endpoint, and verifies the integration
by querying the trace back via the Jaeger query API.

## What this proves

That an integration which expects to send OTLP traces to Jaeger's collector
(`/v1/traces` on port 4318) and read them back via the query API
(`/api/traces?service=<name>`) works end-to-end against a real Jaeger instance.

## Prereqs

- Docker
- `curl`, `jq`

## Ports

| Port | Purpose |
|---|---|
| 16686 | Web UI + Jaeger query HTTP API — `http://localhost:16686` |
| 4318 | OTLP HTTP receiver (send traces here as OTLP/JSON) |
| 4317 | OTLP gRPC receiver |
| 14268 | Legacy Jaeger thrift HTTP receiver |

## Run the smoke test

```bash
./smoke.sh
```

Starts Jaeger, waits until ready, sends a sample OTLP trace with one span
under service `lets-sandbox-demo`, queries `/api/traces?service=lets-sandbox-demo`,
asserts ≥1 trace is returned, prints `OK`.

## Leave it running

```bash
docker compose up -d
./seed/seed.sh
open http://localhost:16686   # find service 'lets-sandbox-demo' in the dropdown
docker compose down -v
```

## What gets seeded

One OTLP trace (1 trace, 1 span) under service name `lets-sandbox-demo`,
operation name `demo-operation`, with a couple of attributes. See
[`seed/sample-trace.json`](seed/sample-trace.json).
