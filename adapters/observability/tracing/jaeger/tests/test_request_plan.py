"""Request-plan + duration-parser tests."""

from __future__ import annotations

import json

from typer.testing import CliRunner

from lets_jaeger.cli import app
from lets_jaeger.client import parse_lookback_to_micros


runner = CliRunner()


def test_services_planner() -> None:
    result = runner.invoke(app, ["services", "--base-url", "http://example:16686", "--dry-run", "--json"])
    assert result.exit_code == 0, result.output
    payload = json.loads(result.output)
    req = payload["request"]
    assert req["method"] == "GET"
    assert req["url"] == "http://example:16686/api/services"


def test_operations_planner_includes_service() -> None:
    result = runner.invoke(
        app, ["operations", "--service", "my-svc", "--base-url", "http://example:16686", "--dry-run", "--json"]
    )
    assert result.exit_code == 0, result.output
    payload = json.loads(result.output)
    assert payload["request"]["params"]["service"] == "my-svc"


def test_trace_search_includes_window() -> None:
    result = runner.invoke(
        app,
        [
            "trace", "search",
            "--service", "my-svc",
            "--operation", "GET /",
            "--lookback", "30m",
            "--limit", "5",
            "--base-url", "http://example:16686",
            "--dry-run", "--json",
        ],
    )
    assert result.exit_code == 0, result.output
    payload = json.loads(result.output)
    params = payload["request"]["params"]
    assert params["service"] == "my-svc"
    assert params["operation"] == "GET /"
    assert params["limit"] == 5
    assert params["end"] - params["start"] == 30 * 60 * 1_000_000  # 30 min in μs


def test_trace_get_planner_uses_path() -> None:
    result = runner.invoke(
        app, ["trace", "get", "abcdef0123456789", "--base-url", "http://example:16686", "--dry-run", "--json"]
    )
    assert result.exit_code == 0, result.output
    payload = json.loads(result.output)
    assert payload["request"]["url"].endswith("/api/traces/abcdef0123456789")


def test_parse_lookback_units() -> None:
    s1, e1 = parse_lookback_to_micros("1h", now=1_000_000)
    assert e1 - s1 == 3600 * 1_000_000
    s2, e2 = parse_lookback_to_micros("7d", now=1_000_000)
    assert e2 - s2 == 7 * 86400 * 1_000_000


def test_token_redacted() -> None:
    result = runner.invoke(
        app, ["services", "--token", "SUPERSECRET", "--base-url", "http://example:16686", "--dry-run", "--json"]
    )
    assert result.exit_code == 0, result.output
    payload = json.loads(result.output)
    assert payload["request"]["headers"]["Authorization"] == "Bearer <redacted>"
    assert "SUPERSECRET" not in result.output
