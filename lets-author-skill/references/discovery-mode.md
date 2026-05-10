# Discovery Mode

Use discovery mode when skill creation should start with research instead of drafting.

## When To Use It

Switch into discovery mode before touching skill files when the request involves:

- brainstorming or idea generation
- market or open-source landscape research — "how are others doing this?"
- architecture, design, or workflow comparison
- "what should we build?" rather than "write the skill now"
- a new skill that might overlap with existing skills in skill-hub or the target repo

This mode is especially useful when the right solution shape is still unclear, or when a new skill might compete with an existing one.

## Source Policy

Discovery mode uses both local and external evidence.

**Local evidence — always inspect:**
- adjacent skills in skill-hub with a similar shape or trigger family
- the `skill-shapes.md` chooser for existing patterns
- install and packaging surfaces used by neighboring skills
- any existing trigger fixtures or boundary datasets near the proposed boundary

**External evidence — use when the user asks for landscape research:**

Prefer in order:
1. official docs for the tool, framework, or workflow in question
2. primary-source repos and maintained examples
3. package registries and release pages
4. high-signal technical writeups from maintainers

Be explicit about dates and source quality. Separate observed facts from inferences or recommendations for the target repo.

For tool-oriented or integration-heavy skills, answer these explicitly:
1. is there already a mature CLI?
2. is there already a mature SDK?
3. if both exist, which should the skill prefer and why?
4. if neither exists, is a new skill still the right surface?

## Default Research Flow

1. Define the research question
2. Map local priors — adjacent skills and existing boundaries
3. Check existing CLIs and SDKs
4. Survey external comparables
5. Extract recurring patterns
6. Build options for the skill-hub context
7. Recommend the best approach
8. Only then draft or update the skill

## Output Contract

Produce a short research brief before implementation. The brief includes:

- problem framing
- local skill-hub context and adjacent skills
- external comparables
- architecture/approach options
- recommendation
- proposed skill boundary
- eval and validation impact
- open questions

Add one explicit section: "Why this should be a new skill instead of a wrapper around an existing tool, a reusable helper, or an update to a neighboring skill."

## Decision Rule

If the recommendation has non-obvious tradeoffs, pause after the brief and ask for confirmation before broad implementation.

If the user clearly wants both research and implementation in one pass, proceed from the brief into implementation and summarize which assumptions were confirmed vs inferred.

If external research shows a stable existing tool or workflow already solves most of the job, default to wrapping or adapting that surface instead of inventing a large new local abstraction.
