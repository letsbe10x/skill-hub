# Design Bundle

The design bundle installs workflows for UX research, content evaluation, and design artifacts.

## Install

```bash
lets install design
```

## Included workflows

| Workflow | Purpose |
|----------|---------|
| lets-research-ux-walkthrough | UX flow evaluation and improvement |
| lets-research-content-evaluate | Content quality and consistency review |

## Artifacts produced

| Artifact | Type | Consumed by |
|----------|------|-------------|
| Design brief | `design_brief` | Engineering |
| UX flows | `ux_flows` | Engineering, Verify |
| Content spec | `content_spec` | Engineering |
| Accessibility checklist | `accessibility_checklist` | Verify |

## Cross-functional handoff

Design receives PRDs from PM and produces design briefs consumed by Engineering.
In the `ship-feature` DAG: `pm → design → pgm → engineering`.
