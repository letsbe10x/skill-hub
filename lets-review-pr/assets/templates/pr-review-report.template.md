# PR Review: {{pr_title}}

**PR:** #{{pr_number}} | **Author:** {{author}} | **Base:** {{base_branch}} ← {{head_branch}}
**Classification:** {{type}} / {{scale}} / {{risk}} / {{complexity}}
**Pipeline:** {{pipeline_mode}} | **Lenses:** {{active_lenses}}

---

## Summary

{{summary_paragraph}}

---

## Context Brief

| Dimension | Value |
|-----------|-------|
| Repo kind | {{repo_kind}} |
| Modules touched | {{modules_touched}} |
| Critical paths | {{critical_paths}} |
| Invariants checked | {{invariants_checked}} |

---

## Findings ({{total_findings}})

| Blocking | Non-blocking |
|----------|-------------|
| {{blocking_count}} ({{critical_count}} CRITICAL + {{high_count}} HIGH) | {{nonblocking_count}} ({{medium_count}} MEDIUM + {{low_count}} LOW) |

### All Findings

| # | Severity | Lens | Location | Finding | Confidence |
|---|----------|------|----------|---------|------------|
{{#findings}}
| {{index}} | {{severity}} | {{lens}} | `{{location}}` | {{title}} | {{confidence}} |
{{/findings}}

---

## Finding Details

{{#findings}}
### [F{{index}}] {{title}} — {{severity}}

- **Lens:** {{lens}}
- **What:** {{description}}
- **Location:** `{{file}}:{{line}}`
- **Why it matters:** {{impact}}
- **Fix:** {{suggested_fix}}
- **Evidence:**
```{{language}}
{{code_snippet}}
```
- **Confidence:** {{confidence}}
- **Caveat:** {{caveat}}
- **Challenge:** {{challenge}}

---

{{/findings}}

{{#has_spec_alignment}}
## Spec Alignment

**Spec:** {{spec_ref}}

### Requirement Coverage

| # | Requirement | Priority | Status | Evidence |
|---|------------|----------|--------|----------|
{{#requirements}}
| {{index}} | {{description}} | {{priority}} | {{status}} | `{{evidence}}` |
{{/requirements}}

### Contract Compliance

{{contract_compliance_details}}

### Spec Verdict: {{spec_verdict}}

{{spec_verdict_rationale}}

---

{{/has_spec_alignment}}

## Deferred Items

{{#deferred}}
- **{{title}}** (`{{location}}`) — {{reason}}
{{/deferred}}
{{^deferred}}
None.
{{/deferred}}

---

## Strengths

{{#strengths}}
- {{description}}
{{/strengths}}

---

## Recommendation

### {{verdict}}

{{verdict_rationale}}

{{#has_blocking}}
### Required Actions

{{#blocking_findings}}
1. **[F{{index}}]** {{title}} — {{suggested_fix}}
{{/blocking_findings}}
{{/has_blocking}}

---

## Provenance

| Field | Value |
|-------|-------|
| Skill | lets-review-pr v3.0.0 |
| Pipeline | {{pipeline_mode}} |
| Lenses | {{active_lenses}} |
| Spec alignment | {{spec_alignment_run}} |
| Findings verified | {{verified_count}} / {{raw_count}} |
| False positives filtered | {{fp_count}} |
| Gate overrides | {{gate_overrides}} |
