# Deploy Readiness Status Schema

Defines the output format for the `lets-deploy-check` skill.

## Status Levels

| Status | Meaning | Action |
|--------|---------|--------|
| `GREEN` | All checks passed. | Safe to deploy. |
| `YELLOW` | No blockers, but warnings present. | Review warnings before deploying. |
| `RED` | One or more blockers detected. | Resolve all blockers before deploying. |

## Report Format

```
Deploy Readiness: <GREEN|YELLOW|RED>
Timestamp: <ISO-8601>

Blocking issues:
  - <issue description> [source: <check name>]

Warnings:
  - <warning description> [source: <check name>]

Checks passed:
  - context authoring verify
  - govern check
  - deploy_service dry-run
```

## Check Sources

- `context authoring verify` — context freshness check
- `govern check` — governance policy check
- `deploy_service dry-run` — deploy adapter dry-run signal
