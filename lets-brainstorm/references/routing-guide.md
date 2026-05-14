# Routing Guide

How to choose the downstream skill after a brainstorm spec is approved.

## Decision Table

| Exploration type | Condition | Route to | Usual mode |
|---|---|---|---|
| `feature` | Implementation scope is clear and bounded | `lets-develop-feature` | Full |
| `architecture` | Decision affects multiple components or teams | `lets-develop-feature` | Full |
| `direct` | Change is small, well-bounded, immediately implementable | `lets-spec-to-pr` | Light |
| `product` | Problem–solution fit is still open; more discovery needed | `lets-opportunity-discovery` | Full |
| `research` | No implementation — user wanted to think through something | None (done) | Either |
| `strategy` | Decision made, no immediate implementation | None (done) | Either |

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

## When the brainstorm doesn't lead to implementation

Not every brainstorm leads to building. If the exploration type is `research` or `strategy`:
- The spec is the output — commit it, present to user, done
- No downstream skill needed
- Still validate and get approval — the spec captures the thinking

## When invoked as a handoff from lets-develop-feature

If you were invoked via the `no_approved_spec` handoff:
- Produce the spec with artifact frontmatter
- On user approval, set `status: approved`
- Control returns to `lets-develop-feature` at `stage_1_ground`
- Do NOT independently route to another downstream — the caller handles routing

## What Not to Do

- Do not always route to `lets-develop-feature` regardless of exploration type.
- Do not skip presenting the routing decision — it is a required human checkpoint.
- Do not route when invoked as a handoff — return the artifact to the caller.
