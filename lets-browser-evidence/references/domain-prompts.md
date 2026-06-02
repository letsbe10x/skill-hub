# Domain prompt patterns (copy into Webwright run or slash commands)

Use with `/webwright:run` (one-shot) or `/webwright:craft` (reusable CLI). Standalone CLI: see SKILL.md Commands.

Always include: base URL, auth state, read-only default, and “no real PII or production credentials.”

## UI audit (lets-build-ui discovery)

```text
Audit the app at BASE_URL (AUTH_STATE).
For each listed surface:
  Screenshot at viewport widths 375, 768, 1024, 1440 (height 1800).
  Capture loading, empty, and error states if reachable without destructive actions.
Write plan.md critical points and check them off.
Save artifacts under WORKSPACE_DIR per the workspace contract.
```

## UX walkthrough (lets-research-ux-walkthrough)

```text
Walk the journey from ENTRY_PATH to SUCCESS_CONDITION at BASE_URL (AUTH_STATE).
At each step: screenshot, note expected vs actual, stop on blockers.
Output step list suitable for a friction log (category, severity, repro).
Read-only: do not complete purchases or submit real user data.
```

## Journey smoke (core journeys / ship gate)

```text
Craft a reusable CLI that proves journey "JOURNEY_NAME":
  start START_STATE, success SUCCESS_CONDITION, steps from the brief.
  Flags: --base-url (default BASE_URL), --viewport-width.
  Print success signal to final_script_log.txt.
  Screenshot at each constraint-relevant step.
```

## Post-change regression

```text
Run again the existing final_script.py (or repo e2e) against BASE_URL.
Compare screenshots and log tail to the paths in the browser evidence brief.
Fail the run if success datum is missing.
```

## Competitive capture (read-only, public pages only)

```text
Capture public marketing/pricing pages at BASE_URL for listed competitors.
Screenshots + short structured notes (positioning, CTA, pricing visible).
No login, no paywalls bypass, no scraping behind auth.
```
