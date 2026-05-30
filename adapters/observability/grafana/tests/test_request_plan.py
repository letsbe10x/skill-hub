"""Request-plan tests — --dry-run produces the right URL/auth shape."""

from __future__ import annotations

import json

from typer.testing import CliRunner

from lets_grafana.cli import app


runner = CliRunner()


def test_dashboard_list_plans_get_with_basic_auth() -> None:
    result = runner.invoke(
        app,
        ["dashboard", "list", "--query", "foo", "--base-url", "http://example:3000", "--dry-run", "--json"],
    )
    assert result.exit_code == 0, result.output
    payload = json.loads(result.output)
    req = payload["request"]
    assert req["method"] == "GET"
    assert req["url"] == "http://example:3000/api/search"
    assert req["params"]["query"] == "foo"
    assert req["auth"]["type"] == "basic"
    assert req["auth"]["password"] == "<redacted>"


def test_token_takes_precedence_and_redacts() -> None:
    result = runner.invoke(
        app,
        ["dashboard", "list", "--token", "GRAFANA_TOKEN", "--base-url", "http://example:3000", "--dry-run", "--json"],
    )
    assert result.exit_code == 0, result.output
    payload = json.loads(result.output)
    req = payload["request"]
    assert req["auth"] is None
    assert req["headers"]["Authorization"] == "Bearer <redacted>"
    assert "GRAFANA_TOKEN" not in result.output


def test_dashboard_get_path() -> None:
    result = runner.invoke(
        app,
        ["dashboard", "get", "my-uid", "--base-url", "http://example:3000", "--dry-run", "--json"],
    )
    assert result.exit_code == 0, result.output
    payload = json.loads(result.output)
    assert payload["request"]["url"].endswith("/api/dashboards/uid/my-uid")


def test_health_planner() -> None:
    result = runner.invoke(app, ["health", "--base-url", "http://example:3000", "--dry-run", "--json"])
    assert result.exit_code == 0, result.output
    payload = json.loads(result.output)
    assert payload["request"]["url"].endswith("/api/health")
