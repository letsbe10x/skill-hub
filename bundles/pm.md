# PM Bundle

The PM bundle installs workflows for product requirements and opportunity analysis.

## Install

```bash
npx github:letsbe10x/skill-hub install pm --agent cursor
```

Change `--agent cursor` to `--agent claude-code`, `--agent codex`, or
`--agent copilot`.

## Included workflows

| Workflow | Purpose |
|----------|---------|
| lets-brainstorm | Structured ideation and problem framing |
| lets-opportunity-discovery | Market opportunity identification |
| lets-research-prd-grooming | PRD refinement and gap analysis |

## Artifacts produced

| Artifact | Used by |
|----------|---------|
| PRD | Design, Engineering, Review |
| Problem statement | Design |
| Success metrics | Verify |
| Acceptance criteria | Engineering, Verify, Review |
| Opportunity map | Engineering planning |

## Typical flow

```
lets-brainstorm → lets-opportunity-discovery → lets-research-prd-grooming
```

## Pairs well with

- `design` — consume PRDs to produce design briefs and UX flows.
- `engineering` — turn PRDs + acceptance criteria into shipped code.
- `research` — broader research toolkit (competitive scan, UX, content evaluation).
