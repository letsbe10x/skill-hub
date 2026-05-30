# lets-splunk

Agent-native CLI for Splunk Enterprise. Wraps the mgmt REST API (search +
server info) and HEC (event ingest) with structured JSON output and
`--dry-run` on every command.

## Install

```bash
pip install -e .
```

## Configure

| Env var | Default | Purpose |
|---|---|---|
| `SPLUNK_MGMT_URL` | `https://localhost:8089` | Splunk mgmt REST URL |
| `SPLUNK_HEC_URL` | `https://localhost:8088` | HEC URL |
| `SPLUNK_USER` | `admin` | mgmt basic-auth username |
| `SPLUNK_PASSWORD` | (required) | mgmt basic-auth password |
| `SPLUNK_HEC_TOKEN` | (required for `ingest`) | HEC token |
| `SPLUNK_INSECURE` | `true` | Skip TLS verify (sandbox uses self-signed cert) |

CLI flags override env vars: `--mgmt-url`, `--hec-url`, `--user`, `--password`,
`--hec-token`, `--insecure / --secure`.

## Use

```bash
# Run a search (blocking; returns parsed results)
lets-splunk search --query 'search index=main sourcetype=access_combined' --earliest -24h --json

# Ingest one event via HEC (JSON object OR raw string both accepted)
lets-splunk ingest --event '{"action":"click","user":"alice"}' --sourcetype my:json --json
lets-splunk ingest --event 'raw log line' --sourcetype my:raw --json

# Server info / health
lets-splunk server-info --json

# Preview without sending
lets-splunk search --query 'search index=*' --dry-run --json
lets-splunk ingest --event '{"x":1}' --dry-run --json
```

## Test

```bash
pip install -e ".[dev]"

# Contract + request-plan
python -m pytest tests -q

# Live smoke against the sandbox (mgmt + HEC + round-trip an ingested event)
python -m pytest tests -m live -q
```

## TLS verification

The Splunk sandbox uses a self-signed certificate by default, so the CLI
ships with `--insecure` as the default. **For production, pass `--secure` or
set `SPLUNK_INSECURE=false`** and provide a real CA bundle if needed.
