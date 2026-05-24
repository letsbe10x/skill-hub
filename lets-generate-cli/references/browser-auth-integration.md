# Browser Auth Integration

How to wire browser-mediated authentication into a generated CLI when the target
has no PAT/API-key flow and requires the user to log in through a browser.

## When to use browser auth

Pick browser auth (vs `env_token` or `oauth_device`) when:

- The target has no programmatic API token (auth is web-session only).
- The target supports SSO/SAML and issuing a PAT requires admin approval the user doesn't have.
- The user prefers reusing their existing browser session over juggling a PAT.

Don't use browser auth when:

- A long-lived API token is available — env tokens are simpler, easier to rotate, and easier to test.
- The target is a CLI tool that doesn't need web auth at all.
- The user is in a CI/headless environment with no browser.

## The pattern

A generated CLI that uses browser auth does **not** drive a browser itself. It:

1. Reads a cached browser session (cookies + storage state) from a known location.
2. Injects the appropriate `Cookie` / `Authorization` / `X-CSRF-Token` headers into outgoing requests.
3. Detects a stale session (401/403) and surfaces a clear "re-authenticate via `<helper>`" error.

A separate, one-time setup step captures the browser session. Two common paths:

### Path A — `letsbe10x-browser-auth` (recommended when available)

If the user has the `letsbe10x-browser-auth` PyPI package installed (along with the `lets browser-auth` CLI), the generated CLI uses it as a dependency.

```python
# in <package>/client.py
try:
    from browser_auth import BrowserAuthStore
    _BA_AVAILABLE = True
except ImportError:
    _BA_AVAILABLE = False


def _load_browser_session(session_name: str) -> dict:
    if not _BA_AVAILABLE:
        raise RuntimeError(
            "Browser auth not available. Install with:\n"
            "  pip install letsbe10x-browser-auth\n"
            "Then capture the session:\n"
            f"  lets browser-auth setup {session_name}"
        )
    store = BrowserAuthStore.default()
    session = store.load(session_name)
    return session.headers
```

Document this in the generated CLI's `README.md`:

```bash
pip install letsbe10x-browser-auth
lets browser-auth setup <my-target>           # one-time interactive capture
<cli-name> <command> --json                   # subsequent calls reuse the session
```

### Path B — Direct Playwright (when `letsbe10x-browser-auth` is unavailable)

If the user isn't running the letsbe10x companion, fall back to driving Playwright directly. Vendor a small helper in the generated CLI:

```python
# in <package>/adapters/browser_session.py
from pathlib import Path
import json
import os

DEFAULT_SESSION_DIR = Path(
    os.environ.get(
        "<TARGET>_BROWSER_SESSION_DIR",
        str(Path.home() / ".cache" / "<package>" / "browser-sessions"),
    )
)


def load_or_capture_session(login_url: str, name: str) -> dict:
    """Return cached browser headers; capture interactively if none exist."""
    session_path = DEFAULT_SESSION_DIR / f"{name}.json"
    if session_path.exists():
        return json.loads(session_path.read_text(encoding="utf-8"))

    # First-time capture via Playwright
    from playwright.sync_api import sync_playwright

    DEFAULT_SESSION_DIR.mkdir(parents=True, exist_ok=True)
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=False)
        context = browser.new_context()
        page = context.new_page()
        page.goto(login_url)
        input("Press Enter after you've logged in...")
        cookies = context.cookies()
        storage = context.storage_state()
        browser.close()

    session = {
        "cookies": cookies,
        "storage_state": storage,
        "headers": _cookies_to_header(cookies),
    }
    session_path.write_text(json.dumps(session, indent=2), encoding="utf-8")
    return session["headers"]
```

This makes the generated CLI standalone — works whether or not the user has the letsbe10x ecosystem installed.

## Mandatory rules

Regardless of path:

1. **Never write the captured session to a world-readable file.** Use mode `0o600`.
2. **Never log cookies or session headers.** Redact at the source.
3. **Always handle 401/403 by telling the user to re-capture the session.** Don't fall back to silent re-prompting in the middle of a command.
4. **Session files belong in a cache dir, not the package install dir.** `~/.cache/<package>/browser-sessions/` is standard on Linux/macOS.
5. **Document the session name convention** in the generated `README.md` so the user knows what `setup <name>` argument to use.

## What goes in the generated CLI's blueprint

```json
{
  "auth": {
    "mode": "browser_auth",
    "browser_auth_name": "<target>",
    "browser_login_url": "https://<target>/login",
    "notes": [
      "Requires letsbe10x-browser-auth or vendored playwright helper.",
      "Capture via `lets browser-auth setup <target>`."
    ]
  }
}
```
