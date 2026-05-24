# skill-hub

A collection of standalone skills for AI coding assistants — Claude Code, Cursor, Codex, and GitHub Copilot.

Skills work out of the box with no platform dependencies. Each skill is a self-contained `SKILL.md` file with a clear procedure, worked examples, and anti-patterns.

## Install

Use `make` from a checkout of this repo. Every command accepts an optional `IDE=` flag — space-separated list of IDEs to install into.

```bash
make help                                           # list all skills and bundles
```

### Install a single skill

```bash
make lets-develop-feature                           # default: claude
make lets-develop-feature IDE=cursor                # specific IDE
make lets-develop-feature IDE="claude cursor"       # multiple IDEs at once
```

### Install a bundle (curated group)

```bash
make engineering                                    # 7 skills for code delivery
make pm IDE=cursor                                  # 3 skills for PM work
make engineering pm IDE="claude codex"              # 2 bundles, 2 IDEs
make all IDE="claude cursor codex copilot"          # everything, everywhere
```

### Supported IDEs and install paths

| IDE      | Default path             | Override variable        |
|----------|--------------------------|--------------------------|
| claude   | `~/.claude/skills/`      | `CLAUDE_SKILLS_DIR`      |
| cursor   | `~/.cursor/skills/`      | `CURSOR_SKILLS_DIR`      |
| codex    | `~/.codex/skills/`       | `CODEX_SKILLS_DIR`       |
| copilot  | `~/.github/skills/`      | `COPILOT_SKILLS_DIR`     |

Set `LETS_SKILLS_DIR=/some/path` to force every IDE to install into the same directory.

## Bundles

| Bundle | Persona | Skills | Doc |
|---|---|---|---|
| starter | First-time user | 4 | [bundles/starter.md](bundles/starter.md) |
| engineering | Engineer | 7 | [bundles/engineering.md](bundles/engineering.md) |
| pm | Product manager | 3 | [bundles/pm.md](bundles/pm.md) |
| design | Designer / UXR | 2 | [bundles/design.md](bundles/design.md) |
| research | Researcher | 5 | [bundles/research.md](bundles/research.md) |
| readiness | Tech lead | 3 | [bundles/readiness.md](bundles/readiness.md) |

## Skills

### SDLC
| Skill | What it does |
|---|---|
| `lets-start-here` | Classify intent and route to the right skill |
| `lets-bootstrap-agents-md` | Generate AGENTS.md from repo evidence |
| `lets-bootstrap-repo` | Bootstrap a new repo with initial structure |
| `lets-develop-feature` | Staged feature development with spec-alignment, graduated rigor, and quality scorecard |
| `lets-review-code` | Multi-lens code review with planner-driven depth, finding verification, and confidence scoring |
| `lets-review-pr` | PR review controlplane with context discovery, multi-lens routing, spec alignment, and GitHub posting |
| `lets-verify-change` | Verify a change meets requirements |
| `lets-verify-ready` | Verify a branch is ready to merge |
| `lets-spec-to-pr` | Implement a spec as a pull request |
| `lets-create-plan` | Create a structured implementation plan |
| `lets-brainstorm` | Explore ideas and options |
| `lets-onboard-repo` | Onboard a new repo with context |

### Research
| Skill | What it does |
|---|---|
| `lets-research-content-evaluate` | Evaluate content quality and effectiveness |
| `lets-research-competitive-scan` | Scan the competitive landscape |
| `lets-research-ux-walkthrough` | Walkthrough UX flows and identify improvements |
| `lets-research-prd-grooming` | Groom and refine PRDs |
| `lets-opportunity-discovery` | Discover opportunities in market or product data |

### Meta
| Skill | What it does |
|---|---|
| `lets-assess-ai-readiness` | Assess a repo's AI-assisted development readiness across 8 pillars with leveled scoring and scaffold plans |

## Contributing

1. Create a directory named `lets-<your-skill>/` with a `SKILL.md` file.
2. The skill must be **platform-neutral** — no CLI references, no runtime dependencies. Platform-specific hooks belong in [skill-overlay](https://github.com/letsbe10x/skill-overlay).
3. Include YAML frontmatter with at minimum: `name`, `description`, `metadata.author`, `metadata.version`, `lifecycle`, `compatibility.agents`.
4. Validate with `forge check lets-<name>/SKILL.md` (from a skill-forge checkout).
5. Add a target for the new skill in the `Makefile`. If it belongs to a bundle, also add it to that bundle's `*_SKILLS` variable.
6. Open a PR. CI runs `forge check` on all changed skills.

### Overlay composition

skill-hub provides clean base skills. Runtime augmentation (context pre-flight, governance checks, pack enrichment) is injected via [skill-overlay](https://github.com/letsbe10x/skill-overlay) at sync time using anchor-based composition. See the overlay repo for details.
