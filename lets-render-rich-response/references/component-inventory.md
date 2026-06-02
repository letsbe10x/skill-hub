# Component inventory (skill bundle)

Human index for [`assets/component-catalog.yml`](../assets/component-catalog.yml). Update the YAML when ux-engine adds registry schemas; keep this file as a one-screen summary.

| catalog_id | kind | schema | Host render | Sandbox |
|------------|------|--------|-------------|---------|
| diff-view | structured | diff-view@1.0.0 | DiffViewRenderer | no |
| simple-form | structured | simple-form@1.0.0 | SimpleFormRenderer | no |
| generated-tile | generated | — | GeneratedTile + harness | allow-scripts only |
| text-fallback | text | — | TextRenderer | no |

**Registration:** only `diff-view` and `simple-form` ship in `registerCanonical`. Custom structured schemas require the host to `registry.register(...)` before emit.

**Payload validation:**

| schema | JSON schema |
|--------|-------------|
| diff-view | [`assets/schemas/diff-view-payload.schema.json`](../assets/schemas/diff-view-payload.schema.json) |
| simple-form | [`assets/schemas/simple-form-payload.schema.json`](../assets/schemas/simple-form-payload.schema.json) |

**Assembly detail:** [`assembly-from-ux-engine.md`](assembly-from-ux-engine.md).
