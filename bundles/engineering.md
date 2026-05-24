# Engineering Bundle

The engineering bundle installs workflows for the full code delivery lifecycle.

## Install

```bash
npx github:letsbe10x/skill-hub install engineering --agent cursor
```

Change `--agent cursor` to `--agent claude-code`, `--agent codex`, or
`--agent copilot`.

## Included workflows

| Workflow | Purpose |
|----------|---------|
| lets-develop-feature | Plan + implement a code change |
| lets-verify-change | Verify implementation against acceptance criteria |
| lets-review-code | Structured code review |
| lets-review-pr | PR-level review with architectural checks |
| lets-onboard-repo | Bootstrap context for a new repository |
| lets-bootstrap-repo | Scaffold repo structure and configuration |
| lets-create-plan | Architecture and implementation planning |

## Typical flow

```
lets-create-plan → lets-develop-feature → lets-verify-change → lets-review-code
```

## Pairs well with

- `repo-readiness` — bootstrap repo context once so the engineering skills run grounded in real facts.
- `pm` — capture the PRD / acceptance criteria the engineering loop verifies against.
