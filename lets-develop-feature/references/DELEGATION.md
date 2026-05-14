# Delegation — lets-develop-feature

Extended reference for upstream skill handoffs. Read SKILL.md Phase 0 section first.

## Handoff Contract

When delegating to an upstream skill, pass:
- The confirmed intent (what the user wants)
- Active discovery signals (what you detected)

When receiving an artifact back, check:
- YAML frontmatter with `status: approved` — if draft, ask user to approve
- If skill failed or is unavailable — fall back to inline discovery

## Artifact Frontmatter (expected from upstream skills)

```yaml
---
artifact_type: spec|friction-log|comparison|persona-report|requirements
produced_by: <skill_name>
produced_at: <ISO 8601>
status: approved|draft
approval_source: user|self-review
---
```

## Graceful Degradation

| Condition | Behavior |
|---|---|
| Required skill unavailable | Use inline discovery (ask user directly) |
| Optional skill unavailable | Skip, note it, proceed |
| Skill produces draft (not approved) | Ask user: "Approve this, or should I ask different questions?" |
| Skill fails mid-run | Explain, offer inline fallback |
| User provides their own spec | Accept directly, skip delegation |

## Adding New Upstream Skills

To register a new upstream skill in the handoff declarations:
1. Add a signal to the detection checklist in INTAKE.md
2. Add a handoff entry in SKILL.md frontmatter
3. Ensure the skill produces artifacts with the frontmatter above
4. No SKILL.md body changes required
