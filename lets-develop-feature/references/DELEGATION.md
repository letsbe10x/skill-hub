# Delegation & Handoff Contract — lets-develop-feature

How lets-develop-feature delegates to upstream skills and consumes their output. Read SKILL.md
`handoffs:` frontmatter for the declaration schema — this file covers the artifact contract
and operational detail.

## Artifact Frontmatter Contract

Every delegated skill must produce a Markdown file with this frontmatter:

```yaml
---
artifact_type: spec | friction-log | comparison | persona-report | requirements | ux-design-brief
produced_by: <skill_name>
produced_at: <ISO 8601 timestamp>
status: approved | draft
approval_source: user | automated | self-review
---
```

`lets-develop-feature` will NOT consume an artifact with `status: draft`. If a delegated skill
produces a draft, surface it to the user for approval before proceeding.

## Graceful Degradation

| Condition | Behavior |
|---|---|
| Required skill not available | Use inline fallback (Path B in Phase 0) |
| Optional skill not available | Skip, note in run state, proceed |
| Skill produces no artifact | Treat as failure; ask user how to proceed |
| Artifact missing frontmatter | Warn user; treat as draft until manually approved |
| User provides their own spec mid-Phase-0 | Accept with `status: approved`, skip brainstorm |

## Adding New Upstream Skills

To register a new upstream skill:

1. Add a signal ID to the detection checklist in `references/INTAKE.md`
2. Add a handoff declaration to SKILL.md frontmatter
3. Ensure the target skill produces artifacts conforming to the frontmatter contract above
4. No changes to SKILL.md body required — the frontmatter IS the registration
