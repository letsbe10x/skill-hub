"""HTTP client for Jaeger query API."""

from __future__ import annotations

import os
import re
import time
from typing import Any

import httpx


def _base_url(base_url: str | None = None) -> str:
    url = (base_url or os.environ.get("JAEGER_URL", "http://localhost:16686")).rstrip("/")
    if not url:
        raise RuntimeError("Jaeger base URL not set. Pass --base-url or set JAEGER_URL.")
    return url


def _headers(token: str | None = None) -> dict[str, str]:
    headers = {"Accept": "application/json"}
    resolved = token or os.environ.get("JAEGER_TOKEN", "")
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


_DURATION_RE = re.compile(r"^(\d+)(s|m|h|d)$")
_MULT = {"s": 1, "m": 60, "h": 3600, "d": 86400}


def parse_lookback_to_micros(lookback: str, *, now: float | None = None) -> tuple[int, int]:
    """Convert a duration like '1h' / '30m' / '7d' to (start_us, end_us) for Jaeger query API."""
    match = _DURATION_RE.match(lookback.strip())
    if not match:
        raise ValueError(f"Invalid lookback '{lookback}'. Use e.g. 1h, 30m, 7d.")
    n = int(match.group(1))
    unit = match.group(2)
    seconds = n * _MULT[unit]
    end_s = now if now is not None else time.time()
    start_s = end_s - seconds
    return int(start_s * 1_000_000), int(end_s * 1_000_000)


def _unwrap(payload: dict[str, Any]) -> Any:
    """Jaeger wraps everything in {"data": ..., "total": ..., "errors": ...}."""
    if payload.get("errors"):
        raise RuntimeError(f"Jaeger returned errors: {payload['errors']}")
    return payload.get("data", payload)


class ApiClient:
    def __init__(
        self,
        *,
        base_url: str | None = None,
        token: str | None = None,
        timeout: float = 30.0,
    ) -> None:
        self.base_url = _base_url(base_url)
        self.token = token or os.environ.get("JAEGER_TOKEN", "")
        self.timeout = timeout

    def request(
        self,
        method: str,
        path: str,
        *,
        params: dict[str, Any] | None = None,
    ) -> Any:
        response = httpx.request(
            method.upper(),
            f"{self.base_url}{path}",
            headers=_headers(self.token),
            params=params or {},
            timeout=self.timeout,
        )
        response.raise_for_status()
        return _unwrap(response.json())
