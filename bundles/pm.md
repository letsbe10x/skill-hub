# PM Bundle

The PM bundle installs workflows for product requirements and opportunity analysis.

## Install

```bash
lets install pm
```

## Included workflows

| Workflow | Purpose |
|----------|---------|
| lets-brainstorm | Structured ideation and problem framing |
| lets-opportunity-discovery | Market opportunity identification |
| lets-research-prd-grooming | PRD refinement and gap analysis |
| lets-research-prd-control-plane | PRD lifecycle management |

## Artifacts produced

| Artifact | Type | Consumed by |
|----------|------|-------------|
| PRD | `prd` | Design, Engineering, Review |
| Problem statement | `problem_statement` | Design |
| Success metrics | `success_metrics` | Verify |
| Acceptance criteria | `acceptance_criteria` | Engineering, Verify, Review |
| Opportunity map | `opportunity_map` | PgM |

## Typical flow

```
lets-brainstorm → lets-opportunity-discovery → lets-research-prd-grooming
```

## Cross-functional handoff

PM artifacts are the starting point for the `ship-feature` workflow.
Design and PgM consume PRDs; Engineering requires both PRD and acceptance criteria.
