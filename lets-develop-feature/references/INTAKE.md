# Intake & Discovery — lets-develop-feature

Extended reference for Phase 0. Read SKILL.md Phase 0 section first — this file adds detail
for edge cases only.

## Signal Detection Checklist

Run these after intent is confirmed:

| Signal | How to detect |
|---|---|
| `no_approved_spec` | No spec.md in `.lets/runs/`, no `lets spec export` match, no ticket/PRD with acceptance criteria referenced |
| `existing_ux_surface` | Request modifies an existing UI flow (not creating new); target files in UI directories |
| `complex_new_ux_surface` | Feature introduces 3+ new screens/components, new interaction patterns, navigation changes, or has accessibility requirements |
| `competitive_context_needed` | User mentions competitors or this is a net-new product surface |
| `persona_validation_needed` | Request introduces a new user-facing concept or mentions target audience |
| `prd_grooming_needed` | User pasted raw feedback or unstructured feature dump |

## Inline Discovery Protocol (Path B Fallback)

When `lets-brainstorm` is unavailable or the change is small enough to not warrant full brainstorm:

1. Ask up to 3 questions (scope, success, constraint)
2. From answers, write a brief inline spec:
   ```
   ## Problem
   [one paragraph]
   ## Approach
   [one paragraph]
   ## Success Criteria
   [2-3 bullets]
   ## Scenarios
   [happy + failure + edge]
   ```
3. Present: "Here's what I'll build. Does this match?"
4. On confirmation: this becomes the approved spec for the run

## Error Cases

| Case | Response |
|---|---|
| User rejects echo | "What did you mean?" — re-echo |
| User says "just do it" / "skip all this" | Set autonomous, use inline discovery if no spec |
| Request too ambiguous even for inline discovery | Ask one disambiguating question, then try again |
| User provides spec mid-conversation | Accept it as approved spec, skip remaining discovery |
