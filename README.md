# skill-hub

A collection of standalone skills for AI coding assistants — Claude Code, Cursor, Codex, and Copilot.

Skills work out of the box with no platform dependencies. Each skill is a self-contained `SKILL.md` file with a clear procedure, worked examples, and anti-patterns.

## Install a skill

### Claude Code
```bash
l10x skill install <skill-name>
```

### Manual
Copy the skill directory into your IDE's skills folder:
- Claude Code: `~/.claude/skills/`
- Cursor: `~/.cursor/skills/`
- Codex: `~/.codex/skills/`

## Sync updates

```bash
l10x skill sync
```

## Skills

### SDLC
| Skill | What it does |
|---|---|
| `lets-start-here` | Classify intent and route to the right skill |
| `lets-bootstrap-agents-md` | Generate AGENTS.md from repo evidence |
| `lets-bootstrap-repo` | Bootstrap a new repo with initial structure |
| `lets-develop-feature` | End-to-end feature development |
| `lets-review-code` | Code review with quality checks |
| `lets-review-pr` | Pull request review end-to-end |
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
| `lets-audit-repo` | Audit a repo for quality and standards |
| `lets-author-skill` | Author a new skill |

## letsbe10x augmentation

For letsbe10x runtime augmentation (context pre-flight, governance, pack enrichment), see [skill-overlay](https://github.com/letsbe10x/skill-overlay).
