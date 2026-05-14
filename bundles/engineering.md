# Engineering Bundle

The engineering bundle installs workflows for the full code delivery lifecycle.

## Install

```bash
lets install engineering
lets install engineering --with stack.python
```

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

## Kit compatibility

| Kit | What it adds |
|-----|-------------|
| stack.python | Python typing, import ordering, docstring rules |
| stack.java | Java naming conventions, pattern enforcement |
| platform.frontend | Component structure, accessibility checks |
| domain.healthcare | HIPAA/PHI handling, audit trail requirements |

## Typical flow

```
lets-create-plan → lets-develop-feature → lets-verify-change → lets-review-code
```

## Artifact requirements

When used in a cross-functional workflow (`ship-feature`), engineering
requires these artifacts from upstream personas:

- PRD (from PM)
- Acceptance criteria (from PM)
- Design brief (from Design)
- Risk register (from PgM)
- Release checklist (from PgM)
