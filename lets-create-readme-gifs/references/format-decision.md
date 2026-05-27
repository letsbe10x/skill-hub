# Format Decision

Picking the right format is a one-time call that determines re-rendering
cost, file size, sharpness, and how the README looks on mobile.

## Decision tree

1. **Does the demo show a terminal session?**
   - Yes → **VHS GIF** (default) or **Animated SVG** (if file-size matters more than format-compatibility).
   - No → go to 2.
2. **Does the demo show a desktop GUI or web app interaction?**
   - Yes → **Hosted MP4** (CDN-served, embedded via `<video>` or YouTube/Vimeo).
   - No → go to 3.
3. **Is the project's primary value visible at all without animation?**
   - Yes → **Static PNG screenshot** (centered, captioned).
   - No → the project may not need a hero demo. Lead with a code block or a logo.

## Format comparison

| Property | VHS GIF | Animated SVG | Hosted MP4 | Static PNG |
|---|---|---|---|---|
| **Deterministic** | ✅ yes (script → bytes) | ✅ yes | ⚠ depends on tool | ✅ |
| **Re-renderable from source** | ✅ `vhs *.tape` | ✅ `svg-term *.cfg` | ⚠ requires re-recording | ✅ if from script |
| **Text sharpness** | medium | ✅ vector — crisp at any zoom | high (codec-dependent) | ✅ |
| **File size (10-15s loop)** | 150–500KB | 30–80KB | 1–5MB (host on CDN) | <100KB |
| **Auto-plays on GitHub** | ✅ | ✅ | ❌ requires click | n/a |
| **Auto-plays on mobile** | ✅ | ✅ | ⚠ depends | n/a |
| **Has audio** | ❌ | ❌ | ✅ | ❌ |
| **Maximum runtime that feels right above-the-fold** | ~15s | ~30s | ~60s (with controls) | static |
| **Tooling** | `vhs` + `ttyd` + `ffmpeg` | `svg-term-cli` (npm) | OBS/Loom/QuickTime + ffmpeg | `freeze`, screenshot tool |
| **Tracked in git** | ✅ (under 1MB) | ✅ always | ❌ CDN-host | ✅ |

## When to pick each

**VHS GIF** — the default. Pick this unless you have a specific reason not to.
The toolchain is one `brew install` away, the file lives in the repo, and
every major terminal-tool README in the field has converged on it (`gum`,
`mods`, `vhs`, `lazygit`, `lazydocker`, `httpie`, `starship`). Used by ~14 of
the 15 verified GIF-led READMEs in the field study.

**Animated SVG** — when:
- The demo is text-heavy (lots of long output lines that need to stay crisp).
- The repo cares about `git clone` size (you're shipping a 30KB svg vs a
  300KB gif).
- You're modeling on `aider`, which uses this format brilliantly.

The trade-off: the toolchain (`svg-term-cli`) is less standard than VHS, and
contributors may not know how to regenerate.

**Hosted MP4** — when:
- The demo is a desktop/web UI interaction (Excalidraw drawing, Supabase
  dashboard, Cal.com booking flow). Terminal tools rarely need this.
- The runtime is longer than ~15s (a real product walkthrough).
- You need audio (almost never useful for a README demo, but possible).

Host on the project's CDN or YouTube/Vimeo. Embed via `<video>` for inline
playback or a thumbnail+link for external. Do **not** check 5MB MP4s into
git — clones get heavy fast.

**Static PNG screenshot** — when:
- The project has nothing interesting to animate (`bat` showing syntax
  highlighting, `tldr` showing a man-page rewrite — both are PNG-only for
  good reason).
- You want the repo to feel "settled" / mature — animation can read as
  noisy in some contexts.

Tooling: `freeze` (charm.sh) for code/terminal-style PNGs with proper
fonts; Snipping tools for UI captures.

## Anti-patterns

- **Screen-recording your own terminal with LICEcap or Kap.** Fonts get
  fuzzy, you can't update without re-recording, no way to script.
  Pick VHS or animated SVG instead.
- **Mixing formats in the same README.** One hero artifact, one format.
- **Linking to a YouTube video as the only hero** ("click here to watch the
  demo"). Loses the auto-play moment that makes readers stay.
- **Using `<picture>` only for dark-mode/light-mode swaps when one image
  works fine.** Adds maintenance burden without value.
