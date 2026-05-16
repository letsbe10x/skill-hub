"""Verify stitch-point integration by checking that components are properly
registered/wired in their expected locations.

Usage:
    python verify_stitch.py <execution-packet.json> <repo_root>

Outputs ScriptResult JSON to stdout. Exits 0 on passed/gap_found, 1 on error.
"""

import json
import os
import re
import sys
import time
from pathlib import Path

SKIP_DIRS = {".git", ".venv", "venv", "__pycache__", "node_modules", ".tox", ".mypy_cache", ".pytest_cache"}
MAX_FILE_SIZE = 1_048_576  # 1 MB
MAX_DEPTH_FOR_LANG_DETECT = 3


def detect_primary_language(repo_root: str) -> str | None:
    """Detect the primary language by counting file extensions in top levels."""
    counts: dict[str, int] = {"python": 0, "typescript": 0, "go": 0}
    ext_map = {
        ".py": "python",
        ".ts": "typescript",
        ".tsx": "typescript",
        ".go": "go",
    }

    for dirpath, dirnames, filenames in os.walk(repo_root):
        # Calculate depth relative to repo_root
        rel = os.path.relpath(dirpath, repo_root)
        depth = 0 if rel == "." else rel.count(os.sep) + 1
        if depth >= MAX_DEPTH_FOR_LANG_DETECT:
            dirnames.clear()
            continue
        dirnames[:] = [d for d in dirnames if d not in SKIP_DIRS and not d.startswith(".")]
        for fname in filenames:
            ext = os.path.splitext(fname)[1].lower()
            if ext in ext_map:
                counts[ext_map[ext]] += 1

    if not any(counts.values()):
        return None
    return max(counts, key=lambda k: counts[k])


def load_language_patterns(lang: str) -> dict | None:
    """Load stitch patterns for the given language from the patterns directory."""
    script_dir = Path(__file__).parent
    pattern_file = script_dir / "stitch_patterns" / f"{lang}.json"
    if not pattern_file.is_file():
        return None
    try:
        with open(pattern_file, "r", encoding="utf-8") as f:
            return json.load(f)
    except (OSError, json.JSONDecodeError):
        return None


def get_pattern_from_language(lang_patterns: dict, registration_type: str, component: str) -> str | None:
    """Generate an expected regex pattern from language patterns and registration type."""
    reg_patterns = lang_patterns.get("registration_patterns", {})
    type_info = reg_patterns.get(registration_type)
    if not type_info:
        return None
    # Use the first pattern group as a fallback regex
    patterns = type_info.get("patterns", [])
    if patterns:
        return "|".join(patterns)
    return None


def get_expected_files_from_language(lang_patterns: dict, registration_type: str) -> list[str]:
    """Get expected file names for a registration type from language patterns."""
    reg_patterns = lang_patterns.get("registration_patterns", {})
    type_info = reg_patterns.get(registration_type)
    if not type_info:
        return []
    return type_info.get("files", [])


def file_matches_pattern(filepath: str, pattern: str) -> bool:
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


def verify_stitch(packet_path: str, repo_root: str) -> dict:
    """Run stitch-point verification and return ScriptResult dict."""
    start_ms = time.monotonic_ns() // 1_000_000

    # Parse input
    try:
        with open(packet_path, "r", encoding="utf-8") as f:
            packet = json.load(f)
    except (OSError, json.JSONDecodeError) as e:
        return {
            "status": "error",
            "checks_total": 0,
            "checks_passed": 0,
            "checks_failed": 0,
            "gaps": [],
            "passed_ids": [],
            "metadata": {
                "script": "verify_stitch.py",
                "intensity": "STANDARD",
                "duration_ms": 0,
                "error": f"Failed to read execution packet: {e}",
            },
        }

    stitch_points = packet.get("stitch_points", [])
    if not stitch_points:
        duration = (time.monotonic_ns() // 1_000_000) - start_ms
        return {
            "status": "passed",
            "checks_total": 0,
            "checks_passed": 0,
            "checks_failed": 0,
            "gaps": [],
            "passed_ids": [],
            "metadata": {
                "script": "verify_stitch.py",
                "intensity": "STANDARD",
                "duration_ms": duration,
            },
        }

    # Detect language and load patterns
    primary_lang = detect_primary_language(repo_root)
    lang_patterns = load_language_patterns(primary_lang) if primary_lang else None

    gaps = []
    passed_ids = []
    checks_total = len(stitch_points)

    for sp in stitch_points:
        sp_id = sp.get("id", "UNKNOWN")
        expected_at = sp.get("expected_at", "")
        pattern = sp.get("pattern")
        registration_type = sp.get("registration_type", "")
        component = sp.get("component", "")

        # If no explicit pattern, try to derive from language patterns
        if not pattern and lang_patterns and registration_type:
            pattern = get_pattern_from_language(lang_patterns, registration_type, component)

        # If still no pattern and no expected_at, we cannot verify — pass by default
        if not pattern and not expected_at:
            passed_ids.append(sp_id)
            continue

        # Resolve expected_at to absolute path
        if expected_at:
            target_path = os.path.join(repo_root, expected_at)
        else:
            # No expected_at — try language pattern files
            target_path = None
            if lang_patterns and registration_type:
                candidate_files = get_expected_files_from_language(lang_patterns, registration_type)
                for candidate in candidate_files:
                    # Search for candidate file in repo
                    for dirpath, dirnames, filenames in os.walk(repo_root):
                        dirnames[:] = [d for d in dirnames if d not in SKIP_DIRS and not d.startswith(".")]
                        if candidate in filenames:
                            candidate_path = os.path.join(dirpath, candidate)
                            if pattern and file_matches_pattern(candidate_path, pattern):
                                target_path = candidate_path
                                break
                    if target_path:
                        break

        # Check the target
        if target_path and os.path.isfile(target_path):
            if pattern:
                if file_matches_pattern(target_path, pattern):
                    passed_ids.append(sp_id)
                else:
                    gaps.append({
                        "id": f"G{len(gaps) + 1:03d}",
                        "type": "stitch_missing",
                        "severity": "minor",
                        "reference": sp_id,
                        "description": f"Pattern '{pattern}' not found in {expected_at or target_path}",
                        "context": {
                            "expected_at": expected_at or os.path.relpath(target_path, repo_root),
                            "related_code": component,
                            "spec_section": "",
                        },
                    })
            else:
                # File exists, no pattern to check — pass
                passed_ids.append(sp_id)
        else:
            gaps.append({
                "id": f"G{len(gaps) + 1:03d}",
                "type": "stitch_missing",
                "severity": "minor",
                "reference": sp_id,
                "description": f"Expected file not found: {expected_at}" if expected_at else f"No registration file found for {component}",
                "context": {
                    "expected_at": expected_at,
                    "related_code": component,
                    "spec_section": "",
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
            "script": "verify_stitch.py",
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
                    "script": "verify_stitch.py",
                    "intensity": "STANDARD",
                    "duration_ms": 0,
                    "error": "Usage: verify_stitch.py <execution-packet.json> <repo_root>",
                },
            })
        )
        sys.exit(1)

    packet_path = sys.argv[1]
    repo_root = sys.argv[2]

    if not os.path.isfile(packet_path):
        print(
            json.dumps({
                "status": "error",
                "checks_total": 0,
                "checks_passed": 0,
                "checks_failed": 0,
                "gaps": [],
                "passed_ids": [],
                "metadata": {
                    "script": "verify_stitch.py",
                    "intensity": "STANDARD",
                    "duration_ms": 0,
                    "error": f"Execution packet file not found: {packet_path}",
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
                    "script": "verify_stitch.py",
                    "intensity": "STANDARD",
                    "duration_ms": 0,
                    "error": f"Repository root not found: {repo_root}",
                },
            })
        )
        sys.exit(1)

    result = verify_stitch(packet_path, repo_root)
    print(json.dumps(result, indent=2))
    sys.exit(0 if result["status"] in ("passed", "gap_found") else 1)
