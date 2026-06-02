---
name: lets-resolve-merge-conflicts
description: "Use when resolving Git merge conflicts or rebase conflicts and you need an intent-aware integration plan (not just ours/theirs). Builds an overlap inventory from the merge base, proposes a resolution strategy, resolves conflicts by semantic unit, validates the integrated result, and produces a conflict-resolution report."
metadata:
  author: letsbe10x
  version: "0.1.0"
  tags: [git, merge, rebase, conflicts, integration, review, delivery]
lifecycle: published
source: https://github.com/letsbe10x/skill-hub/blob/main/lets-resolve-merge-conflicts/SKILL.md
compatibility:
  agents: [claude-code, cursor, codex, copilot]
  requirements:
    - Git repository with both refs available locally
triggers:
  - merge conflict
  - resolve merge conflicts
  - conflicts in rebase
  - rebase conflict
  - fix conflict markers
  - git conflict
  - update branch has conflicts
not-for:
  - Making a product decision when the two branches encode incompatible intent (escalate instead)
---

## Overview

`lets-resolve-merge-conflicts` is for conflicts where cleaning up `<<<<<<<` markers is not enough.
The goal is to preserve the **intent** of both sides: what the updated base branch now expects,
what the incoming branch intended to change, and what the integrated result must guarantee.

This skill treats conflict resolution as a semantic integration task (functions/classes/schemas/tests),
not a line-level hunk-selection exercise.

## When to Use

- A merge or rebase stops due to conflicts.
- Both sides touched the same behavior, API contract, config, or migration.
- “Use ours/theirs” would likely delete valuable work or silently regress intent.
- You need a clear, reviewable merge-resolution recommendation before you edit files.

## When Not to Use

- You do not have access to both sides of the history (missing refs, shallow clone you can’t deepen).
- The conflict is in secrets or sensitive files you’re not allowed to handle in this environment.
- The two branches represent an unresolved product/policy decision (stop and escalate).

## Inputs

- Input: Base ref (the target branch you’re integrating into): example `main`
- Input: Incoming ref (the branch being merged/rebased): example `feature/xyz`
- Input: Conflict mode: `merge` (MERGE_HEAD) vs `rebase` (REBASE_HEAD / interactive rebase)
- Input: Execution mode: recommend only vs apply locally (edit files + stage + continue)
- Input: Non-negotiables (must not regress): behavior, API contract, schema, rollout, observability, tests

## Canonical Sources

- Workflow contract: [references/WORKFLOW.md](references/WORKFLOW.md)
- Conflict-resolution report template: [references/conflict-resolution-report.template.md](references/conflict-resolution-report.template.md)
- Merge context collector: `scripts/collect_merge_context.py`

## Steps

1. Confirm the conflict state and capture the conflict file list (do not edit anything yet).
2. Identify the correct base and incoming refs for this conflict.
3. Build intent for both sides from the merge base (commits + diffs + tests/docs/config/migrations).
4. Inventory overlap from the merge base (shared files + directories), not just conflicted hunks:
   - Use `scripts/collect_merge_context.py` (run with `python3`) to generate a deterministic overlap report.
5. **Checkpoint — propose the resolution strategy before editing files.**
   - Present: base intent, incoming intent, overlap classification, and strategy per area.
   - Ask the user: “Proceed with this plan?” (yes/no). Stop if “no”.
6. Resolve conflicts by semantic unit:
   - Default to manual integration when both sides change the same behavior/contract/safety surface.
   - Use `--ours` or `--theirs` only when one side is clearly obsolete; state the reason explicitly in the report.
   - Treat tests/docs/config/migrations as part of the merge, not afterthoughts.
7. Validate the integrated result:
   - Run the most specific checks available (targeted tests, linters, build).
   - Ensure conflict markers are fully removed and `git status` is clean for the merge/rebase step.
8. Finalize the merge/rebase and produce a conflict-resolution report using the template.

## Checkpoints

- Checkpoint `strategy_checkpoint`: before modifying any conflicted file, present the plan and wait for a clear “yes” to proceed.
- Checkpoint `history_rewrite_checkpoint`: before any `git push --force-with-lease`, ask the user for explicit confirmation and record the reason in the report.

## Commands

```bash
# Show conflicted files (works for both merge and rebase conflicts)
git diff --name-only --diff-filter=U

# Detect whether you're in a merge or rebase
git rev-parse -q --verify MERGE_HEAD && echo "merge in progress" || true
git rev-parse -q --verify REBASE_HEAD && echo "rebase in progress" || true

# Build a merge-base overlap inventory (example refs)
python3 scripts/collect_merge_context.py \
  --base-ref main \
  --incoming-ref feature/xyz \
  --output /tmp/merge_context.json
```

## Examples

```bash
# Typical merge conflict flow (local)
git checkout feature/xyz
git fetch origin
git merge origin/main

# After resolving conflicts and staging:
git commit
```

## Anti-patterns

- **Choosing `--ours` or `--theirs` by default** — this silently deletes valid intent; use it only with a written rationale.
- **Resolving only the conflict markers** — you must reconcile the full semantic unit (function/class/schema/tests), not the hunk.
- **Skipping validation** — conflict-free does not mean correct; run checks that prove intent survived.
- **Force-pushing without confirmation** — rewriting history is a governed action; require explicit user approval.

## Outputs

- Output: Conflict-resolution report (markdown) following [references/conflict-resolution-report.template.md](references/conflict-resolution-report.template.md).
- Output: Optional merge-base inventory at `/tmp/merge_context.json` from `scripts/collect_merge_context.py` (summarize key overlap in the report).
- Output: A resolved merge or continued rebase with all conflict markers removed.

Done when: No remaining unmerged paths (`git diff --name-only --diff-filter=U` is empty).
Done when: The merge/rebase is finalized (`git status` shows clean state and the operation is completed).
Done when: Validation commands were run (or explicitly deferred with user confirmation) and results are recorded in the report.

## Error Handling

- If refs are missing: fetch remotes, deepen clone, or ask the user for the correct refs before proceeding.
- If the conflict is binary (lockfiles, generated artifacts, images): prefer regenerating from source or selecting a single canonical version with rationale.
- If intent is incompatible: stop and escalate; do not “pick a winner” silently.
- If you cannot validate (missing dependencies/CI-only): provide a concrete validation plan and explicitly mark validation as pending in the report.
- If the merge/rebase state is broken or you need to restart: ask for confirmation, then recover with `git merge --abort` or `git rebase --abort` before attempting a new integration.
- If `git rebase --continue` triggers a new conflict batch on a subsequent commit: do not attempt to auto-resolve the new batch. Re-enter the skill from Step 3 (build intent) for the newly conflicted files, using the same base and incoming refs. Update the conflict-resolution report with the new batch before finalising the rebase.
