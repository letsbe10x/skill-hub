# lets-grafana

Agent-native CLI for Grafana. Wraps dashboards, datasources, folders, and
health via the HTTP API with structured JSON output and `--dry-run` on every
command.

## Install

```bash
pip install -e .
```

## Configure

| Env var | Default | Purpose |
|---|---|---|
| `GRAFANA_URL` | `http://localhost:3000` | Base URL |
| `GRAFANA_USER` | `admin` | Basic-auth username (sandbox default) |
| `GRAFANA_PASSWORD` | `admin` | Basic-auth password (sandbox default) |
| `GRAFANA_TOKEN` | (none) | API token; takes precedence over basic auth when set |

CLI flags override env vars: `--base-url`, `--user`, `--password`, `--token`.

## Use

```bash
# Dashboards
lets-grafana dashboard list --json
lets-grafana dashboard get lets-sandbox-demo --json
lets-grafana dashboard create --file ./my-dashboard.json --overwrite --json
lets-grafana dashboard delete lets-sandbox-demo --json

# Datasources / folders
lets-grafana datasource list --json
lets-grafana folder list --json

# Health (no auth)
lets-grafana health --json

# Preview the request without sending it
lets-grafana dashboard list --dry-run --json
```

## Test

```bash
pip install -e ".[dev]"

python -m pytest tests -q                 # contract + request-plan
python -m pytest tests -m live -q         # live smoke (requires running Grafana)
```
