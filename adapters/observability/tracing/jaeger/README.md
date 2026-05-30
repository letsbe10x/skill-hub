# lets-jaeger

Agent-native CLI for Jaeger. Wraps the query API (services, operations,
trace search by service + window, trace fetch by ID) with structured JSON
output and `--dry-run` on every command.

## Install

```bash
pip install -e .
```

## Configure

| Env var | Default | Purpose |
|---|---|---|
| `JAEGER_URL` | `http://localhost:16686` | Jaeger query base URL |
| `JAEGER_TOKEN` | (none) | Bearer token if Jaeger sits behind an auth proxy |

CLI flags override env vars: `--base-url`, `--token`.

## Use

```bash
# Discover
lets-jaeger services --json
lets-jaeger operations --service lets-sandbox-demo --json

# Search traces
lets-jaeger trace search --service my-svc --lookback 1h --limit 20 --json
lets-jaeger trace search --service my-svc --operation "GET /api/foo" --lookback 30m --json
lets-jaeger trace search --service my-svc --tags '{"http.status_code":"500"}' --json

# Fetch one
lets-jaeger trace get <traceId-hex> --json

# Preview
lets-jaeger trace search --service my-svc --dry-run --json
```

## Test

```bash
pip install -e ".[dev]"

python -m pytest tests -q
python -m pytest tests -m live -q   # requires Jaeger on localhost:16686
```
