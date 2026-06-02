# Investigation Findings Template

Use this template to structure the output of the `lets-triage-issue` skill.

---

## Symptom

One paragraph describing the observed failure or unexpected behavior.
Include: what was expected, what actually happened, and when it was first observed.

## Root Cause Hypothesis

The most probable cause of the symptom. State confidence level (high / medium / low).
If multiple hypotheses exist, rank them.

## Evidence

| Source | Detail |
|--------|--------|
| Log / run output | (paste relevant excerpt) |
| Commit / diff | (link or hash) |
| Config change | (file and key) |

## Recommended Action

A concrete, actionable next step. Examples:
- Revert commit `<hash>` — this introduced the regression.
- Update config key `X` in `settings.py` from `Y` to `Z`.
- Escalate: the root cause requires access to external system `<name>`.
