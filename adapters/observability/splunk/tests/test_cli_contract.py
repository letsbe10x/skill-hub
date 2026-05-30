"""Contract — CLI loads, every command exposes --json and --dry-run."""

from __future__ import annotations

import re

from typer.testing import CliRunner

from lets_splunk.cli import app


runner = CliRunner()


def _has_flags(args: list[str]) -> tuple[bool, bool, str]:
    result = runner.invoke(app, [*args, "--help"])
    plain = re.sub(r"\x1b\[[0-9;]*[A-Za-z]", "", result.output)
    return ("--json" in plain, "--dry-run" in plain, plain)


def test_top_level_loads() -> None:
    result = runner.invoke(app, ["--help"])
    assert result.exit_code == 0, result.output
    assert "Splunk" in result.output


def test_every_command_has_flags() -> None:
    for cmd in ["search", "ingest", "server-info"]:
        json_ok, dry_ok, plain = _has_flags([cmd])
        assert json_ok, f"`{cmd}` missing --json\n{plain}"
        assert dry_ok, f"`{cmd}` missing --dry-run\n{plain}"
