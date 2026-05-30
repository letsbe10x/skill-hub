"""Live smoke against https://localhost:8089 (mgmt) and :8088 (HEC). Skipped unless `-m live`."""

from __future__ import annotations

import json
import os
import uuid

import pytest
from typer.testing import CliRunner

from lets_splunk.cli import app


runner = CliRunner()

pytestmark = pytest.mark.live


def _setup_env() -> None:
    os.environ.setdefault("SPLUNK_MGMT_URL", "https://localhost:8089")
    os.environ.setdefault("SPLUNK_HEC_URL", "https://localhost:8088")
    os.environ.setdefault("SPLUNK_USER", "admin")
    os.environ.setdefault("SPLUNK_PASSWORD", "Changeme123!")
    os.environ.setdefault("SPLUNK_HEC_TOKEN", "00000000-0000-0000-0000-000000000000")
    os.environ.setdefault("SPLUNK_INSECURE", "true")


def test_live_server_info_returns_version() -> None:
    _setup_env()
    result = runner.invoke(app, ["server-info", "--json"])
    assert result.exit_code == 0, result.output
    payload = json.loads(result.output)
    assert payload["status"] == "ok"
    # Splunk returns {entry: [{content: {version: ...}}], ...} on output_mode=json
    raw = payload["data"]
    version_found = False
    if isinstance(raw, dict):
        for entry in raw.get("entry", []) or []:
            if entry.get("content", {}).get("version"):
                version_found = True
                break
    assert version_found, f"expected a version in server-info; got {raw}"


def test_live_search_returns_seeded_access_combined_events() -> None:
    _setup_env()
    result = runner.invoke(
        app,
        ["search", "--query", "search index=main sourcetype=access_combined", "--earliest", "-7d", "--json"],
    )
    assert result.exit_code == 0, result.output
    payload = json.loads(result.output)
    assert payload["status"] == "ok"
    assert payload["result_count"] >= 1, "expected ≥1 seeded access_combined event"


def test_live_ingest_then_search_finds_it() -> None:
    _setup_env()
    marker = f"sandbox-smoke-{uuid.uuid4().hex[:8]}"

    # 1. Ingest a uniquely-marked event
    result = runner.invoke(
        app,
        ["ingest", "--event", f'{{"marker":"{marker}"}}', "--sourcetype", "sandbox:smoke", "--json"],
    )
    assert result.exit_code == 0, result.output
    payload = json.loads(result.output)
    assert payload["status"] == "ok"

    # 2. Wait a moment for the index to catch up, then search for it
    import time as _time
    _time.sleep(3)

    found = 0
    for _ in range(6):  # up to ~18s of polling
        result = runner.invoke(
            app,
            ["search", "--query", f"search index=main {marker}", "--earliest", "-5m", "--json"],
        )
        assert result.exit_code == 0, result.output
        payload = json.loads(result.output)
        found = payload["result_count"]
        if found >= 1:
            break
        _time.sleep(3)

    assert found >= 1, f"ingested event with marker={marker} not found within 18s"
