# adapters/observability/

Adapters for the observability vertical. Skills like the upcoming
`lets-investigate-logs`, `lets-investigate-metrics`, `lets-trace-request`,
and `lets-investigate-incident` query backends here.

```
observability/
├── logging/
│   └── splunk/                  # Splunk Enterprise
├── monitoring/
│   └── prometheus/              # Prometheus
├── tracing/
│   └── jaeger/                  # Jaeger
└── dashboarding/
    └── grafana/                 # Grafana
```

## Mirrored layout under `../../sandboxes/observability/`

Every adapter under this directory has a matching Docker sandbox at the
same relative path under `../../sandboxes/observability/`:

| Adapter | Sandbox |
|---------|---------|
| `logging/splunk/`         | `sandboxes/observability/logging/splunk/`         |
| `monitoring/prometheus/`  | `sandboxes/observability/monitoring/prometheus/`  |
| `tracing/jaeger/`         | `sandboxes/observability/tracing/jaeger/`         |
| `dashboarding/grafana/`   | `sandboxes/observability/dashboarding/grafana/`   |

Smoke-test pattern:

```bash
# Start the backend
cd sandboxes/observability/logging/splunk
docker compose up -d
./smoke.sh

# Use the adapter against it
cd ../../../../adapters/observability/logging/splunk
pip install -e .
SPLUNK_MGMT_URL=https://localhost:8089 SPLUNK_USER=admin SPLUNK_PASSWORD=changeme \
  lets-splunk search --query "search index=main | head 5" --json
```

## Future adapters in this vertical

- `logging/loki/`         — Grafana Loki (PRD TBD)
- `logging/kibana/`       — Elastic / Kibana (PRD TBD)
- `logging/datadog/`      — Datadog Logs (PRD TBD)
- `logging/honeycomb/`    — Honeycomb (PRD TBD)
- `tracing/tempo/`        — Grafana Tempo (PRD TBD)
- `alerting/<tool>/`      — Alertmanager / PagerDuty / Opsgenie (PRD TBD)

Each lands as a follow-up PR per the contract documented in `../README.md`.
