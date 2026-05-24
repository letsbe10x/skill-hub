# skill-hub

Evidence-gated workflow skills for AI coding assistants.

`skill-hub` gives Claude Code, Cursor, Codex, Copilot, and other Agent Skills-compatible tools a disciplined engineering operating model: start from intent, create the right spec or plan, implement carefully, verify with fresh evidence, review findings, and only then call work ready.

These are plain Agent Skills. You do **not** need the `lets` CLI to use them.

## Why This Exists

AI coding agents often fail in predictable ways:

- They start coding before the requirement is clear.
- They invent repo facts instead of checking evidence.
- They claim tests pass without running them.
- They make broad changes when a narrow slice would do.
- They review code without verifying findings against the actual diff.

`skill-hub` packages the workflows that prevent those failures. Each skill is a self-contained directory with a `SKILL.md` entrypoint and, when needed, `references/` or `scripts/` loaded on demand.

## Quick Install

Pick the skills you want and copy each skill directory into your agent's skills directory.

| Agent | User-level skills directory | Project-level skills directory |
|---|---|---|
| Claude Code | `~/.claude/skills/` | `.claude/skills/` |
| Cursor | `~/.cursor/skills/` | `.cursor/skills/` |
| Codex | `~/.codex/skills/` | `.codex/skills/` |
| Copilot | `~/.github/skills/` | `.github/skills/` |

Example:

```bash
# Cursor user-level install
mkdir -p ~/.cursor/skills
cp -R lets-start-here ~/.cursor/skills/
cp -R lets-verify-ready ~/.cursor/skills/
cp -R lets-review-code ~/.cursor/skills/
```

Install everything for a specific platform with `make`:

```bash
# Default: Claude Code
make all

# Cursor
make all PLATFORM=cursor

# Codex
make all PLATFORM=codex

# Copilot
make all PLATFORM=copilot
```

## Start Here

If you are unsure which skill to use, install and invoke:

| Skill | Use when |
|---|---|
| `lets-start-here` | You want the agent to classify the task and route to the right workflow |

For most engineering work, a good starter set is:

```bash
make lets-start-here lets-create-plan lets-develop-feature lets-verify-change lets-verify-ready lets-review-code PLATFORM=cursor
```

## What Can It Do?

| User intent | Skill |
|---|---|
| "Where should I start?" | `lets-start-here` |
| "Make this repo AI-ready" | `lets-bootstrap-repo` |
| "Generate or refresh AGENTS.md" | `lets-bootstrap-agents-md` |
| "Assess how ready this repo is for AI coding" | `lets-assess-ai-readiness` |
| "Think through this idea before coding" | `lets-brainstorm` |
| "Create an implementation plan" | `lets-create-plan` |
| "Implement this feature/change" | `lets-develop-feature` |
| "Implement this approved spec as a PR" | `lets-spec-to-pr` |
| "Verify this implementation is complete" | `lets-verify-change` |
| "Before saying done, prove it" | `lets-verify-ready` |
| "Review this code" | `lets-review-code` |
| "Review this PR" | `lets-review-pr` |
| "Find product opportunities" | `lets-opportunity-discovery` |
| "Groom this PRD from evidence" | `lets-research-prd-grooming` |
| "Compare competitors" | `lets-research-competitive-scan` |
| "Evaluate copy or messaging" | `lets-research-content-evaluate` |
| "Walk through a UX flow and log friction" | `lets-research-ux-walkthrough` |

## Suggested Skill Sets

### Engineering

For code delivery from plan through review:

| Skill | What it does |
|---|---|
| `lets-start-here` | Classify intent and route to the right workflow |
| `lets-create-plan` | Turn requirements into a step-by-step implementation plan |
| `lets-develop-feature` | Implement changes with staged execution and evidence gates |
| `lets-verify-change` | Verify implementation against requirements, tests, and smoke checks |
| `lets-verify-ready` | Block completion claims until fresh verification output exists |
| `lets-review-code` | Run multi-lens code review with verified findings |
| `lets-review-pr` | Review pull requests with diff context, spec alignment, and verdicts |
| `lets-spec-to-pr` | Implement an approved spec through PR creation |

### Repo Readiness

For making an existing repo easier and safer for AI agents:

| Skill | What it does |
|---|---|
| `lets-onboard-repo` | Build a first-time reader map of an unfamiliar repo |
| `lets-bootstrap-repo` | Capture maintainer-confirmed service truth and readiness context |
| `lets-bootstrap-agents-md` | Generate evidence-backed AGENTS.md files for module hierarchies |
| `lets-assess-ai-readiness` | Score repo readiness across feedback, determinism, safety, context, and recovery pillars |

### Product And Research

For product strategy, PRDs, UX, and messaging:

| Skill | What it does |
|---|---|
| `lets-brainstorm` | Turn unresolved ideas into validated spec artifacts |
| `lets-opportunity-discovery` | Rank opportunities from a solution, hypothesis, or research corpus |
| `lets-research-prd-grooming` | Transform feedback into PRD deltas, criteria, and open questions |
| `lets-research-competitive-scan` | Compare competitor positioning, pricing, proof, and CTAs |
| `lets-research-content-evaluate` | Evaluate copy or messaging against a rubric and audience |
| `lets-research-ux-walkthrough` | Walk through a UX flow and produce a friction log |

## Full Catalog

| Skill | Status | Notes |
|---|---|---|
| `lets-start-here` | Published | Entry router |
| `lets-bootstrap-agents-md` | Published | Repo documentation generation |
| `lets-bootstrap-repo` | Published | Repo context bootstrap |
| `lets-develop-feature` | Published | Implementation workflow |
| `lets-review-code` | Published | Code review |
| `lets-review-pr` | Published | Pull request review |
| `lets-verify-change` | Published | Implementation verification |
| `lets-verify-ready` | Published | Completion evidence gate |
| `lets-spec-to-pr` | Published | Claude Code-oriented spec-to-PR workflow |
| `lets-create-plan` | Published | Implementation planning |
| `lets-onboard-repo` | Published | Repo onboarding |
| `lets-assess-ai-readiness` | Published | AI-readiness maturity assessment |
| `lets-brainstorm` | Draft | Idea/spec exploration |
| `lets-opportunity-discovery` | Draft | Opportunity ranking |
| `lets-research-prd-grooming` | Draft | PRD evolution |
| `lets-research-competitive-scan` | Draft | Competitive scan |
| `lets-research-content-evaluate` | Draft | Content evaluation |
| `lets-research-ux-walkthrough` | Draft | UX walkthrough |

## Contributing

1. Create a directory named `lets-<your-skill>/` with a `SKILL.md` file.
2. Keep the skill platform-neutral. Do not require a specific agent runtime inside the base skill unless the skill truly depends on it.
3. Include YAML frontmatter with at minimum `name`, `description`, `metadata.author`, `metadata.version`, and `compatibility.agents`.
4. Keep the main `SKILL.md` focused. Put long templates, rubrics, and examples under `references/`.
5. Validate with `skill-forge` before opening a PR.

## Optional: Using The lets CLI

The skills in this repository are plain folders and work without the `lets` CLI.

If you do use the `lets` CLI, the experience can become smoother because `pack.toml` lets a runtime install and sync the skills as a bundle, apply overlays, and enforce organization policy.

```bash
# Install from a local checkout when using letsbe10x tooling
lets plugin install .
```

Runtime augmentation such as context pre-flight, governance checks, and pack enrichment belongs in [skill-overlay](https://github.com/letsbe10x/skill-overlay). This repo stays the clean, portable base skill library.
