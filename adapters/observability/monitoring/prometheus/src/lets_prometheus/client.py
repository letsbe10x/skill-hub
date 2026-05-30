"""HTTP client for Prometheus REST API."""

from __future__ import annotations

import os
from typing import Any

import httpx


def _base_url(base_url: str | None = None) -> str:
    url = (base_url or os.environ.get("PROMETHEUS_URL", "http://localhost:9090")).rstrip("/")
    if not url:
        raise RuntimeError(
            "Prometheus base URL not set. Pass --base-url or set PROMETHEUS_URL."
        )
    return url


def _headers(token: str | None = None) -> dict[str, str]:
    headers = {"Accept": "application/json"}
    resolved = token or os.environ.get("PROMETHEUS_TOKEN", "")
    if resolved:
        headers["Authorization"] = f"Bearer {resolved}"
    return headers


def build_request_plan(
    *,
    method: str,
    path: str,
    base_url: str | None = None,
    token: str | None = None,
    params: dict[str, Any] | None = None,
) -> dict[str, Any]:
    """Compose the request that would be sent — without sending it."""
    url = f"{_base_url(base_url)}{path}"
    redacted = dict(_headers(token))
    if "Authorization" in redacted:
        redacted["Authorization"] = "Bearer <redacted>"
    return {
        "method": method.upper(),
        "url": url,
        "headers": redacted,
        "params": params or {},
    }


def _unwrap(payload: dict[str, Any]) -> dict[str, Any]:
    """Strip Prometheus's status/data envelope, raising on non-success."""
    status = payload.get("status")
    if status != "success":
        err = payload.get("errorType") or payload.get("error") or "unknown error"
        raise RuntimeError(f"Prometheus returned non-success: {err}")
    return payload.get("data", {})


class ApiClient:
    """Thin HTTP client. Every method returns the unwrapped `data` payload."""

    def __init__(
        self,
        *,
        base_url: str | None = None,
        token: str | None = None,
        timeout: float = 30.0,
        verify: bool = True,
    ) -> None:
        self.base_url = _base_url(base_url)
        self.token = token or os.environ.get("PROMETHEUS_TOKEN", "")
        self.timeout = timeout
        self.verify = verify

    def request(
        self,
        method: str,
        path: str,
        *,
        params: dict[str, Any] | None = None,
        json_body: dict[str, Any] | None = None,
    ) -> dict[str, Any]:
        response = httpx.request(
            method.upper(),
            f"{self.base_url}{path}",
            headers=_headers(self.token),
            params=params or {},
            json=json_body,
            timeout=self.timeout,
            verify=self.verify,
        )
        response.raise_for_status()
        return _unwrap(response.json())
