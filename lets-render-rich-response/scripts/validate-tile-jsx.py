#!/usr/bin/env python3
"""Validate GeneratedTileSpec.jsx against ux-engine ban list (sandbox-escape.test.ts).

Exit 0 on pass, 1 on failure. Prints JSON result to stdout; errors to stderr.
"""
from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path
from typing import Any

# Keep in sync with ux-engine sandbox-escape.test.ts (see canonical-sources.md)
BAN_CHECKS: list[tuple[str, str, re.Pattern[str] | None]] = [
    ("B1", "dangerouslySetInnerHTML", None),
    ("B2", "eval()", re.compile(r"\beval\s*\(")),
    ("B3", "Function()", re.compile(r"\bFunction\s*\(")),
    ("B4", "dynamic import()", re.compile(r"\bimport\s*\(")),
    ("B5", "<script> element", re.compile(r"<script[\s>]", re.I)),
    ("B6", "<iframe> element", re.compile(r"<iframe[\s>]", re.I)),
    ("B7", "document.write()", re.compile(r"document\.write\s*\(")),
    ("B8", "window.location assignment", re.compile(r"window\.location\s*=")),
    ("B9", "__proto__ mutation", None),
    ("B10", "Object.defineProperty()", re.compile(r"Object\.defineProperty\s*\(")),
]


def _ban_violations(jsx: str) -> list[dict[str, str]]:
    violations: list[dict[str, str]] = []
    for check_id, message, pattern in BAN_CHECKS:
        if pattern is not None:
            if pattern.search(jsx):
                violations.append({"check": check_id, "message": message})
        elif check_id == "B1" and "dangerouslySetInnerHTML" in jsx:
            violations.append({"check": check_id, "message": message})
        elif check_id == "B9" and "__proto__" in jsx:
            violations.append({"check": check_id, "message": message})
    if re.search(r"React\.createElement\s*\(\s*['\"]script['\"]", jsx, re.I):
        violations.append({"check": "B5", "message": "script element via createElement"})
    if re.search(r"React\.createElement\s*\(\s*['\"]iframe['\"]", jsx, re.I):
        violations.append({"check": "B6", "message": "iframe element via createElement"})
    return violations


def _structural_violations(jsx: str, spec: dict[str, Any]) -> list[dict[str, str]]:
    violations: list[dict[str, str]] = []
    trimmed = jsx.strip()
    if not trimmed:
        violations.append({"check": "S1", "message": "jsx is empty"})
    elif not trimmed.startswith("React.createElement("):
        violations.append({"check": "S2", "message": "jsx must start with React.createElement("})
    if jsx.count("(") != jsx.count(")"):
        violations.append({"check": "S3", "message": "unbalanced parentheses"})
    if re.search(r"<[A-Z]", jsx) or "/>" in jsx:
        violations.append({"check": "S4", "message": "angle-bracket JSX not allowed"})
    if "bridge.dispatchAction" in jsx:
        actions = spec.get("declaredActions") or []
        if not actions:
            violations.append({"check": "S5", "message": "declaredActions required when using bridge.dispatchAction"})
    if "bridge.fetch" in jsx:
        allowlist = spec.get("allowlist") or {}
        urls = allowlist.get("fetchUrls") or []
        if not urls:
            violations.append({"check": "S6", "message": "allowlist.fetchUrls required when using bridge.fetch"})
    return violations


def validate(jsx: str, spec: dict[str, Any]) -> dict[str, Any]:
    violations = _ban_violations(jsx) + _structural_violations(jsx, spec)
    return {"valid": len(violations) == 0, "violations": violations}


def main() -> int:
    parser = argparse.ArgumentParser(description="Validate generated tile JSX")
    parser.add_argument("--jsx", help="JSX source string")
    parser.add_argument("--jsx-file", type=Path, help="Path to JSX file")
    parser.add_argument("--spec", default="{}", help="JSON GeneratedTileSpec (minus jsx or full)")
    parser.add_argument("--spec-file", type=Path, help="Path to JSON spec file")
    args = parser.parse_args()

    if args.jsx_file:
        jsx = args.jsx_file.read_text(encoding="utf-8")
    elif args.jsx:
        jsx = args.jsx
    else:
        print("Provide --jsx or --jsx-file", file=sys.stderr)
        return 1

    if args.spec_file:
        spec = json.loads(args.spec_file.read_text(encoding="utf-8"))
    else:
        spec = json.loads(args.spec)

    if "jsx" in spec and not args.jsx and not args.jsx_file:
        jsx = spec["jsx"]

    result = validate(jsx, spec)
    print(json.dumps(result, indent=2))
    if not result["valid"]:
        for v in result["violations"]:
            print(f"{v['check']}: {v['message']}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
