# Engineering bundle

Skills for the full code delivery lifecycle — plan, build, verify, review, ship.

## Install

```bash
make engineering                                    # default IDE: claude
make engineering IDE=cursor                         # single IDE
make engineering IDE="claude cursor codex"          # multiple IDEs
```

## Included skills

| Skill | Purpose |
|---|---|
| `lets-create-plan` | Architecture and implementation planning |
| `lets-develop-feature` | Staged feature development with spec alignment and quality scorecard |
| `lets-verify-change` | Verify implementation against acceptance criteria |
| `lets-verify-ready` | Verify a branch is ready to merge |
| `lets-review-code` | Multi-lens code review |
| `lets-review-pr` | PR-level review with architectural checks |
| `lets-spec-to-pr` | Implement a spec end-to-end as a pull request |

## Typical flow

```
lets-create-plan → lets-develop-feature → lets-verify-change → lets-review-code
                                                                      ↓
                                            lets-verify-ready → lets-review-pr
```

## Suggested companions

- Run `make starter` first if you haven't bootstrapped the repo for AI use.
- Run `make readiness` once to score the repo and identify AI-readiness gaps.
