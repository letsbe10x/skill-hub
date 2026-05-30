# Confluence sandbox

Spins up Confluence locally via Atlassian's official Docker image. Creates a
demo space + a page via the REST API, then queries the page back to prove the
integration works end-to-end.

## What this proves

That an integration which expects to create + read Confluence pages via the
REST API (`/rest/api/space`, `/rest/api/content`) works end-to-end against a
real Confluence instance — no Atlassian Cloud account required.

## Prereqs

- Docker (with ≥2 GB free RAM for the JVM)
- `curl`, `jq`
- **Shared postgres sandbox up first** (Confluence uses the shared
  `lets-sandbox-data` network — it will not start without it):
  ```bash
  cd ~/lets/skill-hub/sandboxes/databases/postgres
  KEEP_RUNNING=1 ./smoke.sh
  ```
- ~3–5 minutes for Confluence's **first** boot (subsequent boots are ~30s)

## Ports

| Port | Purpose |
|---|---|
| 8090 | Web UI + REST API — `http://localhost:8090` |
| 8091 | Synchrony (collaborative editor) — ships by default; safe to ignore |

## One-time setup (~5 min, manual)

Confluence ships with an interactive setup wizard that asks for an evaluation
license, an admin account, and a sample space. Atlassian does not support
fully unattended setup for evaluation use. The wizard runs once, then
everything is automated.

1. Start the stack:

   ```bash
   docker compose up -d
   ```

2. Wait ~3–5 minutes for the container to boot, then open
   <http://localhost:8090> in a browser.

3. Walk through the wizard. The compose file pre-configures the database
   (PostgreSQL alongside Confluence) via Atlassian's `ATL_JDBC_*` env vars,
   so the wizard **skips its database step** and goes straight to license:
   - **Set up for**: "Production Installation" → click "Continue"
     (note: "Trial" requires an Atlassian Cloud account; "Production" lets
     you paste an evaluation license)
   - **License**: click "Get a Confluence trial license" — opens Atlassian's
     site, log in or sign up with any email, get a 30-day server trial key,
     paste it back. Free, no credit card.
   - **Load Content**: pick "Empty Site"
   - **User Management**: "Manage users and groups within Confluence"
   - **Admin account**: use `admin` / `admin` (or your own — match `.env`)
   - **Email**: skip ("Configure later")

   *Why a separate PostgreSQL container?* Modern Confluence images dropped
   the "Built-in" option — they require a real database. The compose file
   ships PostgreSQL right next to Confluence so this is invisible to you.

4. Once the dashboard loads, the wizard is complete. Run the smoke test:

   ```bash
   ./smoke.sh
   ```

## Run the smoke test (after setup)

```bash
./smoke.sh
```

This:
1. Confirms Confluence is responding and the REST API is reachable
2. Detects whether the setup wizard has been completed (prints clear next steps if not)
3. Creates the `LSB` space (idempotent — skips if it exists)
4. Creates a sample page titled "Sandbox smoke page"
5. Queries `/rest/api/content?spaceKey=LSB` and asserts the page is returned
6. Prints `OK` on success

## Leave it running

```bash
docker compose up -d
open http://localhost:8090       # admin / admin
docker compose down              # keeps data
docker compose down -v           # full reset (re-run the wizard)
```

## What gets seeded

- One space: key `LSB`, name "Lets Sandbox"
- One page: "Sandbox smoke page" in that space

See [`seed/sample-page.json`](seed/sample-page.json) for the exact payload.
