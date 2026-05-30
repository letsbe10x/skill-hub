# Flow spec — recording DSL

The recorder reads a JSON file describing the demo. Each flow has a top-level
config (URL, viewport) and an ordered list of steps. The DSL is intentionally
small; an `evaluate` action and a `.mjs` escape hatch cover anything the JSON
can't express.

## Top-level shape

```json
{
  "url": "http://127.0.0.1:5173",
  "viewport": { "width": 1440, "height": 900 },
  "deviceScaleFactor": 2,
  "colorScheme": "dark",
  "waitUntil": "networkidle",
  "trailingPauseMs": 600,
  "steps": [ ... ]
}
```

| Field | Default | Notes |
|-------|---------|-------|
| `url` | (required) | First URL to navigate. Override at the CLI with `--url`. |
| `viewport` | `{ width: 1440, height: 900 }` | Browser window + video size. |
| `deviceScaleFactor` | `2` | Retina-class for crisp text. Drop to `1` for smaller files. |
| `colorScheme` | `no-preference` | `dark` / `light` / `no-preference`. Sets the `prefers-color-scheme` media feature. |
| `waitUntil` | `networkidle` | Passed to the first `page.goto`. |
| `trailingPauseMs` | `600` | Idle time at the end so the last frame isn't cut off. |
| `steps` | `[]` | Ordered list — see below. |

## Steps reference

Every step has an `action` field. Other fields depend on the action.

### `goto`
Navigate during the flow (in addition to the top-level `url`).
```json
{ "action": "goto", "url": "/skills", "waitUntil": "networkidle" }
```

### `wait`
Pause for a fixed duration. Use this between visible changes so the video has
breathing room.
```json
{ "action": "wait", "ms": 1500 }
```

### `waitForUrl`
Wait until the URL matches (glob pattern, same syntax as Playwright's
`page.waitForURL`).
```json
{ "action": "waitForUrl", "pattern": "**/skills" }
```

### `waitForSelector`
Wait until an element appears.
```json
{ "action": "waitForSelector", "selector": "table tbody tr", "timeoutMs": 10000 }
```

### `scroll`
Smooth scroll to an absolute `y` coordinate over `durationMs`.
```json
{ "action": "scroll", "y": 320, "durationMs": 700 }
```

### `moveMouse`
Move the (invisible) cursor over `steps` interpolation points. Useful for
nudging hover states.
```json
{ "action": "moveMouse", "x": 720, "y": 400, "steps": 20 }
```

### `hover`
Hover an element. Either pass a CSS `selector`, or `role`+`role_options`, or
`text`. `nth` selects from a multi-match locator.
```json
{ "action": "hover", "selector": "table tbody tr", "nth": 0 }
```

### `click`
Click an element. Same locator rules as `hover`. `button` defaults to `"left"`,
`clickCount` to `1`.
```json
{ "action": "click", "selector": "a[href='/skills']" }
```
```json
{ "action": "click", "role": "link", "role_options": { "name": "Skills" } }
```

### `type`
Clear the field, then type `text` with `delayMs` between keystrokes (defaults
to 40ms — slow enough to look human in the video).
```json
{ "action": "type", "selector": "input[type='search']", "text": "lets-build-ui", "delayMs": 40 }
```

### `press`
Press a key (or chord).
```json
{ "action": "press", "key": "Enter" }
{ "action": "press", "key": "Meta+K" }
```

### `screenshot`
Save a still frame to disk during the recording. Doesn't pause the video.
```json
{ "action": "screenshot", "path": "/tmp/checkpoint.png", "fullPage": false }
```

### `evaluate`
Run arbitrary JavaScript in the page context. Last-resort escape hatch.
```json
{ "action": "evaluate", "script": "document.querySelector('.toast').remove()" }
```

## Locator priority

When more than one of `selector` / `role` / `text` is present, the order is:
**role > text > selector**. Combine with `nth` to disambiguate multi-match.

## JavaScript escape hatch

For flows the JSON DSL can't express (multi-window, file uploads, drag-drop,
network interception, etc.), pass a `.mjs` file as `--flow`:

```js
// my-demo.flow.mjs
export default async function (page, { smoothScrollTo, log }) {
  await page.goto("http://127.0.0.1:5173", { waitUntil: "networkidle" });
  await page.waitForTimeout(1500);
  await smoothScrollTo(page, 400, 700);
  // ...full Playwright Page API available
}
```

The recorder calls your default export with the Playwright `page` and a small
helper set. The video is recorded across the whole call.

## Timing tips

- **Pause 1–1.5s** after every navigation so the page settles visually.
- **Pause 400–600ms** after a hover so the hover state is visible in the
  video.
- **Pause 800ms+ before a click** that triggers an animation, then **wait
  for the result** with `wait` or `waitForSelector`.
- **End with `trailingPauseMs: 600`** so the encoder doesn't cut off the
  final frame.
- Target **15–30s total** for a PR demo. Longer than 45s and reviewers
  scrub instead of watching.

## Anti-patterns

- **Selectors tied to React-internal class names** (`__cls_a1b2c3`) — they
  change on every build. Prefer `role` + accessible name, `data-testid`,
  or stable semantic selectors.
- **No `wait` between hover and click** — the hover frame won't render in
  the video.
- **`networkidle` on an app with long-polling / websockets** — use
  `domcontentloaded` instead.
- **Top-level `url` on production** without explicit user consent.
