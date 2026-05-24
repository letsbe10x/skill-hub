# Research bundle

Skills for product, UX, and growth research programs — competitive scans,
content evaluation, UX walkthroughs, PRD grooming, and opportunity discovery.

## Install

```bash
make research                                       # default IDE: claude
make research IDE=cursor                            # single IDE
make research IDE="claude cursor"                   # multiple IDEs
```

## Included skills

| Skill | Purpose |
|---|---|
| `lets-research-competitive-scan` | Battlecard-style competitive landscape scan |
| `lets-research-content-evaluate` | Rubric-based content/messaging evaluation |
| `lets-research-ux-walkthrough` | Click-through UX flow walkthrough with friction log |
| `lets-research-prd-grooming` | PRD refinement and gap analysis |
| `lets-opportunity-discovery` | Surface and rank opportunities from solutions/hypotheses |

## Overlaps

This bundle deliberately overlaps with `pm` (shares `lets-research-prd-grooming`,
`lets-opportunity-discovery`) and `design` (shares `lets-research-ux-walkthrough`,
`lets-research-content-evaluate`). Install whichever matches your work — running
both is harmless (idempotent).

## Suggested companions

- `make pm` if you also write or own PRDs.
- `make design` if you also drive design briefs and UX specs.
