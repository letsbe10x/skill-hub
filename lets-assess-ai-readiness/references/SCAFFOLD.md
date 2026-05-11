# Scaffold — lets-assess-ai-readiness

## Operating Principles

1. **Plan-first** — always show what will be created/changed before doing it
2. **Additive-only** — never delete or overwrite existing files without explicit confirmation
3. **Idempotent** — re-running produces same result; skips already-present artifacts
4. **Safe** — no secrets, no production mutations, no destructive operations
5. **Minimal** — scaffold only what's needed to clear blockers, nothing more

---

## Scaffold by Target Level

### Target L1 (Functional)

Minimum viable AI operation. Agent can build and run something.

| Blocker | Scaffold action |
|---------|----------------|
| No test command discoverable | Add test target to build surface (Makefile/package.json/pyproject.toml) |
| No lockfile | Generate lockfile from manifest (language-specific) |
| No formatter configured | Add formatter config (detect ecosystem, apply default) |
| No setup command | Add setup/install target to build surface |
| No README with commands | Add README skeleton with setup + test + build commands |

### Target L2 (Documented)

Agent has explicit guidance on what to do and not touch.

| Blocker | Scaffold action |
|---------|----------------|
| No agent guidance | Generate AGENTS.md skeleton (invoke `lets-bootstrap-agents-md` if full generation wanted) |
| No .env.example | Generate .env.example from .env references in code (sanitized) |
| No coding rules documented | Generate docs/coding-rules.md from linter config + patterns |
| CI doesn't block merge | Add required status check recommendation (document, don't mutate GitHub) |
| No scoped test execution | Document how to run tests for a single file/module |

### Target L3 (Standardized)

Agent can validate quickly, follow enforced patterns, operate in clear boundaries.

| Blocker | Scaffold action |
|---------|----------------|
| Formatter not in CI | Add format check step to CI workflow |
| Linter not in CI | Add lint step to CI workflow |
| No pattern guide | Generate "Adding a New X" guide from analogous implementations |
| No boundary enforcement | Recommend import restriction rules (don't auto-configure) |
| Test convention inconsistent | Document the target convention; flag deviations as advisory |
| No container config | Generate docker-compose.yml or devcontainer.json skeleton |

### Target L4 (Optimized)

Fast feedback, unambiguous errors, safe scope, cheap recovery.

| Blocker | Scaffold action |
|---------|----------------|
| No layered test targets | Add distinct unit/integration/e2e targets to build surface |
| No feature flags | Recommend feature flag framework (don't auto-install) |
| No dependency graph tooling | Recommend tooling for ecosystem |
| No progressive deploy | Document canary/rollback strategy |
| Docs stale | Flag stale docs for refresh (don't auto-rewrite) |

### Target L5 (Autonomous)

Minimal supervision. Self-healing. Zero-state bootstrap.

L5 scaffolding is primarily recommendations and checklists, not generated files:
- Recommend hermetic build configuration
- Recommend automated rollback on error-rate spike
- Recommend incremental validation tooling
- Recommend docs-as-tests approach
- Recommend impact analysis tooling

---

## Scaffold Templates

Templates live in `assets/templates/`. They are ecosystem-aware — the scaffold engine detects the ecosystem and selects the appropriate variant.

### Ecosystem Detection → Template Selection

| Signal | Ecosystem | Template variant |
|--------|-----------|-----------------|
| `pyproject.toml` or `setup.py` | Python | python/ |
| `package.json` | Node/TypeScript | node/ |
| `go.mod` | Go | go/ |
| `Cargo.toml` | Rust | rust/ |
| `pom.xml` or `build.gradle` | JVM | jvm/ |
| None of the above | Generic | generic/ |

### Template Variables

Templates use `{variable}` placeholders. Common variables:

| Variable | Source |
|----------|--------|
| `{repo_name}` | basename of repo root |
| `{test_command}` | discovered from build surface |
| `{build_command}` | discovered from build surface |
| `{lint_command}` | discovered from linter config |
| `{format_command}` | discovered from formatter config |
| `{language}` | detected primary language |
| `{package_manager}` | detected package manager |

---

## Scaffold Plan Format

Present to user before applying:

```
## Scaffold Plan — Target L{n}

**Blockers addressed:** {count}
**Files to create:** {count}
**Files to modify:** {count}
**Estimated time:** {minutes} min

| # | Action | Path | What changes |
|---|--------|------|-------------|
| 1 | create | README.md | Add quickstart with build/test/lint commands |
| 2 | create | .env.example | Document required environment variables |
| 3 | modify | Makefile | Add `test-unit` and `lint` targets |
| 4 | create | AGENTS.md | Skeleton agent guidance |

### Not scaffolded (manual action required)
- Enable branch protection on default branch (GitHub settings)
- Configure required status checks (GitHub settings)
- Review and verify generated AGENTS.md content

Apply? (yes / modify / cancel)
```

---

## Rules

- Never scaffold secrets (use placeholders: `YOUR_API_KEY_HERE`)
- Never modify GitHub/platform settings (recommend only)
- Never auto-install dependencies (document the command)
- Never overwrite existing files without `--force` or explicit confirmation
- Always show the plan before applying
- Mark scaffolded content as `TODO: Review and customize` where appropriate
- Scaffolded files are starting points, not verified documentation — they do NOT count toward readiness score until human review
