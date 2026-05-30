# adapters/

Per-backend integration code that skills in this repo use to query real
observability, logging, and tracing tools. Each subdirectory is a
self-contained adapter for one backend.

```
adapters/
├── splunk/      → Splunk Enterprise (logs)
├── prometheus/  → Prometheus (metrics)
├── jaeger/      → Jaeger (traces)
└── grafana/     → Grafana (dashboards + datasource queries)
```

## How adapters are used

Skills that need to query a backend reference the adapter by name in
their `backends.json`. At install time, `npx … install … --backend
<name>` copies the chosen adapters to the user's machine (per PRD-178).

The skill never names a vendor inline. It speaks a normalized query DSL;
the adapter translates DSL → backend-native query, calls the backend's
API using credentials from environment variables, and returns normalized
JSON. Multiple skills can share the same adapter.

## Per-adapter layout

Every adapter directory contains:

| File | Purpose |
|------|---------|
| `manifest.json` | Machine-readable metadata: name, version, supported operations, required and optional environment variables. |
| `README.md` | Human-facing install + usage docs (currently the existing Typer CLI README). |
| `pyproject.toml` | Pip-installable package for users who want the full CLI on their shell PATH. |
| `src/lets_<backend>/` | Python source for the full CLI flavor (uses `typer` + `httpx`). |
| `tests/` | Test suite for the CLI flavor. |

The stdlib-only shim (`lets-<backend>` executable, ~200 lines) per
PRD-178 is a follow-up addition; it ships alongside the existing CLI
flavor and is the path the skill flow uses.

## Status (as of this PR)

| Adapter | CLI flavor | Stdlib shim | Reference doc |
|---------|------------|-------------|---------------|
| splunk     | ✓ (typer/httpx) | follow-up | follow-up |
| prometheus | ✓ (typer/httpx) | follow-up | follow-up |
| jaeger     | ✓ (typer/httpx) | follow-up | follow-up |
| grafana    | ✓ (typer/httpx) | follow-up | follow-up |

The CLI flavor is installable today via `pip install -e ./adapters/<backend>`
from the repo root. Skills that consume these adapters land in a separate
follow-up PR per the PRD's Phase 2.

## Contract (locked by PRD-178)

Every adapter in this directory MUST:

1. Carry a valid `manifest.json` (schema: `docs/schema/manifest.schema.json` — landing in a follow-up PR).
2. Accept and emit JSON via a `--json` flag.
3. Read credentials from environment variables only — never from a YAML
   or config file in the user's home directory.
4. Document its environment variables in `manifest.json#env_vars` and
   in the eventual `reference.md`.
5. Fail with a structured error envelope on stderr (exit code 1) when
   misconfigured.

The full per-adapter contract lives in PRD-178 (`prds/discovery/prd-178-…`
in the ground-truth repo). When the stdlib shim and `reference.md` land
for each adapter, this table will tick green.

## Related

- PRD-178 — skill-hub as OSS ground truth, multi-backend foundation
- decision-008 — adapter companion repo boundary (private adapters stay
  in `letsbe10x/adapters`; only the public OSS subset lives here)
- `sandboxes/` — sibling top-level directory in this repo. Each sandbox
  spins up a real instance of the backend an adapter targets, lets you
  smoke-test the adapter end-to-end before pointing it at production.
