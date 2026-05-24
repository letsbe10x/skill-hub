# Your First Install

`skill-hub` is a plain Agent Skills repository. You can install skills by copying
the skill folders into your agent's skills directory.

## 1. Choose A Starter Set

For code delivery, start with the engineering skills:

```bash
npx github:letsbe10x/skill-hub install engineering --agent cursor
```

Change `--agent cursor` to `--agent claude-code`, `--agent codex`, or
`--agent copilot` as needed.

For a project-local install:

```bash
npx github:letsbe10x/skill-hub install engineering --agent cursor --scope project
```

## 2. Or Copy Manually

```bash
mkdir -p ~/.cursor/skills
cp -R lets-start-here ~/.cursor/skills/
cp -R lets-create-plan ~/.cursor/skills/
cp -R lets-develop-feature ~/.cursor/skills/
cp -R lets-verify-change ~/.cursor/skills/
cp -R lets-verify-ready ~/.cursor/skills/
cp -R lets-review-code ~/.cursor/skills/
```

## 3. Start Working

In your agent chat, invoke `lets-start-here` first if you are not sure which
workflow applies. It routes the task to the right skill.

## What just happened?

- **Skill** = one workflow directory with a `SKILL.md` entrypoint.
- **Starter set** = a practical group of skills installed together.
- **Workflow** = a goal-oriented process such as plan, verify, review, or develop.

## Checking what's installed

```bash
ls ~/.cursor/skills
```

Use the equivalent skills directory for your agent.

## Next steps

- Try a review with `lets-review-code`.
- Add repo-readiness skills like `lets-assess-ai-readiness`.
- See all bundles: [bundles/README.md](../bundles/README.md)
