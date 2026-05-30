# Database sandboxes

Local environments for relational, NoSQL, key-value, warehouse, streaming, and
search backends. Some of these double as **shared infrastructure** for other
sandboxes (the Atlassian apps in `ticketing/jira/` and `documentation/confluence/`
both use the shared postgres on the `lets-sandbox-data` network).

## Categories

| Category | What it covers | Tools shipped |
|---|---|---|
| [rdbms/](rdbms/) | Relational databases | postgres |

## Planned

| Category | Tools |
|---|---|
| `rdbms/` | mysql, mariadb |
| `nosql/` | mongodb, cassandra, dynamodb-local |
| `kv/` | redis, etcd, memcached |
| `warehouse/` | clickhouse, duckdb |
| `streaming/` | kafka (KRaft), rabbitmq, nats |
| `search/` | elasticsearch, opensearch, meilisearch, typesense |

## Sandboxes that depend on this vertical

| App sandbox | Depends on |
|---|---|
| [`ticketing/jira/`](../ticketing/jira/) | `rdbms/postgres/` |
| [`documentation/confluence/`](../documentation/confluence/) | `rdbms/postgres/` |

These app sandboxes will not start without the shared postgres up — bring up
`databases/rdbms/postgres/` first.
