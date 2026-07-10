#!/usr/bin/env node
/**
 * vibe-playbook CLI — scaffolds a project from one of the two playbook profiles.
 * Zero dependencies. See PLAYBOOK.md for the methodology.
 *
 *   npx vibe-playbook init solo [target-dir]
 *   npx vibe-playbook init orchestrated [target-dir]
 */
"use strict";

const fs = require("fs");
const path = require("path");

const PROFILES = {
  solo: "template-solo",
  orchestrated: "template",
};

function usage(code) {
  console.log(`vibe-playbook — Claude Code project scaffolding

Usage:
  npx vibe-playbook init <solo|orchestrated> [target-dir] [--force]

Profiles:
  solo          For VIBE CODERS (and developers who want low ceremony): ONE session +
                subagents (scout/implementer/verifier); the agent drives the git/terminal
                mechanics, you approve at gates in plain language. Recommended start;
                switch to orchestrated when you need parallel tracks (docs are identical).
  orchestrated  For SOFTWARE DEVELOPERS: multi-session (Manager/Dev/Ops/Design), you read
                specs/diffs and coordinate sessions; parallel tracks via git worktrees.

Options:
  target-dir    Where to scaffold (default: current directory). Created if missing.
  --force       Overwrite files that already exist in the target.

After init: follow STARTGUIDE.md in the target directory.`);
  process.exit(code);
}

function walk(dir, base) {
  const out = [];
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    const abs = path.join(dir, entry.name);
    const rel = path.relative(base, abs);
    if (entry.isDirectory()) out.push(...walk(abs, base));
    else out.push(rel);
  }
  return out;
}

function main() {
  const args = process.argv.slice(2).filter((a) => a !== "--force");
  const force = process.argv.includes("--force");

  if (args.length === 0 || ["-h", "--help", "help"].includes(args[0])) usage(0);
  if (args[0] !== "init") {
    console.error(`Unknown command: ${args[0]}\n`);
    usage(1);
  }
  const profile = args[1];
  if (!profile || !PROFILES[profile]) {
    console.error(`Pick a profile: solo | orchestrated\n`);
    usage(1);
  }

  const src = path.join(__dirname, "..", PROFILES[profile]);
  if (!fs.existsSync(src)) {
    console.error(`Package is broken: ${PROFILES[profile]}/ not found next to bin/.`);
    process.exit(1);
  }
  const target = path.resolve(args[2] || ".");

  // Collision check: never silently overwrite user files.
  const files = walk(src, src);
  const collisions = files
    .map((rel) => (rel === "gitignore" ? ".gitignore" : rel))
    .filter((rel) => fs.existsSync(path.join(target, rel)));
  if (collisions.length > 0 && !force) {
    console.error(
      `Refusing to overwrite ${collisions.length} existing file(s) in ${target}:\n` +
        collisions.slice(0, 10).map((f) => `  - ${f}`).join("\n") +
        (collisions.length > 10 ? `\n  … and ${collisions.length - 10} more` : "") +
        `\nRe-run with --force to overwrite.`
    );
    process.exit(1);
  }

  fs.mkdirSync(target, { recursive: true });
  fs.cpSync(src, target, { recursive: true, force: true });

  // npm strips files named ".gitignore" from packages, so templates ship "gitignore" — restore the dot.
  const shippedGitignore = path.join(target, "gitignore");
  if (fs.existsSync(shippedGitignore)) {
    fs.renameSync(shippedGitignore, path.join(target, ".gitignore"));
  }

  // Hooks must be executable (npm keeps the bit, but belt-and-suspenders).
  const hooksDir = path.join(target, ".claude", "hooks");
  if (fs.existsSync(hooksDir)) {
    for (const hook of fs.readdirSync(hooksDir)) {
      if (hook.endsWith(".sh")) fs.chmodSync(path.join(hooksDir, hook), 0o755);
    }
  }

  const rel = path.relative(process.cwd(), target) || ".";
  console.log(`Scaffolded the ${profile} profile into ${rel} (${files.length} files).

Next steps:
  1. cd ${rel === "." ? "" : rel + " && "}git init && git add -A && git commit -m "scaffold: playbook v7 ${profile} template"
  2. Open STARTGUIDE.md — adapt CLAUDE.md + .claude/settings.json (~5 min).
  3. Start a Claude Code session in that directory and paste the Phase 0 kickoff from STARTGUIDE.md.`);
}

main();
