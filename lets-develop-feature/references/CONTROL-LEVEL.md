# Control Level — lets-develop-feature

Control level determines how much the user is consulted during the run. It is orthogonal to
rigor (which determines artifact depth).

- **Rigor** = what gets produced (MINIMAL → FULL)
- **Control** = who decides when (Autonomous → Collaborative)

## Override Mechanics

Control level is NOT locked. User can escalate ("walk me through this") or de-escalate
("just go ahead") at any point. Log the change in `run-state.md`.

**Hard-stops always escalate** regardless of control level:
- Spec contradiction, service constraint violation, blocked verdict
- Security/auth modification, irreversible operation

## Rigor × Control Interactions

| Combination | Notes |
|---|---|
| ELEVATED + Autonomous | Warn: "Architecture decisions will be auto-resolved. Are you sure?" |
| FULL + Autonomous | **Invalid** — auto-escalate to Checkpoints minimum, inform user |
| FULL + Checkpoints/Collaborative | Valid — maximum ceremony |

## Brainstorm Mode Mapping

When `lets-brainstorm` is delegated and no `mode_override` is set:

| Control level | Brainstorm mode |
|---|---|
| Autonomous | Light |
| Checkpoints | Light (escalates to Full if scope grows) |
| Collaborative | Full |
