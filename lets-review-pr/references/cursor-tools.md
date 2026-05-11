# Cursor Tool Mapping — lets-review-pr

This file maps Claude Code tool names to their Cursor equivalents for executing this skill.

| Claude Code | Cursor |
|-------------|--------|
| `Read` | `read_file` |
| `Edit` | `edit_file` |
| `Write` | `create_file` |
| `Bash` | `run_terminal_cmd` |
| `Grep` | `codebase_search` |
| `Glob` | `list_dir` |
| `WebFetch` | `web_search` |
| `Agent` | _(no equivalent — use sequential execution)_ |

## Stage-Specific Notes

### Stage 0 — Fetch PR
- Use `run_terminal_cmd` for `gh pr view` and `gh pr diff`
- PR metadata is JSON — pipe through `jq` if needed

### Stage 1 — Context Discovery
- Use `codebase_search` for module map discovery and symbol tracing
- Use `read_file` for AGENTS.md / README.md

### Stage 3 — Multi-Lens Review
- Use `codebase_search` for tracing callers/callees during verification
- Cursor's inline diff view helps compare before/after

### Stage 4 — Verify Findings
- Use `read_file` with line ranges to verify each finding location
- Use `codebase_search` to trace whether callers handle flagged cases

### Stage 7 — Posting
- Use `run_terminal_cmd` for `gh pr review` commands
- Preview the review body in markdown preview before posting
