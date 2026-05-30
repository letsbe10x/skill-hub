# UI State Patterns (required coverage)

Any surface you touch should have these states (where applicable):

## Loading

- Show skeleton/progress if > ~300ms.
- Reserve space to avoid layout shift.
- Keep UI responsive; avoid blocking input where possible.

## Empty

- Explain why it’s empty.
- Provide a next action (create/import/filter reset).
- Avoid “blank screens”.

## Error

- Show what failed in user language.
- Provide recovery (retry, contact support, fallback).
- For forms: errors adjacent to the field with actionable copy.
