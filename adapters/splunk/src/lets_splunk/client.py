"""HTTP client for Splunk Enterprise — both the mgmt REST API and HEC."""

from __future__ import annotations

import os
from typing import Any

import httpx


# ---- URL + auth helpers -------------------------------------------------- #


def _mgmt_url(url: str | None = None) -> str:
    resolved = (url or os.environ.get("SPLUNK_MGMT_URL", "https://localhost:8089")).rstrip("/")
    if not resolved:
        raise RuntimeError("Splunk mgmt URL not set. Pass --mgmt-url or set SPLUNK_MGMT_URL.")
    return resolved


def _hec_url(url: str | None = None) -> str:
    resolved = (url or os.environ.get("SPLUNK_HEC_URL", "https://localhost:8088")).rstrip("/")
    if not resolved:
        raise RuntimeError("Splunk HEC URL not set. Pass --hec-url or set SPLUNK_HEC_URL.")
    return resolved


def _basic(
    user: str | None = None,
    password: str | None = None,
) -> tuple[str, str]:
    resolved_user = user or os.environ.get("SPLUNK_USER", "admin")
    resolved_password = password or os.environ.get("SPLUNK_PASSWORD", "")
    if not resolved_password:
        raise RuntimeError(
            "Splunk mgmt password not set. Pass --password or set SPLUNK_PASSWORD."
        )
    return resolved_user, resolved_password


def _hec_token(token: str | None = None) -> str:
    resolved = token or os.environ.get("SPLUNK_HEC_TOKEN", "")
    if not resolved:
        raise RuntimeError("HEC token not set. Pass --hec-token or set SPLUNK_HEC_TOKEN.")
    return resolved


def _insecure(insecure: bool | None = None) -> bool:
    if insecure is not None:
        return insecure
    return os.environ.get("SPLUNK_INSECURE", "true").lower() in {"1", "true", "yes"}


# ---- Request plans ------------------------------------------------------- #


def build_mgmt_request_plan(
    *,
    method: str,
    path: str,
    mgmt_url: str | None = None,
    user: str | None = None,
    password: str | None = None,
    insecure: bool | None = None,
    params: dict[str, Any] | None = None,
    body: dict[str, Any] | None = None,
) -> dict[str, Any]:
    url = f"{_mgmt_url(mgmt_url)}{path}"
    resolved_user = user or os.environ.get("SPLUNK_USER", "admin")
    return {
        "method": method.upper(),
        "url": url,
        "headers": {"Accept": "application/json"},
        "auth": {"type": "basic", "user": resolved_user, "password": "<redacted>"},
        "params": params or {},
        "body": body,
        "tls_verify": not _insecure(insecure),
    }


def build_hec_request_plan(
    *,
    hec_url: str | None = None,
    token: str | None = None,
    insecure: bool | None = None,
    event: dict[str, Any] | None = None,
) -> dict[str, Any]:
    url = f"{_hec_url(hec_url)}/services/collector/event"
    return {
        "method": "POST",
        "url": url,
        "headers": {
            "Authorization": "Splunk <redacted>",
            "Content-Type": "application/json",
        },
        "body": event or {},
        "tls_verify": not _insecure(insecure),
    }


# ---- Clients ------------------------------------------------------------- #


class MgmtClient:
    """Splunk mgmt REST API client. Always passes `output_mode=json`."""

    def __init__(
        self,
        *,
        mgmt_url: str | None = None,
        user: str | None = None,
        password: str | None = None,
        insecure: bool | None = None,
        timeout: float = 60.0,
    ) -> None:
        self.mgmt_url = _mgmt_url(mgmt_url)
        self.user, self.password = _basic(user, password)
        self.verify = not _insecure(insecure)
        self.timeout = timeout

    def request(
        self,
        method: str,
        path: str,
        *,
        params: dict[str, Any] | None = None,
        data: dict[str, Any] | None = None,
    ) -> dict[str, Any]:
        merged_params = {"output_mode": "json", **(params or {})}
        response = httpx.request(
            method.upper(),
            f"{self.mgmt_url}{path}",
            headers={"Accept": "application/json"},
            auth=(self.user, self.password),
            params=merged_params,
            data=data,
            timeout=self.timeout,
            verify=self.verify,
        )
        response.raise_for_status()
        ct = response.headers.get("content-type", "")
        if "application/json" in ct:
            return response.json()
        return {"text": response.text}


class HecClient:
    def __init__(
        self,
        *,
        hec_url: str | None = None,
        token: str | None = None,
        insecure: bool | None = None,
        timeout: float = 30.0,
    ) -> None:
        self.hec_url = _hec_url(hec_url)
        self.token = _hec_token(token)
        self.verify = not _insecure(insecure)
        self.timeout = timeout

    def send(self, event: dict[str, Any]) -> dict[str, Any]:
        response = httpx.post(
            f"{self.hec_url}/services/collector/event",
            headers={
                "Authorization": f"Splunk {self.token}",
                "Content-Type": "application/json",
            },
            json=event,
            timeout=self.timeout,
            verify=self.verify,
        )
        response.raise_for_status()
        return response.json() if response.content else {"text": ""}
