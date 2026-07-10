# Vibe-Coding Playbook

A reusable methodology + two ready-to-copy project templates for AI-driven ("vibe") development with [Claude Code](https://claude.com/claude-code) — built around three first-class goals:

**consistency · sustainability · context preservation**

The core problem this solves: LLM sessions lose context, drift, and confabulate. The fix here is structural, not hopeful — state lives on disk (living-docs), critical rules are physically enforced (hooks), humans approve at defined gates, and session context is treated as a disposable cache.

> [PLAYBOOK.md](PLAYBOOK.md) holds the full methodology and its design rationale; [CHANGELOG.md](CHANGELOG.md) tracks the versioned process changes. Everything — the playbook, both templates, and every doc generated inside projects — is **English only**: fewer tokens, stronger instruction-following, stable terminology across sessions (chat with the agents in any language you like).

## Install

```bash
npx vibe-playbook init solo my-project          # recommended starting profile
npx vibe-playbook init orchestrated my-project  # multi-session profile
```

The CLI copies the chosen template, restores `.gitignore`, makes the hooks executable, and stamps the directory with its profile+version (`.claude/.vibe-playbook`) — it refuses to overlay a different profile onto an existing scaffold (that would leave stale files mixed in). No dependencies; Node ≥ 18. Prefer not to use npm? Clone this repo and copy the template directory by hand (see the quick starts below).

Tip: pin the version for reproducible scaffolds — `npx vibe-playbook@8 init solo my-project`. A running project keeps the version it was born with; there is deliberately **no in-place upgrade** (see Versioning).

## Pick a profile

The split is by **audience** as much as by project shape:

| | [`template/`](template/) — **Orchestrated** | [`template-solo/`](template-solo/) — **Solo** |
|---|---|---|
| **Made for** | **software developers** — you read specs and diffs, coordinate sessions, run parallel tracks | **vibe coders** — the agent drives all git/terminal mechanics; you describe, approve at gates in plain language, and flow *(developers who want low ceremony: also you)* |
| Sessions | multiple sessions, 4 roles (Manager · Dev · Ops · Design) | **ONE session + subagents** |
| Development | interactive dev sessions (you watch the work) | `implementer` subagent (you read compact reports) |
| Code reading | the dev session's job | `scout` subagent — code never enters the main context |
| Parallel work | parallel tracks via git worktrees | serial by design — one part, one branch at a time |
| Permissions | standard — commit/merge ask first | **wide** — edits/commit/merge pre-allowed; the gates are the control points |
| Ceremony | higher (kickoffs, handovers) | low — `/part` drives everything |
| Best for | larger projects, parallel tracks, long phases | small/medium projects, solo flow, speed |

**Rule of thumb:** if you read diffs and want parallel tracks → orchestrated. If you want to describe → approve → flow → solo. For a few-hour prototype, skip the playbook entirely — process would only slow you down. One honest note for vibe coders: the gates still ask for *your judgment* (does this match what I asked? does it work when I try it?) — that judgment is the safety backbone and no template removes it, especially around money/auth.

Both profiles share the same DNA: the living-docs system, the four human gates, the enforcement hooks, English-only docs, and anti-confabulation ("if it's not in the docs, it's not known"). Because the living-docs layer is **identical** in both, a project can switch profiles mid-flight: swap `.claude/` + `workflow.md` + `CLAUDE.md`, keep all the docs. Recommended path: **start solo, move to orchestrated when you need parallel tracks.**

## Requirements

- **Claude Code** (CLI). The design track additionally uses the **Claude Design MCP** as design decision-maker — that connection requires Claude Code run **from the terminal**.
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

**Nothing enters a protected branch without GATE 4** — not a convention: the `main-guard` hook physically blocks code commits, cherry-picks, and unmarked merges on protected branches (`main`/`master` by default; extend via `VIBE_PROTECTED_BRANCHES`). Merging via GitHub PRs instead? The hook never sees those merges — use branch protection there.

## Quick start — Orchestrated (`template/`)

```bash
npx vibe-playbook init orchestrated my-project && cd my-project
# — or manually from a clone:
#   cp -R vibe-playbook/template/. my-project/ && cd my-project
#   mv gitignore .gitignore && chmod +x .claude/hooks/*.sh
git init && git add -A && git commit -m "scaffold: playbook v8 template"
```

1. **Adapt (~5 min):** fill the `CLAUDE.md` placeholders (project name; test/lint/typecheck commands once the stack is locked) and replace the `npm` examples in `.claude/settings.json` → `allow` with your stack's commands.
2. **Phase 0:** open a Claude Code session in the project directory and paste the Phase 0 kickoff from [`template/STARTGUIDE.md`](template/STARTGUIDE.md). The session becomes the **Manager** and plans the project with you (PRD → architecture → part breakdown). No code is written in Phase 0; it ends with the biggest gate — your approval locks the decisions.
3. **Daily flow:**
   - New part: `/new-part P-N` in the manager session → paste the generated kickoff into a **fresh** session.
   - Ride the gates (table above). On GATE 4 approval the session marks `.claude/.gate4-ok`, merges, removes the marker, updates the docs.
   - **Parallel parts run in separate git worktrees** (the kickoff includes the command) — never two sessions in one directory.
   - Ops/infra work runs in its own persistent session; everything syncs through `infra-state.md` + `NEEDS-FROM-USER.md`.

Full guide: [`template/STARTGUIDE.md`](template/STARTGUIDE.md)

## Quick start — Solo (`template-solo/`)

```bash
npx vibe-playbook init solo my-project && cd my-project
# — or manually from a clone:
#   cp -R vibe-playbook/template-solo/. my-project/ && cd my-project
#   mv gitignore .gitignore && chmod +x .claude/hooks/*.sh
git init && git add -A && git commit -m "scaffold: playbook v8 solo template"
```

1. **Adapt (~5 min):** same as above (CLAUDE.md placeholders + settings allow list). The PreCompact snapshot hook is **on by default** in this profile.
2. **Phase 0:** open ONE Claude Code session and paste the Phase 0 kickoff from [`template-solo/STARTGUIDE.md`](template-solo/STARTGUIDE.md).
3. **Daily flow — everything in that one session:**
   - A part: `/part P-N` — drives spec → gates → implementation → verification → merge, stopping at every 🚦 for you. **Between gates it never prompts you**: permissions are deliberately wide (edits, commit, merge pre-allowed); the invariants are hook-guarded, the gates are your control points.
   - Dispatches go in batches: a small part = its whole approved plan in one implementer run; larger parts = 2–4 step packages — with a checkpoint commit per step either way.
   - The session's context stays clean by design: code questions go to the **scout**, changes to the **implementer**, GATE 4 to the **verifier** — only compact reports come back; the orchestrator verifies each report against `git log`/`git diff --stat`.
   - After every merge the session runs `/tidy` and offers the reset: **`/clear` at part boundaries (recommended — the solo equivalent of a fresh session)**, `/compact` mid-part; it resumes from the docs + memory. Unplanned auto-compaction stays covered by the PreCompact snapshot.
   - Serial by design: one part, one branch, one writing subagent. Need parallel tracks? Switch to the orchestrated profile — the docs carry over unchanged.

Full guide: [`template-solo/STARTGUIDE.md`](template-solo/STARTGUIDE.md)

## What the hooks enforce

| Hook | Event | What it does |
|---|---|---|
| `guard-env.sh` | PreToolUse | Physically blocks **any** access to `.env*` — direct tool reads/writes AND Bash subcommands (`cat`/`cp`/`source`/redirects/scripts), glob forms (`.env*`), case variants (`.ENV`), Grep globs. Only `.env.example` is fully accessible. On a block the agent must stop and ask you — env values are always placed by the human |
| `main-guard.sh` | PreToolUse (Bash) | Blocks code commits, cherry-picks, and unmarked merges on protected branches (`main`/`master` default, `VIBE_PROTECTED_BRANCHES` to extend); exact-branch GATE 4 marker (`.claude/.gate4-ok`); flag forms (`git -C . commit`) covered; docs-only commits stay free |
| `secret-scan.sh` | UserPromptSubmit | If your message looks like it contains a secret (connection string, API key, JWT, private key), it reminds the model of the **leak protocol**: never repeat the value, delete it wherever it was written, recommend rotation — chat history cannot be unsaid |
| `pre-compact.sh` | PreCompact | Snapshots branch/status/log to `docs/archive/compact-snapshots.md` before any compaction (optional in orchestrated, **default-on in solo**) |

Hooks apply to subagent tool calls too. They are safety nets against drift and accidents — not guarantees against a malicious agent.

## Commands

| Command | Orchestrated | Solo | Purpose |
|---|:-:|:-:|---|
| `/gate1` | ✅ | ✅ | Write the part spec → stop at GATE 1 |
| `/gate2` | ✅ | ✅ | Implementation plan from the spec → stop at GATE 2 |
| `/wip` | ✅ | ✅ | Small checkpoint commit on the part branch |
| `/gate3` | ✅ | ✅ | Run test/lint/typecheck → compact evidence block |
| `/gate4` | ✅ | ✅ | GATE 4: verifier subagent + approval ritual |
| `/new-part` | ✅ | — | (Manager) produce a fresh-session kickoff from the living-docs |
| `/part` | — | ✅ | Drive a part end to end, stopping at every gate |
| `/tidy` | — | ✅ | Sync docs to ground truth → declare "safe to compact" |

## Repo layout

```
PLAYBOOK.md        # the full methodology + design rationale
CHANGELOG.md       # versioned process changes (v1 → v6)
README.md          # this file
package.json       # npm package (major version = playbook version)
bin/cli.js         # zero-dependency scaffolder (npx vibe-playbook init …)
template/          # orchestrated profile — multi-session
template-solo/     # solo profile — one session + subagents
test/              # hook test suites (npm test — runs against both templates)
```

Note: the templates ship the file `gitignore` without a leading dot (npm always strips `.gitignore` files from packages); the CLI renames it on init — only manual copies need the `mv`.

## Versioning & the feedback loop

The playbook is versioned **process-code**: this repo is the canonical home; every project copy is stamped ("← playbook vN"). Lessons flow back through a ~5-minute phase retro — *which gate caught something real? which one did you approve without reading? which rule got bypassed, and why?* — labeled **PROJECT** (stays in that project's workflow) or **PLAYBOOK**. PLAYBOOK lessons accumulate in **`PLAYBOOK-FEEDBACK.md`** (ships with every template): a methodology-only log the project fills as it goes; at project end you hand that one file back to this repo and the playbook versions up. Its header carries an **intake protocol**, so entries are critically reviewed — verified, filtered, adopted/adapted/rejected one by one — never blindly applied. Gates are calibrated, not only added: a gate that keeps getting rubber-stamped is lightened; one that catches real problems stays heavy.
