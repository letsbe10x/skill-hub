#!/usr/bin/env python3
"""Collect merge-base context for intent-aware merge analysis.

This script is deterministic and uses only the Git CLI. It helps build an overlap
inventory (commits, changed files, directory counts) for each side and highlights
shared files from the merge base.
"""

from __future__ import annotations

import argparse
import json
import subprocess
import sys
from collections import Counter
from pathlib import Path


def run_git(repo_root: Path, *args: str) -> str:
    result = subprocess.run(
        ["git", *args],
        cwd=repo_root,
        text=True,
        capture_output=True,
        check=False,
    )
    if result.returncode != 0:
        stderr = result.stderr.strip()
        stdout = result.stdout.strip()
        detail = stderr or stdout
        if not detail and args and args[0] == "merge-base":
            detail = "no merge base found or one of the refs does not exist"
        if not detail:
            detail = "git command failed"
        command = " ".join(["git", *args])
        raise RuntimeError(f"{command}: {detail}")
    return result.stdout.strip()


def parse_commits(raw_output: str) -> list[dict[str, str]]:
    commits: list[dict[str, str]] = []
    for line in raw_output.splitlines():
        if not line.strip():
            continue
        parts = line.split("\t", 3)
        if len(parts) < 4:
            continue
        commit_hash, authored_on, author, subject = parts
        commits.append(
            {
                "hash": commit_hash,
                "date": authored_on,
                "author": author,
                "subject": subject,
            }
        )
    return commits


def parse_name_status(raw_output: str) -> list[dict[str, str]]:
    entries: list[dict[str, str]] = []
    for line in raw_output.splitlines():
        if not line.strip():
            continue
        parts = line.split("\t")
        status = parts[0]
        if len(parts) == 2:
            entries.append({"status": status, "path": parts[1]})
            continue
        if len(parts) >= 3:
            entries.append({"status": status, "old_path": parts[1], "path": parts[2]})
            continue
        entries.append({"status": status, "path": ""})
    return entries


def summarize_statuses(entries: list[dict[str, str]]) -> dict[str, int]:
    counts = Counter(entry["status"][0] for entry in entries if entry.get("status"))
    return dict(sorted(counts.items()))


def summarize_directories(paths: list[str]) -> list[dict[str, int | str]]:
    counts: Counter[str] = Counter()
    for path in paths:
        parent = str(Path(path).parent)
        counts["/" if parent == "." else parent] += 1
    return [
        {"directory": directory, "count": count}
        for directory, count in sorted(counts.items(), key=lambda item: (-item[1], item[0]))
    ]


def collect_side(repo_root: Path, merge_base: str, ref: str, commit_limit: int) -> dict[str, object]:
    commit_output = run_git(
        repo_root,
        "log",
        "--date=short",
        f"--max-count={commit_limit}",
        "--pretty=format:%H%x09%ad%x09%an%x09%s",
        f"{merge_base}..{ref}",
    )
    file_output = run_git(repo_root, "diff", "--name-status", f"{merge_base}..{ref}")
    diffstat = run_git(repo_root, "diff", "--shortstat", f"{merge_base}..{ref}")

    file_entries = parse_name_status(file_output)
    file_paths = [entry["path"] for entry in file_entries if entry.get("path")]

    return {
        "ref": ref,
        "commit_count": len(commit_output.splitlines()) if commit_output else 0,
        "commits": parse_commits(commit_output),
        "changed_file_count": len(file_paths),
        "changed_files": file_entries,
        "status_counts": summarize_statuses(file_entries),
        "directory_counts": summarize_directories(file_paths),
        "diffstat": diffstat,
    }


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--base-ref", required=True, help="Current/base branch or commit-ish.")
    parser.add_argument("--incoming-ref", required=True, help="Incoming branch or commit-ish.")
    parser.add_argument("--repo-root", default=".", help="Git repo root or any path inside it.")
    parser.add_argument(
        "--commit-limit",
        type=int,
        default=25,
        help="Maximum commits to capture per side.",
    )
    parser.add_argument("--output", help="Optional path for JSON output. Defaults to stdout.")
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    repo_root = Path(args.repo_root).resolve()

    try:
        resolved_root = Path(run_git(repo_root, "rev-parse", "--show-toplevel"))
        merge_base = run_git(resolved_root, "merge-base", args.base_ref, args.incoming_ref)
        base_data = collect_side(resolved_root, merge_base, args.base_ref, args.commit_limit)
        incoming_data = collect_side(resolved_root, merge_base, args.incoming_ref, args.commit_limit)
    except RuntimeError as exc:
        print(f"[ERROR] {exc}", file=sys.stderr)
        return 1

    base_paths = {entry["path"] for entry in base_data["changed_files"] if entry.get("path")}
    incoming_paths = {entry["path"] for entry in incoming_data["changed_files"] if entry.get("path")}
    shared_files = sorted(base_paths & incoming_paths)

    payload = {
        "repo_root": str(resolved_root),
        "merge_base": merge_base,
        "base": base_data,
        "incoming": incoming_data,
        "overlap": {
            "shared_file_count": len(shared_files),
            "shared_files": shared_files,
            "shared_directory_counts": summarize_directories(shared_files),
        },
    }

    serialized = json.dumps(payload, indent=2, sort_keys=True)
    if args.output:
        output_path = Path(args.output)
        output_path.write_text(serialized + "\n", encoding="utf-8")
    else:
        print(serialized)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

