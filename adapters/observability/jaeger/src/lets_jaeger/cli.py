"""Typer app for `lets-jaeger`."""

from __future__ import annotations

import json
from typing import Any

import typer

from lets_jaeger.client import ApiClient, build_request_plan, parse_lookback_to_micros

app = typer.Typer(
    help="Agent-native CLI for Jaeger. Defaults: JAEGER_URL=http://localhost:16686.",
    no_args_is_help=True,
)
trace_app = typer.Typer(help="Trace operations.", no_args_is_help=True)
app.add_typer(trace_app, name="trace")


def _emit(payload: Any, *, json_output: bool) -> None:
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
    params: dict[str, Any] | None,
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


@app.command("services")
def services(
    base_url: str = typer.Option("", "--base-url"),
    token: str = typer.Option("", "--token"),
    dry_run: bool = typer.Option(False, "--dry-run"),
    json_output: bool = typer.Option(False, "--json"),
) -> None:
    """List service names known to Jaeger."""
    _run(method="GET", path="/api/services", base_url=base_url, token=token, params=None,
         dry_run=dry_run, json_output=json_output)


@app.command("operations")
def operations(
    service: str = typer.Option(..., "--service", "-s", help="Service name."),
    base_url: str = typer.Option("", "--base-url"),
    token: str = typer.Option("", "--token"),
    dry_run: bool = typer.Option(False, "--dry-run"),
    json_output: bool = typer.Option(False, "--json"),
) -> None:
    """List operations recorded for a service."""
    _run(method="GET", path="/api/operations", base_url=base_url, token=token,
         params={"service": service}, dry_run=dry_run, json_output=json_output)


@trace_app.command("search")
def trace_search(
    service: str = typer.Option(..., "--service", "-s", help="Service name."),
    operation: str = typer.Option("", "--operation", help="Filter by operation name."),
    lookback: str = typer.Option("1h", "--lookback", help="Window to search (e.g. 15m, 1h, 24h, 7d)."),
    limit: int = typer.Option(20, "--limit", help="Max traces to return."),
    tags: str = typer.Option("", "--tags", help='JSON object of tag filters, e.g. {"http.status_code":"500"}'),
    base_url: str = typer.Option("", "--base-url"),
    token: str = typer.Option("", "--token"),
    dry_run: bool = typer.Option(False, "--dry-run"),
    json_output: bool = typer.Option(False, "--json"),
) -> None:
    """Search traces by service / operation / tags / lookback."""
    start_us, end_us = parse_lookback_to_micros(lookback)
    params: dict[str, Any] = {
        "service": service,
        "start": start_us,
        "end": end_us,
        "limit": limit,
    }
    if operation:
        params["operation"] = operation
    if tags:
        # Pass through as-is; Jaeger query API accepts JSON-encoded tag filters
        params["tags"] = tags
    _run(method="GET", path="/api/traces", base_url=base_url, token=token, params=params,
         dry_run=dry_run, json_output=json_output)


@trace_app.command("get")
def trace_get(
    trace_id: str = typer.Argument(..., help="Trace ID (hex)."),
    base_url: str = typer.Option("", "--base-url"),
    token: str = typer.Option("", "--token"),
    dry_run: bool = typer.Option(False, "--dry-run"),
    json_output: bool = typer.Option(False, "--json"),
) -> None:
    """Fetch a single trace by ID."""
    _run(method="GET", path=f"/api/traces/{trace_id}", base_url=base_url, token=token, params=None,
         dry_run=dry_run, json_output=json_output)


if __name__ == "__main__":
    app()
