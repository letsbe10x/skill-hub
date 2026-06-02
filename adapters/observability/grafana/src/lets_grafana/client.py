"""HTTP client for Grafana REST API."""

from __future__ import annotations

import os
from typing import Any

import httpx


def _base_url(base_url: str | None = None) -> str:
    url = (base_url or os.environ.get("GRAFANA_URL", "http://localhost:3000")).rstrip("/")
    if not url:
        raise RuntimeError(
            "Grafana base URL not set. Pass --base-url or set GRAFANA_URL."
        )
    return url


def _auth(
    user: str | None = None,
    password: str | None = None,
    token: str | None = None,
) -> tuple[dict[str, str], tuple[str, str] | None]:
    """Return (headers, basic_auth_tuple_or_None). Token takes precedence over basic."""
    headers = {"Accept": "application/json", "Content-Type": "application/json"}
    resolved_token = token or os.environ.get("GRAFANA_TOKEN", "")
    if resolved_token:
        headers["Authorization"] = f"Bearer {resolved_token}"
        return headers, None
    resolved_user = user or os.environ.get("GRAFANA_USER", "admin")
    resolved_password = password or os.environ.get("GRAFANA_PASSWORD", "admin")
    return headers, (resolved_user, resolved_password)


def build_request_plan(
    *,
    method: str,
    path: str,
    base_url: str | None = None,
    user: str | None = None,
    password: str | None = None,
    token: str | None = None,
    params: dict[str, Any] | None = None,
    body: dict[str, Any] | None = None,
) -> dict[str, Any]:
    """Compose the request that would be sent — without sending it."""
    url = f"{_base_url(base_url)}{path}"
    headers, basic = _auth(user, password, token)
    redacted = dict(headers)
    if "Authorization" in redacted:
        redacted["Authorization"] = "Bearer <redacted>"
    auth_repr: dict[str, str] | None
    if basic:
        auth_repr = {"type": "basic", "user": basic[0], "password": "<redacted>"}
    else:
        auth_repr = None
    return {
        "method": method.upper(),
        "url": url,
        "headers": redacted,
        "auth": auth_repr,
        "params": params or {},
        "body": body,
    }


class ApiClient:
    """Thin HTTP client. Returns parsed JSON for every call."""

    def __init__(
        self,
        *,
        base_url: str | None = None,
        user: str | None = None,
        password: str | None = None,
        token: str | None = None,
        timeout: float = 30.0,
    ) -> None:
        self.base_url = _base_url(base_url)
        headers, basic = _auth(user, password, token)
        self.headers = headers
        self.basic = basic
        self.timeout = timeout

    def request(
        self,
        method: str,
        path: str,
        *,
        params: dict[str, Any] | None = None,
        json_body: dict[str, Any] | None = None,
    ) -> Any:
        response = httpx.request(
            method.upper(),
            f"{self.base_url}{path}",
            headers=self.headers,
            auth=self.basic,
            params=params or {},
            json=json_body,
            timeout=self.timeout,
        )
        response.raise_for_status()
        ct = response.headers.get("content-type", "")
        if "application/json" in ct:
            return response.json()
        return {"text": response.text}
