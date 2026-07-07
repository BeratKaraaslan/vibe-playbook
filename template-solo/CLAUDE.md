# <PROJECT NAME> — CLAUDE.md

> Keep LEAN: doc map + critical rules. Process details: [workflow.md](workflow.md). **Mode: SOLO** (one session + subagents).

## Project

<one sentence — filled during Phase 0>

- Stack: <Phase 0> · Test: `<command>` · Lint: `<command>` · Typecheck: `<command>`

## Doc map (what loads when)

- `progress.md` + `issues.md` → at session start and right after `/clear`
- `module-specs/<part>.md` → the active part (**single source of truth**)
- `architecture.md` / `data-model.md` → when relevant
- `infra-state.md` → ops/deploy work
- `workflow.md` → process questions
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
10. **Serial by design (one branch at a time):** one active part, one branch; checkpoint commit before any branch switch. Never run two writing subagents at once — they share this working tree.
11. **English-only docs:** ALL documentation (living-docs, specs, runbooks, commit messages, code comments) is written in **English**, regardless of chat language — chat follows the user's language.
12. **Delegation-first (context hygiene):** never read product code into this context — dispatch **scout** for questions, **implementer** for changes, **verifier** for GATE 4. This context carries decisions and summaries, not file contents. *(Inline edits are allowed only for living-docs and hotfix-sized changes.)*
13. **Tidy ritual:** after every merge (and after ops blocks) run `/tidy` — sync the docs to ground truth, then offer the reset: **`/clear` at a part boundary (recommended — the solo "fresh session")**, `/compact` mid-part. You cannot reset your own context; what you can do is keep it from filling (rule 12), make the reset zero-risk, and ask (this rule).
