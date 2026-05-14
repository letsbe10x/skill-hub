# Run State

**Run ID:** {{run_id}}
**Feature:** {{task_summary}}
**Spec source:** {{spec_source}}
**Branch:** `{{branch_name}}`
**Started:** {{start_timestamp}}
**Last updated:** {{last_updated_timestamp}}

---

## Current Position

**Phase/Stage:** {{current_stage}}
**Status:** in_progress | paused | blocked | completed
**Package:** {{current_package}} of {{total_packages}}
**Control level:** {{control_level}}
**Rigor level:** {{rigor_level}}

---

## Stage Progress

| Stage | Status | Entered | Completed | Notes |
|-------|--------|---------|-----------|-------|
| Phase 0: Intake | {{p0_status}} | {{p0_entered}} | {{p0_completed}} | {{p0_notes}} |
| Stage 1: Ground | {{s1_status}} | {{s1_entered}} | {{s1_completed}} | {{s1_notes}} |
| Stage 2: Classify | {{s2_status}} | {{s2_entered}} | {{s2_completed}} | {{s2_notes}} |
| Stage 3: Plan | {{s3_status}} | {{s3_entered}} | {{s3_completed}} | {{s3_notes}} |
| Stage 4: Architecture | {{s4_status}} | {{s4_entered}} | {{s4_completed}} | {{s4_notes}} |
| Stage 5: Checkpoint | {{s5_status}} | {{s5_entered}} | {{s5_completed}} | {{s5_notes}} |
| Stage 6: Implement | {{s6_status}} | {{s6_entered}} | {{s6_completed}} | {{s6_notes}} |
| Stage 7: Test | {{s7_status}} | {{s7_entered}} | {{s7_completed}} | {{s7_notes}} |
| Stage 8: Verify | {{s8_status}} | {{s8_entered}} | {{s8_completed}} | {{s8_notes}} |
| Stage 9: Complete | {{s9_status}} | {{s9_entered}} | {{s9_completed}} | {{s9_notes}} |

---

## Package Progress

| # | Package | Status | Started | Completed | Verification | Notes |
|---|---------|--------|---------|-----------|--------------|-------|
{{#packages}}
| {{index}} | {{name}} | {{status}} | {{started}} | {{completed}} | {{verification_result}} | {{notes}} |
{{/packages}}

---

## Task Progress

| Task ID | Status | Evidence | Completed at |
|---------|--------|----------|--------------|
{{#tasks}}
| {{id}} | {{status}} | {{evidence}} | {{completed_at}} |
{{/tasks}}

---

## Artifacts

| Artifact | Path | Status | Last updated |
|----------|------|--------|--------------|
| Spec (approved) | {{spec_path}} | {{spec_status}} | {{spec_updated}} |
| Execution packet | {{packet_path}} | {{packet_status}} | {{packet_updated}} |
| Story tasks | {{tasks_path}} | {{tasks_status}} | {{tasks_updated}} |
| Scenario matrix | {{scenarios_path}} | {{scenarios_status}} | {{scenarios_updated}} |
| Architecture notes | {{arch_path}} | {{arch_status}} | {{arch_updated}} |
| Verification record | {{verify_path}} | {{verify_status}} | {{verify_updated}} |
| Handoff | {{handoff_path}} | {{handoff_status}} | {{handoff_updated}} |
| Run state (this file) | run-state.md | active | {{last_updated_timestamp}} |

---

## Decisions Log

| # | Decision | Chosen | Why | Stage | Timestamp |
|---|----------|--------|-----|-------|-----------|
{{#decisions}}
| {{index}} | {{what}} | {{chosen}} | {{why}} | {{stage}} | {{timestamp}} |
{{/decisions}}

---

## Blockers & Risks

| # | Type | Description | Status | Resolution |
|---|------|-------------|--------|------------|
{{#blockers}}
| {{index}} | {{type}} | {{description}} | {{status}} | {{resolution}} |
{{/blockers}}

---

## Assumptions

| # | Assumption | Confidence | Status | Validated at |
|---|------------|------------|--------|--------------|
{{#assumptions}}
| {{index}} | {{text}} | {{confidence}} | {{status}} | {{validated_at}} |
{{/assumptions}}

---

## Resume Context

If resuming from a break, this section provides the minimum context needed to continue:

**Next action:** {{next_action}}
**Pending user input:** {{pending_user_input}}
**Last completed work:** {{last_completed_work}}
**Open contradictions:** {{open_contradictions}}
**Critical state:** {{critical_state_notes}}
