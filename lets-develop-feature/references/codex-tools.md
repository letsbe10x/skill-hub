# Codex Tool Mapping — lets-develop-feature

This file maps Claude Code tool names to their Codex (OpenAI) equivalents.

| Claude Code | Codex |
|-------------|-------|
| `Read` | `read_file` |
| `Edit` | `edit_file` |
| `Write` | `write_file` |
| `Bash` | `shell` |
| `Grep` | `grep` |
| `Glob` | `glob` |
| `Agent` | _(no equivalent — use sequential execution)_ |

## Phase-Specific Notes

### Phase 1 — Classification
- Use `shell` for git commands and risk signal scanning
- Use `grep` to find importers and shared interfaces

### Phase 2 — Context Grounding
- Use `read_file` for AGENTS.md, README.md
- Use `shell` with `find` for module discovery
- Use `grep` for convention patterns

### Phase 3 — Design Checkpoint
- Use `grep` to check existing patterns and boundary usage
- Use `read_file` for full file context

### Phase 6 — Implementation
- Use `edit_file` for modifications to existing files
- Use `write_file` for new files
- Use `shell` for all verification commands
- Note: Codex sandbox may restrict some commands — check available tools
