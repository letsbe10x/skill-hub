# Starter bundle

First-time setup. Routes intent and bootstraps the AI context a repo needs to be
productive with the other skills.

## Install

```bash
make starter                                        # default IDE: claude
make starter IDE=cursor                             # single IDE
make starter IDE="claude cursor"                    # multiple IDEs
```

## Included skills

| Skill | Purpose |
|---|---|
| `lets-start-here` | Classify intent and route to the right skill |
| `lets-onboard-repo` | Onboard a repo and build initial context |
| `lets-bootstrap-repo` | Scaffold repo structure and AI-readable config |
| `lets-bootstrap-agents-md` | Generate `AGENTS.md` from repo evidence |

## When to install

Run this once per new machine or new repo. Other bundles assume you already
have the bootstrap pieces in place, but starter is **not** auto-included —
install it explicitly to keep each bundle's contract predictable.

## Typical flow

```
lets-start-here → lets-onboard-repo → lets-bootstrap-repo → lets-bootstrap-agents-md
```

## Suggested next bundle

After `starter`, install the bundle that matches your role: `engineering`,
`pm`, `design`, `research`, or `readiness`.
