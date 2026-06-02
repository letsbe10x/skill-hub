# Validate generated tile JSX

## Table of contents

1. [Run the gate](#run-the-gate)
2. [Ban list (canonical)](#ban-list-canonical)
3. [Structural checks](#structural-checks)
4. [On failure](#on-failure)

## Run the gate

**Always** validate before publish:

```bash
python3 scripts/validate-tile-jsx.py \
  --jsx "$(cat tile.jsx)" \
  --spec tile-spec.json
```

Or `--jsx-file` / `--spec-file`. Exit `0` = pass; non-zero = reject.

Do not rely on manual regex in chat — the script is the agent-local gate until `rich-response-validate` ships in core.

## Ban list (canonical)

Mirrors `hasBannedConstruct` in [sandbox-escape.test.ts](https://github.com/letsbe10x/ux-engine/blob/main/packages/patterns/src/__tests__/generative/sandbox-escape.test.ts):

| Id | Construct |
|----|-----------|
| V4 / B2 | `eval(` |
| V5 / B1 | `dangerouslySetInnerHTML` |
| V3 | `Function(` |
| V4b | dynamic `import(` |
| V6 / B5 | `<script` or `createElement('script'` |
| V7 / B6 | `<iframe` or nested iframe element |
| V8 / B7 | `document.write(` |
| V9 / B8 | `window.location =` |
| V10 / B9 | `__proto__` |
| V11 / B10 | `Object.defineProperty(` |

Harness/sandbox vectors V1–V3, V12 are enforced at render time in ux-engine (CSP, sandbox attribute, handshake) — not re-checked in this script.

## Structural checks

After ban list:

1. Non-empty trimmed `jsx`
2. Starts with `React.createElement(`
3. Balanced `(` and `)`
4. No angle-bracket JSX (`/<[A-Z]/` or `/>`)
5. If `bridge.dispatchAction` appears → `declaredActions.length >= 1`
6. If `bridge.fetch` appears → `allowlist.fetchUrls` non-empty

## On failure

```json
{
  "valid": false,
  "violations": [{ "check": "B2", "message": "eval()" }]
}
```

Do **not** publish. Emit prose `RailTextMessage` and host `recordValidationFailure` with `reason` from the first violation (see [`publish-artifact.md`](publish-artifact.md)).
