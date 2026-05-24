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

Install a bundle with `npx`:

```bash
npx github:letsbe10x/skill-hub install engineering --agent cursor
```

For a project-local install, add `--scope project`:

```bash
npx github:letsbe10x/skill-hub install engineering --agent cursor --scope project
```

You can also install one skill:

```bash
npx github:letsbe10x/skill-hub install lets-verify-ready --agent cursor
```

Supported agents:

| Agent | User-level skills directory | Project-level skills directory |
|---|---|---|
| Claude Code | `~/.claude/skills/` | `.claude/skills/` |
| Cursor | `~/.cursor/skills/` | `.cursor/skills/` |
| Codex | `~/.codex/skills/` | `.codex/skills/` |
| Copilot | `~/.github/skills/` | `.github/skills/` |

For local development from a checkout, run:

```bash
npx . install engineering --agent cursor
```

Manual copy still works:

```bash
mkdir -p ~/.cursor/skills
cp -R lets-start-here ~/.cursor/skills/
cp -R lets-verify-ready ~/.cursor/skills/
cp -R lets-review-code ~/.cursor/skills/
```

## Start Here

If you are unsure which skill to use, install and invoke:

| Skill | Use when |
|---|---|
| `lets-start-here` | You want the agent to classify the task and route to the right workflow |

For most engineering work, a good starter set is:

```bash
npx github:letsbe10x/skill-hub install engineering --agent cursor
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
5. Validate the `SKILL.md` frontmatter parses as YAML and the file renders cleanly in any markdown viewer before opening a PR.

## Going Further — The `lets` CLI (Optional)

Everything in this repo works as plain Agent Skills with no CLI required. If you want more than copy-and-paste — repeatable installs, drift detection, a knowledge base bound to your repo, and curated bundles — there is a separate, optional companion CLI called `lets` (PyPI package `letsbe10x`) that consumes this repository and adds the management layer around it.

**What `lets` adds on top of skill-hub:**

| Capability | What you get | Command |
|---|---|---|
| **Repo bootstrapping** | One command that scores your repo's AI-readiness and recommends the next steps | `lets init` then `lets repo launchpad` |
| **Knowledge base** | Builds and maintains a verified context pack about your repo (modules, commands, conventions) so skills run grounded in real facts instead of guesses | `lets init` |
| **Skill management** | Tracks every installed skill, detects when an installed skill has drifted from its upstream source, and re-syncs on demand | `lets status`, `lets sync` |
| **Curated bundles** | Browse and install grouped skill sets without remembering names | `lets catalog list`, `lets catalog bundles` |
| **Health checks** | One-shot diagnostic of runtime + installed skills + pending drift | `lets doctor` |

**Install:**

```bash
pipx install letsbe10x   # canonical
# or
pip install letsbe10x

lets doctor --quickstart  # verify install + next steps
```

`skill-hub` itself stays a clean, portable Agent Skills library with no dependency on `lets`. You can use the skills with Claude Code, Cursor, Codex, Copilot, or any other Agent Skills–compatible tool, with or without the CLI.
