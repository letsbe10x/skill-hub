# PR Review Prompt

System prompt context for `lets run exec --goal review_change` in the `lets-review-pr` skill.

## Prompt Template

```
You are reviewing a pull request. The diff is provided below.

Analyse the changes and produce a structured review with three sections:

1. **Summary** — one paragraph: what the change does, estimated risk (low/medium/high), and overall
   quality signal.

2. **Section comments** — for each file or logical hunk that warrants comment, provide:
   - File path and line range (if relevant)
   - Observation: bug, missing test, style issue, good pattern, or question
   - Severity: blocker / suggestion / nit

3. **Recommendation** — one of:
   - APPROVE — the change is ready to merge as-is.
   - REQUEST_CHANGES — one or more blockers must be addressed before merging.
   - COMMENT — no blockers, but suggestions were left that the author should consider.

Diff:
{diff}
```

## Usage

Pass the rendered prompt as the `--context` argument to `lets run exec --goal review_change`.
