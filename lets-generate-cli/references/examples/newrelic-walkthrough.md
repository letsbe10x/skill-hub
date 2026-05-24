# Worked Example — NewRelic CLI

A narrative walkthrough of generating an agent-native CLI for NewRelic. NewRelic
is a good test case because its primary surface is GraphQL (NerdGraph) with a
REST v2 fallback, it uses a custom auth header (`Api-Key`, not `Bearer`), and
it has cursor pagination — three quirks that exercise most of the protocol.

## What the user said

> "Generate a CLI for NewRelic."

## What the agent did

### Phase 1 — Analyze

- Cloned the public `newrelic/newrelic-cli` repo locally.
- Found their docs link to `api.newrelic.com/graphql` as the primary endpoint.
- Found REST v2 endpoints scattered in `docs/` markdown files.
- Found their auth requires header `Api-Key: <USER_API_KEY>`, not `Bearer`.
- Found cursor-based pagination on most list endpoints (`nextCursor` / `actor.entitySearch`).

### Phase 2 — Classify

Picked **`graphql`** as the primary integration kind. NerdGraph is the modern API; REST v2 is legacy and deprecated for new use.

### Phase 3 — Blueprint

Wrote `cligen.blueprint.json`:

```json
{
  "schema_version": "cligen.blueprint.v1",
  "display_name": "NewRelic",
  "package_name": "newrelic_cli",
  "cli_name": "newrelic",
  "integration_kind": "graphql",
  "auth": {
    "mode": "env_token",
    "env_vars": ["NEW_RELIC_API_KEY"],
    "custom_headers": {"Api-Key": "$NEW_RELIC_API_KEY"}
  },
  "commands": [
    {"name": "nerdgraph-query", "group": "nerdgraph", "summary": "Run an arbitrary NerdGraph query.", "mutation_level": "read_only", "json_output": true},
    {"name": "entity-search", "group": "entities", "summary": "Search entities by name/type.", "mutation_level": "read_only", "json_output": true},
    {"name": "alert-condition-list", "group": "alerts", "summary": "List alert conditions for a policy.", "mutation_level": "read_only", "json_output": true},
    {"name": "alert-condition-create", "group": "alerts", "summary": "Create a NRQL alert condition.", "mutation_level": "network_write", "json_output": true},
    {"name": "dashboard-list", "group": "dashboards", "summary": "List dashboards for an account.", "mutation_level": "read_only", "json_output": true}
  ],
  "capabilities": [
    {"name": "nerdgraph", "description": "NerdGraph (GraphQL) primary surface"},
    {"name": "alerts", "description": "Alert policy + condition management"},
    {"name": "dashboards", "description": "Dashboard CRUD"}
  ],
  "assumptions": [
    "NerdGraph is the primary surface; REST v2 is legacy",
    "User has NEW_RELIC_API_KEY (User key, not Admin)"
  ],
  "next_steps": [
    "Add per-domain query commands once introspection lands",
    "Add notification destination commands",
    "Wire workflow orchestrators for alert policy creation"
  ]
}
```

### Phase 4 — Scaffold

Created:

```
~/newrelic-cli/
├── pyproject.toml
├── README.md  (placeholder)
├── src/newrelic_cli/
│   ├── __init__.py
│   ├── cli.py            (Typer app, command stubs)
│   ├── client.py         (HTTP client skeleton)
│   └── nerdgraph.py      (placeholder for introspection helper)
└── tests/
    └── test_cli_contract.py
```

### Phase 5 — Fill the commands

Each command in the blueprint got a real implementation. Key file: `client.py`.

```python
# src/newrelic_cli/client.py
import os
import httpx

BASE_URL = os.environ.get("NEW_RELIC_BASE_URL", "https://api.newrelic.com")
GRAPHQL_PATH = "/graphql"


def _headers(token: str | None = None) -> dict[str, str]:
    api_key = token or os.environ.get("NEW_RELIC_API_KEY", "")
    if not api_key:
        raise RuntimeError(
            "NEW_RELIC_API_KEY is not set. Get a User key from\n"
            "  https://one.newrelic.com/admin-portal/api-keys/home\n"
            "Then: export NEW_RELIC_API_KEY=NRAK-..."
        )
    return {
        "Content-Type": "application/json",
        "Api-Key": api_key,
    }


def nerdgraph_query(query: str, variables: dict | None = None, token: str | None = None) -> dict:
    payload = {"query": query, "variables": variables or {}}
    response = httpx.post(
        f"{BASE_URL.rstrip('/')}{GRAPHQL_PATH}",
        headers=_headers(token),
        json=payload,
        timeout=30,
    )
    response.raise_for_status()
    return _unwrap_response(response.json())


def build_request_plan(query: str, variables: dict | None = None) -> dict:
    return {
        "method": "POST",
        "url": f"{BASE_URL.rstrip('/')}{GRAPHQL_PATH}",
        "headers": {"Content-Type": "application/json", "Api-Key": "<redacted>"},
        "body": {"query": query, "variables": variables or {}},
    }


def _unwrap_response(payload: dict) -> dict:
    if "errors" in payload:
        raise RuntimeError(f"NerdGraph error: {payload['errors']}")
    return payload.get("data", payload)
```

### Phase 6 — Quirks

Three quirks captured in the client:

1. **Custom `Api-Key` header** (not `Bearer`) — already handled above.
2. **Cursor pagination** — added `_paginate` in `adapters/pagination.py`:

   ```python
   def paginate(query_template: str, cursor_path: list[str], page_size: int = 100):
       cursor = None
       while True:
           variables = {"cursor": cursor, "pageSize": page_size}
           result = nerdgraph_query(query_template, variables=variables)
           yield result
           next_cursor = _walk(result, cursor_path)
           if not next_cursor:
               break
           cursor = next_cursor
   ```

3. **Response unwrapping** — `_unwrap_response` already strips the `data.` envelope and raises on `errors`.

### Phase 7 — Orchestrators

Added one orchestrator for alert creation: `newrelic alerts run` takes a NRQL query, creates a policy if needed, creates the condition, returns the full policy + condition in one shot.

### Phase 8 — Tests

```
tests/
├── test_cli_contract.py        # auto-generated, ensures every command has --json
├── test_request_plan.py        # asserts --dry-run output for each command
└── test_fixture_server.py      # spins up pytest-httpserver, returns canned NerdGraph responses, asserts parsed output
```

All green: `pytest tests -q` → 12 passed.

### Phase 9 — Verify

```bash
cd ~/newrelic-cli
pip install -e .                                # ✓
newrelic --help                                  # 5 commands listed
newrelic nerdgraph-query --query '{ actor { user { email } } }' --dry-run --json
# → { "method": "POST", "url": "https://api.newrelic.com/graphql", ... }
pytest tests -q                                  # 12 passed
```

Done. ~4 hours of agent time, including writing this walkthrough.

## What the agent did NOT do

- Did not enumerate all 200+ NerdGraph types. Generated the introspection helper so the user can query whatever they want; surfaced only the 5 most common operations as named commands.
- Did not implement the legacy REST v2. NerdGraph supersedes it; only worth adding if a user has a specific REST-only need.
- Did not add browser auth. NewRelic offers PATs cleanly; `env_token` is the right choice.
- Did not skip the orchestrator for alerts. Creating an alert is a 3-step dance (policy → condition → notification channel); the user gets `newrelic alerts run`, not 3 separate commands.

## What this proves

The same protocol that scaffolds a Splunk-like REST CLI also scaffolds a NewRelic-like GraphQL CLI. The agent picks the right target class in Phase 2 and follows the matching pattern from there.
