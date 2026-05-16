"""Verify scenario coverage by checking that each scenario in the matrix has a
corresponding test in the repository.

Usage:
    python verify_scenarios.py <scenario-matrix.json> <repo_root>

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


def find_test_files(repo_root: str) -> list[str]:
    """Recursively find all test files in repo_root, skipping hidden/vendor dirs."""
    test_files = []
    for dirpath, dirnames, filenames in os.walk(repo_root):
        # Prune skipped directories in-place
        dirnames[:] = [d for d in dirnames if d not in SKIP_DIRS and not d.startswith(".")]
        for fname in filenames:
            if TEST_FILE_PATTERNS.match(fname):
                test_files.append(os.path.join(dirpath, fname))
    return test_files


def file_contains_pattern(filepath: str, pattern: str) -> bool:
    """Check if a file contains the given substring pattern."""
    try:
        size = os.path.getsize(filepath)
        if size > MAX_FILE_SIZE:
            return False
        with open(filepath, "r", encoding="utf-8", errors="ignore") as f:
            content = f.read()
        return pattern in content
    except (OSError, IOError):
        return False


def verify_scenarios(matrix_path: str, repo_root: str) -> dict:
    """Run scenario verification and return ScriptResult dict."""
    start_ms = time.monotonic_ns() // 1_000_000

    # Parse input
    try:
        with open(matrix_path, "r", encoding="utf-8") as f:
            matrix = json.load(f)
    except (OSError, json.JSONDecodeError) as e:
        return {
            "status": "error",
            "checks_total": 0,
            "checks_passed": 0,
            "checks_failed": 0,
            "gaps": [],
            "passed_ids": [],
            "metadata": {
                "script": "verify_scenarios.py",
                "intensity": "STANDARD",
                "duration_ms": 0,
                "error": f"Failed to read scenario matrix: {e}",
            },
        }

    scenarios = matrix.get("scenarios", [])
    if not scenarios:
        duration = (time.monotonic_ns() // 1_000_000) - start_ms
        return {
            "status": "passed",
            "checks_total": 0,
            "checks_passed": 0,
            "checks_failed": 0,
            "gaps": [],
            "passed_ids": [],
            "metadata": {
                "script": "verify_scenarios.py",
                "intensity": "STANDARD",
                "duration_ms": duration,
            },
        }

    # Find all test files once
    test_files = find_test_files(repo_root)

    gaps = []
    passed_ids = []
    checks_total = len(scenarios)

    for scenario in scenarios:
        sid = scenario.get("id", "UNKNOWN")
        test_pattern = scenario.get("test_pattern")
        scenario_type = scenario.get("type", "edge")

        if not test_pattern:
            # No pattern to check — mark as passed with implicit pass
            passed_ids.append(sid)
            continue

        # Search for the pattern in test files
        found = False
        for tf in test_files:
            if file_contains_pattern(tf, test_pattern):
                found = True
                break

        if found:
            passed_ids.append(sid)
        else:
            severity = "structural" if scenario_type in ("happy", "failure") else "minor"
            gaps.append({
                "id": f"G{len(gaps) + 1:03d}",
                "type": "scenario_uncovered",
                "severity": severity,
                "reference": sid,
                "description": f"No test found containing pattern '{test_pattern}' for scenario: {scenario.get('description', sid)}",
                "context": {
                    "expected_at": f"test file matching '{test_pattern}'",
                    "related_code": ", ".join(scenario.get("task_ids", [])),
                    "spec_section": scenario.get("story", ""),
                },
            })

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
            "script": "verify_scenarios.py",
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
                    "script": "verify_scenarios.py",
                    "intensity": "STANDARD",
                    "duration_ms": 0,
                    "error": "Usage: verify_scenarios.py <scenario-matrix.json> <repo_root>",
                },
            })
        )
        sys.exit(1)

    matrix_path = sys.argv[1]
    repo_root = sys.argv[2]

    if not os.path.isfile(matrix_path):
        print(
            json.dumps({
                "status": "error",
                "checks_total": 0,
                "checks_passed": 0,
                "checks_failed": 0,
                "gaps": [],
                "passed_ids": [],
                "metadata": {
                    "script": "verify_scenarios.py",
                    "intensity": "STANDARD",
                    "duration_ms": 0,
                    "error": f"Scenario matrix file not found: {matrix_path}",
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
                    "script": "verify_scenarios.py",
                    "intensity": "STANDARD",
                    "duration_ms": 0,
                    "error": f"Repository root not found: {repo_root}",
                },
            })
        )
        sys.exit(1)

    result = verify_scenarios(matrix_path, repo_root)
    print(json.dumps(result, indent=2))
    sys.exit(0 if result["status"] in ("passed", "gap_found") else 1)
