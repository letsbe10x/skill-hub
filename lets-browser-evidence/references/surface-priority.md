# Browser surface priority

Use the **first** option that is available and appropriate for the brief.

## 1. Webwright host plugin

**When:** Claude Code or Codex with `webwright@webwright` installed (restart session after install).

**How:** `/webwright:run` for one-shot tasks; `/webwright:craft` for parameterized `final_script.py`.

**Why:** Uses the host model; no separate Webwright harness API key for plugin-driven loops.

## 2. Webwright CLI (lets-installed engine)

**When:** Plugin unavailable (e.g. Cursor) or you need a fully automated harness run.

**How:** From the Webwright install created by `make lets-browser-evidence` (path recorded in webwright-ready.json):

```bash
python3 -m webwright.run.cli -c base.yaml -c model_openai.yaml \
  -t "TASK" --start-url URL --task-id ID -o outputs/ID
```

**Requires:** provider API keys in the user environment per chosen model config (not stored in workspace artifacts).  # noqa-capability: resources.secrets: env-only keys for Webwright CLI

## 3. Repo Playwright e2e

**When:** The target application already ships Playwright tests.

**How:** Run the project’s test command (example: `cd apps/gt-ui && pnpm exec playwright test`).

**Why:** Canonical merge gate; no duplicate agent-generated suite.

## 4. IDE browser MCP

**When:** Exploratory pass only, or Webwright not yet installed.

**How:** Navigate with the host browser tool; save screenshots into the workspace manually.

**Limit:** Not sufficient alone for ship gate — follow with crafted script or repo e2e.
