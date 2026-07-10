#!/usr/bin/env node
/**
 * vibe-playbook CLI — scaffolds a project from one of the two playbook profiles.
 * Zero dependencies. See PLAYBOOK.md for the methodology.
 *
 *   npx vibe-playbook init solo [target-dir]
 *   npx vibe-playbook init orchestrated [target-dir]
 *
 * Safety model: the CLI NEVER overwrites existing files (there is deliberately no --force —
 * living docs are the project's memory; destroying them is never a flag away). It also refuses
 * symlinked targets and cross-profile overlays. Re-scaffolding means deleting files yourself, knowingly.
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
  npx vibe-playbook init <solo|orchestrated> [target-dir]

Profiles:
  solo          For VIBE CODERS (and developers who want low ceremony): ONE session +
                subagents (scout/implementer/verifier); the agent drives the git/terminal
                mechanics, you approve at gates in plain language. Recommended start;
                switch to orchestrated when you need parallel tracks (docs are identical).
  orchestrated  For SOFTWARE DEVELOPERS: multi-session (Manager/Dev/Ops/Design), you read
                specs/diffs and coordinate sessions; parallel tracks via git worktrees.

Options:
  target-dir    Where to scaffold (default: current directory). Created if missing.

The CLI never overwrites existing files and never overlays a different profile —
re-scaffolding or switching profiles is a manual, deliberate act (see README).

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

function refuseSymlink(p, what) {
  try {
    if (fs.lstatSync(p).isSymbolicLink()) {
      console.error(`${what} is a symlink — refusing to scaffold through it (files would land outside the target).`);
      process.exit(1);
    }
  } catch {
    /* does not exist — fine */
  }
}

function main() {
  const argv = process.argv.slice(2);
  const unknownOpts = argv.filter((a) => a.startsWith("-") && !["-h", "--help"].includes(a));
  if (unknownOpts.length > 0) {
    console.error(`Unknown option(s): ${unknownOpts.join(" ")} (there is no --force by design)\n`);
    usage(1);
  }
  const args = argv.filter((a) => !a.startsWith("-"));

  if (argv.length === 0 || ["-h", "--help"].includes(argv[0]) || args[0] === "help") usage(0);
  if (args[0] !== "init") {
    console.error(`Unknown command: ${args[0]}\n`);
    usage(1);
  }
  const profile = args[1];
  if (!profile || !PROFILES[profile]) {
    console.error(`Pick a profile: solo | orchestrated\n`);
    usage(1);
  }
  if (args.length > 3) {
    console.error(`Unexpected extra argument(s): ${args.slice(3).join(" ")}\n`);
    usage(1);
  }

  const src = path.join(__dirname, "..", PROFILES[profile]);
  if (!fs.existsSync(src)) {
    console.error(`Package is broken: ${PROFILES[profile]}/ not found next to bin/.`);
    process.exit(1);
  }
  const target = path.resolve(args[2] || ".");

  // Symlink containment: never write "into" a target that redirects elsewhere.
  refuseSymlink(target, "Target directory");
  refuseSymlink(path.join(target, ".claude"), "target/.claude");

  // Profile-mix guard: overlaying a different profile leaves stale agents/commands behind.
  // Profile switching is a manual 3-file swap by design (see README).
  const stampPath = path.join(target, ".claude", ".vibe-playbook");
  if (fs.existsSync(stampPath)) {
    const prev = fs.readFileSync(stampPath, "utf8").trim().split(/\s+/)[0];
    if (prev && prev !== profile) {
      console.error(
        `This directory was scaffolded with the '${prev}' profile; refusing to overlay '${profile}'.\n` +
          `Mixing profiles leaves stale files behind. Switching is a manual swap by design:\n` +
          `replace .claude/ + workflow.md + CLAUDE.md from the other template — the living-docs carry over unchanged.`
      );
      process.exit(1);
    }
  }

  // Collision check: NEVER overwrite existing files. The user deletes files themselves if they
  // really intend to re-scaffold — living docs are project memory, not disposable config.
  const files = walk(src, src);
  const collisions = files
    .flatMap((rel) => (rel === "gitignore" ? ["gitignore", ".gitignore"] : [rel]))
    .filter((rel) => fs.existsSync(path.join(target, rel)));
  if (collisions.length > 0) {
    console.error(
      `Refusing to overwrite ${collisions.length} existing file(s) in ${target}:\n` +
        collisions.slice(0, 10).map((f) => `  - ${f}`).join("\n") +
        (collisions.length > 10 ? `\n  … and ${collisions.length - 10} more` : "") +
        `\nThere is deliberately no --force. If you really mean to re-scaffold, delete those files yourself first.`
    );
    process.exit(1);
  }

  fs.mkdirSync(target, { recursive: true });
  fs.cpSync(src, target, { recursive: true, errorOnExist: true, force: false });

  // npm strips files named ".gitignore" from packages, so templates ship "gitignore" — restore the dot.
  const shippedGitignore = path.join(target, "gitignore");
  if (fs.existsSync(shippedGitignore)) {
    fs.renameSync(shippedGitignore, path.join(target, ".gitignore"));
  }

  // Provenance stamp: which profile + version scaffolded this directory (also powers the mix guard).
  const version = require("../package.json").version;
  fs.mkdirSync(path.join(target, ".claude"), { recursive: true });
  fs.writeFileSync(stampPath, `${profile} v${version}\n`);

  // Hooks must be executable (npm keeps the bit, but belt-and-suspenders).
  const hooksDir = path.join(target, ".claude", "hooks");
  if (fs.existsSync(hooksDir)) {
    for (const hook of fs.readdirSync(hooksDir)) {
      if (hook.endsWith(".sh")) fs.chmodSync(path.join(hooksDir, hook), 0o755);
    }
  }

  const rel = path.relative(process.cwd(), target) || ".";
  console.log(`Scaffolded the ${profile} profile into ${rel} (${files.length} template files + the provenance stamp).

Next steps:
  1. cd ${rel === "." ? "" : rel + " && "}git init && git add -A && git commit -m "scaffold: playbook v8 ${profile} template"
  2. Open STARTGUIDE.md — adapt CLAUDE.md + .claude/settings.json (~5 min).
  3. Start a Claude Code session in that directory and paste the Phase 0 kickoff from STARTGUIDE.md.`);
}

main();
