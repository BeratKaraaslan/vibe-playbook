# STARTGUIDE — new project setup (for the human)

> Source: vibe-playbook v8 `template/` (orchestrated profile). Total time ~10 min.
> **Audience: software developers** — you will read specs/diffs, approve gates, and coordinate sessions.
> **Vibe coder?** → `template-solo/` (one session; the agent drives the mechanics).
> Process rules: [workflow.md](workflow.md) · rationale: the canonical playbook repo.
> Language: chat with the agents in any language — **all docs are written in English** (CLAUDE.md rule 11).

## 1. Scaffold (2 min)

Easiest — via npm (renames `gitignore`, chmods hooks for you):

```bash
npx vibe-playbook init orchestrated <new-project>
cd <new-project>
git init && git add -A && git commit -m "scaffold: playbook v8 template"
```

Or copy manually from a clone:

```bash
cp -R <vibe-playbook>/template/. <new-project>/
cd <new-project>
mv gitignore .gitignore        # shipped without the dot (npm packaging constraint)
chmod +x .claude/hooks/*.sh
rm -rf _overlays               # design-mode machinery: manual copy = sync; for first/none see README "Three design modes"
git init && git add -A && git commit -m "scaffold: playbook v8 template"
```

## 2. Adapt (5 min)

> The mechanical minimum is below. The DEEP adaptation — domain-expert agents, verifier invariants, stack allow-list, optional doc classes — happens inside Phase 0 via **`/adapt`** (its proposal rides the Phase 0 gate; re-run it when a new domain surface appears mid-project).

- **CLAUDE.md:** project name/one-liner + Test/Lint/Typecheck commands (once the stack is locked).
- **.claude/settings.json:** replace the `npm` examples in the allow list to match your stack.
- **First run must be interactive:** Claude Code applies project permissions only after you accept the workspace-trust prompt — open `claude` in the directory once before any headless use.
- **Verifier model:** pinned to a strong model (`opus`) because GATE 4 is rare and quality-critical; budget-sensitive? edit `model:` in `.claude/agents/verifier.md`.
- **Protected branches:** main-guard protects `main`/`master` by default; using `trunk`/`develop`? set `VIBE_PROTECTED_BRANCHES` or edit the line at the top of `.claude/hooks/main-guard.sh`.
- **High-assurance work:** the hooks are accident guards, NOT security boundaries. For hard guarantees add GitHub/GitLab **branch protection**, run GATE 3 / verifier tests in a **clean CI runner** (a reviewed branch's test code is that branch's code), and consider **Claude Code sandboxing** for OS-level file/network limits. For an untrusted branch, isolate the **verifier**: add `isolation: worktree` to `.claude/agents/verifier.md` (a throwaway worktree) and/or turn on the session **`sandbox`** setting (`enabled` · `failIfUnavailable` · `allowUnsandboxedCommands: false` · `filesystem`/`credentials`/`network` denies) — otherwise a branch's test code runs on your host. Put **`.claude/**` under CODEOWNERS / required review**: the control plane deserves the same scrutiny as code.
- **Optional:**
  - Design track (modes `sync`/`first`): the scaffold ships a project-scope **`.mcp.json`** for the **claude-design** MCP — every session in this directory inherits it, but first use still asks EACH user for one interactive approval (a checked-in settings.json cannot pre-approve it); auth = `/design-login`, writes = per-session `/design-consent`. The design decision-maker is Claude Design; the connection requires Claude Code **in the terminal (CLI)** (**mandatory**; run G work from the terminal, not desktop/IDE). `--design none` scaffolds ship no design files — the mode is stamped in `.claude/.vibe-playbook`. *(User-scope alternative: `claude mcp add --scope user --transport http claude-design https://api.anthropic.com/v1/design/mcp`.)*
  - Want the **PreCompact safety net**: add to `settings.json` → `"hooks"`:

```json
"PreCompact": [
  { "hooks": [ { "type": "command", "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/pre-compact.sh" } ] }
]
```

## 3. Start Phase 0

Open a fresh Claude session and paste:

```
You are this project's ① MANAGER session. Role and rules: workflow.md + CLAUDE.md (auto-loaded).

FIRST TASK: read memory-seed/manager-session-pattern.md and save it to your memory
(so every future manager session works under the same contract).

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
3. **D2:** `/design-kickoff <app>` in the manager session → paste into a fresh design session per app. **Birth is manual:** the session drafts the opening prompt, YOU paste it into a new Claude Design chat, review the first build in the UI, and drop `docs/design/<app>/<app>-mcp.text` (project URL). Only then does the session take over via MCP (`/design-consent` per session) — consolidated revises (PART A–D, ≤2 big turns per package). Your revisions route through the Manager.
4. **EXIT 🚦 GATE D:** every prototype approved by you + flows/rules written into the living docs → Phase 1 (normal per-part gates).

## 4. Daily flow (summary)

- **New part:** `/new-part P-N` in the manager session → paste the kickoff block into a **fresh** session.
- **Parallel parts:** each runs in its **own worktree directory** (the kickoff says so) — never run two sessions in one directory; that is the root of conflicts and code loss.
- **Pasting secrets:** never paste real values into chat — "ready, in .env" is enough. If you paste one by accident, the agent applies the leak protocol (does not spread the value, deletes it wherever it was written, **recommends rotation** — chat history cannot be unsaid; rotation is the only permanent fix).
- **Gates:** GATE 1/2 approval is yours · `/gate3` evidence + try it for real (GATE 3) · `/gate4` + approval marker (GATE 4).
- **GATE 4 marker:** on approval the session runs `echo <branch> > .claude/.gate4-ok` → merge → marker removed. main-guard blocks unmarked merges anyway.
- **Ops work:** separate Ops session; sync via `NEEDS-FROM-USER.md` + `infra-state.md`.
- **Phase close:** retro — 3 questions (workflow.md); PLAYBOOK-labeled lessons accumulate in `PLAYBOOK-FEEDBACK.md`.
- **Project end:** hand `PLAYBOOK-FEEDBACK.md` back to the canonical vibe-playbook repo (open a session there, give it the file) — your workflow improves with every project; the intake protocol inside the file prevents blind application.
