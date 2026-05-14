# Journey Link

**Workflow:** {{skill_id}}
**Run ID:** {{run_id}}
**Feature key:** (fill or `none`)
**Journey ID:** (fill or `not created`)

## Core Linkage

| Core Primitive | Identifier | Status | Notes |
|---|---|---|---|
| Spec workspace | (feature key/path) | linked/skipped | (fill) |
| Journey | (journey_id) | linked/skipped | (fill) |
| Engine run | (run_id) | linked/skipped | (fill) |
| Coordination attention | (view/source) | linked/skipped | (fill) |
| Handoff | `handoff.md` | linked | (fill) |
| Evidence bundle | (path/run id) | exported/skipped | (fill) |
| Receipt | (path/run id) | exported/skipped | (fill) |

## Export Commands

```bash
lets run receipt <run_id>
lets run export-evidence <run_id>
lets journey export <journey_id> --update-pointer
lets journey validate <journey_id>
```

## Handoff Notes

(fill with what `lets-verify-change` must consume next)
