# Anti-patterns

Things the agent must not do during CLI generation. Each is a real mistake that
shows up in generated code when an agent rushes.

## Command design

- **Adding a command "because the source has a function with this name."** Group commands by *agent jobs*, not source structure. A user wants `search run "query"`, not `create-job` + `poll-status` + `fetch-results` exposed as the only surface.
- **One CLI command per HTTP endpoint with no thought.** A REST API with 200 endpoints does not become a CLI with 200 top-level commands. Group by resource or domain.
- **Inventing commands not justified by source evidence.** If the analyzer didn't find it and the docs don't describe it, don't add a command for it.
- **Naming commands after implementation details.** `process_search_response_v2` is not a command name. `search results` is.

## Output

- **Returning string status messages from `--json` commands.** `--json` emits a single JSON object. Never bare strings. Never multi-line YAML. Never log lines mixed with the payload.
- **Putting `print()` statements on the request path.** All output goes through the JSON emitter. Logging goes to stderr at the user's chosen verbosity.
- **Truncating output silently.** If the response is huge, document it and offer pagination — don't quietly drop fields.

## Errors

- **Catching exceptions to hide them.** Let upstream errors propagate with context (status code, response body, request URL). Wrapping every `httpx.HTTPError` in a generic "request failed" message destroys debuggability.
- **Returning exit code 0 on partial failure.** If 3 of 5 batch operations succeeded, the exit code reflects the failure. The JSON output enumerates which succeeded and which didn't.
- **Bare `except:` clauses.** Always specify the exception class.

## Safety

- **Using `os.system`, `shell=True`, or f-string-built command lines.** Subprocess invocations use structured argument arrays. No exceptions.
- **Letting `--dry-run` perform a mutation "just to check."** `--dry-run` returns the planned action description. It never writes to disk, never hits the network for mutation endpoints, never modifies upstream state.
- **Skipping mutation level metadata.** Every command declares its level (`read_only`, `local_write`, `external_write`, `network_write`). Defaults are dangerous.
- **Confirming dangerous operations only via `--yes` flag.** For `network_write` or destructive operations, require either an env var (`<TOOL>_ACCEPT_DESTRUCTIVE=1`) or an explicit `--i-mean-it` flag. `--yes` is too easy to type.

## Secrets

- **Hardcoding base URLs or credentials anywhere in generated code.** Always read from env vars or the auth helper. Document the env var in `README.md`.
- **Printing tokens in logs.** Redact at the source: `headers["Authorization"] = "Bearer <redacted>"` in any log/dry-run output.
- **Writing tokens to disk in plain text.** Use the OS keyring or the user's existing auth cache.
- **Including real responses with PII/secrets in tests or fixtures.** Sanitize before committing.

## Workflow

- **Skipping workflow choreography for stateful targets** ("the user can sequence them themselves"). They can't. The next agent shouldn't have to either. Add the orchestrator.
- **Polling without exponential backoff.** Tight loops get rate-limited. Start at 1s, double up to 60s.
- **Polling without timeout.** Every orchestrator command takes `--timeout` (default 60s, but configurable).
- **Not persisting intermediate state.** Long-running orchestrators must support `--resume <session-id>`.

## Testing

- **Writing tests that only assert the CLI registers.** A contract test is the floor. Add a request-plan test and at least one fixture-server test per integration kind.
- **Weakening a test to make it pass.** Fix the code, not the assertion.
- **Using `time.sleep()` in tests.** Mock the clock or use the test framework's wait helpers.
- **Tests that depend on real network or real upstream.** Use fixture servers (`pytest-httpserver`) or recorded responses (`pytest-recording`, VCR). Mark anything else with `@pytest.mark.live` and skip by default.

## Documentation

- **Shipping commands with empty or boilerplate `--help` text.** The CLI is its own discoverability surface; every command and subcommand needs a meaningful docstring/help body so an agent can pick the right call without external docs.
- **Documenting features that don't exist.** README claims drive support tickets when they don't match behavior.
- **Generic install instructions.** Document the actual install command for the user's likely environment.

## Project structure

- **Putting everything in one file.** Once `cli.py` exceeds ~400 lines, split into `cli.py` (Typer registration) + `adapters/<concern>.py` modules.
- **Importing from `src/` paths in tests.** Tests import the package by name (`from <package> import cli`), proving the package installs correctly.
- **Mixing the generated CLI's logic with the target's source.** The CLI lives in its own package directory; the target stays in its own repo.
