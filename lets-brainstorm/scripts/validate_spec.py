#!/usr/bin/env python3
"""Validate a lets-brainstorm spec document before routing to a downstream skill.

Usage:
    python3 scripts/validate_spec.py <spec-file>            # Full mode
    python3 scripts/validate_spec.py --light <spec-file>    # Light mode (express brainstorm)

Exits 0 on pass, 1 on failure. Errors are printed to stderr.
"""
from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

PLACEHOLDER_PATTERNS = [
    re.compile(r"\bTBD\b"),
    re.compile(r"\bTODO\b"),
    re.compile(r"<!--.*?(fill|replace|add here).*?-->", re.IGNORECASE),
    re.compile(r"<[A-Z ]+>"),           # e.g. <Feature Name>
    re.compile(r"\[.*?(TBD|TODO).*?\]", re.IGNORECASE),
]

FULL_REQUIRED_SECTIONS = [
    "## Problem",
    "## Goals",
    "## Success Criteria",
    "## Architecture",
    "## Error Handling",
    "## Testing Approach",
]

LIGHT_REQUIRED_SECTIONS = [
    "## Problem",
    "## Approach",
    "## Success Criteria",
    "## Testing Approach",
]

OPEN_QUESTIONS_HEADER = "## Open Questions"
OPEN_QUESTION_ITEM = re.compile(r"^- \[ \]", re.MULTILINE)


def check(spec_path: Path, *, light: bool = False) -> list[str]:
    errors: list[str] = []

    if not spec_path.exists():
        return [f"File not found: {spec_path}"]

    text = spec_path.read_text()
    lines = text.splitlines()

    required_sections = LIGHT_REQUIRED_SECTIONS if light else FULL_REQUIRED_SECTIONS

    # Required sections present and non-empty.
    for section in required_sections:
        idx = next((i for i, l in enumerate(lines) if l.strip() == section), None)
        if idx is None:
            errors.append(f"Missing section: {section!r}")
            continue
        # Check there is at least one non-blank, non-header line after the section heading
        # before the next heading or end of file.
        content_found = False
        for line in lines[idx + 1:]:
            if line.startswith("## "):
                break
            if line.strip() and not line.startswith("#"):
                content_found = True
                break
        if not content_found:
            errors.append(f"Section is empty: {section!r}")

    # Placeholder scan.
    for i, line in enumerate(lines, start=1):
        for pattern in PLACEHOLDER_PATTERNS:
            if pattern.search(line):
                errors.append(f"Line {i}: placeholder text detected — {line.strip()!r}")
                break

    # Open questions must all be resolved (no unchecked items).
    oq_idx = next((i for i, l in enumerate(lines) if l.strip() == OPEN_QUESTIONS_HEADER), None)
    if oq_idx is not None:
        oq_block = "\n".join(lines[oq_idx:])
        unresolved = OPEN_QUESTION_ITEM.findall(oq_block)
        if unresolved:
            errors.append(
                f"{len(unresolved)} unresolved open question(s) in {OPEN_QUESTIONS_HEADER!r} — "
                "resolve or remove before routing"
            )

    return errors


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Validate a lets-brainstorm spec before routing."
    )
    parser.add_argument(
        "--light",
        action="store_true",
        help="Validate a Light Mode (express brainstorm) spec with the minimal required section set.",
    )
    parser.add_argument("spec", type=Path, help="Path to the spec file")
    args = parser.parse_args()

    errors = check(args.spec, light=args.light)

    mode_label = "LIGHT" if args.light else "FULL"

    if errors:
        print(f"FAIL ({mode_label}): {args.spec}", file=sys.stderr)
        for error in errors:
            print(f"  ERROR: {error}", file=sys.stderr)
        return 1

    print(f"PASS ({mode_label}): {args.spec}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
