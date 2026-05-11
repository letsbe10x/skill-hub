# Root AGENTS.md Template — lets-bootstrap-agents-md

## Frontmatter (required)

```yaml
---
last_compiled_date: "YYYY-MM-DD"
version: "1.0.0"
---
```

Increment version on every regeneration. `last_compiled_date` is the date Phase 6 writes the file.

## Line budget

**Maximum 200 lines.** Content budget test for every line:

> "Would removing this line cause an agent to make a mistake?"

If the answer is no, cut it.

## Stable anchors

- Reference code by **path + symbol** (e.g. `src/engine/goals/registry.py::GoalRegistry`)
- Never reference line numbers — they drift on every commit
- Never include implementation code blocks — link to source instead

## Required sections

| # | Section | Purpose | Content guidance |
|---|---------|---------|-----------------|
| 1 | Project Overview | Orient the agent in < 30 seconds | Entry points (CLI, API, main), project structure table (top-level dirs only) |
| 2 | Architecture | Mental model of how pieces connect | One diagram — mermaid, ascii, or indented tree. Choose by repo shape: monolith → layers, microservice → boundaries, library → public surface |
| 3 | Technology Stack | What to assume is available | Core stack inline (language, framework, package manager). Full inventory in `docs/tech-stack.md` if > 5 deps |
| 4 | Build and Development Commands | How to work locally | Four subsections: setup, run, build, lint/format. VERIFIED commands only. One-line each |
| 5 | Testing | How to validate changes | Test command, test structure (dirs), coverage expectations, verify-before-commit command |
| 6 | Critical Coding Rules | Highest-impact constraints | 3-7 bullets only. Each must be backed by evidence (failing CI, architectural invariant, or ≥ 3 file occurrences). Link to `docs/coding-rules.md` for the full set |
| 7 | Boundaries and Safety Gates | What agents must not do | Three columns: Allowed (no confirmation), Ask-first (need user approval), Never-do (hard block) |
| 8 | Decision-Making Guidance | Optional: situational routing | "If you need to..." table mapping scenarios to actions/commands |
| 9 | Anti-Patterns and Tribal Knowledge | Optional: gotchas | Known footguns, HACK/FIXME-derived warnings, things that look wrong but are intentional |

## Section ordering rules

1. Sections 1-7 are mandatory. Sections 8-9 are optional (include only if evidence exists).
2. Order is fixed — agents scan top-down and expect this layout.
3. If a section would be empty after evidence filtering, include the heading with a single line: `<!-- no evidence-backed content for this section -->`.

## Diagram format selection

| Repo shape | Preferred format | Example |
|---|---|---|
| Layered monolith (≤ 6 layers) | ASCII box diagram | `core → platform → sdlc → engine` |
| Multi-service / workspace | Indented tree with arrows | Directory tree with dependency arrows |
| Library with public API | Table: module → exported surface | `module \| public symbols \| consumers` |
| Complex (> 10 interconnected modules) | Mermaid flowchart | `graph TD; A-->B; B-->C` |

## Content rules

- No prose paragraphs — tables and bullet lists only
- Commands must come from `command-catalog.json` with status VERIFIED
- PLAUSIBLE commands may appear in Decision-Making Guidance only, marked with `(unverified)`
- Every coding rule must cite its source: `[invariant: AGENTS.md#engine]` or `[pattern: 3+ files]`
- Technology stack lists runtime deps only — no dev tooling unless it affects agent behavior
