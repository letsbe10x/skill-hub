# Control Level — lets-develop-feature

Extended reference for control level mechanics. Read SKILL.md first — the control table there
is the primary contract. This file adds override rules and edge cases.

## Override Mechanics

Control level is not locked for the duration of the run.

**User escalates** ("wait", "walk me through this"):
- Switch to collaborative from current stage forward
- No re-run of past stages

**User de-escalates** ("just go ahead", "looks good, proceed"):
- Switch to autonomous or checkpoints from current stage forward

**Hard-stops always escalate** regardless of control level:
- Spec contradiction discovered
- Service constraint violated
- Security/auth code modified
- Irreversible operation (DELETE, DROP, migration)
- Blocked verification verdict

## Rigor × Control Interactions

| Combination | Valid? | Notes |
|---|---|---|
| MINIMAL + Autonomous | Yes | Fastest path |
| MINIMAL + Collaborative | Yes (unusual) | User wants visibility into trivial change |
| ELEVATED + Autonomous | Caution | Warn: "This is elevated-risk — autonomous means I make architecture decisions without asking. Sure?" |
| FULL + Autonomous | Invalid | Auto-escalate to Checkpoints. Inform user. |
| FULL + Collaborative | Yes | Maximum ceremony |

## Brainstorm Mode Mapping

When delegating to `lets-brainstorm` and no explicit mode is set:

| Control level | Brainstorm mode |
|---|---|
| Autonomous | Light |
| Checkpoints | Light (escalates if scope grows) |
| Collaborative | Full |
