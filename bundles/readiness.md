# Readiness bundle

Score a repo's AI-assisted development readiness and bootstrap the artifacts
it needs to improve. Aimed at tech leads and staff engineers driving AI
adoption across a codebase.

## Install

```bash
make readiness                                      # default IDE: claude
make readiness IDE=cursor                           # single IDE
make readiness IDE="claude cursor"                  # multiple IDEs
```

## Included skills

| Skill | Purpose |
|---|---|
| `lets-assess-ai-readiness` | 8-pillar readiness assessment with leveled scoring + scaffold plans |
| `lets-bootstrap-agents-md` | Generate `AGENTS.md` from repo evidence |
| `lets-bootstrap-repo` | Scaffold repo structure and AI-readable config |

## Typical flow

```
lets-assess-ai-readiness → (review gaps) → lets-bootstrap-repo → lets-bootstrap-agents-md
```

## Suggested companions

- `make starter` for the broader first-time-setup flow (includes intent routing
  and onboarding).
- `make engineering` once the repo is bootstrapped, so the team can start using
  AI in the change-flow.
