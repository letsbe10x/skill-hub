# UX + UI Heuristics Rubric (issue logging)

Use this rubric to produce an actionable issue list with repro notes and severity.
Keep findings concrete (where, what, impact). Separate observation from inference.

## Severity Scale

- **Critical**: blocks task completion, causes severe confusion, or violates accessibility basics.
- **Moderate**: harms conversion/usability, causes repeated friction, or makes key content hard to parse.
- **Minor**: polish issue; does not block completion but reduces perceived quality.

## Categories (log issues against these)

1. **Information hierarchy**
   - Primary CTA obvious?
   - Headings and spacing guide scanning?
2. **Consistency**
   - Tokens consistent (color/spacing/type)?
   - Components follow a single style language?
3. **Affordances + feedback**
   - Buttons look clickable, links look like links?
   - Loading/disabled/active/selected states are clear?
4. **Error prevention + recovery**
   - Forms validate well and explain errors near the field?
   - Clear retry paths for failures?
5. **Accessibility**
   - Keyboard nav works; focus is visible
   - Contrast meets minimum targets
6. **Responsive + touch**
   - No horizontal scroll at mobile widths
   - Touch targets are sufficiently large
7. **Performance + perceived performance**
   - Avoid layout shift; skeletons/spinners when needed
   - No jank on scroll
8. **Content clarity**
   - Copy is concise; empty states explain what to do next
9. **Navigation**
   - Current location is clear; back behavior is predictable
10. **Trust**
   - Pricing clarity, security cues (as appropriate), and reduced surprise
11. **Cognitive load**
    - Too many choices at once; lack of progressive disclosure?
    - Jargon-heavy labels; unclear defaults; unnecessary configuration?
12. **Data flow + states**
    - UI reflects async realities (loading/empty/error/partial)?
    - Failure recovery is clear (retry, undo, permission messaging)?
13. **Onboarding + learnability**
    - New users can reach first success quickly?
    - Empty states teach the next best action?

## Issue Template

For each issue, record:

- **Surface**: page/flow/screen
- **Location**: component/section + selector or component name (if known)
- **Category**: from the list above
- **Severity**: critical/moderate/minor
- **Observation**: what happens (no guesses)
- **Impact**: what user outcome is harmed
- **Fix idea**: 1–2 sentence recommendation (no over-design)
- **Repro notes**: device/viewport, auth state, locale, data conditions
