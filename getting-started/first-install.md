# Your first install

skill-hub installs via plain `make` — no extra CLI required.

## 1. Pick your IDE

Supported: `claude` (default), `cursor`, `codex`, `copilot`. Multiple IDEs
can be installed in one go.

```bash
make help
```

## 2. Bootstrap your repo

Run `starter` first to install the routing + bootstrap skills.

```bash
make starter                                        # default: claude
make starter IDE="claude cursor"                    # multiple IDEs
```

## 3. Install the bundle for your role

```bash
make engineering           # for engineers
make pm                    # for PMs
make design                # for designers / UXR
make research              # for researchers
make readiness             # for tech leads driving AI adoption
```

Or install a single skill:

```bash
make lets-develop-feature
```

## 4. (Optional) Install everything

```bash
make all IDE="claude cursor codex copilot"
```

## What just happened?

- **Skill** = a single `lets-<name>/` directory copied into your IDE's skills folder.
- **Bundle** = a Make target that installs several related skills in one command.
- **IDE flag** = `IDE="claude cursor"` controls where each skill is copied; one
  install per IDE listed.

## Where skills go

| IDE | Install path |
|---|---|
| claude | `~/.claude/skills/` |
| cursor | `~/.cursor/skills/` |
| codex | `~/.codex/skills/` |
| copilot | `~/.github/skills/` |

Override any of these with `CLAUDE_SKILLS_DIR=…` (etc.), or force a single path
with `LETS_SKILLS_DIR=/some/path`.

## Next steps

- Browse [bundles/README.md](../bundles/README.md) for what each bundle contains.
- Add your own skill — see the *Contributing* section of the [root README](../README.md).
