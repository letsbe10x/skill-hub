# adapters/observability/

Adapters for the observability vertical. Skills like the upcoming
`lets-investigate-logs`, `lets-investigate-metrics`, `lets-trace-request`,
and `lets-investigate-incident` query backends here.

```
observability/
├── splunk/         Splunk Enterprise
├── prometheus/     Prometheus
├── jaeger/         Jaeger
└── grafana/        Grafana
```

Per-tool categorization (logging / metrics / tracing / dashboards / etc.)
lives as metadata in each adapter's `manifest.json` under the `categories`
key. Many tools span multiple categories — Splunk is both logging and
monitoring, Grafana spans dashboards + alerting + datasources, Datadog
covers everything. Single-category directories would force false choices,
so we kept the directory layout one-level-flat and put taxonomy where it
belongs: in metadata.

## Catalog

| Adapter | Categories | Required env vars |
|---------|------------|-------------------|
| `splunk/`     | logging, monitoring  | `SPLUNK_MGMT_URL`, `SPLUNK_USER`, `SPLUNK_PASSWORD` |
| `prometheus/` | metrics              | `PROMETHEUS_URL` |
| `jaeger/`     | tracing              | `JAEGER_URL` |
| `grafana/`    | dashboards, alerting, datasources | `GRAFANA_URL` |

For full detail per adapter, see its own `README.md` and `manifest.json`.

## Mirrored sandboxes

Every adapter here has a matching Docker sandbox at the same path under
`../../sandboxes/observability/<tool>/`. Smoke pattern:

```bash
# Start the backend
cd sandboxes/observability/splunk
docker compose up -d
./smoke.sh

# Use the adapter against it
cd ../../../adapters/observability/splunk
pip install -e .
SPLUNK_MGMT_URL=https://localhost:8089 SPLUNK_USER=admin SPLUNK_PASSWORD=changeme \
  lets-splunk search --query "search index=main | head 5" --json
```

## Future adapters in this vertical

Each lands as its own PR per the contract documented in `../README.md`:

- `loki/`         — Grafana Loki
- `kibana/`       — Elastic / Kibana
- `datadog/`      — Datadog (logs + metrics + traces + APM)
- `honeycomb/`    — Honeycomb
- `tempo/`        — Grafana Tempo
- `alertmanager/` — Prometheus Alertmanager
- `pagerduty/`    — PagerDuty
