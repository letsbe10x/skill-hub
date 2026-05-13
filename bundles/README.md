# Workflow Bundles

Bundles group related workflows for one-command installation.

## Available bundles

| Bundle | Purpose | Install |
|--------|---------|---------|
| engineering | Code delivery, review, verification | `lets install engineering` |
| pm | PRDs, acceptance criteria, opportunities | `lets install pm` |
| design | Design briefs, UX flows, content | `lets install design` |
| pgm | Milestones, risks, release planning | `lets install pgm` |

## Customizing with kits

Kits add domain-specific Rules/Guardrails to a bundle:

```bash
lets install engineering --with stack.python
lets install engineering --with domain.healthcare
```

See `lets kit status` for enabled kits.

## Bundle composition

When you install a bundle, the runtime:

1. Resolves all member workflows (skills)
2. Resolves requested kits and their dependencies
3. Writes a deterministic lockfile
4. Installs skills to your agent host

Kits compose through an 8-layer fixed order — later layers can tighten
policy but never loosen it.

## Per-bundle docs

- [engineering.md](engineering.md) — Code delivery workflows
- [pm.md](pm.md) — Product management workflows
- [design.md](design.md) — Design workflows
