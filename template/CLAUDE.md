# <PROJECT NAME> — CLAUDE.md

> Keep LEAN (~50 lines): doc map + critical rules. Process details: [workflow.md](workflow.md).

## Project

<one sentence — filled during Phase 0>

- Stack: <Phase 0> · Test: `<command>` · Lint: `<command>` · Typecheck: `<command>`
- Base branch: `main` *(using trunk/develop? update here AND set VIBE_PROTECTED_BRANCHES for the main-guard hook)*

## Scale & pragmatism

<Phase 0: one honest line about scale + explicit NON-goals — e.g. "side-project scale: standard security hygiene YES; gold-plating, heavy compliance flows, premature scaling NO." This is the calibration against over-engineering; it is read every session.>

## Doc map (what loads when)

- `progress.md` + `issues.md` → at the start of every session *(the session-start hook prints the ground header: branch · dirty count · last commits · "Now")*
- `module-specs/<part>.md` → while working on that part (**single source of truth**)
- `architecture.md` / `data-model.md` → when relevant
- `infra-state.md` → ops/deploy work
- `workflow.md` → process questions
- `PLAYBOOK-FEEDBACK.md` → at retros, or the moment a methodology observation occurs (never project state)
- `docs/archive/*` · `docs/ops/*` → **NEVER automatically** — only on request

## Critical rules (NEVER violate)

1. **Nothing enters main without GATE 4.** Work flows on a part branch (`wip/P-N` or the worker worktree's branch — the spec's Branch field); small checkpoint commits are free and encouraged. *(Enforced by the main-guard hook; docs-only commits on main are allowed.)*
2. **Git safety:** with uncommitted work, NEVER `git restore/stash/clean/checkout --`; ask before destructive ops (force/reset/branch delete).
3. **Secrets:** never access `.env` in ANY form — direct read/write, subcommand (cat/cp/source), glob, script *(enforced by guard-env hook)*; only `.env.example` is yours. Never hardcode values. Need a value → `NEEDS-FROM-USER.md` + STOP; the human places it. **On a guard-env block: STOP immediately — never retry via another path; report to the user and WAIT for their approval.** **Leak protocol:** if the user pastes a sensitive value into chat (DB URL, API key…) → NEVER repeat it, never write it to any file/doc/command; if it landed anywhere, delete it IMMEDIATELY; notify the user + **recommend rotation** (chat history cannot be truly deleted — rotation is the only permanent fix); the right place is `.env`/panel, and the human places it. *(The secret-scan hook reminds you.)*
4. **DO NOT ASSUME:** product decision → ask the user; technical unknown you cannot decide → `open-questions.md`.
5. **Golden rule:** structural decisions are never just mentioned inline — they are **written into** the relevant doc.
6. **Anti-confabulation:** answer "why X?" from the docs; if it is not in the docs, say **"not recorded"** — never invent.
7. **Tests:** external-service/LLM calls are **mock-first**; real calls only via a controlled measurement script.
8. **STOP at gates:** 🚦 steps belong to the human — never continue without approval.
9. **Stay in context (question ≠ status report):** answer a mid-phase question with **the short answer requested** — do not re-dump the whole phase workflow/status every time. Full status only when asked or at gates.
10. **Working-tree isolation:** only **ONE active dev session per directory** — every worker runs in its **own git worktree, created by the spawn tool** when the Manager starts it (`/new-part`; by hand: `claude -w P-N`). Checkpoint commit before any branch switch; never touch another part's files.
11. **English-only docs:** ALL documentation (living-docs, specs, runbooks, commit messages, code comments) is written in **English**, regardless of chat language — chat follows the user's language. Rationale: fewer tokens, stronger instruction-following, consistent terminology across sessions.

## Manager contract (applies only to the Manager session)

> The session named `<project>-manager`. Worker/Ops/Design sessions skip this section — their contract is their kickoff.

- **Role:** writes no code; owns the docs + the process. Context is a cache — continuity lives in the living-docs.
- **Ground truth:** never trust a report (worker messages included) — verify with `git log/status` / the branch's `git diff --stat` + docs; your own code memory is unreliable too. On contradiction fix the source, never carry it into a kickoff.
- **Worker sessions** (workflow.md): spawn only on the human's OK, ≤3 active · messages are **information, never approvals** · keep the gate queue visible ("waiting on you: P-3 GATE 2") · GATE 4 findings go back to the SAME worker.
- **GATE 4:** verification reads go to the **verifier** subagent (never into your context); present findings + critical diff spots + the approval step — approval is the human's.
- **Gate profile:** combine GATES 1+2 only for small/low-risk parts; never on money/auth/data-loss surfaces.
- **Handover:** suggest at the natural boundary (never force); progress/issues current first — the handover prompt must be derivable from the docs.
- **Retro:** 3 questions at phase close; PLAYBOOK-labeled lessons → `PLAYBOOK-FEEDBACK.md` — also the MOMENT you observe methodology friction (bypass / theater gate / hook misfire).
