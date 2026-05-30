"""Request-plan tests — --dry-run produces the right URL/method/headers."""

from __future__ import annotations

import json

from typer.testing import CliRunner

from lets_prometheus.cli import app


runner = CliRunner()


def test_query_dry_run_plans_get() -> None:
    result = runner.invoke(
        app, ["query", "--query", "up", "--base-url", "http://example:9090", "--dry-run", "--json"]
    )
    assert result.exit_code == 0, result.output
    payload = json.loads(result.output)
    req = payload["request"]
    assert req["method"] == "GET"
    assert req["url"] == "http://example:9090/api/v1/query"
    assert req["params"]["query"] == "up"
    # No bearer set, so no Authorization header
    assert "Authorization" not in req["headers"]


def test_query_with_token_is_redacted_in_dry_run() -> None:
    result = runner.invoke(
        app,
        [
            "query",
            "--query",
            "up",
            "--base-url",
            "http://example:9090",
            "--token",
            "SECRET",
            "--dry-run",
            "--json",
        ],
    )
    assert result.exit_code == 0, result.output
    payload = json.loads(result.output)
    assert payload["request"]["headers"]["Authorization"] == "Bearer <redacted>"
    assert "SECRET" not in result.output


def test_query_range_planner() -> None:
    result = runner.invoke(
        app,
        [
            "query-range",
            "--query",
            "up",
            "--start",
            "1700000000",
            "--end",
            "1700003600",
            "--step",
            "60s",
            "--base-url",
            "http://example:9090",
            "--dry-run",
            "--json",
        ],
    )
    assert result.exit_code == 0, result.output
    payload = json.loads(result.output)
    req = payload["request"]
    assert req["url"].endswith("/api/v1/query_range")
    assert req["params"]["step"] == "60s"


def test_targets_planner() -> None:
    result = runner.invoke(
        app, ["targets", "--state", "active", "--base-url", "http://example:9090", "--dry-run", "--json"]
    )
    assert result.exit_code == 0, result.output
    payload = json.loads(result.output)
    assert payload["request"]["params"]["state"] == "active"
