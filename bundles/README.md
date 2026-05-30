# Workflow Bundles

Bundles group related workflows so users can choose a practical starter set.
They are documentation-level groupings in this standalone repo: install them by
using the `npx` installer or by copying skill directories manually.

## Available bundles

| Bundle | Purpose | Install |
|--------|---------|---------|
| starter | First-time setup — intent routing + repo bootstrap | `npx github:letsbe10x/skill-hub install starter --agent cursor` |
| engineering | Code delivery, review, verification | `npx github:letsbe10x/skill-hub install engineering --agent cursor` |
| sdlc | Engineering subset focused on the change loop | `npx github:letsbe10x/skill-hub install sdlc --agent cursor` |
| pm | PRDs, acceptance criteria, opportunities | `npx github:letsbe10x/skill-hub install pm --agent cursor` |
| design | Design briefs, UX flows, content | `npx github:letsbe10x/skill-hub install design --agent cursor` |
| research | Competitive scan, content eval, UX, PRD grooming, opportunities | `npx github:letsbe10x/skill-hub install research --agent cursor` |
| repo-readiness | Score + bootstrap a repo for AI readiness, plus governance audit | `npx github:letsbe10x/skill-hub install repo-readiness --agent cursor` |
| ui | Build + capture evidence for UIs (`lets-build-ui` + `lets-browser-evidence`) | `npx github:letsbe10x/skill-hub install ui --agent cursor` |
| all | Every skill in the repo | `npx github:letsbe10x/skill-hub install all --agent cursor` |

Change `--agent cursor` to `--agent claude-code`, `--agent codex`, or
`--agent copilot`.

## Manual install

```bash
mkdir -p ~/.cursor/skills
cp -R lets-start-here ~/.cursor/skills/
cp -R lets-create-plan ~/.cursor/skills/
```

## Bundle composition

When you install a bundle manually:

1. Pick the bundle doc.
2. Copy each listed skill directory into your agent's skills directory.
3. Restart or reload the agent if your host requires it.
4. Invoke the skill by name or let the agent select it from context.

## Per-bundle docs

- [starter.md](starter.md) — First-time setup
- [engineering.md](engineering.md) — Code delivery workflows
- [pm.md](pm.md) — Product management workflows
- [design.md](design.md) — Design workflows
- [research.md](research.md) — Cross-functional research workflows
- [repo-readiness.md](repo-readiness.md) — AI-readiness assessment + bootstrap
- [ui.md](ui.md) — Build + verify UIs with evidence
