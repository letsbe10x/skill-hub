# Observability sandboxes

Local environments for the major observability tools, grouped by the signal
they handle. Use these to verify integrations end-to-end against a real
running instance, without needing a hosted account.

## Categories

| Category | What it covers | Tools shipped |
|---|---|---|
| [logging/](logging/) | Log ingest + search | splunk |
| [tracing/](tracing/) | Distributed traces / spans | jaeger |
| [monitoring/](monitoring/) | Time-series metrics | prometheus |
| [dashboarding/](dashboarding/) | Visualization + panels | grafana |
| [alerting/](alerting/) | Alert routing + on-call (placeholder) | — |

## Full sandbox inventory

| Sandbox | Category | Port(s) |
|---|---|---|
| [logging/splunk/](logging/splunk/) | logging | 8000 (UI), 8088 (HEC), 8089 (mgmt) |
| [tracing/jaeger/](tracing/jaeger/) | tracing | 16686 (UI), 4318 (OTLP HTTP) |
| [monitoring/prometheus/](monitoring/prometheus/) | monitoring | 9090 (UI + API) |
| [dashboarding/grafana/](dashboarding/grafana/) | dashboarding | 3000 (UI) |

## Running them together

Each sandbox is independent and uses non-overlapping ports, so you can run all
four in parallel:

```bash
for path in \
  logging/splunk \
  tracing/jaeger \
  monitoring/prometheus \
  dashboarding/grafana
do
  (cd "$path" && docker compose up -d)
done
```

Tear them all down:

```bash
for path in \
  logging/splunk \
  tracing/jaeger \
  monitoring/prometheus \
  dashboarding/grafana
do
  (cd "$path" && docker compose down -v)
done
```

## Adding a new tool

1. Pick the right category folder. If none fits (e.g. profiling, eBPF, RUM), add a new category folder with its own `README.md`.
2. Create `<category>/<tool>/` following the sandbox contract in [../README.md](../README.md).
3. Update this README's tables.
