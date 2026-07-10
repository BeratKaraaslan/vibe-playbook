# workflow.md — working rules (normative summary, SOLO mode)

> **← playbook v7 (solo profile)** · canonical home: the vibe-playbook repo. RULES only here; rationale lives in the playbook.
> Project-specific deviations go into "Project deviations" at the bottom — do not edit the body.
> Abbreviation: GATE 1–4 = the human gates.

## The model

**ONE session = the orchestrator (you).** It plans, dispatches subagents, verifies ground truth, updates the living-docs, and stops at gates. **Product code is never written or read in this context** — subagents carry it:

| Subagent | Does | Returns |
|---|---|---|
| **scout** | read-only codebase Q&A | compact findings + file:line refs |
| **implementer** | ONE part-step: edits code on the part branch, runs tests, checkpoint commit | DONE/BLOCKED + changed files + test result + commit hash + open questions |
| **verifier** | GATE 4 verification from code | VERDICT / EVIDENCE / RISKS / TESTS |

> Hooks (main-guard, guard-env) apply to subagent tool calls too — the guards hold everywhere.
> Design (G) work: the decision-maker is **Claude Design** (MCP; Claude Code **in the terminal** — mandatory). Implementation still goes through the implementer.

## Part cycle

`/part <P-N>` drives a part end to end, stopping at every gate:

```
/spec → 🚦GATE 1 · /plan → 🚦GATE 2 · implementer dispatches (checkpoint commits) ·
/gate3 → 🚦GATE 3 (evidence + human tries it) · /review (verifier) → 🚦GATE 4 ·
merge ritual (.gate4-ok → merge → rm) → /tidy
```

- **Gate profile** (in the spec): small/low-risk → GATES 1+2 combined into one approval; money/auth/data-loss surface → never combined.
- **GATE 4 approval belongs to the human.** After approval: `echo <branch> > .claude/.gate4-ok` → merge → `rm .claude/.gate4-ok`. **PR variant:** if merges happen on GitHub, the GATE 4 marker = the PR approval and main-guard never sees the merge — protect main with **branch protection** instead.
- **Dispatch in batches, not drips:** small part = the whole approved plan in ONE implementer dispatch; larger part = coherent batches of 2–4 steps per dispatch. The implementer makes a **checkpoint commit per step** either way — granular history, few interruptions.
- **Autonomy by design:** the branch lifecycle (create → checkpoints → merge after the GATE 4 marker) runs **without permission prompts** — solo permissions are deliberately wide (file edits, `git commit`, `git merge` pre-allowed). The human control points are the GATES; the invariants are hook-guarded (main-guard, guard-env).
- **After every implementer dispatch, verify the ground:** `git log`/`git diff --stat` vs the report — subagent reports are as fallible as session reports; on contradiction fix the source, never proceed on the report alone.
- **Cancel / rollback:** part cancelled = abandon the branch (deleting = ask first) + one line in issues + mark the spec `CANCELLED` · plan falls apart mid-IMPL = back to GATE 2 with a **delta plan** · GATE 4 finds a spec-level flaw = back to GATE 1; lesson goes to the retro.
- **Serial by design:** one active part, one branch, one writing subagent. Scouts/verifiers may run in parallel (read-only). Need truly parallel tracks → **switch to the orchestrated template**: the living-docs are identical; swap `.claude/` + `workflow.md` and continue where you left off.

## Context hygiene (the heart of solo mode)

1. **Prevent (delegation-first, rule 12):** code never enters this context — scouts answer, implementers change, verifiers check. This context carries decisions, approvals, and one-line summaries.
2. **Make the reset safe (`/tidy`, rule 13):** after merges and ops blocks — docs synced to ground truth, rotation done, chat-only decisions swept into docs → offer the reset: **`/clear` at a part boundary (RECOMMENDED — the solo equivalent of orchestrated's fresh session)**, `/compact` mid-part. The human runs it (one keystroke); **the model cannot reset its own context** — what it can do is keep it from filling, make the reset zero-risk, and ask.
3. **Safety net (PreCompact hook — ON by default in solo):** a long-lived session WILL compact; the ground snapshot lands in `docs/archive/compact-snapshots.md` before it happens. Quality order: `/clear` at a boundary > `/compact` > unplanned auto-compaction (still safe, thanks to the snapshot + docs discipline).

- **Restart test:** after `/clear`, a fresh session must resume from CLAUDE.md + living-docs + memory alone. If it could not, that is a **docs gap** — fix the doc. *(Memory survives `/clear`: behavior lives in memory, state lives in docs, so clearing is cheap.)*

## Critical rules

The 13 rules in CLAUDE.md apply at all times. Rules 1 and 3 are physical: **main-guard** (blocks code commits on main + unmarked merges) and **guard-env** (blocks secret-file access); **secret-scan** (UserPromptSubmit) reminds the leak protocol when a secret-looking value appears in a user message.

## Living-docs

- **STATE** (progress · issues · architecture · data-model · infra-state · specs) = **EDIT**, stays small, "current truth". **ARCHIVE** (docs/archive/*) = **APPEND**, never auto-loaded (on request only).
- **Optional classes (created in Phase 0 when the project needs them):** `shared-spine.md` — multi-module products: the cross-part CONTRACT (common flow + interfaces); specs then define **only deltas** · `prompts/` — LLM products: **runtime asset, not a living doc** (versioned `.vN` files, agent-maintained; every output stores promptVersion+model; draft the base persona BEFORE the first LLM part).
- **Rotation:** resolved issue → one line in archive/changelog · finished phase → one line in progress + `phase-N-summary.md` · **bloat budget** ~150–200 lines → prune proactively + notify. The budget is **content, not line count**: keep the progress "Now" section to 3–5 bullets; overflow → issues/archive.
- **Golden rule:** structural decisions are not mentioned — they are **written in**. In solo mode this is doubly critical: the docs are the only memory that survives compaction and `/clear`.

## Ops

Ops work happens inline in this session (there is no separate ops session), but the discipline is unchanged:
- **Instant runbook:** every why-decision lands in `docs/ops/<runbook>.md` before the task counts as done. An unwritten decision DOES NOT EXIST.
- **Script > runbook-prose:** a runbook step that runs more than once becomes an executable script (`ops/`); the runbook documents the WHY and calls the script.
- `infra-state.md` kept current · needs → `NEEDS-FROM-USER.md` + **STOP** · **hand-in-hand:** "deployed" is never declared by AI alone — verified together in the real environment. Beware **sham-green CI** — a green pipeline is not proof, the real smoke is; before the first prod cutover, keep a short **go-live checklist** (env · migrations · seeds · secrets · full-journey smoke).
- An ops block is a natural `/tidy` (+ compact) point: operational noise is exactly what you want out of the context.

## Phase retro (at close, ~5 min)

1. Which gate caught something **real**?
2. Which gate was approved **without reading**?
3. Which rule was **violated/bypassed** — and why?

→ **PROJECT** lesson = "Project deviations" / the relevant spec · **PLAYBOOK** lesson = changelog candidate for the canonical repo.
**Calibration:** a gate repeatedly approved without reading gets lightened; gates that catch real things stay heavy.

## Project deviations

*(filled during Phase 0 and retros — empty. Rule overrides also live here, written explicitly — e.g. "push authority is delegated to the agent; the ask-first default is void.")*
