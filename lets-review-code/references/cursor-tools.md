# Cursor Tool Mappings — lets-review-code

When executing this skill in Cursor, map the following tool references:

| Skill reference | Cursor equivalent |
|----------------|-------------------|
| `Read` file | Open file in editor, read content |
| `Bash` command | Terminal command execution |
| `grep` / `find` | Codebase search (`@codebase` or Ctrl+Shift+F) |
| `git diff` | Source control diff view |
| `git log` | Source control history |
| `Edit` file | Apply edit to file |

## Notes

- Cursor has built-in codebase indexing — use `@codebase` queries for tracing callers/callees
- Terminal output in Cursor is limited — for large diffs, prefer the SCM diff view
- File reading in Cursor uses the editor buffer — already-open files are preferred
- For the lint gate, run the linter in the integrated terminal
