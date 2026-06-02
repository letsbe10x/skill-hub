"""Live smoke against http://localhost:3000 (admin/admin). Skipped unless `-m live`."""

from __future__ import annotations

import json
import os

import pytest
from typer.testing import CliRunner

from lets_grafana.cli import app


runner = CliRunner()

pytestmark = pytest.mark.live


def _setup_env() -> None:
    os.environ.setdefault("GRAFANA_URL", "http://localhost:3000")
    os.environ.setdefault("GRAFANA_USER", "admin")
    os.environ.setdefault("GRAFANA_PASSWORD", "admin")


def test_live_health() -> None:
    _setup_env()
    result = runner.invoke(app, ["health", "--json"])
    assert result.exit_code == 0, result.output
    payload = json.loads(result.output)
    assert payload["status"] == "ok"
    assert payload["data"]["database"] == "ok"


def test_live_dashboard_list_includes_seeded_dashboard() -> None:
    _setup_env()
    result = runner.invoke(app, ["dashboard", "list", "--json"])
    assert result.exit_code == 0, result.output
    payload = json.loads(result.output)
    assert payload["status"] == "ok"
    dashboards = payload["data"]
    assert isinstance(dashboards, list)
    uids = {d.get("uid") for d in dashboards}
    assert "lets-sandbox-demo" in uids, f"expected seeded dashboard; got UIDs {uids}"


def test_live_datasource_list_works() -> None:
    _setup_env()
    result = runner.invoke(app, ["datasource", "list", "--json"])
    assert result.exit_code == 0, result.output
    payload = json.loads(result.output)
    assert payload["status"] == "ok"
    assert isinstance(payload["data"], list)  # may be empty in a fresh sandbox
