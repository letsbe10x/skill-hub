#!/usr/bin/env python3
"""Validate structured tile payloads against skill JSON schemas.

Usage:
  python3 scripts/validate-structured-payload.py --schema diff-view --payload payload.json
  python3 scripts/validate-structured-payload.py --schema simple-form --payload payload.json
"""
from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

SKILL_ROOT = Path(__file__).resolve().parent.parent

SCHEMA_MAP = {
    "diff-view": SKILL_ROOT / "assets/schemas/diff-view-payload.schema.json",
    "simple-form": SKILL_ROOT / "assets/schemas/simple-form-payload.schema.json",
}


def _validate_basic(schema_id: str, payload: dict) -> list[str]:
    """Lightweight validation without jsonschema dependency."""
    errors: list[str] = []
    if schema_id == "diff-view":
        if not isinstance(payload.get("left"), str) or not isinstance(payload.get("right"), str):
            errors.append("diff-view requires string left and right")
        mode = payload.get("mode")
        if mode is not None and mode not in ("line", "char"):
            errors.append("mode must be line or char")
    elif schema_id == "simple-form":
        fields = payload.get("fields")
        if not isinstance(fields, list) or len(fields) == 0:
            errors.append("simple-form requires non-empty fields array")
        elif len(fields) > 8:
            errors.append("simple-form allows at most 8 fields")
        else:
            allowed = {"text", "select", "date", "multiselect"}
            for i, f in enumerate(fields):
                if not isinstance(f, dict):
                    errors.append(f"fields[{i}] must be object")
                    continue
                for req in ("id", "label", "type"):
                    if req not in f:
                        errors.append(f"fields[{i}] missing {req}")
                if f.get("type") not in allowed:
                    errors.append(f"fields[{i}] type must be one of {sorted(allowed)}")
                if f.get("type") in ("select", "multiselect") and not f.get("options"):
                    errors.append(f"fields[{i}] select/multiselect needs options")
    return errors


def main() -> int:
    parser = argparse.ArgumentParser(description="Validate structured tile payload")
    parser.add_argument("--schema", required=True, choices=sorted(SCHEMA_MAP))
    parser.add_argument("--payload", help="JSON payload string")
    parser.add_argument("--payload-file", type=Path)
    args = parser.parse_args()

    if args.payload_file:
        payload = json.loads(args.payload_file.read_text(encoding="utf-8"))
    elif args.payload:
        payload = json.loads(args.payload)
    else:
        print("Provide --payload or --payload-file", file=sys.stderr)
        return 1

    errors = _validate_basic(args.schema, payload)
    result = {"valid": len(errors) == 0, "schema": args.schema, "errors": errors}
    print(json.dumps(result, indent=2))
    if errors:
        for e in errors:
            print(e, file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
