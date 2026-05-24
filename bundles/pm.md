# PM bundle

Skills for product requirements, opportunity analysis, and PRD grooming.

## Install

```bash
make pm                                             # default IDE: claude
make pm IDE=cursor                                  # single IDE
make pm IDE="claude cursor"                         # multiple IDEs
```

## Included skills

| Skill | Purpose |
|---|---|
| `lets-brainstorm` | Structured ideation and problem framing |
| `lets-opportunity-discovery` | Surface and rank market opportunities |
| `lets-research-prd-grooming` | PRD refinement and gap analysis |

## Typical flow

```
lets-brainstorm → lets-opportunity-discovery → lets-research-prd-grooming
```

## Suggested companions

- `make research` adds competitive scanning, UX walkthroughs, and content evaluation.
- `make design` adds UX flow + content review skills used downstream of PRDs.
