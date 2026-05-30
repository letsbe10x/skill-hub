"""Typer app for `lets-splunk`."""

from __future__ import annotations

import json
from typing import Any

import typer

from lets_splunk.client import (
    HecClient,
    MgmtClient,
    build_hec_request_plan,
    build_mgmt_request_plan,
)

app = typer.Typer(
    help=(
        "Agent-native CLI for Splunk Enterprise. "
        "Defaults: SPLUNK_MGMT_URL=https://localhost:8089, "
        "SPLUNK_HEC_URL=https://localhost:8088, SPLUNK_USER=admin."
    ),
    no_args_is_help=True,
)


def _emit(payload: Any, *, json_output: bool) -> None:
    if json_output:
        typer.echo(json.dumps(payload, indent=2, sort_keys=True, default=str))
    else:
        typer.echo(str(payload))


# ------------------------- search (mgmt API) ---------------------------- #


@app.command("search")
def search(
    query: str = typer.Option(
        ...,
        "--query",
        "-q",
        help='SPL search, e.g. "search index=main sourcetype=access_combined" (must start with the search command).',
    ),
    earliest: str = typer.Option("-24h", "--earliest", help="Earliest time modifier (e.g. -24h, -7d, 0)."),
    latest: str = typer.Option("now", "--latest", help="Latest time modifier."),
    max_count: int = typer.Option(100, "--max-count", help="Max events to return."),
    mgmt_url: str = typer.Option("", "--mgmt-url"),
    user: str = typer.Option("", "--user"),
    password: str = typer.Option("", "--password"),
    insecure: bool = typer.Option(True, "--insecure/--secure", help="Skip TLS verify (sandbox default)."),
    dry_run: bool = typer.Option(False, "--dry-run"),
    json_output: bool = typer.Option(False, "--json"),
) -> None:
    """Run a blocking SPL search via mgmt REST and return parsed results."""
    body = {
        "search": query,
        "exec_mode": "blocking",
        "earliest_time": earliest,
        "latest_time": latest,
        "output_mode": "json",
    }
    if dry_run:
        plan = build_mgmt_request_plan(
            method="POST",
            path="/services/search/jobs",
            mgmt_url=mgmt_url or None,
            user=user or None,
            password=password or None,
            insecure=insecure,
            body=body,
        )
        _emit({"status": "request_planned", "request": plan}, json_output=json_output)
        return

    client = MgmtClient(
        mgmt_url=mgmt_url or None,
        user=user or None,
        password=password or None,
        insecure=insecure,
    )
    create_resp = client.request("POST", "/services/search/jobs", data=body)
    sid = create_resp.get("sid") if isinstance(create_resp, dict) else None
    if not sid:
        # Splunk older flow may return XML with the SID even when output_mode=json is requested
        # for the POST itself. Fall back to scraping if needed.
        text = create_resp.get("text", "") if isinstance(create_resp, dict) else ""
        import re as _re
        m = _re.search(r"<sid>([^<]+)</sid>", text)
        if not m:
            raise typer.Exit(code=1)
        sid = m.group(1)

    results = client.request(
        "GET",
        f"/services/search/jobs/{sid}/results",
        params={"count": max_count},
    )
    payload = {
        "status": "ok",
        "sid": sid,
        "results": results.get("results", []) if isinstance(results, dict) else [],
        "result_count": len(results.get("results", [])) if isinstance(results, dict) else 0,
    }
    _emit(payload, json_output=json_output)


# ------------------------- ingest (HEC) --------------------------------- #


@app.command("ingest")
def ingest(
    event: str = typer.Option(..., "--event", "-e", help="Event payload (string OR JSON object)."),
    sourcetype: str = typer.Option("agent:json", "--sourcetype"),
    index: str = typer.Option("main", "--index"),
    host: str = typer.Option("", "--host"),
    hec_url: str = typer.Option("", "--hec-url"),
    hec_token: str = typer.Option("", "--hec-token"),
    insecure: bool = typer.Option(True, "--insecure/--secure"),
    dry_run: bool = typer.Option(False, "--dry-run"),
    json_output: bool = typer.Option(False, "--json"),
) -> None:
    """Send one event to Splunk via HEC."""
    # Accept either a JSON object string or a raw string.
    try:
        parsed_event: Any = json.loads(event)
    except json.JSONDecodeError:
        parsed_event = event

    body: dict[str, Any] = {"event": parsed_event, "sourcetype": sourcetype, "index": index}
    if host:
        body["host"] = host

    if dry_run:
        plan = build_hec_request_plan(
            hec_url=hec_url or None, token=hec_token or None, insecure=insecure, event=body
        )
        _emit({"status": "request_planned", "request": plan}, json_output=json_output)
        return

    client = HecClient(hec_url=hec_url or None, token=hec_token or None, insecure=insecure)
    response = client.send(body)
    _emit({"status": "ok", "response": response}, json_output=json_output)


# ------------------------- server-info ---------------------------------- #


@app.command("server-info")
def server_info(
    mgmt_url: str = typer.Option("", "--mgmt-url"),
    user: str = typer.Option("", "--user"),
    password: str = typer.Option("", "--password"),
    insecure: bool = typer.Option(True, "--insecure/--secure"),
    dry_run: bool = typer.Option(False, "--dry-run"),
    json_output: bool = typer.Option(False, "--json"),
) -> None:
    """Fetch Splunk server info (version, license, build)."""
    if dry_run:
        plan = build_mgmt_request_plan(
            method="GET",
            path="/services/server/info",
            mgmt_url=mgmt_url or None,
            user=user or None,
            password=password or None,
            insecure=insecure,
        )
        _emit({"status": "request_planned", "request": plan}, json_output=json_output)
        return
    client = MgmtClient(
        mgmt_url=mgmt_url or None,
        user=user or None,
        password=password or None,
        insecure=insecure,
    )
    data = client.request("GET", "/services/server/info")
    _emit({"status": "ok", "data": data}, json_output=json_output)


if __name__ == "__main__":
    app()
