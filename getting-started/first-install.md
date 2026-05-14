# Your first install

## 1. Install a bundle

```bash
lets install engineering
```

This installs workflows for code delivery, review, and verification.

## 2. (Optional) Add a kit

```bash
lets install engineering --with stack.python
```

Kits add language-specific or domain-specific rules/guardrails.

## 3. Start working

```bash
lets develop-feature
```

## What just happened?

- **Bundle** = group of workflows installed together
- **Kit** = rules/guardrails that customize behavior for your stack
- **Workflow** = a goal-oriented skill (review, verify, develop)

## Checking what's installed

```bash
lets kit status
```

Shows your installed bundles, enabled kits, and lock hash.

## Next steps

- Add more kits: `lets kit enable domain.healthcare --on engineering`
- Try a review: `lets review-code`
- See all bundles: [bundles/README.md](../bundles/README.md)
