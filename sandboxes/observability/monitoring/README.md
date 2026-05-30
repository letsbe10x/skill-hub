# Monitoring sandboxes

Local instances of time-series metric backends. Each sandbox spins up a real
instance, exercises a query against live metrics, and verifies the round-trip.

## Available

| Tool | Image | Notes |
|---|---|---|
| [prometheus/](prometheus/) | `prom/prometheus:latest` | Self-scrape config out of the box |

## Planned

| Tool | Self-host story |
|---|---|
| `victoria-metrics/` | `victoriametrics/victoria-metrics:latest` — Prometheus-compatible, lower memory |
| `influxdb/` | `influxdb:latest` — different query language (InfluxQL/Flux) |
| `thanos/` | Multi-cluster Prometheus federation; layered on top of Prometheus |
| `mimir/` | `grafana/mimir:latest` — horizontally-scalable Prometheus |
| `node-exporter/` | Companion image to seed Prometheus with realistic host metrics |
