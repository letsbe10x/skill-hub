# Workflow Bundles

Bundles group related workflows so users can choose a practical starter set.
They are documentation-level groupings in this standalone repo: install them by
copying the listed skill directories or by using the `Makefile` targets.

## Available bundles

| Bundle | Purpose | Starter install |
|--------|---------|---------|
| engineering | Code delivery, review, verification | `make sdlc PLATFORM=cursor` |
| pm | PRDs, acceptance criteria, opportunities | `make research PLATFORM=cursor` |
| design | Design briefs, UX flows, content | `make lets-research-ux-walkthrough lets-research-content-evaluate PLATFORM=cursor` |

Change `PLATFORM=cursor` to `claude-code`, `codex`, or `copilot`.

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

- [engineering.md](engineering.md) — Code delivery workflows
- [pm.md](pm.md) — Product management workflows
- [design.md](design.md) — Design workflows
