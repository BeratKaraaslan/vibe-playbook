# STARTGUIDE — new project setup (for the human)

> Source: vibe-playbook v6 `template/` (orchestrated profile). Total time ~10 min.
> **Audience: software developers** — you will read specs/diffs, approve gates, and coordinate sessions.
> **Vibe coder?** → `template-solo/` (one session; the agent drives the mechanics).
> Process rules: [workflow.md](workflow.md) · rationale: the canonical playbook repo.
> Language: chat with the agents in any language — **all docs are written in English** (CLAUDE.md rule 11).

## 1. Scaffold (2 min)

Easiest — via npm (renames `gitignore`, chmods hooks for you):

```bash
npx vibe-playbook init orchestrated <new-project>
cd <new-project>
git init && git add -A && git commit -m "scaffold: playbook v6 template"
```

Or copy manually from a clone:

```bash
cp -R <vibe-playbook>/template/. <new-project>/
cd <new-project>
mv gitignore .gitignore        # shipped without the dot (npm packaging constraint)
chmod +x .claude/hooks/*.sh
git init && git add -A && git commit -m "scaffold: playbook v6 template"
```

## 2. Adapt (5 min)

- **CLAUDE.md:** project name/one-liner + Test/Lint/Typecheck commands (once the stack is locked).
- **.claude/settings.json:** replace the `npm` examples in the allow list to match your stack.
- **Optional:**
  - Using the design track: **connect the Claude Design MCP** — the design decision-maker is Claude Design and the connection requires Claude Code **in the terminal (CLI)** (**mandatory**; run G work from the terminal, not desktop/IDE). Not using it: `docs/design/` can be deleted.
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

All docs in English (CLAUDE.md rule 11); chat follows my language.
EXIT 🚦 PHASE 0 GATE (the biggest one): present all docs for my approval; decisions lock here.
FIRST STEP: extract the questions you will ask me about the PRD — before doing anything else.
```

## 4. Daily flow (summary)

- **New part:** `/new-part P-N` in the manager session → paste the kickoff block into a **fresh** session.
- **Parallel parts:** each runs in its **own worktree directory** (the kickoff says so) — never run two sessions in one directory; that is the root of conflicts and code loss.
- **Pasting secrets:** never paste real values into chat — "ready, in .env" is enough. If you paste one by accident, the agent applies the leak protocol (does not spread the value, deletes it wherever it was written, **recommends rotation** — chat history cannot be unsaid; rotation is the only permanent fix).
- **Gates:** GATE 1/2 approval is yours · `/gate3` evidence + try it for real (GATE 3) · `/review` + approval marker (GATE 4).
- **GATE 4 marker:** on approval the session runs `echo <branch> > .claude/.gate4-ok` → merge → marker removed. main-guard blocks unmarked merges anyway.
- **Ops work:** separate Ops session; sync via `NEEDS-FROM-USER.md` + `infra-state.md`.
- **Phase close:** retro — 3 questions (workflow.md).
