# Checkpointing & Resume — lets-develop-feature

Progressive state management for resumability, auditability, and status retrieval.

## Core Principle

`run-state.md` is the single source of truth for where a run stands. It is updated at every
stage transition, every package completion, and every significant event. Any agent (or human)
can read this file and know exactly what has happened, what's next, and what's blocking.

## When to Write State

| Event | What to update |
|-------|----------------|
| Stage entry | `current_stage`, stage row status → `in_progress`, `entered` timestamp |
| Stage completion | Stage row status → `completed`, `completed` timestamp, notes |
| Stage skipped | Stage row status → `skipped`, notes with reason |
| Stage blocked | Stage row status → `blocked`, add to Blockers table |
| Package start | `current_package`, package row status → `in_progress`, `started` timestamp |
| Package completed | Package row → `completed`, `verification_result`, `completed` timestamp |
| Package blocked | Package row → `blocked`, add to Blockers table |
| Task completed | Task row → `done`, `evidence`, `completed_at` |
| Decision made | Add to Decisions Log |
| Assumption validated/invalidated | Update Assumptions table status |
| Artifact created/updated | Update Artifacts table with path, status, timestamp |
| Blocker discovered | Add to Blockers table |
| Blocker resolved | Update Blockers table status → `resolved`, add resolution |
| Control level change | Update `control_level` in Current Position |
| Scope change | Log in Decisions, update execution packet |

## The Resume Protocol

When a new conversation begins and a `run-state.md` exists:

### Step 1 — Detect

Look for `run-state.md` in the run directory:
- `<spec-workspace>/runs/develop-feature/<run_id>/run-state.md`
- Or wherever the run artifacts live (see Run State section in SKILL.md)

If found and `status != completed`: this is a resume.

### Step 2 — Validate

Compare state file against reality:

```
1. Read run-state.md → extract current_stage, current_package, task progress
2. Read story-tasks.md → compare checked items vs run-state task table
3. git log --oneline → do commits exist for claimed-completed packages?
4. git diff --name-only → are there uncommitted changes beyond the last checkpoint?
5. Run test suite → does it pass? (evidence for claimed verification)
```

**Reconciliation rules:**
- State file says "done" but no code evidence → mark `unverified`, re-verify
- Code exists beyond what state file claims → update state file to match reality
- State file says "in_progress" but code is committed → likely completed, verify and update
- Contradictions between state file and code → surface to user before continuing

### Step 3 — Present Status

```markdown
"Resuming run [run_id] for [feature].

**Current position:** Stage [X], package [Y/Z]
**Completed:** [list completed stages]
**Last action:** [from resume context]
**Next action:** [from resume context]

[If discrepancies found]: I found [N] discrepancies between the saved state and current
code state: [describe]. Want me to reconcile before continuing?"
```

### Step 4 — Continue

After validation and user acknowledgment (if needed):
1. Re-read the spec section relevant to the current package
2. Re-read service context (Stage 1 output)
3. Continue from the exact point indicated by `next_action`

## Status Retrieval

Anyone should be able to ask "what's the status?" and get a clear answer from run-state.md
without reading any other file.

### Quick Status (what the file's header gives you)

```
Feature: [name]
Stage: [current], Package: [N/M]
Status: [in_progress | paused | blocked]
Last updated: [timestamp]
```

### Detailed Status (full read)

- Which stages are done, which are pending
- Which packages/tasks are complete with evidence
- What decisions have been made
- What's blocking progress
- What the next action is

### Programmatic Access

When `lets` CLI is available:
```bash
lets run status                    # quick status from run-state.md
lets run status --detail           # full state dump
lets run list                      # all active runs
lets run resume <run_id>           # resume protocol
```

When CLI is unavailable, just read `run-state.md` directly.

## Artifact Consistency

### Cross-reference invariants

At any point, these must be consistent:

| Artifact A | Artifact B | Consistency rule |
|-----------|-----------|-----------------|
| run-state.md (task progress) | story-tasks.md (checkboxes) | Same tasks checked in both |
| run-state.md (package status) | execution-packet.md (packages) | Same packages, matching status |
| run-state.md (artifacts table) | actual files on disk | Every listed path exists; status matches content |
| run-state.md (decisions) | execution-packet.md (design decisions) | Decisions in state reflected in packet |
| story-tasks.md (checked tasks) | code on disk | Every checked task has corresponding code |
| scenario-matrix.md (scenarios) | test files | Covered scenarios have test evidence |
| verification-record.md (results) | actual test output | Claimed results match real output |

### When artifacts drift

If you detect inconsistency:
1. Determine which artifact represents reality (usually: code > state file > other artifacts)
2. Update the stale artifact to match
3. Note the correction in run-state.md decisions log: "Corrected drift: [what was wrong]"

### Update discipline

- **Never** update run-state.md without also updating the corresponding detailed artifact
- **Never** check off a task in story-tasks.md without also updating run-state.md
- **Never** complete a package without writing its verification result to both run-state.md and traceability

## Checkpoint Persistence vs. Context Window

The state file exists for two audiences:

1. **Resume audience** — a new conversation that needs to pick up where the last left off
2. **Audit audience** — a human or downstream skill that needs to understand what happened

The context window holds working memory. The state file holds durable memory. When context
is about to be lost (conversation ending, compaction, handoff), ensure run-state.md is
current — it's the bridge to the next session.

### What to persist vs. what stays in context

| Information | Persist to file? | Why |
|-------------|-----------------|-----|
| Current stage/package | Yes (run-state.md) | Resume needs it |
| Task completion with evidence | Yes (both files) | Audit + resume |
| Design decisions | Yes (run-state.md + packet) | Historical record |
| Intermediate reasoning | No | Ephemeral, context-only |
| Spec re-read content | No | Re-read from source on resume |
| User preferences/control level | Yes (run-state.md) | Resume needs it |
| Blocker details | Yes (run-state.md) | Resume + escalation |
| Verification command output | Yes (verification-record.md) | Evidence |

## Anti-patterns

- **Writing state only at the end** — state must be progressive, not retrospective
- **State file diverging from reality** — update immediately, not "later"
- **Resuming without validation** — always check code against claimed state
- **Silently fixing discrepancies** — surface them; they may indicate lost work
- **Treating state file as optional** — for STANDARD+ rigor, it's required
- **Updating one artifact but not its counterpart** — cross-references must stay in sync
- **Storing intermediate reasoning in state** — state is for facts and positions, not deliberation
