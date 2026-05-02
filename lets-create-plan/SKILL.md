---
name: lets-create-plan
description: "Use when you have an approved spec and need a step-by-step implementation plan. Translates spec requirements into bite-sized tasks with exact file paths, complete code, and run commands."
metadata:
  author: cogsmith-ai
  version: "1.0.0"
  tags: [planning, implementation, workflow]
lifecycle: published
source: https://github.com/letsbe10x/skills/blob/main/lets-create-plan/SKILL.md
compatibility:
  agents: [claude-code, cursor, codex, copilot]
triggers:
  - write a plan
  - create an implementation plan
  - plan this feature
  - before we start coding
outcome_runtime:
  open_agency_zones:
    - task_decomposition
    - implementation_strategy
    - test_strategy
  governed_action_zones:
    - execution_plan_claims
  allowed_moves:
    - challenge_initial_framing
    - request_missing_requirements
    - narrow_scope_to_reviewable_slice
  hard_limits:
    - do_not_skip_verification_planning
    - do_not_hide_open_questions
  required_decision_frames:
    - implementation_plan_strategy
  validation_gates:
    - plan_completeness_gate
  mutation_policy: read_only
  human_checkpoint_triggers:
    - missing_truth
    - strategic_pivot
---

> **Note:** This is the standalone version. For letsbe10x runtime augmentation (context pre-flight, governance, pack enrichment), use the `l10x` profile from [skill-overlay](https://github.com/letsbe10x/skill-overlay).

# lets-create-plan

Write a comprehensive implementation plan before any code is touched.

## Overview

Plans are the contract between specification and implementation. A good plan leaves nothing to interpretation: it names exact files, includes code in steps, specifies commands with expected output, and ends every logical unit with a commit. The engineer reading the plan may know nothing about the codebase or problem domain — the plan covers all of it.

Follow DRY, YAGNI, and TDD throughout. Each task must produce working, testable software on its own.

## When to Use

- You have a spec or requirements document and are about to start implementing
- A feature touches multiple files or subsystems and needs decomposition before coding
- An agentic worker needs a handoff artifact to execute implementation task-by-task
- You want to gate implementation on an explicit architecture decision

## When Not to Use

- You already have a reviewed plan and only need to execute it (use an execution skill)
- The task is a trivial change that fits in a single focused diff
- You are still exploring solution space or choosing between multiple approaches (do that first, then plan)

## Inputs

- Input: The spec/requirements text (ticket, PRD, issue, or user request)
- Input: Repo context (existing modules, constraints, patterns, and expected interfaces)
- Input: Acceptance criteria (what must be true for the work to be considered complete)

## Steps

1. **Announce** — State: "I'm using the lets-create-plan skill to create the implementation plan."

2. **Scope check** — If the spec covers multiple independent subsystems that were not broken up during brainstorming, propose separate plans (one per subsystem) before proceeding. Each plan must produce working, testable software independently.

3. **Map the file structure** — Before writing tasks, list every file that will be created or modified and what it is responsible for. Lock in decomposition decisions here.
   - One responsibility per file; prefer smaller focused files over large ones.
   - Files that change together live together; split by responsibility, not by layer.
   - In existing codebases, follow established patterns.

4. **Write the plan header** — Every plan starts with:
   ```markdown
   # [Feature Name] Implementation Plan

   > **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

   **Goal:** [One sentence]

   **Architecture:** [2-3 sentences]

   **Tech Stack:** [Key technologies/libraries]

   ---
   ```

5. **Write bite-sized tasks** — Each step is one action (2–5 minutes):
   - "Write the failing test" — step
   - "Run it to confirm it fails" — step
   - "Write minimal code to pass" — step
   - "Run tests; confirm they pass" — step
   - "Commit" — step

   Each task block includes:
   - Exact file paths to create/modify/test
   - Checkbox steps (`- [ ]`) with actual code in fenced blocks
   - Commands to run with expected output
   - A commit step

6. **No placeholders** — Never write placeholder markers (for example: "to be determined", "to do later", "fix later"), vague statements like "add appropriate error handling", or "write tests for the above" without actual test code.

7. **Self-review** — After writing the full plan, check:
   - Every requirement in the spec is covered
   - No placeholder text remains
   - Types and variable names are consistent across tasks

8. **Save the plan** — Write to the repo's plans folder (commonly `docs` → `plans`) as `YYYY-MM-DD-feature-name.md` (override with project convention if one exists).

9. **Execution handoff** — Offer two options:
   - **Subagent-Driven** (recommended): use `superpowers:subagent-driven-development`
   - **Inline Execution**: use `superpowers:executing-plans`

## Checkpoints

- Confirm (y/n): proceed with implementation only after the plan includes exact file paths, runnable commands, and explicit success criteria.

## Error handling

- If requirements are missing, ambiguous, or conflicting, stop and ask clarifying questions before writing tasks.
- If you cannot name exact files up front, propose two concrete decomposition options and ask the user to choose.
- If a command or test step fails, include the full error output in the plan and add a fallback or recovery step (for example: retry with more logging, narrow the scope, or revert to the last known-good state).

## Anti-patterns

- **Writing a plan before the spec is approved** — blocked. Spec approval is a prerequisite.
- **Including implementation details not in the spec** — scope is defined by the spec; anything beyond it is out of scope.
- **Writing steps that depend on context not stated in any prior step** — every step must be self-contained.
- **Using placeholder text or deferred items in any plan step** — plans must be complete before handoff; every step must have a concrete action and expected result.
- **Skipping verification planning** — every plan must include at least one verification step that confirms the implementation is correct; skip no verification step.

## Outputs

- Output: A plan file in the repo's plans folder (commonly `docs` → `plans`) named `YYYY-MM-DD-feature-name.md`
- Output: Each task block is self-contained and actionable with no outside context required
- Output: The plan is ready to hand off to an agentic worker or a human engineer
- Done when: Every requirement is mapped to at least one runnable command + expected result, and no step depends on unstated context.

## Example

```markdown
# Incremental cache invalidation Implementation Plan

**Goal:** Reduce stale reads by invalidating cache keys on writes.

1. Add a failing unit test for cache invalidation. (input: failing scenario) (output: a failing test)
2. Implement invalidation logic. (input: failing test) (output: test passes)
3. Run the full test suite; record the summary line.
4. Commit.
```
