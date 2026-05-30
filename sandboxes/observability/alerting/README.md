# Alerting sandboxes

Local instances of alert routing and on-call escalation tools. None landed yet
— see [../README.md](../README.md) for the sandbox contract.

## Planned

| Tool | Self-host story |
|---|---|
| `alertmanager/` | `prom/alertmanager:latest` — pairs with the Prometheus sandbox; routes Prometheus alerts to receivers |
| `grafana-oncall/` | `grafana/oncall:latest` — open-source on-call rotation and escalation |
| `karma/` | `ghcr.io/prymitive/karma:latest` — Alertmanager UI with grouping/silence helpers |
| `pagerduty/` | No self-host — recorded HTTP fixtures only |
| `opsgenie/` | No self-host — recorded fixtures only |
