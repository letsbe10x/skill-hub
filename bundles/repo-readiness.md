# Repo Readiness Bundle

Score a repo's AI-assisted development readiness and bootstrap the artifacts
it needs to improve. Aimed at tech leads and staff engineers driving AI
adoption across a codebase.

## Install

```bash
npx github:letsbe10x/skill-hub install repo-readiness --agent cursor
```

Change `--agent cursor` to `--agent claude-code`, `--agent codex`, or
`--agent copilot`.

## Included workflows

| Workflow | Purpose |
|----------|---------|
| lets-onboard-repo | Build a first-time reader map of an unfamiliar repo |
| lets-bootstrap-repo | Scaffold repo structure and AI-readable config |
| lets-bootstrap-agents-md | Generate `AGENTS.md` from repo evidence |
| lets-assess-ai-readiness | 8-pillar readiness assessment with leveled scoring + scaffold plans |

## Typical flow

```
lets-assess-ai-readiness → (review gaps) → lets-bootstrap-repo → lets-bootstrap-agents-md
```

## Suggested companions

- `starter` for the broader first-time-setup flow (includes intent routing).
- `engineering` once the repo is bootstrapped, so the team can start using
  AI in the change-flow.
