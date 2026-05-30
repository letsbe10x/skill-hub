# Remediation Patterns

Common gap types and their standard remediation steps for use with `lets-audit-repo`.

## Pattern: Missing AGENTS.md

**Gap**: No `AGENTS.md` found in module directory.
**Remediation**: Create `<module>/AGENTS.md` with at minimum: purpose, owner, and allowed
  dependency directions. See `src/letsbe10x/engine/AGENTS.md` as a reference.

## Pattern: Stale context pack

**Gap**: Context pack has not been refreshed within the configured TTL.
**Remediation**: Run `lets context authoring bootstrap` to rebuild. If adapters are missing,
  run `lets adapter test <name>` to diagnose.

## Pattern: No governance policy file

**Gap**: `governance/` directory is missing or contains no policy files.
**Remediation**: Run `lets govern init` (if available) or create a minimal policy file at
  `governance/policies/base.yaml`.

## Pattern: Import layer violation

**Gap**: A lower-layer module imports from a higher-layer module.
**Remediation**: Refactor to use lazy in-function imports (approved exception pattern) or
  move the shared logic to the correct layer. See `CLAUDE.md` critical invariants.

## Pattern: Missing test coverage

**Gap**: A module has no corresponding test file under `tests/`.
**Remediation**: Create `tests/test_<module>.py` with at minimum a smoke test for the
  module's public API.
