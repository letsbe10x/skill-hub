---
name: lets-generate-cli
description: "Use when generating a working, agent-native CLI for any target tool — REST API, GraphQL API, stateful workflow, process-backed tool, or GUI app. The agent follows a structured methodology to produce an installable Python package with Typer commands, an HTTP/process client, JSON output, --dry-run support, and tests. Discoverability is handled by the CLI's own --help surface."
metadata:
  author: letsbe10x
  version: "0.1.0"
  tags: [cli, generation, agent-native, harness, wrapper, scaffold]
lifecycle: published
compatibility:
  agents: [claude-code, cursor, codex, copilot]
triggers:
  - generate a CLI for
  - make this tool agent-native
  - wrap this API as a CLI
  - build a CLI harness
  - make a CLI for splunk
  - give me a CLI for newrelic
  - turn this GUI app into a CLI
  - create an agent-usable CLI
  - automate this tool from the command line
discovery_signals:
  keywords: [cli, generation, scaffold, harness, agent-native, wrapper, api, graphql, openapi, rest, typer, click]
  languages: [python, markdown, yaml, json]
  frameworks: [typer, click, httpx, playwright]
  governance_impact:
    adds_mutation_policy: external_write
    requires_adapters: []
    installs_hooks: []
    extends_critical_paths: false
  min_context_readiness: 10
---

# lets-generate-cli

## Overview

This skill turns any tool — a SaaS API, an internal platform, a desktop
application, a CLI wrapper, a stateful workflow engine — into an agent-operable
command-line interface. The agent reads a documented generation protocol and
writes a real, installable Python package: Typer CLI, HTTP or process client,
`--json` output on every command, `--dry-run` for safety, rich `--help` text on
every command and subcommand for agent/LLM discoverability, and tests that
exercise the real shape (fixture HTTP server, request-plan assertion, or
recorded responses).

The skill is **methodology-driven**, not template-driven. The agent makes
target-specific judgement calls (auth quirks, pagination, response shapes,
stateful workflows, headless backends) using the patterns in
[`references/generation-protocol.md`](references/generation-protocol.md) and
[`references/target-class-patterns.md`](references/target-class-patterns.md).

## When to Use

- A user asks for a CLI for any tool that doesn't already have an agent-native
  one (Splunk, NewRelic, Datadog, Jira, Linear, an internal API, Blender, GIMP,
  a custom GUI).
- A user wants to wrap a REST/GraphQL API so coding agents can call it without
  hand-crafting HTTP requests every time.
- A user wants to turn a process-backed tool (anything with a binary) into a
  structured CLI with JSON output.
- A user wants to turn a GUI app into a headless, agent-callable CLI.

## When Not to Use

- The target already ships a first-class agent CLI or MCP server that meets the
  user's needs — use the existing one instead.
- The user wants a one-off script, not a packaged CLI — write the script
  directly and skip this skill.
- The target is a closed-source binary with no documented surface and no
  reverse-engineering option — explain the limitation and stop.
- The user wants the agent to *operate* the tool, not generate a CLI for it —
  use a generic computer-use or browser-automation flow.

## Inputs and Outputs

### Inputs

| Input | Required | Source |
|---|---|---|
| Target reference | yes | Local source path, public docs URL, OpenAPI spec URL, or GraphQL endpoint URL |
| Output directory | yes | Where the generated CLI package will be written |
| Target name (human-readable) | yes | e.g. "NewRelic", "Splunk Enterprise" |
| Auth strategy preference | optional | `env_token`, `browser_auth`, `oauth_device`, `session_login` (default: `env_token`) |
| Integration kind hint | optional | `rest_api`, `graphql`, `process`, `file_project`, `gui_backend`, `mixed` (agent infers if omitted) |

### Outputs

| Output | Location | Format |
|---|---|---|
| Installable Python package | `<output-dir>/` with `pyproject.toml`, `src/<package>/`, `tests/` | Python source + `pyproject.toml` |
| CLI entrypoint | `<output-dir>/src/<package>/cli.py` | Typer app with one command per capability |
| Upstream client | `<output-dir>/src/<package>/client.py` (REST/GraphQL) or `adapters/<tool>_backend.py` (process/GUI) | Python module |
| Generated `README.md` | `<output-dir>/README.md` | Human-facing install + usage docs |
| Test suite | `<output-dir>/tests/` | At minimum: contract test, request-plan test, fixture-server test |
| `cligen.blueprint.json` (optional) | `<output-dir>/cligen.blueprint.json` | Typed JSON description of the CLI's commands, capabilities, auth, integration kind |

## Example

> User: "Generate a CLI for NewRelic."

1. Agent confirms target reference: NewRelic Cloud — primary surface is NerdGraph (GraphQL), with REST v2 fallback for older endpoints.
2. Agent runs through Phase 1 (analyze): clones `newrelic/newrelic-cli` if user has nothing local, finds REST endpoints in docs, notes GraphQL is the primary surface but not auto-discoverable from regex.
3. Agent writes the blueprint: `integration_kind: graphql`, auth: `env_token` with `NEW_RELIC_API_KEY` env var, custom header `Api-Key` (not `Bearer`).
4. Agent scaffolds the package per [`references/target-class-patterns.md#graphql`](references/target-class-patterns.md) — `nerdgraph.py` with introspection helper, `cli.py` with a `nerdgraph query` command and per-mutation commands.
5. Agent adds NewRelic quirks: `Api-Key` header, GraphQL cursor pagination, response unwrapping at `data.actor`.
6. Agent writes tests: contract test, request-plan test on a few commands, fixture-server test using `pytest-httpserver` with canned NerdGraph responses.
7. Agent runs `pytest tests -q` from the output directory; all green.
8. Agent verifies discoverability: every command and subcommand has rich `--help` text so an agent can introspect the CLI without external docs.

Result: `~/newrelic-cli/` is an installable package. `pip install -e . && newrelic --help` works. Commands have `--json --dry-run`. Tests pass against a fixture.

## Steps

The full protocol lives in [`references/generation-protocol.md`](references/generation-protocol.md). High-level:

1. **Acquire source evidence.** Read the target's repo, docs, OpenAPI/GraphQL schema, or public docs page. Catalog endpoints, capabilities, and quirks.
2. **Classify the integration.** Pick one of REST/OpenAPI, REST without OpenAPI, GraphQL, stateful workflow, process wrapper, file-project, GUI backend, or mixed. Follow the matching section in [`references/target-class-patterns.md`](references/target-class-patterns.md).
3. **Write the blueprint.** Express the CLI's intent as a typed JSON blueprint (commands, capabilities, auth, integration kind). Optional but recommended — gives the user a reviewable plan before code is written.
4. **Scaffold the package.** Create `pyproject.toml`, package directory, Typer CLI shell, HTTP/process client skeleton, test directory.
5. **Fill the commands.** Implement each command. Wire `--json`, `--dry-run`, mutation level metadata. Reuse generated client helpers. Add adapters under `<package>/adapters/` for non-trivial logic.
6. **Handle target quirks.** Centralize in the client: default query params, response unwrapping, pagination, rate-limit retries, auth header customization.
7. **Build workflow orchestrators.** For stateful targets (Splunk-like search jobs), add a top-level `run` command that drives create → poll → fetch end-to-end.
8. **Write tests.** Contract test (auto-pattern), request-plan tests for API commands, fixture-server tests for response-parsing paths, workflow tests for orchestrators.
9. **Verify.** Run `pytest tests -q` from the output dir. Run `pip install -e . && <cli-name> --help`. Confirm every command lists, every command has `--json`, every mutating command has `--dry-run`, and every command/subcommand has a meaningful `--help` body.

## Outputs

The generated package directory contains:

```
<output-dir>/
├── pyproject.toml                  # installable Python package config
├── README.md                       # human-facing install + usage docs
├── cligen.blueprint.json           # (optional) typed CLI description
├── src/<package>/
│   ├── __init__.py
│   ├── cli.py                      # Typer app — one command per capability
│   ├── client.py                   # HTTP client (or process backend)
│   ├── nerdgraph.py                # (GraphQL targets) introspection + query helpers
│   └── adapters/                   # target-specific quirk handlers
│       ├── pagination.py
│       └── <tool>_backend.py       # (process/GUI targets) headless binary wrapper
└── tests/
    ├── test_cli_contract.py        # CLI loads, --help works, every command has --json
    ├── test_request_plan.py        # --dry-run produces expected URL/method/headers
    ├── test_fixture_server.py      # fixture HTTP server, real parsing path
    └── test_workflows.py           # (stateful targets) end-to-end orchestration
```

## Anti-patterns

- **Adding a command "because the source has a function with this name."** Group commands by *agent jobs*, not source structure. A user wants `search run "query"`, not `create-job` + `poll-status` + `fetch-results` exposed raw.
- **Returning string status messages from `--json` commands.** `--json` always emits a single JSON object — never bare strings, never multi-line YAML, never log lines.
- **Catching exceptions to hide them.** Let upstream errors propagate with context (status code, response body, request URL).
- **Using `os.system`, `shell=True`, or f-string-built command lines.** Subprocess invocations use structured argument arrays. No exceptions.
- **Hardcoding base URLs or credentials anywhere in generated code.** Always read from env vars or the auth helper. Document the env var in `README.md`.
- **Letting `--dry-run` perform a mutation "just to check."** `--dry-run` returns the request plan or a planned-action description. It never writes to disk, never hits the network for mutation endpoints, never modifies upstream state.
- **Skipping workflow choreography for stateful targets** ("the user can sequence them themselves"). They can't, and the next agent shouldn't have to either. Add the high-level orchestrator.
- **Writing tests that only assert the CLI registers.** A contract test is the floor. Add a request-plan test and at least one fixture-server test per integration kind.

## Error Handling

| Failure | Recovery |
|---|---|
| Target source isn't accessible (URL 404, repo private) | Stop. Tell the user what's missing and ask for a local clone path or a public docs URL. |
| Analyzer finds no endpoints / capabilities | Don't fabricate. Tell the user the source has no discoverable surface; ask if they have docs, an OpenAPI spec, or example client code to point at. |
| GraphQL endpoint requires auth for introspection | Ask the user for a token. If they don't have one, skip introspection and ask them to paste sample queries from their docs. |
| Generated tests fail | Read the failure, fix the gap in the client or command, re-run. Do not weaken the test to make it pass. |
| Target needs an auth flow the agent doesn't recognize | Check [`references/target-class-patterns.md`](references/target-class-patterns.md) for the auth flow patterns. If none fit, ask the user for details about the flow before generating code. |
| `pip install -e .` fails in the generated dir | Check `pyproject.toml` syntax. Confirm Python version compatibility (target >=3.10 by default). Surface the real error to the user, don't paper over. |

## Gating Contract

This skill is a **gate** for CLI generation. When invoked, the agent must:

- **Never skip Phase 1 (analyze).** Don't generate from imagination — read real source evidence.
- **Never emit code without the corresponding entry in the blueprint** (if a blueprint is being used). The blueprint and the code must stay in sync.
- **Never ship a generated CLI without at least one passing test** beyond the auto-generated contract test.
- **Never expose a stateful API as raw endpoints** without also adding a workflow orchestrator command.
- **Never ship a command without meaningful `--help` text.** The generated CLI is its own discoverability surface — every command and subcommand must carry a docstring/help body that an agent can read to pick the right call without external docs.

If any of the above can't be honored, stop and explain to the user why.
