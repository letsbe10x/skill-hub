# Generation Protocol

The full 8-phase methodology for generating an agent-native CLI for any target.
The agent reads this end-to-end before starting a generation run.

## Operating Contract

Every generation run follows these 8 phases in order. Skipping a phase requires
explicit user permission and a one-line note in the generated `README.md`
explaining why.

### Phase 1 — Acquire Source Evidence

Goal: understand the target before you write anything.

- Accept the target reference: local source path, public docs URL, OpenAPI/Swagger spec URL, or GraphQL endpoint URL.
- Clone or fetch as needed. Prefer local clones for full analysis.
- Catalog:
  - Package metadata (`pyproject.toml`, `package.json`, `go.mod`, `Cargo.toml`, etc.)
  - Documentation (`README.md`, `docs/`, hosted reference docs)
  - Entrypoints, examples, code samples
  - API specs (OpenAPI YAML/JSON, GraphQL SDL, Postman collections)
  - Existing CLI binaries (`bin/`, `cmd/`) — building blocks you can wrap

Output: a written analysis with the target's display name, package name, primary language, integration kind, candidate command list, and known limitations.

### Phase 2 — Classify the Integration

Pick exactly one primary integration kind. See [`target-class-patterns.md`](target-class-patterns.md) for the per-class deep dive.

| Integration kind | When to pick it |
|---|---|
| `rest_api` (with OpenAPI) | Target ships an OpenAPI/Swagger spec |
| `rest_api` (without OpenAPI) | REST endpoints documented in markdown/code but no spec |
| `graphql` | Primary surface is a GraphQL endpoint (e.g. NerdGraph) |
| `stateful_workflow` | API requires create → poll → fetch choreography (e.g. Splunk search jobs) |
| `process` | Wraps an existing binary; you spawn it via subprocess |
| `file_project` | Reads/writes a structured project file format (e.g. .ai for Illustrator) |
| `gui_backend` | GUI app with a headless mode (Blender, GIMP, LibreOffice, OBS) |
| `mixed` | Genuinely needs more than one approach (rare; usually decomposable) |

### Phase 3 — Write the Blueprint

Optional but strongly recommended. The blueprint is a typed JSON description the user can review before code is written.

Structure (minimum):

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
    {
      "name": "nerdgraph-query",
      "group": "nerdgraph",
      "summary": "Run an arbitrary NerdGraph query.",
      "mutation_level": "read_only",
      "integration_kind": "graphql",
      "json_output": true
    }
  ],
  "capabilities": [...],
  "assumptions": ["NerdGraph is the primary surface; REST v2 is legacy"],
  "next_steps": ["Add per-domain query commands once introspection lands"]
}
```

Save to `<output-dir>/cligen.blueprint.json`. Re-read after edits — it's the source of truth.

### Phase 4 — Scaffold the Package

Create the minimal installable skeleton before writing real commands:

```
<output-dir>/
├── pyproject.toml          # package config, deps (typer, httpx, etc.)
├── README.md               # placeholder; fills in Phase 9
├── src/<package>/
│   ├── __init__.py
│   ├── cli.py              # Typer app, command stubs
│   └── client.py           # HTTP client skeleton
└── tests/
    └── test_cli_contract.py  # auto-pattern: CLI loads, --help works
```

Use the templates in [`../assets/`](../assets/) as starting points. They are starting points only — adapt them per target.

### Phase 5 — Fill the Commands

For each command in the blueprint:

1. Identify the integration kind for *this command* (a `mixed` CLI can have REST commands alongside process-backed ones).
2. Write the real implementation. Reuse client helpers (`build_request_plan`, `ApiClient.request`, `Backend.run`).
3. Implement `--dry-run` to print the planned action and exit without side effects.
4. Implement `--json` to emit a single JSON object.
5. Declare and respect `mutation_level` — `external_write` / `network_write` commands must require explicit confirmation flags or environment variables.
6. Move logic past ~40 lines into `<package>/adapters/<concern>.py`.

### Phase 6 — Handle Target Quirks

Real APIs have quirks the scaffold can't guess. Centralize in the client, not per-command:

| Quirk | How to handle |
|---|---|
| Custom auth header (e.g. NewRelic's `Api-Key`, not `Bearer`) | Customize the client's `_build_headers()`. |
| Default query params (e.g. Splunk's `output_mode=json`) | Add to the client's base request builder. |
| Response wrappers (e.g. `{ "data": [...] }`) | Normalize in a `_unwrap_response` helper. |
| Multi-format responses (Atom XML, JSONP) | Detect by `Content-Type`, parse into dict. |
| Cursor pagination | Add a `_paginate(method, path, params)` generator; expose via `--all` flag. |
| Rate limits / retry-after | Wrap `httpx.request` in `_request_with_backoff(...)`. Honor `Retry-After`. |
| Idempotency keys for write endpoints | Generate UUID, attach to request headers, document in `--help`. |

### Phase 7 — Build Workflow Orchestrators

For `stateful_workflow` targets, raw endpoints aren't enough. Add a single high-level command that drives the full choreography.

Example for Splunk:

```bash
# Raw endpoints (the user can still call these)
splunk search create --query "..." --json
splunk search status --sid SID --json
splunk search results --sid SID --json

# Orchestrator (what the user actually wants)
splunk search run --query "..." --timeout 60 --json
# → creates the job, polls until done, returns results in one call
```

Persist intermediate state (sid, cursor, etc.) to a session file under `~/.cache/<package>/sessions/`. Use file locking for concurrent safety.

### Phase 8 — Test

Every command must have tests beyond the contract floor. See [`testing-guide.md`](testing-guide.md) for patterns. Minimum:

| Test | What it proves | When required |
|---|---|---|
| Contract | CLI loads, `--help` works, every command has `--json` | always |
| Request plan | `--dry-run` produces the expected URL/method/headers | every API-backed command |
| Fixture server | Fixture HTTP server (e.g. `pytest-httpserver`) returns canned responses; CLI parses them | every command that hits an upstream |
| Workflow | End-to-end orchestration against fixture | every orchestrator command |

Run from the output dir: `pytest tests -q`. All green before declaring done.

### Phase 9 — Emit the Generated SKILL.md

Every generated CLI ships with an Agent Skills–compatible `SKILL.md` so downstream agents can discover and invoke it. Use this template:

```yaml
---
name: <cli-name>
description: "Agent-native CLI for <display-name>. <One-line summary of what the tool does.>"
metadata:
  version: "0.1.0"
  tags: [<integration-kind>, <domain>]
lifecycle: published
compatibility:
  agents: [claude-code, cursor, codex, copilot]
triggers:
  - "<verb> <noun> in <display-name>"
  - "query <display-name>"
  - "use <display-name> to <action>"
---

# <cli-name>

## Overview
<What this CLI does, what it wraps, what auth it needs.>

## When to Use
- <Concrete scenarios where an agent should reach for this CLI.>

## Inputs and Outputs
- Auth: <env var or auth flow>
- Output: every command emits JSON via `--json`
- Dry-run: every mutating command supports `--dry-run`

## Steps
1. Ensure auth is configured: `export <ENV_VAR>=...`
2. List commands: `<cli-name> --help`
3. Run a command: `<cli-name> <command> --json`

## Anti-patterns
- **<anti-pattern 1>** — <reason>
- **<anti-pattern 2>** — <reason>
```

### Phase 10 — Verify

Final checks before declaring done:

```bash
cd <output-dir>
pip install -e .                          # installs cleanly
<cli-name> --help                          # full command surface visible
<cli-name> <read-command> --json --dry-run # produces a valid JSON plan
pytest tests -q                            # all green
```

If any step fails, fix it. Do not declare done.

## Non-Negotiables

1. **Blueprint is the source of truth** (if used). Code without a corresponding blueprint entry is technical debt.
2. **`--json` on every command.** No exceptions.
3. **`--dry-run` on every mutating command.** No exceptions.
4. **Mutation level declared on every command.** Even read-only ones — explicitly.
5. **No shell strings.** Subprocess uses argument arrays.
6. **No secrets in logs, docs, examples, tests, or blueprints.** Redact at source.
7. **No silent failures.** Missing binary / missing env var → fail loud with the fix in the message.
8. **Tests prove behavior, not coverage.** Contract test is floor, not ceiling.
9. **Generated CLI ships with its own SKILL.md.** Phase 9 is not optional.
