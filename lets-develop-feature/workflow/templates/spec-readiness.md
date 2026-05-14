# Spec Readiness

**Workflow:** {{skill_id}}
**Run ID:** {{run_id}}
**Feature key:** (fill or `none`)
**Spec source:** (fill: `lets spec`, PRD, issue, user request, or other)
**Journey ID:** (fill or `not created`)

## Core Preflight

| Check | Command or Source | Result | Notes |
|---|---|---|---|
| Classification | `lets classify --request "..." --format json` | (fill) | (fill) |
| Spec status | `lets spec status --format json` | (fill or skipped) | (fill) |
| Spec export | `lets spec export <feature_key>` | (fill or skipped) | (fill) |
| Journey status | `lets journey status <journey_id>` | (fill or skipped) | (fill) |

## Specification Quality Checklist

- [ ] WHAT and WHY are clear before HOW
- [ ] User stories or user-facing scenarios are identifiable
- [ ] Functional requirements are testable and unambiguous
- [ ] Success criteria are measurable or acceptance criteria are explicit
- [ ] Scope boundary is clear
- [ ] Security, privacy, compliance, or data concerns are identified
- [ ] Critical clarifications are resolved or explicitly blocking
- [ ] Non-critical assumptions are documented

## Readiness Verdict

**Verdict:** ready | blocked | proceed-with-risk

**Reasoning:** (fill)
