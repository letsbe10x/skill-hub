# Stacked PR Guide — lets-develop-feature

How to decompose large changes into reviewable, independently-mergeable slices.

## When to Use Stacked PRs

Use stacked PRs when ANY of:
- Total change > 500 LOC
- Change spans > 10 files
- Change has natural layers (schema → logic → API → UI)
- Multiple independent features bundled in one task
- Reviewer would struggle to hold full context in one review

## Slice Principles

### 1. Each Slice is Coherent

A slice must:
- Be independently reviewable (reviewer can understand it alone)
- Pass all tests when applied on top of its dependencies
- Not introduce dead code (every line has a purpose at merge time)
- Have a clear one-sentence description

### 2. Bottom-Up Ordering

```
Slice 1 (bottom): Types, schemas, contracts (foundation)
Slice 2: Business logic, services (uses foundations)
Slice 3: API endpoints, handlers (uses services)
Slice 4 (top): Integration, wiring, tests (connects everything)
```

Merge order: bottom-up. Each slice builds on the previous.

### 3. Independent Verifiability

Each slice must have:
- Its own verification command
- Tests that pass with just that slice applied
- No forward references to later slices

## Slice Identification

### Natural Boundaries

| Boundary | Slice content |
|----------|---------------|
| **Data layer** | New models, schema changes, migrations |
| **Domain logic** | Business rules, services, validation |
| **Interface layer** | API routes, controllers, handlers |
| **Integration** | External service clients, queue consumers |
| **Configuration** | Feature flags, env vars, config files |
| **Tests** | Test infrastructure, fixtures, helpers |

### Example Decomposition

Task: "Add billing endpoint with invoice generation"

```
Slice 1 — Foundation (types + schema)
  - src/models/invoice.py (new model)
  - migrations/003_add_invoices.py
  - tests/test_models.py (model tests)
  
Slice 2 — Domain logic
  - src/services/billing.py (invoice generation logic)
  - tests/test_billing.py (unit tests)
  
Slice 3 — API endpoint
  - src/api/routes/billing.py (endpoint handler)
  - tests/test_api_billing.py (integration tests)
  
Slice 4 — Integration + wiring
  - src/api/__init__.py (register route)
  - config/features.yaml (feature flag)
  - tests/test_e2e_billing.py (e2e test)
```

## Branch Management

```bash
# Create stacked branches
git checkout main
git checkout -b feat/billing-1-models

# ... implement slice 1, commit ...
git push -u origin feat/billing-1-models

git checkout -b feat/billing-2-services
# ... implement slice 2, commit ...
git push -u origin feat/billing-2-services

git checkout -b feat/billing-3-api
# ... implement slice 3, commit ...
git push -u origin feat/billing-3-api
```

### PR Creation

```bash
# Each PR targets the previous slice (not main)
gh pr create --base main --head feat/billing-1-models --title "feat(billing): add invoice model and migration"
gh pr create --base feat/billing-1-models --head feat/billing-2-services --title "feat(billing): add invoice generation service"
gh pr create --base feat/billing-2-services --head feat/billing-3-api --title "feat(billing): add billing API endpoint"
```

### After Bottom PR Merges

When a lower slice merges to main, rebase upper slices:

```bash
git checkout feat/billing-2-services
git rebase main
git push --force-with-lease

git checkout feat/billing-3-api
git rebase feat/billing-2-services
git push --force-with-lease
```

## Execution Packet Integration

When using stacked PRs, the execution packet should note:

```markdown
### Slice Plan

| Slice | Branch | Content | Base |
|-------|--------|---------|------|
| 1 | feat/billing-1-models | Models + migration | main |
| 2 | feat/billing-2-services | Business logic | slice-1 |
| 3 | feat/billing-3-api | API endpoint + wiring | slice-2 |

### Per-Slice Work Packages
[Group work packages by slice]
```

## Anti-patterns

- **Circular dependencies between slices** — if slice 3 needs something from slice 1 that doesn't exist yet, the ordering is wrong
- **Dead code in lower slices** — don't add code in slice 1 that only has callers in slice 3; put it in slice 3
- **Mega slice + tiny slices** — if one slice is 400 LOC and others are 20 LOC, rebalance
- **Testing only in the top slice** — each slice must have its own tests that pass independently
- **Tight coupling across slices** — if changing slice 1 requires changing slice 2, they should be one slice
