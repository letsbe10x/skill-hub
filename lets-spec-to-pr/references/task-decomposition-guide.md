# Task Decomposition Guide

Guidelines for breaking a spec or PRD into discrete implementation tasks for `lets-spec-to-pr`.

## Decomposition Rules

1. **One task per file group** — changes that touch the same module or package belong in one task.
2. **One task per feature unit** — a self-contained capability that can be tested independently.
3. **No task should span more than ~200 lines of new/changed code** — split larger chunks.
4. **Data model changes are always their own task** — migrations, schema changes, contract updates.
5. **Tests for a feature belong in the same task** — do not separate implementation from its tests.

## Task Format

Each task passed to `change_code` should include:

- **Goal**: one sentence describing what to implement.
- **Acceptance criteria**: the conditions under which the task is done.
- **Files in scope**: list of files expected to change (optional but helpful).
- **Spec reference**: the section of the spec this task satisfies.

## Example

```
Goal: Add `l10x context authoring verify` command to CLI.
Acceptance criteria: `uv run l10x context authoring verify` exits 0 when context is fresh.
Files in scope: src/letsbe10x_run/cli.py, tests/test_cli.py
Spec reference: Section 3.2 — Context Freshness Check
```
