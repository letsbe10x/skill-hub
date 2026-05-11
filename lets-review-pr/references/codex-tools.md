# Codex Tool Mapping — lets-review-pr

This file maps Claude Code tool names to their Codex (OpenAI) equivalents for executing this skill.

| Claude Code | Codex |
|-------------|-------|
| `Read` | `read_file` |
| `Edit` | `edit_file` |
| `Write` | `write_file` |
| `Bash` | `shell` |
| `Grep` | `grep` |
| `Glob` | `glob` |
| `WebFetch` | `web_search` |
| `Agent` | _(no equivalent — use sequential execution)_ |

## Stage-Specific Notes

### Stage 0 — Fetch PR
- Use `shell` for all `gh` commands
- Parse JSON output with `jq` or python inline

### Stage 1 — Context Discovery
- Use `read_file` for AGENTS.md, README.md
- Use `shell` with `find` for module discovery
- Use `grep` for symbol tracing

### Stage 3 — Multi-Lens Review
- Use `grep` for caller/callee tracing during verification
- Use `read_file` with line ranges for focused context

### Stage 4 — Verify Findings
- Use `read_file` to verify each finding's file:line reference
- Use `grep` to check for handling in callers

### Stage 7 — Posting
- Write review body to temp file via `write_file`
- Post via `shell`: `gh pr review $PR_ID --body-file /tmp/review.md`
- Codex sandbox may restrict network — check `gh auth status` first
