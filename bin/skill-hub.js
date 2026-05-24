#!/usr/bin/env node

const fs = require("fs");
const os = require("os");
const path = require("path");

const repoRoot = path.resolve(__dirname, "..");

const bundles = {
  all: [
    "lets-start-here",
    "lets-bootstrap-agents-md",
    "lets-bootstrap-repo",
    "lets-develop-feature",
    "lets-review-code",
    "lets-review-pr",
    "lets-verify-change",
    "lets-verify-ready",
    "lets-spec-to-pr",
    "lets-create-plan",
    "lets-brainstorm",
    "lets-onboard-repo",
    "lets-research-content-evaluate",
    "lets-research-competitive-scan",
    "lets-research-ux-walkthrough",
    "lets-research-prd-grooming",
    "lets-opportunity-discovery",
    "lets-assess-ai-readiness",
  ],
  engineering: [
    "lets-start-here",
    "lets-bootstrap-agents-md",
    "lets-bootstrap-repo",
    "lets-develop-feature",
    "lets-review-code",
    "lets-review-pr",
    "lets-verify-change",
    "lets-verify-ready",
    "lets-spec-to-pr",
    "lets-create-plan",
    "lets-brainstorm",
    "lets-onboard-repo",
  ],
  sdlc: [
    "lets-start-here",
    "lets-bootstrap-agents-md",
    "lets-bootstrap-repo",
    "lets-develop-feature",
    "lets-review-code",
    "lets-review-pr",
    "lets-verify-change",
    "lets-verify-ready",
    "lets-spec-to-pr",
    "lets-create-plan",
    "lets-brainstorm",
    "lets-onboard-repo",
  ],
  research: [
    "lets-research-content-evaluate",
    "lets-research-competitive-scan",
    "lets-research-ux-walkthrough",
    "lets-research-prd-grooming",
    "lets-opportunity-discovery",
  ],
  pm: [
    "lets-brainstorm",
    "lets-opportunity-discovery",
    "lets-research-prd-grooming",
  ],
  design: [
    "lets-research-ux-walkthrough",
    "lets-research-content-evaluate",
  ],
  "repo-readiness": [
    "lets-onboard-repo",
    "lets-bootstrap-repo",
    "lets-bootstrap-agents-md",
    "lets-assess-ai-readiness",
  ],
  starter: [
    "lets-start-here",
    "lets-onboard-repo",
    "lets-bootstrap-repo",
    "lets-bootstrap-agents-md",
  ],
};

const agentDirs = {
  "claude-code": {
    user: ["~", ".claude", "skills"],
    project: [".claude", "skills"],
  },
  cursor: {
    user: ["~", ".cursor", "skills"],
    project: [".cursor", "skills"],
  },
  codex: {
    user: ["~", ".codex", "skills"],
    project: [".codex", "skills"],
  },
  copilot: {
    user: ["~", ".github", "skills"],
    project: [".github", "skills"],
  },
};

function usage() {
  console.log(`skill-hub

Usage:
  skill-hub list
  skill-hub install <bundle-or-skill> [--agent cursor] [--scope user|project] [--dir path]

Bundles:
  all, starter, engineering, sdlc, research, pm, design, repo-readiness

Agents:
  claude-code, cursor, codex, copilot

Examples:
  npx github:letsbe10x/skill-hub install engineering --agent cursor
  npx github:letsbe10x/skill-hub install lets-verify-ready --agent claude-code
  npx github:letsbe10x/skill-hub install all --dir ./.cursor/skills
`);
}

function parseArgs(argv) {
  const args = [...argv];
  const command = args.shift();
  const positionals = [];
  const options = { agent: "claude-code", scope: "user", dir: null };

  while (args.length) {
    const arg = args.shift();
    if (arg === "--agent") {
      options.agent = requireValue(arg, args.shift());
    } else if (arg === "--scope") {
      options.scope = requireValue(arg, args.shift());
    } else if (arg === "--dir") {
      options.dir = requireValue(arg, args.shift());
    } else if (arg === "-h" || arg === "--help") {
      options.help = true;
    } else if (arg.startsWith("--")) {
      fail(`Unknown option: ${arg}`);
    } else {
      positionals.push(arg);
    }
  }

  return { command, positionals, options };
}

function requireValue(flag, value) {
  if (!value || value.startsWith("--")) {
    fail(`Missing value for ${flag}`);
  }
  return value;
}

function fail(message) {
  console.error(`error: ${message}`);
  console.error("");
  usage();
  process.exit(1);
}

function expandHome(parts) {
  if (parts[0] === "~") {
    return path.join(os.homedir(), ...parts.slice(1));
  }
  return path.resolve(process.cwd(), ...parts);
}

function installDir(options) {
  if (options.dir) {
    return path.resolve(process.cwd(), options.dir);
  }
  const agent = agentDirs[options.agent];
  if (!agent) {
    fail(`Unsupported agent "${options.agent}". Valid agents: ${Object.keys(agentDirs).join(", ")}`);
  }
  const parts = agent[options.scope];
  if (!parts) {
    fail(`Unsupported scope "${options.scope}". Use "user" or "project".`);
  }
  return expandHome(parts);
}

function skillDirs() {
  return fs
    .readdirSync(repoRoot, { withFileTypes: true })
    .filter((entry) => entry.isDirectory())
    .map((entry) => entry.name)
    .filter((name) => name.startsWith("lets-"))
    .filter((name) => fs.existsSync(path.join(repoRoot, name, "SKILL.md")))
    .sort();
}

function resolveSelection(selection) {
  if (!selection) {
    fail("Missing bundle or skill name.");
  }
  if (bundles[selection]) {
    return bundles[selection];
  }
  if (skillDirs().includes(selection)) {
    return [selection];
  }
  fail(`Unknown bundle or skill "${selection}". Run "skill-hub list" to see options.`);
}

function copyDirectory(source, destination) {
  fs.rmSync(destination, { recursive: true, force: true });
  fs.mkdirSync(path.dirname(destination), { recursive: true });
  fs.cpSync(source, destination, {
    recursive: true,
    filter: (src) => !src.includes(`${path.sep}.git${path.sep}`),
  });
}

function install(selection, options) {
  const skills = resolveSelection(selection);
  const targetRoot = installDir(options);
  fs.mkdirSync(targetRoot, { recursive: true });

  for (const skill of skills) {
    const source = path.join(repoRoot, skill);
    if (!fs.existsSync(path.join(source, "SKILL.md"))) {
      fail(`Skill folder is missing SKILL.md: ${skill}`);
    }
    const destination = path.join(targetRoot, skill);
    copyDirectory(source, destination);
    console.log(`installed ${skill} -> ${destination}`);
  }
}

function list() {
  console.log("Bundles:");
  for (const [name, skills] of Object.entries(bundles)) {
    console.log(`  ${name} (${skills.length})`);
  }
  console.log("");
  console.log("Skills:");
  for (const skill of skillDirs()) {
    console.log(`  ${skill}`);
  }
}

function main() {
  const { command, positionals, options } = parseArgs(process.argv.slice(2));
  if (!command || options.help) {
    usage();
    return;
  }
  if (command === "list") {
    list();
    return;
  }
  if (command === "install") {
    install(positionals[0], options);
    return;
  }
  fail(`Unknown command: ${command}`);
}

main();
