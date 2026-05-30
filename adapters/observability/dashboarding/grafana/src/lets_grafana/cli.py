"""Typer app for `lets-grafana`."""

from __future__ import annotations

import json
from typing import Any

import typer

from lets_grafana.client import ApiClient, build_request_plan

app = typer.Typer(
    help="Agent-native CLI for Grafana. Defaults: GRAFANA_URL=http://localhost:3000, GRAFANA_USER=admin, GRAFANA_PASSWORD=admin.",
    no_args_is_help=True,
)
dashboard_app = typer.Typer(help="Dashboard operations.", no_args_is_help=True)
datasource_app = typer.Typer(help="Datasource operations.", no_args_is_help=True)
folder_app = typer.Typer(help="Folder operations.", no_args_is_help=True)
app.add_typer(dashboard_app, name="dashboard")
app.add_typer(datasource_app, name="datasource")
app.add_typer(folder_app, name="folder")


def _emit(payload: Any, *, json_output: bool) -> None:
    if json_output:
        typer.echo(json.dumps(payload, indent=2, sort_keys=True, default=str))
    else:
        typer.echo(str(payload))


def _common_auth_kwargs(base_url: str, user: str, password: str, token: str) -> dict[str, Any]:
    return {
        "base_url": base_url or None,
        "user": user or None,
        "password": password or None,
        "token": token or None,
    }


def _run(
    *,
    method: str,
    path: str,
    base_url: str,
    user: str,
    password: str,
    token: str,
    params: dict[str, Any] | None,
    body: dict[str, Any] | None,
    dry_run: bool,
    json_output: bool,
) -> None:
    if dry_run:
        plan = build_request_plan(
            method=method, path=path, **_common_auth_kwargs(base_url, user, password, token),
            params=params, body=body,
        )
        _emit({"status": "request_planned", "request": plan}, json_output=json_output)
        return
    client = ApiClient(**_common_auth_kwargs(base_url, user, password, token))
    data = client.request(method, path, params=params, json_body=body)
    _emit({"status": "ok", "data": data}, json_output=json_output)


@dashboard_app.command("list")
def dashboard_list(
    query: str = typer.Option("", "--query", help="Substring filter on title."),
    type: str = typer.Option("dash-db", "--type", help="dash-db, dash-folder."),
    base_url: str = typer.Option("", "--base-url"),
    user: str = typer.Option("", "--user"),
    password: str = typer.Option("", "--password"),
    token: str = typer.Option("", "--token"),
    dry_run: bool = typer.Option(False, "--dry-run"),
    json_output: bool = typer.Option(False, "--json"),
) -> None:
    """List dashboards via /api/search."""
    params: dict[str, Any] = {"type": type}
    if query:
        params["query"] = query
    _run(method="GET", path="/api/search", base_url=base_url, user=user, password=password, token=token,
         params=params, body=None, dry_run=dry_run, json_output=json_output)


@dashboard_app.command("get")
def dashboard_get(
    uid: str = typer.Argument(..., help="Dashboard UID."),
    base_url: str = typer.Option("", "--base-url"),
    user: str = typer.Option("", "--user"),
    password: str = typer.Option("", "--password"),
    token: str = typer.Option("", "--token"),
    dry_run: bool = typer.Option(False, "--dry-run"),
    json_output: bool = typer.Option(False, "--json"),
) -> None:
    """Fetch a dashboard by UID."""
    _run(method="GET", path=f"/api/dashboards/uid/{uid}", base_url=base_url, user=user,
         password=password, token=token, params=None, body=None,
         dry_run=dry_run, json_output=json_output)


@dashboard_app.command("create")
def dashboard_create(
    file: typer.FileText = typer.Option(..., "--file", "-f", help="Path to dashboard JSON to POST."),
    overwrite: bool = typer.Option(False, "--overwrite", help="Overwrite existing dashboard with same uid."),
    base_url: str = typer.Option("", "--base-url"),
    user: str = typer.Option("", "--user"),
    password: str = typer.Option("", "--password"),
    token: str = typer.Option("", "--token"),
    dry_run: bool = typer.Option(False, "--dry-run"),
    json_output: bool = typer.Option(False, "--json"),
) -> None:
    """Create or update a dashboard from a JSON file."""
    raw = file.read()
    try:
        parsed = json.loads(raw)
    except json.JSONDecodeError as exc:
        typer.echo(f"Error: invalid JSON in --file: {exc}", err=True)
        raise typer.Exit(code=2)
    # If the file contains a bare dashboard object, wrap it.
    if "dashboard" not in parsed:
        parsed = {"dashboard": parsed, "overwrite": overwrite}
    else:
        parsed.setdefault("overwrite", overwrite)
    _run(method="POST", path="/api/dashboards/db", base_url=base_url, user=user,
         password=password, token=token, params=None, body=parsed,
         dry_run=dry_run, json_output=json_output)


@dashboard_app.command("delete")
def dashboard_delete(
    uid: str = typer.Argument(..., help="Dashboard UID."),
    base_url: str = typer.Option("", "--base-url"),
    user: str = typer.Option("", "--user"),
    password: str = typer.Option("", "--password"),
    token: str = typer.Option("", "--token"),
    dry_run: bool = typer.Option(False, "--dry-run"),
    json_output: bool = typer.Option(False, "--json"),
) -> None:
    """Delete a dashboard by UID."""
    _run(method="DELETE", path=f"/api/dashboards/uid/{uid}", base_url=base_url, user=user,
         password=password, token=token, params=None, body=None,
         dry_run=dry_run, json_output=json_output)


@datasource_app.command("list")
def datasource_list(
    base_url: str = typer.Option("", "--base-url"),
    user: str = typer.Option("", "--user"),
    password: str = typer.Option("", "--password"),
    token: str = typer.Option("", "--token"),
    dry_run: bool = typer.Option(False, "--dry-run"),
    json_output: bool = typer.Option(False, "--json"),
) -> None:
    """List configured datasources."""
    _run(method="GET", path="/api/datasources", base_url=base_url, user=user,
         password=password, token=token, params=None, body=None,
         dry_run=dry_run, json_output=json_output)


@folder_app.command("list")
def folder_list(
    base_url: str = typer.Option("", "--base-url"),
    user: str = typer.Option("", "--user"),
    password: str = typer.Option("", "--password"),
    token: str = typer.Option("", "--token"),
    dry_run: bool = typer.Option(False, "--dry-run"),
    json_output: bool = typer.Option(False, "--json"),
) -> None:
    """List dashboard folders."""
    _run(method="GET", path="/api/folders", base_url=base_url, user=user,
         password=password, token=token, params=None, body=None,
         dry_run=dry_run, json_output=json_output)


@app.command("health")
def health(
    base_url: str = typer.Option("", "--base-url"),
    dry_run: bool = typer.Option(False, "--dry-run"),
    json_output: bool = typer.Option(False, "--json"),
) -> None:
    """Check Grafana health (no auth required)."""
    _run(method="GET", path="/api/health", base_url=base_url, user="", password="", token="",
         params=None, body=None, dry_run=dry_run, json_output=json_output)


if __name__ == "__main__":
    app()
