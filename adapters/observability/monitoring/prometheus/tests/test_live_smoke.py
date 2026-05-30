"""Live smoke — runs against http://localhost:9090. Skipped unless `-m live`."""

from __future__ import annotations

import json
import os

import pytest
from typer.testing import CliRunner

from lets_prometheus.cli import app


runner = CliRunner()

pytestmark = pytest.mark.live


def test_live_query_up_metric_returns_at_least_one_series() -> None:
    os.environ.setdefault("PROMETHEUS_URL", "http://localhost:9090")
    result = runner.invoke(app, ["query", "--query", "up", "--json"])
    assert result.exit_code == 0, result.output
    payload = json.loads(result.output)
    assert payload["status"] == "ok"
    data = payload["data"]
    assert data["resultType"] == "vector"
    assert len(data["result"]) >= 1, "expected ≥1 'up' series from the live sandbox"


def test_live_targets_lists_self_scrape() -> None:
    os.environ.setdefault("PROMETHEUS_URL", "http://localhost:9090")
    result = runner.invoke(app, ["targets", "--state", "active", "--json"])
    assert result.exit_code == 0, result.output
    payload = json.loads(result.output)
    assert payload["status"] == "ok"
    active = payload["data"].get("activeTargets", [])
    assert len(active) >= 1
    # the sandbox scrapes itself
    assert any("prometheus" in (t.get("labels", {}).get("job", "")).lower() for t in active)
