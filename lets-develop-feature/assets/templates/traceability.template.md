# Implementation Traceability

**Feature:** {{task_summary}}
**Rigor:** {{rigor_level}}
**Started:** {{start_date}}
**Completed:** {{end_date}}

---

## Work Package Execution

| # | Package | Files Changed | Tests Added/Modified | Verification | Status |
|---|---------|--------------|---------------------|--------------|--------|
{{#packages}}
| {{index}} | {{intent}} | {{files_changed}} | {{tests_changed}} | {{verification_output}} | {{status}} |
{{/packages}}

---

## Design Decisions Implemented

| Decision | How Realized | Validation |
|----------|-------------|-----------|
{{#decisions}}
| {{what}} | {{realization}} | {{validation}} |
{{/decisions}}

---

## Scope Changes

| Type | Description | Approved | Reason |
|------|-------------|----------|--------|
{{#scope_changes}}
| {{type}} | {{description}} | {{approved}} | {{reason}} |
{{/scope_changes}}

{{^scope_changes}}
No scope changes — implementation matched original packet.
{{/scope_changes}}

---

## Known Limitations

{{#limitations}}
- **{{title}}:** {{description}} — **Disposition:** {{disposition}}
{{/limitations}}

{{^limitations}}
None — all requirements addressed.
{{/limitations}}

---

## Evidence Summary

| Evidence Type | Command | Result | Timestamp |
|--------------|---------|--------|-----------|
{{#evidence}}
| {{type}} | `{{command}}` | {{result}} | {{timestamp}} |
{{/evidence}}

---

## Governance Record

- **Classification:** {{classification}}
- **Rigor applied:** {{rigor_level}}
- **Design checkpoint:** {{design_checkpoint_status}}
- **Critical path files:** {{critical_path_count}} (all mitigated: {{all_mitigated}})
- **Scope expansions:** {{scope_expansion_count}}
- **Human approvals:** {{human_approvals}}
