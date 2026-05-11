## Readiness Report — {{repo_name}}

**Level:** {{readiness_level}}
**Score:** {{score}}/100
**Date:** {{date}}

| Pillar | Status | Score | Notes |
|--------|--------|-------|-------|
| Service | {{service_status}} | {{service_score}}/40 | {{service_notes}} |
| Engineering | {{engineering_status}} | {{engineering_score}}/20 | {{engineering_notes}} |
| Delivery | {{delivery_status}} | {{delivery_score}}/20 | {{delivery_notes}} |
| Observability | {{observability_status}} | {{observability_score}}/20 | {{observability_notes}} |

### Top gaps

{{#gaps}}
{{index}}. **{{title}}** — {{remediation}}
{{/gaps}}

### Recommended next action

{{next_action}}
