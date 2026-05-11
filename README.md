# skill-hub

A collection of standalone skills for AI coding assistants — Claude Code, Cursor, Codex, and Copilot.

Skills work out of the box with no platform dependencies. Each skill is a self-contained `SKILL.md` file with a clear procedure, worked examples, and anti-patterns.

## Install a skill

### Claude Code
```bash
lets skill install <skill-name>
```

### Manual
Copy the skill directory into your IDE's skills folder:
- Claude Code: `~/.claude/skills/`
- Cursor: `~/.cursor/skills/`
- Codex: `~/.codex/skills/`

## Sync updates

```bash
lets skill sync
```

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
| `lets-audit-repo` | Audit a repo for quality and standards |
| `lets-author-skill` | Author a new skill |

## Contributing

1. Create a directory named `lets-<your-skill>/` with a `SKILL.md` file.
2. The skill must be **platform-neutral** — no `l10x` CLI references, no runtime
   dependencies. Platform-specific hooks belong in
   [skill-overlay](https://github.com/letsbe10x/skill-overlay).
3. Include YAML frontmatter with at minimum: `name`, `description`, `metadata.author`,
   `metadata.version`, `lifecycle`, `compatibility.agents`.
4. Validate with `forge check lets-<name>/SKILL.md` (from a skill-forge checkout).
5. Open a PR. CI runs `forge check` on all changed skills.

### Overlay composition

skill-hub provides clean base skills. Runtime augmentation (context pre-flight,
governance checks, pack enrichment) is injected via
[skill-overlay](https://github.com/letsbe10x/skill-overlay) at sync time using
anchor-based composition. See the overlay repo for details.

## letsbe10x augmentation

For letsbe10x runtime augmentation (context pre-flight, governance, pack enrichment), see [skill-overlay](https://github.com/letsbe10x/skill-overlay).
