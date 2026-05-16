"""Verify spec coverage by checking that each requirement has corresponding
implementation code and tests in the repository.

Usage:
    python verify_spec_coverage.py <spec-requirements.json> <repo_root>

Outputs ScriptResult JSON to stdout. Exits 0 on passed/gap_found, 1 on error.
"""

import json
import os
import re
import sys
import time
from pathlib import Path

SKIP_DIRS = {".git", ".venv", "venv", "__pycache__", "node_modules", ".tox", ".mypy_cache", ".pytest_cache"}
TEST_FILE_PATTERNS = re.compile(r"(^test_.*\.py$|.*_test\.py$|.*\.test\.ts$|.*\.spec\.ts$|.*_test\.go$)")
MAX_FILE_SIZE = 1_048_576  # 1 MB


def walk_repo_files(repo_root: str) -> tuple[list[str], list[str]]:
    """Walk repo and return (all_files, test_files) lists of absolute paths."""
    all_files = []
    test_files = []
    for dirpath, dirnames, filenames in os.walk(repo_root):
        dirnames[:] = [d for d in dirnames if d not in SKIP_DIRS and not d.startswith(".")]
        for fname in filenames:
            filepath = os.path.join(dirpath, fname)
            all_files.append(filepath)
            if TEST_FILE_PATTERNS.match(fname):
                test_files.append(filepath)
    return all_files, test_files


def file_matches_regex(filepath: str, pattern: str) -> bool:
    """Check if a file's content matches the given regex pattern."""
    try:
        size = os.path.getsize(filepath)
        if size > MAX_FILE_SIZE:
            return False
        with open(filepath, "r", encoding="utf-8", errors="ignore") as f:
            content = f.read()
        return bool(re.search(pattern, content, re.MULTILINE))
    except (OSError, IOError, re.error):
        return False


def derive_test_patterns(code_patterns: list[str]) -> list[str]:
    """Derive test-oriented patterns from code patterns by prepending test_."""
    test_patterns = []
    for cp in code_patterns:
        # For function-like patterns (e.g., "def create_invoice"), derive test name
        match = re.match(r"^(?:def|func|function)\s+(\w+)", cp)
        if match:
            func_name = match.group(1)
            test_patterns.append(f"test_{func_name}")
        else:
            # Generic: prepend test_ to the pattern as a substring search
            # Strip regex anchors/metacharacters for substring matching
            clean = re.sub(r"[\^$.*+?{}()|\\[\]]", "", cp)
            if clean.strip():
                test_patterns.append(f"test_{clean.strip()}")
    return test_patterns


def search_files_for_patterns(files: list[str], patterns: list[str]) -> bool:
    """Check if any file in the list matches any of the given regex patterns."""
    for filepath in files:
        for pattern in patterns:
            if file_matches_regex(filepath, pattern):
                return True
    return False


def verify_spec_coverage(spec_path: str, repo_root: str) -> dict:
    """Run spec coverage verification and return ScriptResult dict."""
    start_ms = time.monotonic_ns() // 1_000_000

    # Parse input
    try:
        with open(spec_path, "r", encoding="utf-8") as f:
            spec = json.load(f)
    except (OSError, json.JSONDecodeError) as e:
        return {
            "status": "error",
            "checks_total": 0,
            "checks_passed": 0,
            "checks_failed": 0,
            "gaps": [],
            "passed_ids": [],
            "metadata": {
                "script": "verify_spec_coverage.py",
                "intensity": "STANDARD",
                "duration_ms": 0,
                "error": f"Failed to read spec requirements: {e}",
            },
        }

    requirements = spec.get("requirements", [])
    if not requirements:
        duration = (time.monotonic_ns() // 1_000_000) - start_ms
        return {
            "status": "passed",
            "checks_total": 0,
            "checks_passed": 0,
            "checks_failed": 0,
            "gaps": [],
            "passed_ids": [],
            "metadata": {
                "script": "verify_spec_coverage.py",
                "intensity": "STANDARD",
                "duration_ms": duration,
            },
        }

    # Walk repo once
    all_files, test_files = walk_repo_files(repo_root)

    gaps = []
    passed_ids = []
    checks_total = len(requirements)

    for req in requirements:
        req_id = req.get("id", "UNKNOWN")
        code_patterns = req.get("code_patterns", [])
        testable = req.get("testable", True)
        description = req.get("description", req_id)
        source = req.get("source", "")
        test_pattern = req.get("test_pattern")

        # Step 1: Check if requirement is implemented (code patterns found)
        implemented = False
        if code_patterns:
            implemented = search_files_for_patterns(all_files, code_patterns)
        else:
            # No code patterns — cannot verify implementation, pass by default
            passed_ids.append(req_id)
            continue

        if not implemented:
            # Not implemented at all
            gaps.append({
                "id": f"G{len(gaps) + 1:03d}",
                "type": "spec_unimplemented",
                "severity": "structural",
                "reference": req_id,
                "description": f"No implementation found for requirement: {description}",
                "context": {
                    "expected_at": f"code matching patterns: {code_patterns}",
                    "related_code": ", ".join(req.get("task_ids", [])),
                    "spec_section": source,
                },
            })
            continue

        # Step 2: If implemented and testable, check for tests
        if testable:
            has_test = False

            # Use explicit test_pattern if provided
            if test_pattern:
                for tf in test_files:
                    try:
                        size = os.path.getsize(tf)
                        if size > MAX_FILE_SIZE:
                            continue
                        with open(tf, "r", encoding="utf-8", errors="ignore") as f:
                            content = f.read()
                        if test_pattern in content:
                            has_test = True
                            break
                    except (OSError, IOError):
                        continue
            else:
                # Derive test patterns from code patterns
                derived = derive_test_patterns(code_patterns)
                if derived:
                    for tf in test_files:
                        try:
                            size = os.path.getsize(tf)
                            if size > MAX_FILE_SIZE:
                                continue
                            with open(tf, "r", encoding="utf-8", errors="ignore") as f:
                                content = f.read()
                            for dp in derived:
                                if dp in content:
                                    has_test = True
                                    break
                        except (OSError, IOError):
                            continue
                        if has_test:
                            break
                else:
                    # Cannot derive test patterns — pass without test check
                    has_test = True

            if has_test:
                passed_ids.append(req_id)
            else:
                gaps.append({
                    "id": f"G{len(gaps) + 1:03d}",
                    "type": "spec_unimplemented",
                    "severity": "minor",
                    "reference": req_id,
                    "description": f"Implementation found but no test covers requirement: {description}",
                    "context": {
                        "expected_at": "test file covering the implementation",
                        "related_code": ", ".join(req.get("task_ids", [])),
                        "spec_section": source,
                    },
                })
        else:
            # Not testable — code presence is sufficient
            passed_ids.append(req_id)

    checks_passed = len(passed_ids)
    checks_failed = len(gaps)
    status = "passed" if checks_failed == 0 else "gap_found"
    duration = (time.monotonic_ns() // 1_000_000) - start_ms

    return {
        "status": status,
        "checks_total": checks_total,
        "checks_passed": checks_passed,
        "checks_failed": checks_failed,
        "gaps": gaps,
        "passed_ids": passed_ids,
        "metadata": {
            "script": "verify_spec_coverage.py",
            "intensity": "STANDARD",
            "duration_ms": duration,
        },
    }


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print(
            json.dumps({
                "status": "error",
                "checks_total": 0,
                "checks_passed": 0,
                "checks_failed": 0,
                "gaps": [],
                "passed_ids": [],
                "metadata": {
                    "script": "verify_spec_coverage.py",
                    "intensity": "STANDARD",
                    "duration_ms": 0,
                    "error": "Usage: verify_spec_coverage.py <spec-requirements.json> <repo_root>",
                },
            })
        )
        sys.exit(1)

    spec_path = sys.argv[1]
    repo_root = sys.argv[2]

    if not os.path.isfile(spec_path):
        print(
            json.dumps({
                "status": "error",
                "checks_total": 0,
                "checks_passed": 0,
                "checks_failed": 0,
                "gaps": [],
                "passed_ids": [],
                "metadata": {
                    "script": "verify_spec_coverage.py",
                    "intensity": "STANDARD",
                    "duration_ms": 0,
                    "error": f"Spec requirements file not found: {spec_path}",
                },
            })
        )
        sys.exit(1)

    if not os.path.isdir(repo_root):
        print(
            json.dumps({
                "status": "error",
                "checks_total": 0,
                "checks_passed": 0,
                "checks_failed": 0,
                "gaps": [],
                "passed_ids": [],
                "metadata": {
                    "script": "verify_spec_coverage.py",
                    "intensity": "STANDARD",
                    "duration_ms": 0,
                    "error": f"Repository root not found: {repo_root}",
                },
            })
        )
        sys.exit(1)

    result = verify_spec_coverage(spec_path, repo_root)
    print(json.dumps(result, indent=2))
    sys.exit(0 if result["status"] in ("passed", "gap_found") else 1)
