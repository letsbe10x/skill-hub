"""Typer app for `lets-prometheus`."""

from __future__ import annotations

import json
from typing import Any

import typer

from lets_prometheus.client import ApiClient, build_request_plan

app = typer.Typer(
    help="Agent-native CLI for Prometheus. Reads PROMETHEUS_URL from env (default http://localhost:9090).",
    no_args_is_help=True,
)


def _emit(payload: dict[str, Any] | list[Any], *, json_output: bool) -> None:
    if json_output:
        typer.echo(json.dumps(payload, indent=2, sort_keys=True, default=str))
    else:
        typer.echo(str(payload))


def _run(
    *,
    method: str,
    path: str,
    base_url: str,
    token: str,
    params: dict[str, Any],
    dry_run: bool,
    json_output: bool,
) -> None:
    if dry_run:
        plan = build_request_plan(
            method=method, path=path, base_url=base_url or None, token=token or None, params=params
        )
        _emit({"status": "request_planned", "request": plan}, json_output=json_output)
        return
    client = ApiClient(base_url=base_url or None, token=token or None)
    data = client.request(method, path, params=params)
    _emit({"status": "ok", "data": data}, json_output=json_output)


@app.command("query")
def query(
    promql: str = typer.Option(..., "--query", "-q", help="PromQL instant query."),
    time: str = typer.Option("", "--time", help="Evaluation timestamp (RFC3339 or unix seconds)."),
    base_url: str = typer.Option("", "--base-url", help="Prometheus base URL."),
    token: str = typer.Option("", "--token", help="Bearer token."),
    dry_run: bool = typer.Option(False, "--dry-run", help="Print request plan, do not execute."),
    json_output: bool = typer.Option(False, "--json", help="Emit JSON."),
) -> None:
    """Run an instant PromQL query."""
    params: dict[str, Any] = {"query": promql}
    if time:
        params["time"] = time
    _run(
        method="GET",
        path="/api/v1/query",
        base_url=base_url,
        token=token,
        params=params,
        dry_run=dry_run,
        json_output=json_output,
    )


@app.command("query-range")
def query_range(
    promql: str = typer.Option(..., "--query", "-q", help="PromQL range query."),
    start: str = typer.Option(..., "--start", help="Start timestamp (RFC3339 or unix seconds)."),
    end: str = typer.Option(..., "--end", help="End timestamp."),
    step: str = typer.Option("15s", "--step", help="Step duration (e.g. 15s, 1m)."),
    base_url: str = typer.Option("", "--base-url"),
    token: str = typer.Option("", "--token"),
    dry_run: bool = typer.Option(False, "--dry-run"),
    json_output: bool = typer.Option(False, "--json"),
) -> None:
    """Run a range PromQL query."""
    params = {"query": promql, "start": start, "end": end, "step": step}
    _run(
        method="GET",
        path="/api/v1/query_range",
        base_url=base_url,
        token=token,
        params=params,
        dry_run=dry_run,
        json_output=json_output,
    )


@app.command("labels")
def labels(
    base_url: str = typer.Option("", "--base-url"),
    token: str = typer.Option("", "--token"),
    dry_run: bool = typer.Option(False, "--dry-run"),
    json_output: bool = typer.Option(False, "--json"),
) -> None:
    """List all label names."""
    _run(
        method="GET",
        path="/api/v1/labels",
        base_url=base_url,
        token=token,
        params={},
        dry_run=dry_run,
        json_output=json_output,
    )


@app.command("series")
def series(
    match: list[str] = typer.Option(..., "--match", help="Series selector (repeatable)."),
    base_url: str = typer.Option("", "--base-url"),
    token: str = typer.Option("", "--token"),
    dry_run: bool = typer.Option(False, "--dry-run"),
    json_output: bool = typer.Option(False, "--json"),
) -> None:
    """Find time series matching selectors."""
    params: dict[str, Any] = {"match[]": match}
    _run(
        method="GET",
        path="/api/v1/series",
        base_url=base_url,
        token=token,
        params=params,
        dry_run=dry_run,
        json_output=json_output,
    )


@app.command("targets")
def targets(
    state: str = typer.Option("any", "--state", help="any, active, dropped."),
    base_url: str = typer.Option("", "--base-url"),
    token: str = typer.Option("", "--token"),
    dry_run: bool = typer.Option(False, "--dry-run"),
    json_output: bool = typer.Option(False, "--json"),
) -> None:
    """List scrape targets and their health."""
    _run(
        method="GET",
        path="/api/v1/targets",
        base_url=base_url,
        token=token,
        params={"state": state},
        dry_run=dry_run,
        json_output=json_output,
    )


@app.command("status")
def status(
    base_url: str = typer.Option("", "--base-url"),
    token: str = typer.Option("", "--token"),
    dry_run: bool = typer.Option(False, "--dry-run"),
    json_output: bool = typer.Option(False, "--json"),
) -> None:
    """Report Prometheus runtime info."""
    _run(
        method="GET",
        path="/api/v1/status/runtimeinfo",
        base_url=base_url,
        token=token,
        params={},
        dry_run=dry_run,
        json_output=json_output,
    )


if __name__ == "__main__":
    app()
