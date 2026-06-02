---
name: lets-inspect-metrics
description: "Use this skill whenever the user wants to check service health through metrics — including latency, error rate, throughput, CPU/memory saturation, SLO burn, or dashboard panel inspection. Trigger on incident phrasing like 'is the service healthy', 'did latency spike after the deploy', 'why are requests slow', 'check error rate', 'is CPU saturated', or 'look at the Grafana panel for X'. Read-only — never mutates dashboards or datasources."
metadata:
  author: letsbe10x
  version: "0.1.0"
  tags: [observability, metrics, prometheus, grafana, watchtower]
lifecycle: published
source: https://github.com/letsbe10x/skills/blob/main/lets-inspect-metrics/SKILL.md
compatibility:
  agents: [claude-code, cursor, codex, copilot]
  requirements:
    - "adapter capability: metrics"
triggers:
  - check metrics
  - latency spike
  - error rate
  - grafana dashboard
  - promql
goals:
  - inspect_service
outcome_runtime:
  open_agency_zones:
    - metric_selection
    - anomaly_assessment
  validation_gates:
    - surface_readiness_gate

    - metric_health_claim
  allowed_moves:
    - narrow_time_window
    - pivot_to_related_metric
    - request_missing_capability
  hard_limits:
    - do_not_mutate_dashboards
    - do_not_claim_healthy_without_red_use_coverage
  mutation_policy: read_only
  human_checkpoint_triggers:
    - missing_truth
---

## Investigation Law

**NO "METRICS LOOK FINE" WITHOUT BOTH A RATE AND AN ERROR SIGNAL IN THE WINDOW.**

A single green graph is not coverage. Rate, error rate, and saturation must each return a value (or explicit no_data). If SLO targets are defined, burn rate must also be checked. If the last scrape timestamp is stale, all readings are invalid — report UNKNOWN, not healthy.

## Overview

`lets-inspect-metrics` reads the metrics surface of the watchtower capability contract. Prometheus is the primary source today; Grafana panels and datasources are resolved through the same capability so the skill stays provider-agnostic. Read-only by invariant.

## When to Use

- Latency or error rate is suspected — need a PromQL / panel read.
- A Grafana dashboard panel needs to be inspected but the user doesn't know the raw query.
- Capacity / saturation assessment (CPU, memory, queue depth) is needed.
- Do NOT use for logs or k8s state — use `lets-search-logs` / `lets-diagnose-k8s`.

## Steps

1. **Identify scope** — service, metric family (RED / USE / custom / panel), and window.
2. **Run the probe** `lets inspect surface metrics --service $SERVICE --metric-name $METRIC --since $WINDOW` — capability adapter resolves Prometheus vs Grafana datasource. `$METRIC` is a family like `error_rate`, `latency_p99`, `request_rate`. `$WINDOW` is relative (`15m`, `2h`, `1d`). For a Grafana dashboard snapshot: `lets inspect surface dashboards --service $SERVICE --name $DASHBOARD_NAME`.
3. **Handle probe status first:**
   - `ok` → proceed
   - `no_data` → do NOT assume healthy or idle; record `no_data` with the affected metric names, note scrape target may be down, stop
   - `not_ready` → stop, report `UNKNOWN` with probe detail
   - `error` → retry once with narrower window; if still error, report `UNKNOWN`
4. **Health claims require all three RED signals** — rate, error rate, and duration must each return a value (or explicit `no_data`). A single green signal does not constitute coverage. If any signal returns `no_data`, the verdict is `UNKNOWN` for that dimension, not `healthy`.
5. **Check for misleading zeros** — a rate of 0 rps may mean no traffic (valid) or scrape failure (invalid). Cross-check with `up` metric or probe coverage before interpreting silence as health.
6. **Emit the metrics card.**

## Anti-patterns

- **Writing raw PromQL against Prometheus HTTP API** — blocked. The metrics capability is the seam.
- **Editing a Grafana dashboard** — blocked. Do not mutate dashboards. This skill is read-only; dashboard changes go through the dedicated dashboard workflow.
- **Claiming health from request latency alone** — blocked. Do not claim healthy without RED/USE coverage; error rate and saturation are also required.
- Don't anchor to absolute thresholds without baseline context — "p95 latency is 450ms" is meaningless without knowing the normal baseline. An agent should compare to the preceding equivalent window, not judge against an arbitrary number.
- Don't conflate panel snapshot with metric truth — a Grafana panel may display a transformed or pre-aggregated view that hides the underlying signal. If the panel shows a rolling average, the raw metric may spike while the panel looks smooth. Always note when panel data is being used instead of raw metric.

## Outputs

- Output: **RED summary** — rate, errors, duration with verdict per sub-metric.
- Output: **USE summary** — utilisation, saturation, errors when host/container level is in scope.
- Output: **Panel snapshots** — per panel-id, last value and 95th percentile in window.
- Output: **Probe status** — `ok` | `no_data` | `not_ready` | `error`.

Note: 
- no_data:idle — rate is zero but scrape is confirmed fresh (service may just have no traffic)
- no_data:stale — last scrape is old; readings are unreliable
- no_data:unregistered — metric name not found in the target's label set


## Output Format — Metrics Card

```
### Metrics Card: {service} / {window}

**Probe status**: ok | no_data | not_ready | error
**Scrape freshness**: confirmed ({timestamp}) | stale | unknown

#### RED Summary
| Signal | Value | Verdict |
|--------|-------|---------|
| Rate (rps) | N | ok / anomaly / no_data |
| Error rate (%) | N | ok / anomaly / no_data |
| Duration p50/p95/p99 (ms) | N/N/N | ok / anomaly / no_data |

#### USE Summary (if host/container in scope)
| Signal | Value | Verdict |
|--------|-------|---------|
| Utilisation (%) | N | ok / anomaly / no_data |
| Saturation | N | ok / anomaly / no_data |
| Errors | N | ok / anomaly / no_data |

#### SLO Burn Rate (if targets defined)
<burn rate over window> — within budget / burning / no_data

#### Verdict
HEALTHY | DEGRADED | UNKNOWN — <1–2 sentence rationale, cite which signals drove the verdict>
```

Done when: the metrics card is produced or `UNKNOWN` is recorded with probe detail.
