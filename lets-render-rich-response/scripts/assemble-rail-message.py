#!/usr/bin/env python3
"""Assemble a RailMessageV2 JSON artifact from classification + payload input.

Reads assets/component-catalog.yml and merges envelope fields with caller payload.
For generated tiles, can load jsx from a file or assets/templates/*.jsx.txt.

Usage:
  python3 scripts/assemble-rail-message.py \\
    --catalog-id diff-view \\
    --envelope envelope.json \\
    --payload payload.json \\
    --out message.json
"""
from __future__ import annotations

import argparse
import json
import sys
from datetime import datetime, timezone
from pathlib import Path

try:
    import yaml
except ImportError:
    yaml = None  # type: ignore


SKILL_ROOT = Path(__file__).resolve().parent.parent


def _load_yaml(path: Path) -> dict:
    if yaml is None:
        print("PyYAML required: pip install pyyaml", file=sys.stderr)
        sys.exit(2)
    return yaml.safe_load(path.read_text(encoding="utf-8")) or {}


def _catalog_row(catalog: dict, catalog_id: str) -> dict:
    for row in catalog.get("render_paths") or []:
        if row.get("id") == catalog_id:
            return row
    print(f"Unknown catalog_id: {catalog_id}", file=sys.stderr)
    sys.exit(1)


def assemble(
    catalog_id: str,
    envelope: dict,
    payload: dict,
    jsx: str | None = None,
) -> dict:
    catalog = _load_yaml(SKILL_ROOT / "assets" / "component-catalog.yml")
    row = _catalog_row(catalog, catalog_id)
    kind = row.get("kind")
    now = datetime.now(timezone.utc).isoformat().replace("+00:00", "Z")

    base = {
        "messageId": envelope.get("messageId", f"msg-{catalog_id}-001"),
        "runId": envelope["runId"],
        "episodeId": envelope.get("episodeId", "ep-001"),
        "emittedAt": envelope.get("emittedAt", now),
        "summary": envelope.get("summary", envelope.get("label", catalog_id)),
    }

    if kind == "structured":
        return {
            "kind": "structured",
            **base,
            "schemaId": row["schema_id"],
            "schemaVersion": row["schema_version"],
            "label": envelope.get("label", base["summary"]),
            "payload": payload,
        }

    if kind == "generated":
        if not jsx:
            print("generated-tile requires --jsx or --jsx-file", file=sys.stderr)
            sys.exit(1)
        tile = {
            "tileId": envelope.get("tileId", f"tile-{base['messageId']}"),
            "label": envelope.get("label", "Generated tile"),
            "jsx": jsx.strip(),
            "declaredActions": payload.get("declaredActions", []),
            "allowlist": payload.get(
                "allowlist",
                {"fetchUrls": [], "navigateRoutes": []},
            ),
        }
        for opt in ("subjectRef", "qualityGates", "scope", "recipeTrace"):
            if opt in payload:
                tile[opt] = payload[opt]
        return {"kind": "generated", **base, "tile": tile}

    if kind == "text":
        return {"kind": "text", **base, "body": payload.get("body", base["summary"])}

    print(f"Unsupported kind: {kind}", file=sys.stderr)
    sys.exit(1)


def main() -> int:
    parser = argparse.ArgumentParser(description="Assemble RailMessageV2 from catalog row")
    parser.add_argument("--catalog-id", required=True, help="diff-view | simple-form | generated-tile | text-fallback")
    parser.add_argument("--envelope", required=True, help="JSON with runId, messageId, label, summary, ...")
    parser.add_argument("--payload", default="{}", help="JSON payload or tile extras")
    parser.add_argument("--jsx", help="JSX string for generated-tile")
    parser.add_argument("--jsx-file", type=Path, help="Path to jsx file")
    parser.add_argument("--out", type=Path, help="Write assembled message JSON")
    args = parser.parse_args()

    envelope = json.loads(args.envelope)
    payload = json.loads(args.payload)
    jsx = args.jsx
    if args.jsx_file:
        jsx = args.jsx_file.read_text(encoding="utf-8")

    message = assemble(args.catalog_id, envelope, payload, jsx=jsx)
    out = json.dumps(message, indent=2)
    if args.out:
        args.out.write_text(out + "\n", encoding="utf-8")
    else:
        print(out)
    return 0


if __name__ == "__main__":
    sys.exit(main())
