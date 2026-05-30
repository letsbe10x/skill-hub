"""Request-plan tests for mgmt + HEC."""

from __future__ import annotations

import json

from typer.testing import CliRunner

from lets_splunk.cli import app


runner = CliRunner()


def test_search_plans_post_to_jobs_with_blocking() -> None:
    result = runner.invoke(
        app,
        [
            "search",
            "--query", "search index=main",
            "--mgmt-url", "https://example:8089",
            "--user", "u",
            "--password", "p",
            "--dry-run", "--json",
        ],
    )
    assert result.exit_code == 0, result.output
    payload = json.loads(result.output)
    req = payload["request"]
    assert req["method"] == "POST"
    assert req["url"].endswith("/services/search/jobs")
    assert req["body"]["exec_mode"] == "blocking"
    assert req["auth"]["password"] == "<redacted>"
    assert req["tls_verify"] is False  # default --insecure for sandbox


def test_password_redacted_in_output() -> None:
    result = runner.invoke(
        app,
        [
            "search",
            "--query", "search index=main",
            "--mgmt-url", "https://example:8089",
            "--user", "u",
            "--password", "SUPERSECRET",
            "--dry-run", "--json",
        ],
    )
    assert result.exit_code == 0, result.output
    assert "SUPERSECRET" not in result.output


def test_ingest_plans_post_to_hec_with_token_redacted() -> None:
    result = runner.invoke(
        app,
        [
            "ingest",
            "--event", '{"k":"v"}',
            "--hec-url", "https://example:8088",
            "--hec-token", "HEC_TOKEN_SECRET",
            "--dry-run", "--json",
        ],
    )
    assert result.exit_code == 0, result.output
    payload = json.loads(result.output)
    req = payload["request"]
    assert req["method"] == "POST"
    assert req["url"].endswith("/services/collector/event")
    assert req["headers"]["Authorization"] == "Splunk <redacted>"
    assert "HEC_TOKEN_SECRET" not in result.output


def test_ingest_parses_json_event_payload() -> None:
    result = runner.invoke(
        app,
        [
            "ingest",
            "--event", '{"action":"click"}',
            "--hec-url", "https://example:8088",
            "--hec-token", "X",
            "--dry-run", "--json",
        ],
    )
    assert result.exit_code == 0, result.output
    payload = json.loads(result.output)
    assert payload["request"]["body"]["event"] == {"action": "click"}


def test_ingest_passes_string_event_when_not_json() -> None:
    result = runner.invoke(
        app,
        [
            "ingest",
            "--event", "raw log line",
            "--hec-url", "https://example:8088",
            "--hec-token", "X",
            "--dry-run", "--json",
        ],
    )
    assert result.exit_code == 0, result.output
    payload = json.loads(result.output)
    assert payload["request"]["body"]["event"] == "raw log line"


def test_server_info_plans_get() -> None:
    result = runner.invoke(
        app,
        [
            "server-info",
            "--mgmt-url", "https://example:8089",
            "--user", "u",
            "--password", "p",
            "--dry-run", "--json",
        ],
    )
    assert result.exit_code == 0, result.output
    payload = json.loads(result.output)
    req = payload["request"]
    assert req["method"] == "GET"
    assert req["url"].endswith("/services/server/info")
