#!/usr/bin/env node
/**
 * vibe-playbook CLI — scaffolds a project from one of the two playbook profiles.
 * Zero dependencies. See PLAYBOOK.md for the methodology.
 *
 *   npx vibe-playbook init solo [target-dir] [--design <first|sync|none>]
 *   npx vibe-playbook init orchestrated [target-dir] [--design <first|sync|none>]
 *
 * Safety model: the CLI NEVER overwrites existing files (there is deliberately no --force —
 * living docs are the project's memory; destroying them is never a flag away). It refuses
 * cross-profile/mode overlays and any symlink/hardlink on the write path (target, target/.claude,
 * nested destination dirs, and the stamp) so files cannot land outside the target. Ancestors ABOVE
 * the target are resolved normally (standard realpath). Re-scaffolding means deleting files yourself.
 */
"use strict";

const fs = require("fs");
const path = require("path");

const PROFILES = {
  solo: "template-solo",
  orchestrated: "template",
};

const DESIGN_MODES = ["first", "sync", "none"];

// Design-mode file policy. Modes differ by WHOLE FILES only (no doc surgery):
// _overlays/ is CLI machinery and is never copied as base; --design none additionally
// excludes the design-track files. The same predicate drives the collision check AND
// the copy, so the collision list always equals exactly what would be written.
function excluded(rel, mode) {
  const parts = rel.split(path.sep);
  if (parts[0] === "_overlays") return true;
  if (mode !== "none") return false;
  return (
    (parts[0] === "docs" && parts[1] === "design") ||
    rel === ".mcp.json" ||
    rel === path.join(".claude", "agents", "design-guardian.md")
  );
}

function usage(code) {
  console.log(`vibe-playbook — Claude Code project scaffolding

Usage:
  npx vibe-playbook init <solo|orchestrated> [target-dir] [--design <first|sync|none>]

Profiles:
  solo          For VIBE CODERS (and developers who want low ceremony): ONE session +
                subagents (scout/implementer/verifier); the agent drives the git/terminal
                mechanics, you approve at gates in plain language. Recommended start;
                switch to orchestrated when you need parallel tracks (docs are identical).
  orchestrated  For SOFTWARE DEVELOPERS: multi-session (Manager/Dev/Ops/Design), you read
                specs/diffs and coordinate sessions; parallel tracks via git worktrees.

Options:
  target-dir    Where to scaffold (default: current directory). Created if missing.
  --design      Design mode (default: none):
                  none   no design surface (default; backend/server-only, e.g. an LLM gateway)
                  sync   design track alongside development (Claude Design MCP loop)
                  first  prototype-before-code — design phases (D0→D2) + GATE D before Phase 1
  --            End of options (a target-dir that begins with '-' may follow).

The CLI never overwrites existing files and never overlays a different profile or
design mode — re-scaffolding or switching is a manual, deliberate act (see README).

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

  // Options: --design <mode> | --design=<mode> (default: none) · -h/--help · -- (end of options).
  // Everything else starting with "-" is rejected (there is deliberately no --force).
  let mode = "none";
  const args = [];
  const unknownOpts = [];
  let wantHelp = false;
  let endOpts = false;
  for (let i = 0; i < argv.length; i++) {
    const a = argv[i];
    if (endOpts) { args.push(a); continue; }
    if (a === "--") { endOpts = true; continue; }
    if (a === "-h" || a === "--help") { wantHelp = true; continue; }
    if (a === "--design") { mode = argv[++i]; continue; }
    if (a.startsWith("--design=")) { mode = a.slice("--design=".length); continue; }
    if (a.startsWith("-")) { unknownOpts.push(a); continue; }
    args.push(a);
  }
  if (!DESIGN_MODES.includes(mode ?? "")) {
    console.error(`Invalid --design value: '${mode ?? "(missing)"}' (pick: first | sync | none)\n`);
    usage(1);
  }
  if (unknownOpts.length > 0) {
    console.error(`Unknown option(s): ${unknownOpts.join(" ")} (there is no --force by design)\n`);
    usage(1);
  }

  if (argv.length === 0 || wantHelp || args[0] === "help") usage(0);
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
  const overlaySrc = path.join(src, "_overlays", "design-first");
  if (mode === "first" && !fs.existsSync(overlaySrc)) {
    console.error(`Package is broken: ${PROFILES[profile]}/_overlays/design-first/ not found.`);
    process.exit(1);
  }
  const target = path.resolve(args[2] || ".");

  // Symlink containment: never write "into" a target that redirects elsewhere.
  refuseSymlink(target, "Target directory");
  refuseSymlink(path.join(target, ".claude"), "target/.claude");

  // Stamp containment: the stamp is written unconditionally, so a symlinked/hardlinked
  // .vibe-playbook would let the write escape the target. Refuse both before we read OR write it.
  const stampPath = path.join(target, ".claude", ".vibe-playbook");
  refuseSymlink(stampPath, "target/.claude/.vibe-playbook");
  try {
    const st = fs.lstatSync(stampPath);
    if (st.nlink > 1) {
      console.error(`target/.claude/.vibe-playbook is a hardlink (nlink=${st.nlink}) — refusing (the stamp write would modify a linked file).`);
      process.exit(1);
    }
  } catch {
    /* does not exist — fine */
  }

  // Profile/mode-mix guard: overlaying a different profile or design mode leaves stale files behind.
  // Switching is a manual swap by design (see README).
  if (fs.existsSync(stampPath)) {
    const toks = fs.readFileSync(stampPath, "utf8").trim().split(/\s+/);
    const prev = toks[0];
    if (prev && prev !== profile) {
      console.error(
        `This directory was scaffolded with the '${prev}' profile; refusing to overlay '${profile}'.\n` +
          `Mixing profiles leaves stale files behind. Switching is a manual swap by design:\n` +
          `replace .claude/ + workflow.md + CLAUDE.md from the other template — the living-docs carry over unchanged.`
      );
      process.exit(1);
    }
    const prevMode = toks[2]; // pre-8.3 stamps carry no mode token → profile check only
    if (prevMode && prevMode !== mode) {
      console.error(
        `This directory was scaffolded with design mode '${prevMode}'; refusing to overlay '${mode}'.\n` +
          `Design modes differ by whole files; switching is a manual, deliberate act (see README).`
      );
      process.exit(1);
    }
  }

  // Collision check: NEVER overwrite existing files. The user deletes files themselves if they
  // really intend to re-scaffold — living docs are project memory, not disposable config.
  // The set is mode-aware: it equals exactly what would be written.
  const baseFiles = walk(src, src).filter((rel) => !excluded(rel, mode));
  const overlayFiles = mode === "first" ? walk(overlaySrc, overlaySrc) : [];
  const files = baseFiles.concat(overlayFiles);
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

  // Nested-symlink containment: a pre-existing symlinked directory INSIDE the target would let
  // cpSync write through it to an external location. Check every destination dir at/below target.
  // (Ancestors ABOVE target are intentionally not checked — resolving them is normal realpath,
  // e.g. /tmp -> /private/tmp.)
  const destDirs = new Set();
  for (const rel of files) {
    const parts = rel.split(path.sep);
    for (let k = 1; k < parts.length; k++) destDirs.add(parts.slice(0, k).join(path.sep));
  }
  for (const d of destDirs) {
    refuseSymlink(path.join(target, d), `target/${d.split(path.sep).join("/")}`);
  }

  fs.mkdirSync(target, { recursive: true });
  fs.cpSync(src, target, {
    recursive: true,
    errorOnExist: true,
    force: false,
    filter: (s) => s === src || !excluded(path.relative(src, s), mode),
  });
  if (mode === "first") {
    fs.cpSync(overlaySrc, target, { recursive: true, errorOnExist: true, force: false });
  }

  // npm strips files named ".gitignore" from packages, so templates ship "gitignore" — restore the dot.
  const shippedGitignore = path.join(target, "gitignore");
  if (fs.existsSync(shippedGitignore)) {
    fs.renameSync(shippedGitignore, path.join(target, ".gitignore"));
  }

  // Provenance stamp: profile + version + design mode (also powers the mix guard and /adapt).
  const version = require("../package.json").version;
  fs.mkdirSync(path.join(target, ".claude"), { recursive: true });
  fs.writeFileSync(stampPath, `${profile} v${version} ${mode}\n`);

  // Hooks must be executable (npm keeps the bit, but belt-and-suspenders).
  const hooksDir = path.join(target, ".claude", "hooks");
  if (fs.existsSync(hooksDir)) {
    for (const hook of fs.readdirSync(hooksDir)) {
      if (hook.endsWith(".sh")) fs.chmodSync(path.join(hooksDir, hook), 0o755);
    }
  }

  const rel = path.relative(process.cwd(), target) || ".";
  console.log(`Scaffolded the ${profile} profile (design mode: ${mode}) into ${rel} (${files.length} template files + the provenance stamp).

Next steps:
  1. cd ${rel === "." ? "" : rel + " && "}git init && git add -A && git commit -m "scaffold: playbook v8 ${profile} template"
  2. Open STARTGUIDE.md — adapt CLAUDE.md + .claude/settings.json (~5 min).
  3. Start a Claude Code session in that directory and paste the Phase 0 kickoff from STARTGUIDE.md.${
    mode === "first"
      ? `\n  4. Design-first mode: after the Phase 0 gate, run the design phase (D0→D2 → GATE D) — see docs/design/design-first.md + STARTGUIDE §3b.`
      : ""
  }`);
}

main();
