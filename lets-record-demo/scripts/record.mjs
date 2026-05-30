#!/usr/bin/env node
// Generic Playwright recorder for lets-record-demo.
//
// Drives a headless Chromium through a declarative flow spec (JSON) and
// writes a .webm. If --out ends in .mov / .mp4 / .gif, the script also
// invokes scripts/convert.sh to produce the requested format.
//
// Usage:
//   node record.mjs --flow <path.json|path.mjs> --out <path.{webm,mov,mp4,gif}>
//                   [--url <override>] [--quiet]
//
// JSON flow schema: see ../references/flow-spec.md.
// JS escape-hatch: a .mjs flow exports `default async function(page, helpers)`.

import { spawnSync } from "node:child_process";
import { existsSync, mkdirSync, readFileSync, renameSync, rmSync, statSync } from "node:fs";
import { dirname, extname, resolve, basename } from "node:path";
import { pathToFileURL } from "node:url";

const HOME = process.env.HOME || process.env.USERPROFILE || "";
const TOOLS_DIR = process.env.LETS_RECORD_DEMO_HOME || `${HOME}/.letsbe10x/tools/record-demo`;
const SCRIPT_DIR = dirname(new URL(import.meta.url).pathname);

const args = (() => {
  const out = {};
  const argv = process.argv.slice(2);
  for (let i = 0; i < argv.length; i++) {
    const a = argv[i];
    if (!a.startsWith("--")) continue;
    const eqIdx = a.indexOf("=");
    if (eqIdx > -1) {
      out[a.slice(2, eqIdx)] = a.slice(eqIdx + 1);
    } else {
      const next = argv[i + 1];
      if (next !== undefined && !next.startsWith("--")) {
        out[a.slice(2)] = next;
        i++;
      } else {
        out[a.slice(2)] = true;
      }
    }
  }
  return out;
})();

if (args.help || (!args.flow && !args.h)) {
  console.log(`Usage: node record.mjs --flow <path> --out <path> [--url <override>] [--quiet]

Required:
  --flow <path>   Flow spec (.json) or JavaScript flow (.mjs).
  --out  <path>   Output path. Extension determines format:
                  .webm = raw Playwright capture, no conversion
                  .mov  = H.264 + faststart (PR-friendly, default)
                  .mp4  = H.264 + faststart
                  .gif  = palette-quantized gif (no audio)

Optional:
  --url <url>     Override the flow's "url" field.
  --quiet         Suppress per-step log lines.
`);
  process.exit(args.help ? 0 : 1);
}

const FLOW_PATH = resolve(args.flow);
const OUT_PATH = resolve(args.out || `${process.env.PWD || "."}/demo.mov`);
const OUT_EXT = extname(OUT_PATH).toLowerCase();
const KEEP_WEBM = OUT_EXT === ".webm";
const WEBM_PATH = KEEP_WEBM ? OUT_PATH : OUT_PATH.replace(/\.[^.]+$/, ".webm");
const VIDEO_DIR = `${dirname(WEBM_PATH)}/._record-demo-${process.pid}`;

if (!existsSync(FLOW_PATH)) {
  console.error(`[record] flow not found: ${FLOW_PATH}`);
  process.exit(2);
}

if (!existsSync(`${TOOLS_DIR}/node_modules/playwright/package.json`)) {
  console.error(`[record] playwright not installed under ${TOOLS_DIR}`);
  console.error(`[record] run: bash ${SCRIPT_DIR}/setup.sh`);
  process.exit(3);
}

// Lazy-import Playwright from the tools dir.
const pwUrl = pathToFileURL(`${TOOLS_DIR}/node_modules/playwright/index.mjs`).href;
const { chromium } = await import(pwUrl);

mkdirSync(dirname(OUT_PATH), { recursive: true });
if (existsSync(VIDEO_DIR)) rmSync(VIDEO_DIR, { recursive: true, force: true });
mkdirSync(VIDEO_DIR, { recursive: true });

// --- Load flow ---------------------------------------------------------------
let flow;
let jsFlow = null;
if (FLOW_PATH.endsWith(".mjs") || FLOW_PATH.endsWith(".js")) {
  jsFlow = (await import(pathToFileURL(FLOW_PATH).href)).default;
  if (typeof jsFlow !== "function") {
    console.error(`[record] JS flow must export a default async function(page, helpers)`);
    process.exit(2);
  }
  flow = { url: args.url, viewport: { width: 1440, height: 900 } };
} else {
  flow = JSON.parse(readFileSync(FLOW_PATH, "utf8"));
}
if (args.url) flow.url = args.url;

const viewport = flow.viewport || { width: 1440, height: 900 };
const deviceScaleFactor = flow.deviceScaleFactor ?? 2;
const colorScheme = flow.colorScheme || "no-preference";
const log = args.quiet ? () => {} : (...a) => console.log("[record]", ...a);

log(`flow=${FLOW_PATH}`);
log(`out=${OUT_PATH}`);
log(`viewport=${viewport.width}x${viewport.height} scale=${deviceScaleFactor} colorScheme=${colorScheme}`);

// --- Helpers ----------------------------------------------------------------
async function smoothScrollTo(page, targetY, durationMs = 600) {
  await page.evaluate(
    ([target, dur]) => {
      return new Promise((done) => {
        const start = window.scrollY;
        const delta = target - start;
        const t0 = performance.now();
        function step(now) {
          const t = Math.min(1, (now - t0) / dur);
          const eased = 0.5 - Math.cos(Math.PI * t) / 2;
          window.scrollTo(0, start + delta * eased);
          if (t < 1) requestAnimationFrame(step);
          else done(undefined);
        }
        requestAnimationFrame(step);
      });
    },
    [targetY, durationMs],
  );
}

function locatorFor(page, step) {
  if (!step.selector) throw new Error(`step "${step.action}" requires "selector"`);
  let loc = step.role
    ? page.getByRole(step.role, step.role_options || {})
    : step.text
      ? page.getByText(step.text)
      : page.locator(step.selector);
  if (typeof step.nth === "number") loc = loc.nth(step.nth);
  return loc;
}

// --- Recording session -------------------------------------------------------
const browser = await chromium.launch({ headless: true });
const context = await browser.newContext({
  viewport,
  deviceScaleFactor,
  colorScheme: colorScheme === "no-preference" ? null : colorScheme,
  recordVideo: { dir: VIDEO_DIR, size: viewport },
});
const page = await context.newPage();

try {
  if (flow.url) {
    log(`goto ${flow.url}`);
    await page.goto(flow.url, { waitUntil: flow.waitUntil || "networkidle" });
  }

  if (jsFlow) {
    await jsFlow(page, { smoothScrollTo, log });
  } else {
    for (const [i, step] of (flow.steps || []).entries()) {
      const tag = `${i + 1}/${flow.steps.length} ${step.action}`;
      switch (step.action) {
        case "goto":
          log(`${tag} ${step.url}`);
          await page.goto(step.url, { waitUntil: step.waitUntil || "networkidle" });
          break;
        case "wait":
          log(`${tag} ${step.ms}ms`);
          await page.waitForTimeout(step.ms ?? 500);
          break;
        case "waitForUrl":
          log(`${tag} ${step.pattern}`);
          await page.waitForURL(step.pattern);
          break;
        case "waitForSelector":
          log(`${tag} ${step.selector}`);
          await page.waitForSelector(step.selector, { timeout: step.timeoutMs ?? 30000 });
          break;
        case "scroll":
          log(`${tag} y=${step.y} dur=${step.durationMs ?? 600}`);
          await smoothScrollTo(page, step.y ?? 0, step.durationMs ?? 600);
          break;
        case "moveMouse":
          log(`${tag} (${step.x},${step.y})`);
          await page.mouse.move(step.x, step.y, { steps: step.steps ?? 20 });
          break;
        case "hover":
          log(`${tag} ${step.selector}`);
          await locatorFor(page, step).hover();
          break;
        case "click":
          log(`${tag} ${step.selector}`);
          await locatorFor(page, step).click({
            button: step.button || "left",
            clickCount: step.clickCount || 1,
          });
          break;
        case "type":
          log(`${tag} ${step.selector}`);
          await locatorFor(page, step).fill("");
          await locatorFor(page, step).type(step.text ?? "", { delay: step.delayMs ?? 40 });
          break;
        case "press":
          log(`${tag} ${step.key}`);
          await page.keyboard.press(step.key);
          break;
        case "screenshot":
          log(`${tag} ${step.path}`);
          await page.screenshot({ path: step.path, fullPage: !!step.fullPage });
          break;
        case "evaluate":
          log(`${tag} (eval)`);
          await page.evaluate(step.script);
          break;
        default:
          throw new Error(`unknown action: ${step.action}`);
      }
    }
  }

  const trailing = flow.trailingPauseMs ?? 600;
  if (trailing > 0) await page.waitForTimeout(trailing);
} catch (err) {
  await context.close();
  await browser.close();
  rmSync(VIDEO_DIR, { recursive: true, force: true });
  console.error(`[record] failed: ${err.message}`);
  process.exit(4);
}

const video = page.video();
await context.close();
await browser.close();

if (!video) {
  rmSync(VIDEO_DIR, { recursive: true, force: true });
  console.error(`[record] no video produced (recordVideo not active?)`);
  process.exit(5);
}

const raw = await video.path();
renameSync(raw, WEBM_PATH);
rmSync(VIDEO_DIR, { recursive: true, force: true });
const size = statSync(WEBM_PATH).size;
log(`wrote ${WEBM_PATH} (${(size / 1024).toFixed(1)} KB)`);

// --- Optional conversion ----------------------------------------------------
if (!KEEP_WEBM) {
  const convert = `${SCRIPT_DIR}/convert.sh`;
  if (!existsSync(convert)) {
    console.error(`[record] convert.sh not found at ${convert}`);
    process.exit(6);
  }
  log(`convert -> ${OUT_PATH}`);
  const r = spawnSync("bash", [convert, WEBM_PATH, OUT_PATH], { stdio: "inherit" });
  if (r.status !== 0) {
    console.error(`[record] conversion failed (exit ${r.status})`);
    process.exit(r.status || 7);
  }
  const outSize = statSync(OUT_PATH).size;
  log(`wrote ${OUT_PATH} (${(outSize / 1024).toFixed(1)} KB)`);
}

console.log(`\n[record] ✓ done`);
console.log(`  webm: ${WEBM_PATH}`);
if (!KEEP_WEBM) console.log(`  out:  ${OUT_PATH}`);
