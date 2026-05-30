# lets-prometheus

Agent-native CLI for Prometheus. Wraps the HTTP query API (`/api/v1/query`,
`/api/v1/query_range`, `/api/v1/labels`, `/api/v1/series`, `/api/v1/targets`,
`/api/v1/status/runtimeinfo`) with structured JSON output and `--dry-run`
support on every command.

## Install

```bash
pip install -e .
```

## Configure

| Env var | Default | Purpose |
|---|---|---|
| `PROMETHEUS_URL` | `http://localhost:9090` | Base URL of the Prometheus server |
| `PROMETHEUS_TOKEN` | (none) | Bearer token, if Prometheus sits behind an auth proxy |

CLI flags override env vars: `--base-url`, `--token`.

## Use

```bash
# Query a metric
lets-prometheus query --query 'up' --json

# Range query
lets-prometheus query-range --query 'up' --start 1700000000 --end 1700003600 --step 60s --json

# List label names
lets-prometheus labels --json

# Find series
lets-prometheus series --match '{__name__="up"}' --json

# Inspect scrape targets
lets-prometheus targets --state active --json

# Runtime info
lets-prometheus status --json

# Preview the request without sending it
lets-prometheus query --query up --dry-run --json
```

## Test

```bash
pip install -e ".[dev]"

# Contract + request-plan (always run)
python -m pytest tests -q

# Live smoke against a running Prometheus on http://localhost:9090
python -m pytest tests -m live -q
```
