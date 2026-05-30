# Dashboarding sandboxes

Local instances of visualization and dashboarding tools. Each sandbox spins up
a real instance, creates a sample dashboard via the API, and verifies the
round-trip by fetching it back.

## Available

| Tool | Image | Notes |
|---|---|---|
| [grafana/](grafana/) | `grafana/grafana:latest` | admin/admin, dashboard API exercised |

## Planned

| Tool | Self-host story |
|---|---|
| `superset/` | `apache/superset:latest` — BI-oriented dashboards over SQL sources |
| `metabase/` | `metabase/metabase:latest` — friendlier BI tool, SQL + GUI queries |
| `redash/` | `redash/redash:latest` — query-and-dashboard, simpler than Superset |
| `kibana/` | `docker.elastic.co/kibana/kibana:latest` — pairs with the Elasticsearch sandbox |
