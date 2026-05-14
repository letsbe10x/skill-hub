# Routing Guide

How to choose what happens after a brainstorm spec is approved. Not all brainstorms lead to
implementation — some end with a decision, a strategy, or a research direction.

## Decision Table

| Exploration type | Condition | Route to | Usual mode |
|---|---|---|---|
| `feature` | Implementation scope is clear and bounded | `lets-create-plan` or `lets-develop-feature` | Full |
| `architecture` | Decision affects multiple components or teams | `lets-create-plan` | Full |
| `direct` | Change is small, well-bounded, immediately implementable | `lets-develop-feature` (autonomous) or `lets-spec-to-pr` | Light |
| `product` | Problem–solution fit is still open; more discovery needed | `lets-opportunity-discovery` | Full |
| `research` | Decision requires evidence gathering, competitive scan, or user research | `lets-research-*` (appropriate variant) | Full |
| `strategy` | Decision is made; no implementation follows (org decision, process choice, content direction) | No downstream skill — present decision summary | Either |

### When the brainstorm doesn't lead to implementation

Not every brainstorm routes to a build skill. When the exploration resolved a question without
creating implementation work (e.g., "should we use Postgres or DynamoDB?" → decision made,
recorded, done), present the decision summary and ask: "Is there anything to implement from this,
or is the decision itself the outcome?"

If the user says the decision is the outcome: commit the spec as a decision record and stop.
No downstream routing required.

### When invoked as a handoff from lets-develop-feature

When `lets-brainstorm` was delegated to by `lets-develop-feature` (via its Phase 0 handoff
declarations), do NOT route to a downstream skill at the end. Instead, produce the approved spec
artifact and return control to `lets-develop-feature`. The calling skill handles the rest of the
lifecycle.

Detection: check if the brainstorm was invoked with `context_pass` containing `intent_echo` and
`discovery_signals` — this indicates it was called as a delegation, not standalone.

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

- Do not always route to an implementation skill — brainstorms can end with a decision, not code.
- Do not route to `lets-develop-feature` when invoked standalone without an approved spec — `lets-develop-feature` will invoke brainstorm itself via Phase 0 when needed.
- Do not skip presenting the routing decision — it is a required human checkpoint.
- Do not attempt downstream routing when invoked as a delegation from `lets-develop-feature` — just return the approved artifact.
- Do not assume implementation follows — ask if the decision is the outcome or if something needs to be built.
