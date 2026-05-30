# Jira sandbox

Spins up Jira Software locally via Atlassian's official Docker image, backed
by the shared `databases/rdbms/postgres/` sandbox. Creates a demo project +
an issue via the REST API, then queries the issue back to prove the
integration works end-to-end.

## What this proves

That an integration which expects to create + read Jira issues via the REST
API (`/rest/api/2/project`, `/rest/api/2/issue`, `/rest/api/2/search`) works
end-to-end against a real Jira instance.

## Prereqs

- Docker (with ≥2 GB free RAM for the JVM)
- `curl`, `jq`
- **Shared postgres sandbox up first** (Jira uses the shared `lets-sandbox-data`
  network — it will not start without it):
  ```bash
  cd ~/lets/skill-hub/sandboxes/databases/rdbms/postgres
  KEEP_RUNNING=1 ./smoke.sh
  ```
- ~3–5 minutes for Jira's **first** boot (subsequent boots are ~30s)

## Ports

| Port | Purpose |
|---|---|
| 8080 | Web UI + REST API — `http://localhost:8080` |

## One-time setup (~3–5 min, manual)

Jira Software needs an evaluation license. Atlassian doesn't ship a
completely-free Server edition (Server was discontinued in 2024 — only
paid + free-eval). The eval license is genuinely free and takes ~2 min:

1. Start the stack:
   ```bash
   docker compose up -d
   ```
2. Wait ~3–5 min for first boot, then open <http://localhost:8080>.
3. Walk the wizard. The compose file pre-configures the database (shared
   postgres) via `ATL_JDBC_*` env vars, so the wizard **skips the database
   page** and starts at License:
   - **License**: click "Get an evaluation license" → my.atlassian.com →
     sign in / sign up with any email → generate a 30-day server trial
     license → paste back. Free, no credit card.
   - **Application Properties**: defaults are fine.
   - **Admin account**: `admin` / `admin` (match `.env`)
   - **Email**: skip ("Configure later")
4. Once the dashboard loads, run:
   ```bash
   ./smoke.sh
   ```

The `jira_data` volume persists across restarts, so you only do the wizard
once. `docker compose down -v` wipes it; `docker compose down` (no `-v`)
preserves it.

## Why not the "free" community images?

Two paths I investigated and rejected:

- **`addono/jira-software-standalone`** — wraps Atlassian's official SDK
  (`atlas-run-standalone`), legitimate, no license signup. But first boot
  downloads ~500 Maven artifacts (15+ min on a fresh machine). Too slow for
  a sandbox-pattern UX.
- **`haxqer/jira`** — 104M pulls, but its GitHub README returns HTTP 451
  (Unavailable For Legal Reasons), strongly suggesting it ships
  `atlassian-agent.jar` (a known license-cracker). Not legitimate.

The official image + 2-min MyAtlassian signup is genuinely the fastest +
cleanest path. The signup is annoying once; the alternative is hostile.

## Run the smoke test (after setup)

```bash
./smoke.sh
```

1. Confirms Jira is responding and the REST API is reachable
2. Detects whether the setup wizard has been completed (prints clear next steps if not)
3. Creates the `LSB` project (idempotent — skips if it exists)
4. Creates a sample issue
5. Queries `/rest/api/2/search?jql=project=LSB` and asserts ≥1 issue
6. Prints `OK` on success

## What gets seeded

- One project: key `LSB`, name "Lets Sandbox", type Software (Scrum)
- One issue: "Sandbox smoke issue"

See [`seed/sample-issues.json`](seed/sample-issues.json) for the payload.
