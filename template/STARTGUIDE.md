# STARTGUIDE — new project setup (for the human)

> Source: vibe-playbook v9 `template/` (orchestrated profile). Total time ~10 min.
> **Audience: software developers** — you will read specs/diffs and approve gates; the Manager spawns and tracks the worker sessions for you.
> **Claude Code ≥ 2.1.224** for Manager-run sessions (cross-session messaging) — run `claude update`. Older versions work with the fallback (you paste kickoffs and relay reports).
> **Vibe coder?** → `template-solo/` (one session; the agent drives the mechanics).
> Process rules: [workflow.md](workflow.md) · rationale: the canonical playbook repo.
> Language: chat with the agents in any language — **all docs are written in English** (CLAUDE.md rule 11).

## 1. Scaffold (2 min)

Easiest — via npm (renames `gitignore`, chmods hooks for you):

```bash
npx vibe-playbook init orchestrated <new-project>
cd <new-project>
git init && git add -A && git commit -m "scaffold: playbook v9 template"
```

Or copy manually from a clone:

```bash
cp -R <vibe-playbook>/template/. <new-project>/
cd <new-project>
mv gitignore .gitignore        # shipped without the dot (npm packaging constraint)
chmod +x .claude/hooks/*.sh
rm -rf _overlays               # design-mode machinery: manual copy = sync; for first/none see README "Three design modes"
git init && git add -A && git commit -m "scaffold: playbook v9 template"
```

## 2. Adapt (5 min)

> The mechanical minimum is below. The DEEP adaptation — domain-expert agents, verifier invariants, stack allow-list, optional doc classes — happens inside Phase 0 via **`/adapt`** (its proposal rides the Phase 0 gate; re-run it when a new domain surface appears mid-project).

- **CLAUDE.md:** project name/one-liner + Test/Lint/Typecheck commands (once the stack is locked).
- **.claude/settings.json:** replace the `npm` examples in the allow list to match your stack.
- **First run must be interactive:** Claude Code applies project permissions only after you accept the workspace-trust prompt — open `claude` in the directory once before any headless use.
- **Verifier model:** pinned to a strong model (`opus`, `effort: high`) because GATE 4 is rare and quality-critical; optional upgrade: `model: fable`; budget-sensitive? edit `model:` in `.claude/agents/verifier.md`.
- **Protected branches:** main-guard protects `main`/`master` by default; using `trunk`/`develop`? set `VIBE_PROTECTED_BRANCHES` or edit the line at the top of `.claude/hooks/main-guard.sh`.
- **High-assurance work:** the hooks are accident guards, NOT security boundaries. For hard guarantees add GitHub/GitLab **branch protection**, run GATE 3 / verifier tests in a **clean CI runner** (a reviewed branch's test code is that branch's code), and consider **Claude Code sandboxing** for OS-level file/network limits. For an untrusted branch, isolate the **verifier**: add `isolation: worktree` to `.claude/agents/verifier.md` (a throwaway worktree) and/or turn on the session **`sandbox`** setting (`enabled` · `failIfUnavailable` · `allowUnsandboxedCommands: false` · `filesystem`/`credentials`/`network` denies) — otherwise a branch's test code runs on your host. Put **`.claude/**` under CODEOWNERS / required review**: the control plane deserves the same scrutiny as code. **Auto mode** (the default start mode since Claude Code 2.1.283) does not replace these: its classifier allows `.env` reads and pushes to the default branch — our hooks + deny/ask rules remain the only secret/branch controls.
- **Optional:**
  - Design track (modes `sync`/`first`): the scaffold ships a project-scope **`.mcp.json`** for the **claude-design** MCP — every session in this directory inherits it, but first use still asks EACH user for one interactive approval (a checked-in settings.json cannot pre-approve it); design-system access = `/design-login`, writes = `/design consent` (an ongoing grant; revoke with `/design revoke`). The endpoint in `.mcp.json` is undocumented — verify the connection with `/mcp`. *(2026-10: the standalone Claude Design site closes **2026-12-14** — new designs become claude.ai artifacts and standalone project links stop working; where the Design template is enabled, `/design <brief>` from Claude Code creates one directly and is the preferred birth path.)* `--design none` scaffolds ship no design files — the mode is stamped in `.claude/.vibe-playbook`. *(User-scope alternative: `claude mcp add --scope user --transport http claude-design https://api.anthropic.com/v1/design/mcp`.)*
  - **GATE 3 try-outs in worker worktrees** need your local `.env`: a `.worktreeinclude` file (gitignore syntax, e.g. `.env`) makes Claude Code copy it into new worktrees — a harness-side copy, your choice; the agent still never reads it.
  - Want the **PreCompact safety net**: add to `settings.json` → `"hooks"`:

```json
"PreCompact": [
  { "hooks": [ { "type": "command", "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/pre-compact.sh" } ] }
]
```

## 3. Start Phase 0

Open the Manager session **named `<project>-manager`** (CLI: `claude -n <project>-manager`; Desktop: rename the session) — workers address their reports to that name. Paste:

```
You are this project's ① MANAGER session (named <project>-manager). Role and rules:
workflow.md + CLAUDE.md (auto-loaded; the "Manager contract" section is yours).

PHASE 0 = PLANNING — no code. Order of work:
1. Q&A with me: clarify the problem/scope → fill PRD.md
2. Technical decisions (proposal with rationale + my approval) → architecture.md + data-model.md
3. Split the work into parts (P code / G design) → progress.md table + module-spec skeletons
4. phase-kickoffs.md: draft kickoffs for later phases
5. open-questions.md + NEEDS-FROM-USER.md: everything left open
   (DO NOT ASSUME — ask me for product decisions)
6. Run /adapt — derive the project-specific .claude configuration (domain experts?
   verifier invariants? stack allow-list? optional doc classes?); the proposal joins
   the approval package below

All docs in English (CLAUDE.md rule 11); chat follows my language.
EXIT 🚦 PHASE 0 GATE (the biggest one): present all docs for my approval; decisions lock here.
FIRST STEP: extract the questions you will ask me about the PRD — before doing anything else.
```

## 3b. Design-first start (only `--design first` scaffolds)

After the Phase 0 gate, a design phase runs BEFORE Phase 1 (full mechanics: `docs/design/design-first.md`):

1. **D0:** the Manager distills a ~15-line design brief per app (never the full strategy doc) and materializes `docs/design/<app>/`.
2. **D1:** design-system project in Claude Design — 2 art directions → you pick → iterate → LOCK → publish (READ-ONLY canon afterwards).
3. **D2:** `/design-kickoff <app>` in the manager session → on your OK it spawns one design session per app (no worktree — design sessions never run git). **Birth is human-initiated:** the session drafts the opening prompt, YOU start the project (paste it into a new Claude Design chat — or, where the Design template is enabled, `/design <brief>` from Claude Code), review the first build, and drop `docs/design/<app>/<app>-mcp.text` (project URL). Only then does the session take over via MCP (`/design consent` — an ongoing grant) — consolidated revises (PART A–D, ≤2 big turns per package). Your revisions route through the Manager.
4. **EXIT 🚦 GATE D:** every prototype approved by you + flows/rules written into the living docs → Phase 1 (normal per-part gates).

## 4. Daily flow (summary)

- **New part:** `/new-part P-N` in the manager session → it shows the kickoff and proposes the spawn → **you OK it** → the worker starts in its own worktree (Desktop: a linked session · CLI: `claude --bg`). Up to 3 workers at once.
- **Where you are needed:** the Manager keeps a gate queue ("waiting on you: P-3 GATE 2"). Open that worker (Desktop: click it · CLI: `claude agents` → `claude attach <id>`) and approve GATES 1–3 **there**. Worker messages to the Manager are information — never approvals.
- **Never two sessions in one directory** — every worker has its own worktree (the spawn creates it; GATE 4 removes it). That is the root of conflicts and code loss.
- **Pasting secrets:** never paste real values into chat — "ready, in .env" is enough. If you paste one by accident, the agent applies the leak protocol (does not spread the value, deletes it wherever it was written, **recommends rotation** — chat history cannot be unsaid; rotation is the only permanent fix).
- **Gates:** GATES 1–3 in the worker (GATE 3 = `/gate3` evidence + try it for real) · GATE 4 in the **Manager**: `/gate4` (verifier; `full` parts also get `/code-review high`) → your approval → marker + merge → the worker is closed and its worktree removed. CONDITIONAL → the Manager sends the fix list to the same worker.
- **GATE 4 marker:** on approval the Manager runs `echo <branch> > .claude/.gate4-ok` → merge → marker removed. main-guard blocks unmarked merges anyway.
- **Ops work:** ONE persistent Ops worker (`<project>-ops`); the Manager routes infra needs to it; sync via `NEEDS-FROM-USER.md` + `infra-state.md`.
- **No messaging (older Claude Code / other surfaces):** `/new-part` prints the kickoff block; run `claude -n "<project>-P-N" -w P-N`, paste it, and relay the worker's one-line reports to the Manager yourself.
- **Phase close:** retro — 3 questions (workflow.md); PLAYBOOK-labeled lessons accumulate in `PLAYBOOK-FEEDBACK.md`.
- **Project end:** hand `PLAYBOOK-FEEDBACK.md` back to the canonical vibe-playbook repo (open a session there, give it the file) — your workflow improves with every project; the intake protocol inside the file prevents blind application.
