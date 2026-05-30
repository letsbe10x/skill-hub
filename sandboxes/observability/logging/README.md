# Logging sandboxes

Local instances of log-ingest-and-search platforms. Each sandbox spins up a
real instance, seeds sample log events, and verifies the round-trip via the
tool's search API.

## Available

| Tool | Image | Notes |
|---|---|---|
| [splunk/](splunk/) | `splunk/splunk:latest` | 60-day trial license, HEC + REST search |

## Planned

| Tool | Self-host story |
|---|---|
| `loki/` | `grafana/loki:latest` — paired well with the Grafana sandbox |
| `elasticsearch/` | Official ES image; commonly paired with Kibana |
| `vector/` | Self-host; collector + transformer |
| `fluentd/` | Self-host; aggregator with many output plugins |
| `opensearch/` | AWS fork of Elasticsearch |
