# Review Report: {{change_title}}

**Commit:** `{{commit_sha_short}}`
**Author:** {{author}}
**Date:** {{date}}

---

## Classification

| Dimension | Value |
|-----------|-------|
| **Type** | {{change_type}} |
| **Scale** | {{scale}} ({{loc_added}}+ / {{loc_removed}}-) |
| **Risk** | {{risk_level}} |
| **Depth** | {{review_depth}} |
| **Lenses** | {{active_lenses}} |
| **Gate overrides** | {{gate_overrides}} |

---

## Lint Results

| Metric | Value |
|--------|-------|
| Linter | {{linter_name}} |
| Exit code | {{lint_exit_code}} |
| New issues | {{lint_new_issues}} |
| Pre-existing issues | {{lint_preexisting}} |
| Auto-fixable | {{lint_fixable}} |

---

## Findings Summary

| Severity | Count | Blocks? |
|----------|-------|---------|
| CRITICAL | {{count_critical}} | Yes |
| HIGH | {{count_high}} | Yes |
| MEDIUM | {{count_medium}} | No |
| LOW | {{count_low}} | No |

**Blocking findings:** {{blocking_count}}
**Total findings:** {{total_findings}}

---

## Findings

| # | Severity | Lens | Location | Finding | Confidence |
|---|----------|------|----------|---------|------------|
{{#findings}}
| {{index}} | {{severity}} | {{lens}} | `{{location}}` | {{title}} | {{confidence}} |
{{/findings}}

---

## Finding Details

{{#findings}}
### [F{{index}}] {{title}} — {{severity}}

- **What:** {{description}}
- **Why it matters:** {{impact}}
- **Fix:** {{suggested_fix}}
- **Evidence:** 
```{{language}}
{{code_snippet}}
```
- **Confidence:** {{confidence}}
- **Caveat:** {{caveat}}
- **Challenge:** {{challenge}}
- **Classification:** {{classification}} ({{classification_reasoning}})

---

{{/findings}}

## Deferred Items

{{#deferred}}
- **{{title}}** (`{{location}}`) — {{reason_deferred}}
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

## Verdict

**{{verdict}}**

{{verdict_rationale}}

---

## Provenance

| Field | Value |
|-------|-------|
| Skill | lets-review-code v3.0.0 |
| Depth | {{review_depth}} |
| Lenses run | {{active_lenses}} |
| AI failure scan | {{ai_scan_enabled}} |
| Verification pass | {{verification_run}} |
| Findings verified | {{findings_verified_count}} / {{findings_total_count}} |
| False positives filtered | {{false_positives_count}} |
