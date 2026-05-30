"""Live smoke against http://localhost:16686. Skipped unless `-m live`."""

from __future__ import annotations

import json
import os

import pytest
from typer.testing import CliRunner

from lets_jaeger.cli import app


runner = CliRunner()

pytestmark = pytest.mark.live


def test_live_services_includes_seeded() -> None:
    os.environ.setdefault("JAEGER_URL", "http://localhost:16686")
    result = runner.invoke(app, ["services", "--json"])
    assert result.exit_code == 0, result.output
    payload = json.loads(result.output)
    assert payload["status"] == "ok"
    services = payload["data"]
    assert isinstance(services, list)
    assert "lets-sandbox-demo" in services, f"expected seeded service; got {services}"


def test_live_trace_search_returns_seeded_trace() -> None:
    os.environ.setdefault("JAEGER_URL", "http://localhost:16686")
    result = runner.invoke(
        app, ["trace", "search", "--service", "lets-sandbox-demo", "--lookback", "24h", "--json"]
    )
    assert result.exit_code == 0, result.output
    payload = json.loads(result.output)
    assert payload["status"] == "ok"
    traces = payload["data"]
    assert len(traces) >= 1, "expected ≥1 trace for lets-sandbox-demo in the last 24h"
