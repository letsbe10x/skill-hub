# Delegation & Handoff Contract — lets-develop-feature

How lets-develop-feature delegates to upstream discovery skills and consumes their output.

## Handoff Declaration Schema

Handoff declarations live in SKILL.md frontmatter under the `handoffs:` key:

```yaml
handoffs:
  - trigger: <signal_id>
    delegate_to: <skill_name>
    artifact_expected: <filename>
    resume_at: <stage_id>
    required: true|false
    mode_override: full|light|null
    depends_on: [<other_trigger_id>]
    context_pass:
      - <context_item>
```

### Field Definitions

| Field | Type | Required | Description |
|---|---|---|---|
| `trigger` | string | yes | Signal ID that activates this handoff (from signal detection) |
| `delegate_to` | string | yes | Skill name to invoke |
| `artifact_expected` | string | yes | Filename the delegated skill must produce |
| `resume_at` | string | yes | Stage ID where lets-develop-feature resumes after receiving artifact |
| `required` | boolean | yes | Can the user skip this delegation? |
| `mode_override` | string | no | Force the delegated skill into a specific mode (e.g., brainstorm Full vs Light) |
| `depends_on` | list[string] | no | Other trigger IDs that must complete first (ordering constraint) |
| `context_pass` | list[string] | no | What context to forward to the delegated skill |

### Context Items

| Item | What gets passed |
|---|---|
| `intent_echo` | The confirmed plain-language intent from Turn 1 |
| `discovery_signals` | The full signal detection results (JSON) |
| `service_context` | Stage 1 service context summary (only if Stage 1 already ran) |
| `upstream_spec` | A previously collected spec artifact (for skills that depend on brainstorm) |

## Artifact Contract

Every delegated skill must produce a Markdown file with this frontmatter:

```yaml
---
artifact_type: <type>
produced_by: <skill_name>
produced_at: <ISO 8601 timestamp>
status: approved|draft
approval_source: user|automated|self-review
---
```

### Artifact Types

| Type | Produced by | Content |
|---|---|---|
| `spec` | lets-brainstorm | Approved feature specification with requirements, acceptance criteria, testing approach |
| `friction-log` | lets-research-ux-walkthrough | UX friction points, severity ratings, flow analysis |
| `comparison` | lets-research-competitive-scan | Competitor feature comparison, positioning, proof points |
| `persona-report` | lets-persona-simulate | Persona evaluation signals, themes, segment breakdowns |
| `requirements` | lets-research-prd-grooming | Structured requirements from raw feedback, ranked opportunities |

### Approval Gate

`lets-develop-feature` will NOT consume an artifact with `status: draft`.

If a delegated skill produces a draft:
1. Surface to user: "The [skill] produced a draft but it hasn't been approved yet."
2. Offer: "Want to review and approve it now, or should I ask [skill] to complete its approval process?"
3. Wait for `status: approved` before proceeding.

## Artifact Storage

```
.lets/runs/develop-feature/<run_id>/
  intake/
    intent-echo.md              # Turn 1 record
    discovery-signals.json      # Signal detection results
    control-level.md            # Chosen control level
    delegation-plan.md          # Which handoffs activated and user's choices
  upstream/
    spec.md                     # From lets-brainstorm
    friction-log.md             # From lets-research-ux-walkthrough (optional)
    comparison.md               # From lets-research-competitive-scan (optional)
    persona-report.md           # From lets-persona-simulate (optional)
    requirements.md             # From lets-research-prd-grooming (optional)
```

## Runtime Execution Protocol

### Step 1: Match signals to handoffs

After Phase 0 Turn 2 signal detection:

```
for each handoff in frontmatter.handoffs:
    if handoff.trigger in active_signals:
        add to triggered_handoffs
```

### Step 2: Resolve dependencies and order

```
topological_sort(triggered_handoffs, key=depends_on)
```

Required handoffs before optional. Within each priority band, respect `depends_on`.

### Step 3: Present delegation plan

Separate required from optional. Present to user. Required items are non-negotiable (explain why).
Optional items are offers ("Would you like me to also...?").

### Step 4: Execute in order

For each confirmed handoff:

1. **Prepare context:** Assemble `context_pass` items into a briefing
2. **Invoke skill:** Pass briefing as the skill's input. Apply `mode_override` if set.
3. **Collect artifact:** Skill produces file in `upstream/` directory
4. **Verify status:** Check `status: approved` in frontmatter
5. **Handle draft:** If status is draft, pause and ask user (see Approval Gate)
6. **Log completion:** Record in `delegation-plan.md`

### Step 5: Resume

After all required (and chosen optional) handoffs complete:
- Determine `resume_at` — use the earliest stage among all completed handoffs
- Announce: "Discovery complete. Moving to [stage name]."
- Proceed to that stage with all upstream artifacts available

## Mode Override Logic

When `mode_override` is null, the delegated skill's mode is influenced by control level:

| Control level | Brainstorm mode | Research depth |
|---|---|---|
| Autonomous | Light | Quick scan |
| Checkpoints | Light (escalates if complex) | Standard |
| Collaborative | Full | Thorough |

When `mode_override` is set, it takes precedence regardless of control level.

## Adding New Handoffs

To register a new upstream skill:

1. Add a signal ID to the detection protocol in `references/INTAKE.md`
2. Add a handoff declaration to SKILL.md frontmatter
3. Ensure the target skill produces artifacts conforming to the artifact contract
4. No changes to SKILL.md body required

This extensibility is the key benefit of declarative handoffs over inline orchestration logic.

## Error Scenarios

| Scenario | Handling |
|---|---|
| Delegated skill not available | Skip if optional; block and explain if required |
| Delegated skill produces no artifact | Treat as failure; ask user how to proceed |
| Artifact missing frontmatter | Warn user; treat as draft until manually approved |
| Circular dependency in depends_on | Reject at parse time; surface as skill configuration error |
| User wants to re-run a delegation | Allow; overwrite previous artifact in upstream/ |
| User provides their own spec mid-Phase-0 | Accept as upstream/spec.md with status: approved, skip brainstorm |
