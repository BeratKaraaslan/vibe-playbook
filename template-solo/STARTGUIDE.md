# STARTGUIDE — new project setup, SOLO mode (for the human)

> Source: vibe-playbook v8 `template-solo/`. Total time ~10 min.
> **Audience: vibe coders** — and developers who want low ceremony. You do NOT need git/terminal expertise beyond pasting the blocks below: the agent drives branches, commits, and merges; **you steer in plain language and approve at the gates**. The one thing no template removes: the gates ask for your judgment ("is this what I asked for? does it work when I try it?") — that judgment is the safety backbone, especially around money/auth.
> **Solo = ONE session + subagents.** Serial flow. Need parallel tracks (client/backend/design at once)? Use `template/` (orchestrated) — or switch later; the living-docs are identical.
> Language: chat in any language — **all docs are written in English** (CLAUDE.md rule 11).

## 1. Scaffold (2 min)

Easiest — via npm (renames `gitignore`, chmods hooks for you):

```bash
npx vibe-playbook init solo <new-project>
cd <new-project>
git init && git add -A && git commit -m "scaffold: playbook v8 solo template"
```

Or copy manually from a clone:

```bash
cp -R <vibe-playbook>/template-solo/. <new-project>/
cd <new-project>
mv gitignore .gitignore        # shipped without the dot (npm packaging constraint)
chmod +x .claude/hooks/*.sh
git init && git add -A && git commit -m "scaffold: playbook v8 solo template"
```

## 2. Adapt (5 min)

- **CLAUDE.md:** project name/one-liner + Test/Lint/Typecheck commands (once the stack is locked).
- **.claude/settings.json:** replace the `npm` examples in the allow list to match your stack.
- **Permissions are deliberately WIDE in this profile** (file edits, `git commit`, `git merge` are pre-allowed) so the agent flows between gates without prompting you — your control points are the GATES; the invariants are hook-guarded (main-guard, guard-env). Prefer more prompts? Tighten the allow list.
- **First run must be interactive:** Claude Code applies project permissions (including the wide ones above) only after you accept the workspace-trust prompt — open `claude` in the directory once before any headless use.
- **Verifier model:** pinned to a strong model (`opus`) because GATE 4 is rare and quality-critical; budget-sensitive? edit `model:` in `.claude/agents/verifier.md`.
- **Protected branches:** main-guard protects `main`/`master` by default; using `trunk`/`develop`? set `VIBE_PROTECTED_BRANCHES` or edit the line at the top of `.claude/hooks/main-guard.sh`.
- **PreCompact hook is ON by default** in solo mode (a long session will compact; the snapshot safety net should be there). Remove it from settings.json only if you really want to.
- Using the design track: **connect the Claude Design MCP** — the design decision-maker is Claude Design; the connection requires Claude Code **in the terminal (CLI)** (mandatory). Not using it: delete `docs/design/`.

## 3. Start Phase 0

Open a Claude session in the project directory and paste:

```
You are this project's SOLO ORCHESTRATOR session. Role and rules: workflow.md + CLAUDE.md (auto-loaded).

FIRST TASK: read memory-seed/solo-session-pattern.md and save it to your memory
(it must survive /clear — behavior lives in memory, state lives in the docs).

PHASE 0 = PLANNING — no code, no subagent dispatches. Order of work:
1. Q&A with me: clarify the problem/scope → fill PRD.md
2. Technical decisions (proposal with rationale + my approval) → architecture.md + data-model.md
3. Split the work into parts (P code / G design) → progress.md table + module-spec skeletons
4. open-questions.md + NEEDS-FROM-USER.md: everything left open
   (DO NOT ASSUME — ask me for product decisions)

All docs in English (CLAUDE.md rule 11); chat follows my language.
EXIT 🚦 PHASE 0 GATE (the biggest one): present all docs for my approval; decisions lock here.
Then run /tidy — the docs become the ground truth and I may /compact before Phase 1.
FIRST STEP: extract the questions you will ask me about the PRD — before doing anything else.
```

## 4. Daily flow (summary)

- **A part:** `/part P-N` — the session drives spec→gates→implementer→verify→merge, stopping at every 🚦 for you. Between gates it does NOT prompt you (wide permissions; hooks guard the invariants); dispatches go in batches (small part = whole plan in one go).
- **Your context stays clean automatically:** questions go to the scout, code changes to the implementer, GATE 4 to the verifier — you read compact reports, not file dumps.
- **After every merge:** the session runs `/tidy` and offers the reset — **`/clear` at part boundaries (recommended: the solo "fresh session"; it resumes from docs + memory)**, `/compact` mid-part. If you do nothing, auto-compaction is still covered by the PreCompact snapshot.
- **Pasting secrets:** never paste real values into chat — "ready, in .env" is enough. If you paste one by accident, the agent applies the leak protocol (does not spread it, deletes it where written, **recommends rotation**).
- **Gates:** GATE 1/2 approval is yours · `/gate3` evidence + try it for real (GATE 3) · `/gate4` + approval marker (GATE 4; main-guard blocks unmarked merges anyway).
- **Ops work:** inline, same session — runbook + infra-state discipline unchanged; a finished ops block is a natural compact point.
- **Phase close:** retro — 3 questions (workflow.md); PLAYBOOK-labeled lessons accumulate in `PLAYBOOK-FEEDBACK.md`.
- **Project end:** hand `PLAYBOOK-FEEDBACK.md` back to the canonical vibe-playbook repo (open a session there, give it the file) — your workflow improves with every project; the intake protocol inside the file prevents blind application.
