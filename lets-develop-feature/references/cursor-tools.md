# Cursor Tool Mapping — lets-develop-feature

This file maps Claude Code tool names to their Cursor equivalents.

| Claude Code | Cursor |
|-------------|--------|
| `Read` | `read_file` |
| `Edit` | `edit_file` |
| `Write` | `create_file` |
| `Bash` | `run_terminal_cmd` |
| `Grep` | `codebase_search` |
| `Glob` | `list_dir` |
| `Agent` | _(no equivalent — use sequential execution)_ |

## Phase-Specific Notes

### Phase 1 — Classification
- Use `run_terminal_cmd` for git commands and file scanning
- Use `codebase_search` to identify importers and blast radius

### Phase 2 — Context Grounding
- Use `read_file` for AGENTS.md, README.md
- Use `codebase_search` for convention discovery
- Use `list_dir` for module map

### Phase 3 — Design Checkpoint
- Use `codebase_search` to verify boundary decisions
- Use `read_file` for existing patterns in target modules

### Phase 6 — Implementation
- Use `edit_file` for modifications
- Use `create_file` for new files
- Use `run_terminal_cmd` for verification commands after each package
