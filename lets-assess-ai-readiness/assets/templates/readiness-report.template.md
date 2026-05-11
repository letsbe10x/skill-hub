## AI Readiness Report — {{repo_name}}

**Overall: {{level}} ({{label}})** → next: {{next_level}} ({{next_label}})

### Pillar Scorecard

| Pillar | Level | Score | Status |
|--------|-------|-------|--------|
| Feedback Velocity | {{feedback_level}} | {{feedback_score}}/{{feedback_max}} | {{feedback_bar}} |
| Error Signal Clarity | {{errors_level}} | {{errors_score}}/{{errors_max}} | {{errors_bar}} |
| Determinism | {{determinism_level}} | {{determinism_score}}/{{determinism_max}} | {{determinism_bar}} |
| Change Safety | {{safety_level}} | {{safety_score}}/{{safety_max}} | {{safety_bar}} |
| Context Discoverability | {{context_level}} | {{context_score}}/{{context_max}} | {{context_bar}} |
| Pattern Consistency | {{patterns_level}} | {{patterns_score}}/{{patterns_max}} | {{patterns_bar}} |
| Recovery Cost | {{recovery_level}} | {{recovery_score}}/{{recovery_max}} | {{recovery_bar}} |
| Environment Independence | {{env_level}} | {{env_score}}/{{env_max}} | {{env_bar}} |

### Blockers to {{next_level}} ({{next_label}})

| # | Check | Pillar | Evidence | Fix |
|---|-------|--------|----------|-----|
{{#blockers}}
| {{index}} | `{{check_id}}` | {{pillar}} | {{evidence}} | {{remediation}} |
{{/blockers}}

**Cheapest path:** {{cheapest_path_summary}}

### Level Derivation

- Context level: {{context_readiness_level}}
- Agent level: {{agent_level}} (limited by: {{limiting_pillar}})
- Overall: min({{context_readiness_level}}, {{agent_level}}) = {{level}}

### Advisory (non-gating)

{{#advisory}}
- **{{signal}}** ({{pillar}}, confidence {{confidence}}): {{observation}} → {{suggestion}}
{{/advisory}}
