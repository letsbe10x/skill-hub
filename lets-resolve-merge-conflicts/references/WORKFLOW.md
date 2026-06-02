# Merge Conflicts Workflow (letsbe10x)

Use this workflow when the merged result may need synthesis, not just selection.

## Inputs

- Base ref (example: `main`)
- Incoming ref (example: `feature/xyz`)
- Mode: merge vs rebase
- Whether to recommend only or apply locally
- Non-negotiable constraints (must not regress)

## 1) Build intent before touching conflict markers

Do not start by editing `<<<<<<<` markers. First, understand what each side *means*.

Recommended Git inventory (works even if the merge/rebase is currently stopped):

```bash
MERGE_BASE="$(git merge-base main feature/xyz)"

git log --oneline "${MERGE_BASE}..main"
git log --oneline "${MERGE_BASE}..feature/xyz"

git diff --stat "${MERGE_BASE}..main"
git diff --stat "${MERGE_BASE}..feature/xyz"
```

Questions to answer:
- What does base expect now that did not exist when the incoming branch diverged?
- What does the incoming branch introduce, and what invariants does it assume?
- Which contracts (API/schema/config/flags) changed on either side?
- Which tests/docs/migrations are “part of the change” (and must be carried forward)?

## 2) Map the overlap surface (merge-base, not hunks)

Generate a deterministic overlap inventory:

```bash
python3 scripts/collect_merge_context.py \
  --base-ref main \
  --incoming-ref feature/xyz \
  --output /tmp/merge_context.json
```

Classify overlap:
- `independent`: same area, no shared intent
- `complementary`: both sides improve the same flow; combine
- `competing`: both sides solve the same problem differently
- `policy-conflict`: outcome is ambiguous; needs a decision

## 3) Checkpoint: propose strategy and get approval

Stop and present:
- Base intent summary (what + why)
- Incoming intent summary (what + why)
- Conflict inventory + overlap classification
- Proposed strategy per area: manual integration / ours / theirs / re-sequence / escalate

Ask for explicit approval before editing:

> “Here’s my understanding and the proposed strategy. Should I proceed? (yes/no)”

## 4) Resolve conflicts by semantic unit

Work at the level of full functions, classes, modules, schemas, or test suites.

Rules:
- Default to manual integration when both sides touch the same behavior/contract/safety surface.
- Use `--ours` or `--theirs` only with a written rationale (obsolete/stale/reverted/superseded).
- Treat tests/docs/config/migrations/flags/metrics as part of the merge.

## 5) Validate the integrated result

Run checks that prove both intents survived:
- Targeted tests for changed behavior
- Build/lint/typecheck where available
- Contract/caller checks if schemas or APIs changed

If validation cannot run locally, produce a plan and mark it as pending in the report.

## 6) Finalize safely

Merge mode:
- `git add -A`
- `git commit` (finalizes merge commit)

Rebase mode:
- `git add -A`
- `git rebase --continue`

Before any history rewrite (`git push --force-with-lease`), ask for explicit user approval and record the reason.
