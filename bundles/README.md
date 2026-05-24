# Bundles

Bundles group related skills for one-command installation. A bundle is just a Make
target that installs each of its member skills — every skill is also installable
on its own.

## Available bundles

| Bundle | Persona | Install |
|---|---|---|
| [starter](starter.md) | First-time user | `make starter` |
| [engineering](engineering.md) | Engineer | `make engineering` |
| [pm](pm.md) | Product manager | `make pm` |
| [design](design.md) | Designer / UXR | `make design` |
| [research](research.md) | Researcher | `make research` |
| [readiness](readiness.md) | Tech lead | `make readiness` |

## Compose bundles and IDEs

Bundle targets compose freely with each other and with the `IDE=` flag:

```bash
make engineering                                    # 1 bundle, claude (default)
make engineering IDE=cursor                         # 1 bundle, 1 IDE
make engineering pm IDE="claude codex"              # 2 bundles, 2 IDEs
make all IDE="claude cursor codex copilot"          # everything, everywhere
```

`make all` installs every skill in the repo (the union of every bundle, deduped).

## How bundles work

1. Bundle membership lives in the `Makefile` as a single source of truth
   (`STARTER_SKILLS := …`, `ENGINEERING_SKILLS := …`, etc).
2. A bundle target declares those skills as Make dependencies — installing the
   bundle just installs each skill, once per IDE in `IDE=`.
3. Skills can belong to multiple bundles. Installing both bundles re-runs the
   copy for the shared skill, which is idempotent.
4. Every skill is **always** available as its own target, whether or not it
   appears in any bundle.

## Adding a new bundle

1. Define `MY_BUNDLE_SKILLS := lets-foo lets-bar` near the other bundle
   variables in the `Makefile`.
2. Add a target: `my-bundle: $(MY_BUNDLE_SKILLS)`.
3. Add `my-bundle` to the `.PHONY` declaration.
4. Add `$(MY_BUNDLE_SKILLS)` to the `ALL_SKILLS` union.
5. Create `bundles/my-bundle.md` with persona, member list, and typical flow.
6. Link it from this README's bundle table.
