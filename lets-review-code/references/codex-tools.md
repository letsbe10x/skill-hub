# Codex Tool Mappings — lets-review-code

When executing this skill in OpenAI Codex CLI, map the following tool references:

| Skill reference | Codex equivalent |
|----------------|------------------|
| `Read` file | `read_file` tool |
| `Bash` command | `shell` tool |
| `grep` / `find` | `shell` tool with grep/find commands |
| `git diff` | `shell` tool: `git diff ...` |
| `git log` | `shell` tool: `git log ...` |
| `Edit` file | `write_file` or `patch_file` tool |

## Notes

- Codex CLI operates in a sandboxed environment — file paths must be relative or absolute within the workspace
- Shell commands are executed in the workspace root
- For large file reads, use line ranges to stay within token limits
- The `patch_file` tool is preferred for targeted edits (similar to Claude Code's `Edit`)
