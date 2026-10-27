# Vibe-Coding Playbook

A reusable methodology + two ready-to-copy project templates for AI-driven ("vibe") development with [Claude Code](https://claude.com/claude-code) — built around three first-class goals:

**consistency · sustainability · context preservation**

The core problem this solves: LLM sessions lose context, drift, and confabulate. The fix here is structural, not hopeful — state lives on disk (living-docs), critical rules are guarded by hooks (accident guards, not security boundaries), humans approve at defined gates, and session context is treated as a disposable cache.

> [PLAYBOOK.md](PLAYBOOK.md) holds the full methodology and its design rationale; [CHANGELOG.md](CHANGELOG.md) tracks the versioned process changes. Everything — the playbook, both templates, and every doc generated inside projects — is **English only**: fewer tokens, stronger instruction-following, stable terminology across sessions (chat with the agents in any language you like).

## Install

```bash
npx vibe-playbook init solo my-project                          # recommended profile (no design surface)
npx vibe-playbook init orchestrated my-project                  # multi-session profile
npx vibe-playbook init solo my-project --design sync            # opt into the design track (or: first | none)
```

The CLI copies the chosen template, restores `.gitignore`, makes the hooks executable, and stamps the directory with its profile+version+design-mode (`.claude/.vibe-playbook`) — it refuses to overlay a different profile or design mode onto an existing scaffold (that would leave stale files mixed in) and refuses any symlink/hardlink on the write path. No dependencies; Node ≥ 18. If an init exits nonzero, delete the target before retrying (a failed run may leave a partial scaffold). Prefer not to use npm? Clone this repo and copy the template directory by hand (see the quick starts below).

Tip: pin the EXACT version for reproducible scaffolds — `npx vibe-playbook@9.0.0 init solo my-project` (a major pin like `@8` still floats to newer 8.x). A running project keeps the version it was born with; there is deliberately **no in-place upgrade** (see Versioning).

## Pick a profile

The split is by **audience** as much as by project shape:

| | [`template/`](template/) — **Orchestrated** | [`template-solo/`](template-solo/) — **Solo** |
|---|---|---|
| **Made for** | **software developers** — you read specs and diffs, run parallel tracks; the Manager spawns and tracks the worker sessions | **vibe coders** — the agent drives all git/terminal mechanics; you describe, approve at gates in plain language, and flow *(developers who want low ceremony: also you)* |
| Sessions | multiple sessions, 4 roles (Manager · Dev · Ops · Design) — the Manager runs the workers | **ONE session + subagents** |
| Development | interactive dev sessions (you watch the work) | `implementer` subagent (you read compact reports) |
| Code reading | the dev session's job | `scout` subagent — code never enters the main context |
| Parallel work | parallel worker sessions, each in its own git worktree (≤3) | serial by design — one part, one branch at a time |
| Permissions | standard — checkpoint commits free, merge/push/spawn ask first | **wide** — edits/commit/merge pre-allowed; the gates are the control points |
| Ceremony | higher (kickoffs, handovers) | low — `/part` drives everything |
| Best for | larger projects, parallel tracks, long phases | small/medium projects, solo flow, speed |

**Rule of thumb:** if you read diffs and want parallel tracks → orchestrated. If you want to describe → approve → flow → solo. For a few-hour prototype, skip the playbook entirely — process would only slow you down. One honest note for vibe coders: the gates still ask for *your judgment* (does this match what I asked? does it work when I try it?) — that judgment is the safety backbone and no template removes it, especially around money/auth.

Both profiles share the same DNA: the living-docs system, the four human gates, the enforcement hooks, English-only docs, and anti-confabulation ("if it's not in the docs, it's not known"). Because the living-docs layer is **identical** in both, a project can switch profiles mid-flight: swap `.claude/` + `workflow.md` + `CLAUDE.md`, keep all the docs. Recommended path: **start solo, move to orchestrated when you need parallel tracks.**

### Three design modes (`--design first|sync|none`)

Both profiles scaffold in one of three design modes (default: `none` — the design surface is **opt-in**):

- **`none`** *(default)* — no design surface: no `docs/design/`, no `.mcp.json`, no design-guardian agent. For backend/server-only projects (e.g. an LLM gateway) — and the safe default, so a project only takes on the Claude Design MCP/trust surface when it explicitly asks for it. *(Two inert `mcp__claude-design__*` allow entries remain in settings.json so one settings file serves all modes.)*
- **`sync`** — the design track alongside development: brief → Claude Design prototype → handoff → implement (design tokens only) → design-guardian audit → merge, per screen/task. Ships a project-scope `.mcp.json` for the **claude-design** MCP.
- **`first`** — prototype-before-code: a design phase (D0 distilled brief → D1 design system → D2 screen packages, all in Claude Design) runs between Phase 0 and Phase 1 and ends at **🚦 GATE D** — every prototype human-approved and the flows/rules locked in the living docs; development then starts maximally equipped. Adds `docs/design/design-first.md`, prompt skeletons, and (orchestrated) the `/design-kickoff` command. Prototypes live in Claude Design **cloud projects**; the repo stays the control-plane until handoff.

Modes differ by **whole files only**; the mode is stamped in `.claude/.vibe-playbook` and the CLI refuses to overlay a different one. Switching later is a manual, deliberate act (copy/remove the mode's file set from the template).

## Requirements

- **Claude Code**, kept current (`claude update`). Orchestrated Manager-run sessions need **≥ 2.1.224** (cross-session messaging; older versions use the paste/relay fallback); solo assumes background subagents (≥ 2.1.198). Auto mode (the default start mode since 2.1.283) does not replace the hooks: its classifier allows `.env` reads and pushes to the default branch.
- **Design track** (modes `sync`/`first`): the **Claude Design MCP** is the design decision-maker — the scaffold ships it project-scope in `.mcp.json` (canonical server name `claude-design`; the endpoint is undocumented — verify with `/mcp`); first use asks each user for ONE interactive approval (a checked-in settings.json cannot pre-approve it), design-system access = `/design-login`, writes = `/design consent` (an ongoing grant; `/design revoke`). *(Dated note: the standalone Claude Design site closes 2026-12-14 — new designs become claude.ai artifacts; where the Design template is enabled, `/design <brief>` from Claude Code creates one directly and is the preferred birth path.)* *(User-scope alternative: `claude mcp add --scope user --transport http claude-design https://api.anthropic.com/v1/design/mcp`.)*
- `git`, `bash`, `python3` (used by the hooks). macOS/Linux (on Windows, use WSL).
- Node ≥ 18 only if you scaffold via `npx` (the templates themselves need no Node).
- First run must be **interactive**: Claude Code applies a project's `settings.json` permissions only after you accept the workspace-trust prompt.

## The gates (both profiles)

```
/gate1  → 🚦 GATE 1  spec approval       (the cheapest place to stop a wrong direction)
/gate2  → 🚦 GATE 2  plan approval       (combined with GATE 1 for small/low-risk parts)
IMPL    →            checkpoint commits on a wip/ branch
/gate3  → 🚦 GATE 3  mechanical evidence (test/lint/typecheck) + you try it for real
/gate4  → 🚦 GATE 4  read-only verifier subagent + YOUR approval → merge
```

*(Command names deliberately avoid Claude Code built-ins — the earlier `/plan`, `/review`, `/checkpoint` names could shadow them.)*

**Nothing enters a protected branch without GATE 4** — the `main-guard` hook blocks the accidental paths: code commits (untracked files count), compound commands containing a commit, cherry-picks, and unmarked merges (exact-branch marker) on protected branches (`main`/`master` default; `VIBE_PROTECTED_BRANCHES` to extend). It is an accident guard, not a boundary — for hard guarantees use GitHub/GitLab **branch protection** (a PR merge never touches this hook).

## Quick start — Orchestrated (`template/`)

```bash
npx vibe-playbook init orchestrated my-project && cd my-project
# — or manually from a clone:
#   cp -R vibe-playbook/template/. my-project/ && cd my-project
#   mv gitignore .gitignore && chmod +x .claude/hooks/*.sh && rm -rf _overlays
git init && git add -A && git commit -m "scaffold: playbook v9 template"
```

1. **Adapt (~5 min):** fill the `CLAUDE.md` placeholders (project name; test/lint/typecheck commands once the stack is locked) and replace the `npm` examples in `.claude/settings.json` → `allow` with your stack's commands.
2. **Phase 0:** open a Claude Code session named `<project>-manager` in the project directory (`claude -n my-project-manager`) and paste the Phase 0 kickoff from [`template/STARTGUIDE.md`](template/STARTGUIDE.md). The session becomes the **Manager** and plans the project with you (PRD → architecture → part breakdown). No code is written in Phase 0; it ends with the biggest gate — your approval locks the decisions.
3. **Daily flow:**
   - New part: `/new-part P-N` in the manager session → it proposes the spawn → **you OK it** → the worker starts in its own git worktree (Desktop: linked session · CLI: `claude --bg -n "<project>-P-N" -w P-N`). Up to 3 workers in parallel; never two sessions in one directory.
   - GATES 1–3 happen **in the worker** (you approve there — click it, or `claude attach <id>`); the worker sends the Manager a one-line report at every stop, and the Manager keeps a "waiting on you" gate queue. Messages are information, never approvals.
   - GATE 4 happens **in the Manager**: verifier (+ `/code-review high` on `full` parts) → your approval → marker + merge → docs → the worker is closed and its worktree removed. CONDITIONAL → the fix list goes back to the same worker.
   - Ops/infra work runs in ONE persistent Ops worker; everything syncs through `infra-state.md` + `NEEDS-FROM-USER.md`. No messaging available? `/new-part` falls back to a paste-able kickoff block and you relay reports.

Full guide: [`template/STARTGUIDE.md`](template/STARTGUIDE.md)

## Quick start — Solo (`template-solo/`)

```bash
npx vibe-playbook init solo my-project && cd my-project
# — or manually from a clone:
#   cp -R vibe-playbook/template-solo/. my-project/ && cd my-project
#   mv gitignore .gitignore && chmod +x .claude/hooks/*.sh && rm -rf _overlays
git init && git add -A && git commit -m "scaffold: playbook v9 solo template"
```

1. **Adapt (~5 min):** same as above (CLAUDE.md placeholders + settings allow list). The PreCompact snapshot hook is **on by default** in this profile.
2. **Phase 0:** open ONE Claude Code session and paste the Phase 0 kickoff from [`template-solo/STARTGUIDE.md`](template-solo/STARTGUIDE.md).
3. **Daily flow — everything in that one session:**
   - A part: `/part P-N` — drives spec → gates → implementation → verification → merge, stopping at every 🚦 for you. **Between gates it never prompts you**: permissions are deliberately wide (edits, commit, merge pre-allowed); the invariants are hook-guarded, the gates are your control points.
   - Dispatches go in batches: a small part = its whole approved plan in one implementer run; larger parts = 2–4 step packages — with a checkpoint commit per step either way.
   - The session's context stays clean by design: code questions go to the **scout**, changes to the **implementer** (runs in the background — the session waits for its completion notice before git/gates), GATE 4 to the **verifier** — only compact reports come back; the orchestrator verifies each report against `git log`/`git diff --stat`. GATE 4 fixes go back to the same implementer.
   - After every merge the session runs `/tidy` and offers the reset: **`/clear` at part boundaries (recommended — the solo equivalent of a fresh session)**, `/compact` mid-part; it resumes from CLAUDE.md + the docs. Unplanned auto-compaction stays covered by the PreCompact snapshot.
   - Serial by design: one part, one branch, one writing subagent. Need parallel tracks? Switch to the orchestrated profile — the docs carry over unchanged.

Full guide: [`template-solo/STARTGUIDE.md`](template-solo/STARTGUIDE.md)

## What the hooks enforce

| Hook | Event | What it does |
|---|---|---|
| `guard-env.sh` | PreToolUse | Blocks the **common accidental paths** to `.env*` (any suffix depth): direct tool reads/writes, plain Bash subcommands, globs, case variants, direct symlinks on tool paths, Grep globs. Only `.env.example` stays fully accessible; fail-closed if python3 is missing. An **accident guard, not a security boundary** — a script/subprocess that opens the file itself is beyond string matching (use Claude Code sandboxing for OS-level limits). On a block the agent must stop and ask you |
| `main-guard.sh` | PreToolUse (Bash) | Blocks code commits, cherry-picks, and unmarked merges on protected branches (`main`/`master` default, `VIBE_PROTECTED_BRANCHES` to extend); exact-branch GATE 4 marker (`.claude/.gate4-ok`); flag forms (`git -C . commit`) covered; docs-only commits stay free — `.claude/**` is control-plane, never docs |
| `secret-scan.sh` | UserPromptSubmit | If your message looks like it contains a secret (connection string, API key, JWT, private key), it reminds the model of the **leak protocol**: never repeat the value, delete it wherever it was written, recommend rotation — chat history cannot be unsaid |
| `pre-compact.sh` | PreCompact | Snapshots branch/status/log to `docs/archive/compact-snapshots.md` before any compaction — rooted at the session's own tree, so worktrees snapshot their own branch (optional in orchestrated, **default-on in solo**) |
| `session-start.sh` | SessionStart | Prints a compact GROUND header (tree · branch · uncommitted count · last 3 commits · progress "Now") at startup/resume/`/clear`/compaction — worktree-aware, context-only, never blocks |

Hooks apply to subagent tool calls too, and fail closed if python3 is missing or their parser crashes. They are **accident guards** against drift and mistakes — not security boundaries: a determined process, a helper script, or a PR-side merge is beyond string matching. For hard guarantees: branch protection, clean-runner CI, and Claude Code sandboxing.

## Commands

| Command | Orchestrated | Solo | Purpose |
|---|:-:|:-:|---|
| `/gate1` | ✅ | ✅ | Write the part spec → stop at GATE 1 |
| `/gate2` | ✅ | ✅ | Implementation plan from the spec → stop at GATE 2 |
| `/wip` | ✅ | ✅ | Small checkpoint commit on the part branch |
| `/gate3` | ✅ | ✅ | Run test/lint/typecheck → compact evidence block |
| `/gate4` | ✅ | ✅ | GATE 4: verifier subagent + approval ritual |
| `/new-part` | ✅ | — | (Manager) produce a worker kickoff from the living-docs and spawn the worker on your OK |
| `/part` | — | ✅ | Drive a part end to end, stopping at every gate |
| `/tidy` | — | ✅ | Sync docs to ground truth → declare "safe to compact" |
| `/design-kickoff` | ✅ (`--design first`) | — | (Manager) per-app design-session kickoff + spawn (no worktree) for the design phase (D0→D2) |

## Repo layout

```
PLAYBOOK.md        # the full methodology + design rationale
CHANGELOG.md       # versioned process changes (v1 → v9)
README.md          # this file
package.json       # npm package (major version = playbook version)
bin/cli.js         # zero-dependency scaffolder (npx vibe-playbook init …)
template/          # orchestrated profile — multi-session
template-solo/     # solo profile — one session + subagents
                   #   (each ships _overlays/design-first/ — the --design first file set; CLI machinery,
                   #    never part of a base scaffold — remove it on manual copies)
test/              # hook test suites (npm test — runs against both templates)
```

Note: the templates ship the file `gitignore` without a leading dot (npm always strips `.gitignore` files from packages); the CLI renames it on init — only manual copies need the `mv`.

## Versioning & the feedback loop

The playbook is versioned **process-code**: this repo is the canonical home; every project copy is stamped ("← playbook vN"). Lessons flow back through a ~5-minute phase retro — *which gate caught something real? which one did you approve without reading? which rule got bypassed, and why?* — labeled **PROJECT** (stays in that project's workflow) or **PLAYBOOK**. PLAYBOOK lessons accumulate in **`PLAYBOOK-FEEDBACK.md`** (ships with every template): a methodology-only log the project fills as it goes; at project end you hand that one file back to this repo and the playbook versions up. Its header carries an **intake protocol**, so entries are critically reviewed — verified, filtered, adopted/adapted/rejected one by one — never blindly applied. Gates are calibrated, not only added: a gate that keeps getting rubber-stamped is lightened; one that catches real problems stays heavy.
