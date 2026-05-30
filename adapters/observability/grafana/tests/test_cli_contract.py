"""Contract — CLI loads, subcommand tree is reachable."""

from __future__ import annotations

import re

from typer.testing import CliRunner

from lets_grafana.cli import app


runner = CliRunner()


def _has_json_and_dry_run(args: list[str]) -> tuple[bool, bool, str]:
    result = runner.invoke(app, [*args, "--help"])
    plain = re.sub(r"\x1b\[[0-9;]*[A-Za-z]", "", result.output)
    return ("--json" in plain, "--dry-run" in plain, plain)


def test_top_level_loads() -> None:
    result = runner.invoke(app, ["--help"])
    assert result.exit_code == 0, result.output
    assert "Grafana" in result.output


def test_dashboard_subtree() -> None:
    for cmd in ["dashboard list", "dashboard get", "dashboard create", "dashboard delete"]:
        json_ok, dry_ok, plain = _has_json_and_dry_run(cmd.split())
        assert json_ok, f"`{cmd}` missing --json\n{plain}"
        assert dry_ok, f"`{cmd}` missing --dry-run\n{plain}"


def test_datasource_and_folder_subtrees() -> None:
    for cmd in ["datasource list", "folder list", "health"]:
        json_ok, dry_ok, plain = _has_json_and_dry_run(cmd.split())
        assert json_ok, f"`{cmd}` missing --json\n{plain}"
        assert dry_ok, f"`{cmd}` missing --dry-run\n{plain}"
