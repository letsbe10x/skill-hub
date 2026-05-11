# Execution Packet

**Task:** {{task_summary}}
**Classification:** {{type}} / {{scale}} / {{risk}} / {{rigor_level}}
**Branch:** `{{branch_name}}`
**Date:** {{date}}

---

## Context

**Repo:** {{repo_name}} ({{repo_kind}})
**Modules touched:** {{modules_touched}}
**Critical paths:** {{critical_paths}}

---

## Design Decisions

{{#design_decisions}}
| Decision | Chosen | Alternatives | Rationale |
|----------|--------|-------------|-----------|
{{#decisions}}
| {{what}} | {{chosen}} | {{alternatives}} | {{why}} |
{{/decisions}}
{{/design_decisions}}

{{^design_decisions}}
N/A — mechanical change, no design decisions required.
{{/design_decisions}}

---

## Work Packages

| # | Files | Intent | Verification | Risk | Methodology |
|---|-------|--------|--------------|------|-------------|
{{#packages}}
| {{index}} | {{files}} | {{intent}} | `{{verification}}` | {{risk}} | {{methodology}} |
{{/packages}}

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
