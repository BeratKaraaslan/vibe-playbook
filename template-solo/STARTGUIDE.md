# STARTGUIDE — new project setup, SOLO mode (for the human)

> Source: vibe-playbook v9 `template-solo/`. Total time ~10 min.
> **Audience: vibe coders** — and developers who want low ceremony. You do NOT need git/terminal expertise beyond pasting the blocks below: the agent drives branches, commits, and merges; **you steer in plain language and approve at the gates**. The one thing no template removes: the gates ask for your judgment ("is this what I asked for? does it work when I try it?") — that judgment is the safety backbone, especially around money/auth.
> **Solo = ONE session + subagents.** Serial flow. Need parallel tracks (client/backend/design at once)? Use `template/` (orchestrated) — or switch later; the living-docs are identical.
> **Keep Claude Code current** (`claude update`): this profile assumes background subagents (≥ 2.1.198).
> Language: chat in any language — **all docs are written in English** (CLAUDE.md rule 11).

## 1. Scaffold (2 min)

Easiest — via npm (renames `gitignore`, chmods hooks for you):

```bash
npx vibe-playbook init solo <new-project>
cd <new-project>
git init && git add -A && git commit -m "scaffold: playbook v9 solo template"
```

Or copy manually from a clone:

```bash
cp -R <vibe-playbook>/template-solo/. <new-project>/
cd <new-project>
mv gitignore .gitignore        # shipped without the dot (npm packaging constraint)
chmod +x .claude/hooks/*.sh
rm -rf _overlays               # design-mode machinery: manual copy = sync; for first/none see README "Three design modes"
git init && git add -A && git commit -m "scaffold: playbook v9 solo template"
```

## 2. Adapt (5 min)

> The mechanical minimum is below. The DEEP adaptation — domain-expert agents, verifier invariants, stack allow-list, optional doc classes — happens inside Phase 0 via **`/adapt`** (its proposal rides the Phase 0 gate; re-run it when a new domain surface appears mid-project).

- **CLAUDE.md:** project name/one-liner + Test/Lint/Typecheck commands (once the stack is locked).
- **.claude/settings.json:** replace the `npm` examples in the allow list to match your stack.
- **Permissions are deliberately WIDE in this profile** (file edits, `git commit`, `git merge` are pre-allowed) so the agent flows between gates without prompting you — your control points are the GATES; the invariants are hook-guarded (main-guard, guard-env). Prefer more prompts? Tighten the allow list.
- **First run must be interactive:** Claude Code applies project permissions (including the wide ones above) only after you accept the workspace-trust prompt — open `claude` in the directory once before any headless use.
- **Verifier model:** pinned to a strong model (`opus`, `effort: high`) because GATE 4 is rare and quality-critical; optional upgrade: `model: fable`; budget-sensitive? edit `model:` in `.claude/agents/verifier.md`.
- **Protected branches:** main-guard protects `main`/`master` by default; using `trunk`/`develop`? set `VIBE_PROTECTED_BRANCHES` or edit the line at the top of `.claude/hooks/main-guard.sh`.
- **High-assurance work:** the hooks are accident guards, NOT security boundaries. For hard guarantees add GitHub/GitLab **branch protection**, run GATE 3 / verifier tests in a **clean CI runner** (a reviewed branch's test code is that branch's code), and consider **Claude Code sandboxing** for OS-level file/network limits. For an untrusted branch, isolate the **verifier**: add `isolation: worktree` to `.claude/agents/verifier.md` (a throwaway worktree) and/or turn on the session **`sandbox`** setting (`enabled` · `failIfUnavailable` · `allowUnsandboxedCommands: false` · `filesystem`/`credentials`/`network` denies) — otherwise a branch's test code runs on your host. Put **`.claude/**` under CODEOWNERS / required review**: the control plane deserves the same scrutiny as code. **Auto mode** (the default start mode since Claude Code 2.1.283) does not replace these: its classifier allows `.env` reads and pushes to the default branch — our hooks + deny/ask rules remain the only secret/branch controls.
- **PreCompact hook is ON by default** in solo mode (a long session will compact; the snapshot safety net should be there). Remove it from settings.json only if you really want to.
- Design track (modes `sync`/`first`): the scaffold ships a project-scope **`.mcp.json`** for the **claude-design** MCP — every session in this directory inherits it, but first use still asks EACH user for one interactive approval (a checked-in settings.json cannot pre-approve it); design-system access = `/design-login`, writes = `/design consent` (an ongoing grant; revoke with `/design revoke`). The design decision-maker is Claude Design; the endpoint in `.mcp.json` is undocumented — verify the connection with `/mcp`. *(2026-10: the standalone Claude Design site closes **2026-12-14** — new designs become claude.ai artifacts and standalone project links stop working; where the Design template is enabled, `/design <brief>` from Claude Code creates one directly and is the preferred birth path.)* `--design none` scaffolds ship no design files — the mode is stamped in `.claude/.vibe-playbook`. *(User-scope alternative: `claude mcp add --scope user --transport http claude-design https://api.anthropic.com/v1/design/mcp`.)*

## 3. Start Phase 0

Open a Claude session in the project directory and paste:

```
You are this project's SOLO ORCHESTRATOR session. Role and rules: workflow.md + CLAUDE.md (auto-loaded).

Your behavior contract is the "Orchestrator contract" section of CLAUDE.md (it reloads after
/clear — behavior lives in CLAUDE.md, state lives in the docs).

PHASE 0 = PLANNING — no code, no subagent dispatches. Order of work:
1. Q&A with me: clarify the problem/scope → fill PRD.md
2. Technical decisions (proposal with rationale + my approval) → architecture.md + data-model.md
3. Split the work into parts (P code / G design) → progress.md table + module-spec skeletons
4. open-questions.md + NEEDS-FROM-USER.md: everything left open
   (DO NOT ASSUME — ask me for product decisions)
5. Run /adapt — derive the project-specific .claude configuration (domain experts?
   verifier invariants? stack allow-list? optional doc classes?); the proposal joins
   the approval package below

All docs in English (CLAUDE.md rule 11); chat follows my language.
EXIT 🚦 PHASE 0 GATE (the biggest one): present all docs for my approval; decisions lock here.
Then run /tidy — the docs become the ground truth and I may /compact before Phase 1.
FIRST STEP: extract the questions you will ask me about the PRD — before doing anything else.
```

## 3b. Design-first start (only `--design first` scaffolds)

After the Phase 0 gate, paste this into the SAME session (full mechanics: `docs/design/design-first.md`):

```
Design phase (design-first mode) — you are still the SOLO ORCHESTRATOR. Read docs/design/design-first.md.
D0: distill the ~15-line design brief from PRD/architecture — never paste the full docs into the design tool.
D1: draft the birth prompt into docs/design/prompts/ (STATUS: DRAFT) and STOP — I will start the project
    (paste it into a new Claude Design chat, or /design <brief> where the Design template is enabled),
    review the first build, and drop the <app>-mcp.text pointer file.
After the pointer exists: consent via /design consent (ongoing grant), then drive D2 packages via MCP — one consolidated revise per
package (PART A–D), max 2 big turns, then micro-fix batches. Business rules we settle along the way are
written into architecture.md / data-model.md / module-spec skeletons in the same session (golden rule).
EXIT 🚦 GATE D: all prototypes approved by me + flows/rules in the living docs → Phase 1.
```

## 4. Daily flow (summary)

- **A part:** `/part P-N` — the session drives spec→gates→implementer→verify→merge, stopping at every 🚦 for you. Between gates it does NOT prompt you (wide permissions; hooks guard the invariants); dispatches go in batches (small part = whole plan in one go). The implementer runs in the background — you can keep chatting; the session waits for its completion notice before touching git or a gate.
- **Your context stays clean automatically:** questions go to the scout, code changes to the implementer, GATE 4 to the verifier — you read compact reports, not file dumps.
- **After every merge:** the session runs `/tidy` and offers the reset — **`/clear` at part boundaries (recommended: the solo "fresh session"; it resumes from CLAUDE.md + docs)**, `/compact` mid-part. If you do nothing, auto-compaction is still covered by the PreCompact snapshot.
- **Pasting secrets:** never paste real values into chat — "ready, in .env" is enough. If you paste one by accident, the agent applies the leak protocol (does not spread it, deletes it where written, **recommends rotation**).
- **Gates:** GATE 1/2 approval is yours · `/gate3` evidence + try it for real (GATE 3) · `/gate4` + approval marker (GATE 4; main-guard blocks unmarked merges anyway).
- **Ops work:** inline, same session — runbook + infra-state discipline unchanged; a finished ops block is a natural compact point.
- **Phase close:** retro — 3 questions (workflow.md); PLAYBOOK-labeled lessons accumulate in `PLAYBOOK-FEEDBACK.md`.
- **Project end:** hand `PLAYBOOK-FEEDBACK.md` back to the canonical vibe-playbook repo (open a session there, give it the file) — your workflow improves with every project; the intake protocol inside the file prevents blind application.
