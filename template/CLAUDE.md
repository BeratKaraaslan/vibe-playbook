# <PROJECT NAME> — CLAUDE.md

> Keep LEAN (~50 lines): doc map + critical rules. Process details: [workflow.md](workflow.md).

## Project

<one sentence — filled during Phase 0>

- Stack: <Phase 0> · Test: `<command>` · Lint: `<command>` · Typecheck: `<command>`

## Scale & pragmatism

<Phase 0: one honest line about scale + explicit NON-goals — e.g. "side-project scale: standard security hygiene YES; gold-plating, heavy compliance flows, premature scaling NO." This is the calibration against over-engineering; it is read every session.>

## Doc map (what loads when)

- `progress.md` + `issues.md` → at the start of every session
- `module-specs/<part>.md` → while working on that part (**single source of truth**)
- `architecture.md` / `data-model.md` → when relevant
- `infra-state.md` → ops/deploy work
- `workflow.md` → process questions
- `PLAYBOOK-FEEDBACK.md` → at retros, or the moment a methodology observation occurs (never project state)
- `docs/archive/*` · `docs/ops/*` → **NEVER automatically** — only on request

## Critical rules (NEVER violate)

1. **Nothing enters main without GATE 4.** Work flows on a part branch (`wip/P-N`); small checkpoint commits are free and encouraged. *(Enforced by the main-guard hook; docs-only commits on main are allowed.)*
2. **Git safety:** with uncommitted work, NEVER `git restore/stash/clean/checkout --`; ask before destructive ops (force/reset/branch delete).
3. **Secrets:** never access `.env` in ANY form — direct read/write, subcommand (cat/cp/source), glob, script *(enforced by guard-env hook)*; only `.env.example` is yours. Never hardcode values. Need a value → `NEEDS-FROM-USER.md` + STOP; the human places it. **On a guard-env block: STOP immediately — never retry via another path; report to the user and WAIT for their approval.** **Leak protocol:** if the user pastes a sensitive value into chat (DB URL, API key…) → NEVER repeat it, never write it to any file/doc/command; if it landed anywhere, delete it IMMEDIATELY; notify the user + **recommend rotation** (chat history cannot be truly deleted — rotation is the only permanent fix); the right place is `.env`/panel, and the human places it. *(The secret-scan hook reminds you.)*
4. **DO NOT ASSUME:** product decision → ask the user; technical unknown you cannot decide → `open-questions.md`.
5. **Golden rule:** structural decisions are never just mentioned inline — they are **written into** the relevant doc.
6. **Anti-confabulation:** answer "why X?" from the docs; if it is not in the docs, say **"not recorded"** — never invent.
7. **Tests:** external-service/LLM calls are **mock-first**; real calls only via a controlled measurement script.
8. **STOP at gates:** 🚦 steps belong to the human — never continue without approval.
9. **Stay in context (question ≠ status report):** answer a mid-phase question with **the short answer requested** — do not re-dump the whole phase workflow/status every time. Full status only when asked or at gates.
10. **Working-tree isolation:** only **ONE active dev session per directory** — parallel parts run in **separate git worktrees** (the kickoff specifies). Checkpoint commit before any branch switch; never touch another part's files.
11. **English-only docs:** ALL documentation (living-docs, specs, runbooks, commit messages, code comments) is written in **English**, regardless of chat language — chat follows the user's language. Rationale: fewer tokens, stronger instruction-following, consistent terminology across sessions.
