# Target-Class Patterns

For each integration kind, the patterns to follow. The agent picks one as the
primary class in Phase 2 and the matching section below drives the rest of the
generation.

## REST API with OpenAPI / Swagger

Best case. The spec gives you commands, parameter shapes, response schemas, auth scheme.

- **Discovery**: parse the spec directly (don't regex docs). Use `operationId` as the command name when present; fall back to `<METHOD>-<path-slug>`.
- **Auth**: read from `securitySchemes`. Map `http: bearer` → `env_token`. Map API key in header → `env_token` with custom header. Map OAuth → `oauth_device`.
- **Parameters**: required fields become CLI options; optional fields become `--<name>`. Path params come from the command's positional args.
- **Response shape**: use the spec's response schema to document the `--json` output in `--help`.
- **Pagination**: if the spec has `x-next` link headers or cursor params, wire `_paginate` and expose `--all`.

Targets in this class: Stripe, Linear (REST v2), Jira Cloud, Datadog, GitHub REST (deprecated but present), Atlassian APIs.

## REST API without OpenAPI

Common case. You're parsing markdown and Go/JS/Python source for endpoint hints.

- **Discovery**: regex on docs and source for `GET /...`, `POST /...`. Verify each candidate by checking the docs page.
- **Auth**: most use `Bearer` in `Authorization`; some use a custom header (NewRelic's `Api-Key`, Splunk's `Authorization: Splunk <token>`). Always check; do not assume.
- **Quirks** (see [`generation-protocol.md`](generation-protocol.md#phase-6--handle-target-quirks)): default query params (`output_mode=json`), response wrappers, etc.
- **Tests**: fixture-server test is mandatory — without a spec, parsing is the only contract.

Targets: Splunk Enterprise REST, NewRelic REST v2, older internal APIs.

## GraphQL

The endpoint is one URL; the API is the schema.

- **Discovery**: run the standard introspection query `{ __schema { types { name fields { name type { name } } } } }`. If introspection is disabled or requires auth, ask the user for sample queries from their docs.
- **Command shape**: one command per root query field; mutations get a `--mutation` flag or live under a `mutate` subcommand.
- **Selection sets**: default to all scalar fields; expose `--select <field1,field2>` to narrow; expose `--depth N` to descend into nested object types.
- **Variables**: every command takes `--var name=value` (repeatable) for query variables; coerces by type from the schema.
- **Auth**: usually a token in `Authorization: Bearer` or a custom header (NewRelic's `Api-Key`).
- **Pagination**: GraphQL connections (Relay-style) use `first/after`; non-Relay APIs use whatever the schema dictates. Wire `--all` to walk pageInfo.
- **Tests**: fixture-server returning canned introspection + query responses.

Targets: NewRelic NerdGraph, GitHub v4, Linear, Shopify Admin API.

Example layout for a GraphQL target:

```
src/<package>/
├── cli.py                  # Typer app with `query` + per-mutation commands
├── client.py               # http transport
├── nerdgraph.py            # schema cache, introspection, query builder
└── adapters/
    └── pagination.py       # relay-cursor walker
```

## Stateful Workflow

Target requires a multi-step dance for any real operation.

- **Identify the choreography**: usually create → poll → fetch. Sometimes create → wait-for-callback → fetch.
- **Expose the raw steps as commands** (`job create`, `job status`, `job results`) so power users can sequence.
- **Add a single orchestrator command** (`job run`) that drives the whole sequence with `--timeout`, exponential-backoff polling, and a JSON final result.
- **Persist intermediate state** (e.g. `sid` for Splunk) under `~/.cache/<package>/sessions/`. Use file locking so concurrent invocations don't corrupt.
- **Resume**: orchestrator should accept `--resume <session-id>` to pick up an interrupted run.

Targets: Splunk search jobs, Snowflake async queries, BigQuery jobs, GitHub Actions workflow dispatches, Linear async exports.

## Process (Subprocess wrapper)

Target is a binary you spawn.

- **Find the binary**: `shutil.which()` first; document alternative paths (Homebrew, /Applications/, /opt/) for the platforms you support.
- **Argument arrays only**: never `shell=True`, never f-string-interpolated command lines.
- **Capture both stdout and stderr** for `--json`; merge into the JSON output object.
- **Surface install instructions**: when the binary is missing, raise `RuntimeError` with the exact install command for the user's platform.
- **Pass-through arguments**: even raw pass-through args go through a structured array.

Targets: `ffmpeg`, `git`, `kubectl`, `terraform`, `aws`, custom internal binaries.

## File / Project Format

Target is a structured file format. The CLI reads, writes, transforms.

- **Implement the format reader first** — pure parsing, no I/O side effects.
- **Implement the writer second** — read-modify-write atomically via tempfile + `os.replace()`.
- **Probe/info commands** (`inspect`, `list`, `describe`) before mutation commands.
- **Mutation commands** take `--in <path>`, `--out <path>` (or `--in-place` with a backup).
- **Schema validation** on read and before write if the format has a schema.

Targets: 3MF files, SVG, OpenDocument, Markdown front-matter manipulators.

## GUI Backend

Target is a GUI app with a headless mode (the most ambitious class).

- **Find the headless entrypoint**: Blender → `blender --background`, GIMP → `gimp-console`, LibreOffice → `soffice --headless`, Inkscape → `inkscape --shell`.
- **Document the entrypoint** in `<package>/adapters/<tool>_backend.py`.
- **Data layer first**: implement the project file format (Blender `.blend` is opaque — use Python API from inside `--background`; GIMP has Script-Fu; LibreOffice has UNO).
- **Probe commands** (`inspect`, `list-layers`, `describe`) before mutation.
- **Export pipeline**: generate valid intermediate files, then invoke the backend for conversion (e.g. SVG → Inkscape → PNG).
- **Backend missing**: `RuntimeError` with platform-specific install command. Do not silently fall back.

Example install instructions raise:

```python
def _find_blender() -> str:
    blender = shutil.which("blender")
    if blender:
        return blender
    raise RuntimeError(
        "Blender not found. Install via:\n"
        "  macOS:   brew install --cask blender\n"
        "  Ubuntu:  sudo apt install blender\n"
        "  Windows: https://www.blender.org/download/\n"
        "Or set BLENDER_BIN to the binary path."
    )
```

Targets: Blender, GIMP, Inkscape, LibreOffice, OBS Studio, Kdenlive, FreeCAD, Krita.

## Mixed

Genuinely needs more than one approach. Rare.

- **Decompose**: most "mixed" targets are actually decomposable into per-command integration kinds (one command is REST, another spawns a binary). Use `mixed` at the package level but tag each command with its own `integration_kind`.
- **Single client class is OK** even with mixed commands — pass the integration kind into the command handler and dispatch.

Targets: Tools that ship both an API and a CLI you also need to wrap (e.g. `gh` CLI + GitHub API; `splunk` binary + Splunk REST).
