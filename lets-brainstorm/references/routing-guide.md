# Routing Guide

How to choose the downstream skill after a brainstorm spec is approved.

## Decision Table

| Exploration type | Condition | Route to | Usual mode |
|---|---|---|---|
| `feature` | Implementation scope is clear and bounded | `lets-create-plan` | Full |
| `architecture` | Decision affects multiple components or teams | `lets-create-plan` | Full |
| `direct` | Change is small, well-bounded, immediately implementable | `lets-spec-to-pr` | Light |
| `product` | Problem–solution fit is still open; more discovery needed | `lets-opportunity-discovery` | Full |

## Mode and routing

Light Mode is a workflow choice, not a destination — the downstream skill is determined by the
exploration *type*, not the mode. A Light-Mode exploration that stayed `direct` routes to
`lets-spec-to-pr` with its Light spec. If Light Mode is escalated to Full mid-way, re-apply the
decision table against the final exploration type.

## Tie-breakers

**feature vs direct:** If the spec's Architecture section describes more than two components or the
Testing Approach names more than three scenarios, treat it as `feature` and route to
`lets-create-plan`. If the implementation fits in a single focused diff, route to `lets-spec-to-pr`.

**feature vs product:** If the Success Criteria section could not be written without assumptions
about what users actually want, the exploration has not converged — route to
`lets-opportunity-discovery` before creating a plan.

**architecture vs feature:** If the spec's Component Design section names components owned by
different teams, or if the Data Flow section crosses service boundaries, treat it as `architecture`
and route to `lets-create-plan`. The plan will need cross-team review before execution.

## Presenting the Routing Decision

Always present the routing decision explicitly before invoking the downstream skill:

> "Based on the exploration type (**[type]**) and the spec we produced, the next step is
> **[downstream skill]** — [one sentence on why]. Shall I proceed?"

Wait for confirmation. If the user disagrees, re-classify and re-route.

## What Not to Do

- Do not always route to `lets-create-plan` regardless of exploration type.
- Do not route to `lets-develop-feature` directly — implementation requires a plan first.
- Do not skip presenting the routing decision — it is a required human checkpoint.
