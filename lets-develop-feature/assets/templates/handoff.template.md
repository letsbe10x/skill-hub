# Handoff: lets-develop-feature → lets-verify-change

**Task:** {{task_summary}}
**Rigor:** {{rigor_level}}
**Classification:** {{type}} / {{scale}} / {{risk}}
**Packages:** {{completed_count}}/{{total_count}} completed
**Date:** {{date}}

---

## Evidence

| Check | Status | Detail |
|-------|--------|--------|
| Tests | {{test_status}} | {{test_detail}} |
| Lint | {{lint_status}} | {{lint_detail}} |
| Type check | {{typecheck_status}} | {{typecheck_detail}} |
| Build | {{build_status}} | {{build_detail}} |

---

## Changes

```
{{git_diff_stat}}
```

---

## Verification Commands

```bash
{{#verification_commands}}
{{command}}
{{/verification_commands}}
```

---

{{#design_decisions}}
## Design Decisions

| Decision | Approach | Rationale |
|----------|----------|-----------|
{{#decisions}}
| {{what}} | {{chosen}} | {{why}} |
{{/decisions}}

---
{{/design_decisions}}

{{#scope_changes}}
## Scope Changes

{{#changes}}
- **{{type}}:** {{description}} (approved: {{approved_by}})
{{/changes}}

---
{{/scope_changes}}

{{#known_limitations}}
## Known Limitations

{{#items}}
- {{description}}
{{/items}}

---
{{/known_limitations}}

## Concerns for Verification

{{#concerns}}
- {{description}}
{{/concerns}}

{{^concerns}}
No specific concerns — standard verification should suffice.
{{/concerns}}

---

## Traceability

| Package | Files Changed | Tests | Verification | Status |
|---------|--------------|-------|--------------|--------|
{{#packages}}
| {{index}}: {{intent}} | {{files}} | {{tests}} | {{verification_result}} | {{status}} |
{{/packages}}
