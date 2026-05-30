# Database sandboxes

Local environments for relational, NoSQL, key-value, warehouse, streaming, and
search backends. Some of these double as **shared infrastructure** for other
sandboxes (the Atlassian apps in `ticketing/jira/` and `documentation/confluence/`
both use the shared postgres on the `lets-sandbox-data` network).

## Tools shipped

| Tool | Notes |
|---|---|
| [`postgres/`](postgres/) | Relational. Used by jira + confluence sandboxes. |

## Planned

| Tool | Kind |
|---|---|
| `mysql/`, `mariadb/` | relational |
| `mongodb/`, `cassandra/`, `dynamodb-local/` | NoSQL |
| `redis/`, `etcd/`, `memcached/` | key-value |
| `clickhouse/`, `duckdb/` | warehouse |
| `kafka/` (KRaft), `rabbitmq/`, `nats/` | streaming |
| `elasticsearch/`, `opensearch/`, `meilisearch/`, `typesense/` | search |

## Sandboxes that depend on this vertical

| App sandbox | Depends on |
|---|---|
| [`ticketing/jira/`](../ticketing/jira/) | `databases/postgres/` |
| [`documentation/confluence/`](../documentation/confluence/) | `databases/postgres/` |

These app sandboxes will not start without the shared postgres up — bring up
`databases/postgres/` first.
