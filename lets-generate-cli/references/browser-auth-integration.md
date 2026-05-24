# Browser Auth Integration

How to wire browser-mediated authentication into a generated CLI when the
target has no PAT / API key and the user authenticates through a browser.

## When to use it

Pick browser auth when:

- The target has no programmatic API token (auth is web-session only).
- SSO/SAML is required and issuing a PAT needs admin approval the user doesn't have.
- The user prefers reusing their existing browser session.

Skip it when:

- A long-lived API token is available — env tokens are simpler.
- The target is a local CLI tool that doesn't need web auth.
- The user is in a CI/headless environment with no browser.

## How it works

A generated CLI does not drive a browser itself. It:

1. Reads a cached browser session (cookies + storage state) from a known location.
2. Injects the right headers (`Cookie`, `Authorization`, custom headers) into outgoing requests.
3. Detects a stale session (401/403) and tells the user to re-capture.

A one-time setup step captures the session up front.

## One-time setup

```bash
lets browser-auth setup <name>
```

Chrome opens, the user logs in to the target, the session state is saved
under a logical name (e.g. `my-target`). Repeat for as many targets as
needed — each gets its own named session.

## Using it in a generated CLI

```python
# in <package>/client.py
from browser_auth import BrowserAuthStore


def _session_headers(name: str = "my-target") -> dict:
    store = BrowserAuthStore.default()
    session = store.load(name)
    if session is None:
        raise RuntimeError(
            f"No cached browser session for '{name}'. Run:\n"
            f"  lets browser-auth setup {name}"
        )
    return session.headers


def request(method: str, path: str, *, base_url: str) -> dict:
    import httpx
    headers = {"Accept": "application/json", **_session_headers()}
    response = httpx.request(method, f"{base_url}{path}", headers=headers, timeout=30)
    if response.status_code in (401, 403):
        raise RuntimeError(
            "Session expired. Re-capture with:\n"
            "  lets browser-auth setup my-target"
        )
    response.raise_for_status()
    return response.json()
```

## Blueprint declaration

```json
{
  "auth": {
    "mode": "browser_auth",
    "browser_auth_name": "my-target",
    "browser_login_url": "https://my-target/login"
  }
}
```

## Rules

1. **Never log cookie / session header values.** Redact at the source.
2. **Always handle 401/403 by telling the user to re-capture.** Don't silently re-prompt mid-command.
3. **One session name per target.** Reuse across runs; don't generate fresh sessions per invocation.
