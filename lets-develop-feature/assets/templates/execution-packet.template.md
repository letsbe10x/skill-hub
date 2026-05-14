# Execution Packet

**Task:** {{task_summary}}
**Classification:** {{type}} / {{scale}} / {{risk}} / {{rigor_level}}
**Branch:** `{{branch_name}}`
**Date:** {{date}}
**Spec source:** {{spec_source}}
**Feature key:** {{feature_key}}
**Journey ID:** {{journey_id}}

---

## Context

**Repo:** {{repo_name}} ({{repo_kind}})
**Modules touched:** {{modules_touched}}
**Critical paths:** {{critical_paths}}
**Core linkage:** {{core_linkage_summary}}

---

## Spec Readiness

| Check | Status | Evidence |
|-------|--------|----------|
| Spec source identified | {{spec_source_status}} | {{spec_source_evidence}} |
| Critical clarifications resolved | {{clarification_status}} | {{clarification_evidence}} |
| Requirements are testable | {{requirements_status}} | {{requirements_evidence}} |
| Scope boundary defined | {{scope_status}} | {{scope_evidence}} |

---

## User Stories

| Story | Priority | Independent test criteria | MVP |
|-------|----------|---------------------------|-----|
{{#user_stories}}
| {{id}} | {{priority}} | {{test_criteria}} | {{mvp}} |
{{/user_stories}}

{{^user_stories}}
N/A — no user-story decomposition needed for this rigor level.
{{/user_stories}}

---

## Design Decisions

{{#design_decisions}}
| Decision | Chosen | Alternatives | Rationale | Evidence |
|----------|--------|-------------|-----------|----------|
{{#decisions}}
| {{what}} | {{chosen}} | {{alternatives}} | {{why}} | {{evidence}} |
{{/decisions}}
{{/design_decisions}}

{{^design_decisions}}
N/A — mechanical change, no design decisions required.
{{/design_decisions}}

---

## Work Packages

| # | Files | Intent | Stories | Task IDs | Verification | Risk | Methodology |
|---|-------|--------|---------|----------|--------------|------|-------------|
{{#packages}}
| {{index}} | {{files}} | {{intent}} | {{stories}} | {{task_ids}} | `{{verification}}` | {{risk}} | {{methodology}} |
{{/packages}}

---

## Story Tasks

| Task | Story | Files | Depends on | Parallel | Verification | Maps to |
|------|-------|-------|------------|----------|--------------|---------|
{{#story_tasks}}
| {{id}} | {{story}} | {{files}} | {{depends_on}} | {{parallel}} | `{{verification}}` | {{maps_to}} |
{{/story_tasks}}

{{^story_tasks}}
N/A — story task decomposition skipped for this rigor level.
{{/story_tasks}}

---

## Design Artifacts

| Artifact | Source or Path | Status | Notes |
|----------|----------------|--------|-------|
| Research decisions | {{research_path}} | {{research_status}} | {{research_notes}} |
| Data model | {{data_model_path}} | {{data_model_status}} | {{data_model_notes}} |
| Contracts | {{contracts_path}} | {{contracts_status}} | {{contracts_notes}} |
| Quickstart or smoke scenario | {{quickstart_path}} | {{quickstart_status}} | {{quickstart_notes}} |

---

## Critical Path Files

{{#critical_files}}
- `{{file}}` — {{marker}}. **Mitigation:** {{mitigation}}
{{/critical_files}}

{{^critical_files}}
None — no critical-path files in scope.
{{/critical_files}}

---

## Dependencies & Ordering

{{#dependencies}}
- Package {{from}} must complete before package {{to}} (reason: {{reason}})
{{/dependencies}}

{{^dependencies}}
No ordering constraints — packages are independent.
{{/dependencies}}

---

## Scope Boundary

**IN scope:**
{{#in_scope}}
- {{item}}
{{/in_scope}}

**OUT of scope (deferred):**
{{#out_of_scope}}
- {{item}}
{{/out_of_scope}}

---

## Slice Plan (if stacked PRs)

{{#slices}}
| Slice | Branch | Content | Base |
|-------|--------|---------|------|
{{#slice_list}}
| {{index}} | `{{branch}}` | {{content}} | {{base}} |
{{/slice_list}}
{{/slices}}

{{^slices}}
Single PR — change fits in one reviewable unit.
{{/slices}}

---

## Risk Summary

| Risk level | Signal | Mitigation |
|-----------|--------|------------|
{{#risks}}
| {{level}} | {{signal}} | {{mitigation}} |
{{/risks}}

---

**Governance:** {{governance_action}}
**Evidence expectations:** {{evidence_expectations}}
