"""Contract tests — CLI loads, every command supports --json and --dry-run."""

from __future__ import annotations

import re

from typer.testing import CliRunner

from lets_prometheus.cli import app


runner = CliRunner()


def _commands() -> list[str]:
    """Parse the Commands box from `--help` output.

    Rich draws each panel as a box bounded by ╭─╮ … ╰─╯. We open scanning
    when we hit a line containing "Commands" and stop the moment we hit the
    bottom corner ╰ — otherwise epilog text after the box gets parsed as
    fake commands.
    """
    result = runner.invoke(app, ["--help"])
    assert result.exit_code == 0, result.output
    plain = re.sub(r"\x1b\[[0-9;]*[A-Za-z]", "", result.output)
    in_commands = False
    cmds: list[str] = []
    for raw in plain.splitlines():
        line = raw.rstrip()
        if "Commands" in line and not in_commands:
            in_commands = True
            continue
        if in_commands:
            stripped = line.lstrip(" │")
            if stripped.startswith("╰"):
                # End of Commands box — stop so epilog/examples text isn't parsed
                break
            if not stripped or stripped.startswith("─"):
                continue
            token = stripped.split()[0] if stripped.split() else ""
            if token and re.match(r"^[a-z][a-z0-9-]*$", token):
                cmds.append(token)
    return cmds


def test_cli_registers() -> None:
    result = runner.invoke(app, ["--help"])
    assert result.exit_code == 0
    assert "Prometheus" in result.output


def test_every_command_has_json_and_dry_run() -> None:
    cmds = _commands()
    assert "query" in cmds, f"expected core commands; got {cmds}"
    assert len(cmds) >= 5, f"expected at least 5 commands; got {cmds}"
    for cmd in cmds:
        result = runner.invoke(app, [cmd, "--help"])
        assert result.exit_code == 0, f"{cmd} --help failed: {result.output}"
        plain = re.sub(r"\x1b\[[0-9;]*[A-Za-z]", "", result.output)
        assert "--json" in plain, f"command `{cmd}` is missing --json"
        assert "--dry-run" in plain, f"command `{cmd}` is missing --dry-run"
