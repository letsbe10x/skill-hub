## {{verdict_emoji}} {{verdict}}

**Pipeline:** {{pipeline_mode}} | **Lenses:** {{active_lenses}}

### Summary

{{summary_paragraph}}

---

### Findings ({{total_findings}})

{{#has_critical}}
<details>
<summary>:red_circle: CRITICAL ({{critical_count}})</summary>

{{#critical_findings}}
**[F{{index}}] {{title}}** — `{{location}}`

{{description}}

**Fix:** {{suggested_fix}}

---

{{/critical_findings}}
</details>

{{/has_critical}}
{{#has_high}}
<details>
<summary>:orange_circle: HIGH ({{high_count}})</summary>

{{#high_findings}}
**[F{{index}}] {{title}}** — `{{location}}`

{{description}}

**Fix:** {{suggested_fix}}

---

{{/high_findings}}
</details>

{{/has_high}}
{{#has_medium}}
<details>
<summary>:yellow_circle: MEDIUM ({{medium_count}})</summary>

{{#medium_findings}}
**[F{{index}}] {{title}}** — `{{location}}`

{{description}}

---

{{/medium_findings}}
</details>

{{/has_medium}}
{{#has_low}}
<details>
<summary>:white_circle: LOW ({{low_count}})</summary>

{{#low_findings}}
- **[F{{index}}] {{title}}** — `{{location}}`: {{description}}
{{/low_findings}}

</details>

{{/has_low}}

{{#has_spec_alignment}}
### Spec Alignment

**Spec:** {{spec_ref}} | **Coverage:** {{p0_coverage}} P0, {{p1_coverage}} P1 | **Verdict:** {{spec_verdict}}

{{#spec_gaps}}
- :warning: **Missing:** {{requirement}} ({{priority}})
{{/spec_gaps}}

{{/has_spec_alignment}}

### Strengths

{{#strengths}}
- :white_check_mark: {{description}}
{{/strengths}}

---

*Reviewed with lets-review-pr v3.0.0 | {{pipeline_mode}} pipeline | {{lens_count}} lenses*
