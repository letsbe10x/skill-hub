# Canonical sources (read first)

This skill is **orchestration only**. Types, renderers, harness, and security corpus are owned elsewhere.

## ux-engine (runtime truth)

| Topic | GitHub source |
|-------|----------------|
| Contracts (`RailMessageV2`, `GeneratedTileSpec`, audit) | [interaction-generative.ts](https://github.com/letsbe10x/ux-engine/blob/main/packages/contracts/src/interaction-generative.ts) |
| `RailMessageRenderer`, `GeneratedTile`, harness | [patterns generative module](https://github.com/letsbe10x/ux-engine/tree/main/packages/patterns/src/generative) |
| Fast-path renderers | [DiffViewRenderer](https://github.com/letsbe10x/ux-engine/blob/main/packages/patterns/src/generative/renderers/DiffViewRenderer.tsx), [SimpleFormRenderer](https://github.com/letsbe10x/ux-engine/blob/main/packages/patterns/src/generative/renderers/SimpleFormRenderer.tsx) |
| Ban-list test corpus | [sandbox-escape.test.ts](https://github.com/letsbe10x/ux-engine/blob/main/packages/patterns/src/__tests__/generative/sandbox-escape.test.ts) |

In a letsbe10x workspace, clone **ux-engine** beside **skills** or consume `@letsbe10x/ux-contracts` / `@letsbe10x/ux-patterns` from the host app.

## ground-truth (product truth)

| Topic | GitHub source |
|-------|----------------|
| Technical PRD | [PRD-163](https://github.com/letsbe10x/ground-truth/blob/main/prds/discovery/prd-163-agentic-conversation-surfaces-technical.md) |
| ADR | [decision-037](https://github.com/letsbe10x/ground-truth/blob/main/decisions/decision-037-agentic-conversation-surfaces.md) |
| Doctrine | [track-2 doctrine](https://github.com/letsbe10x/ground-truth/blob/main/features/agentic-ux-engine/docs/track-2-agentic-conversation-doctrine.md) |
| Stage-10 tasks | [execution plan](https://github.com/letsbe10x/ground-truth/blob/main/features/agentic-ux-engine/plans/stage-10-execution-plan.md) |

## core (planned)

Stage-10 plan places in-process sub-skills in the **core** repo (see execution plan link above). Until those goals ship, agents use this skills-repo workflow plus [`scripts/validate-tile-jsx.py`](../scripts/validate-tile-jsx.py).

## Skill bundle (agent collate layer)

| Path | Role |
|------|------|
| [`assets/component-catalog.yml`](../assets/component-catalog.yml) | Maps intent → schema/renderer path (mirrors `registerCanonical`) |
| [`assets/tile-kind-decision.yml`](../assets/tile-kind-decision.yml) | Classification decision tree |
| [`assets/templates/`](../assets/templates/) | Envelope + metrics-card JSX starters |
| [`references/assembly-from-ux-engine.md`](assembly-from-ux-engine.md) | How showcase/gt-ui wire registry + renderer |

## Related agent skills

| Skill | When |
|-------|------|
| [lets-build-ui](https://github.com/letsbe10x/skills/blob/main/lets-build-ui/SKILL.md) | Changing ux-engine widgets, tokens, or Stage 9 chrome |
| [lets-author-skill](https://github.com/letsbe10x/skills/blob/main/lets-author-skill/SKILL.md) | Changing this skill's bundle or forge gates |
