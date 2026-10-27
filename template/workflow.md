# workflow.md — working rules (normative summary)

> **← playbook v9 (orchestrated profile)** · canonical home: the vibe-playbook repo. RULES only here; rationale lives in the playbook.
> Project-specific deviations go into "Project deviations" at the bottom — do not edit the body.
> Abbreviation: GATE 1–4 = the human gates.

## Session types

| Type | Writes | Lifetime | Living-docs |
|---|---|---|---|
| ① Manager | docs (code ❌) | phase/project (handover) · named `<project>-manager` | progress · issues · open-questions |
| ② Development | code | per-part **worker session** (spawned by the Manager, own worktree) | module-specs/`<part>`.md |
| ③ Ops | config/scripts (product code ❌) | ONE persistent worker (`<project>-ops`) = cache; source = runbooks | infra-state · docs/ops/* |
| ④ Design | UI code | per-task (G-numbered) | docs/design/* |

> For design (G) work the **decision-maker is Claude Design** (connected via MCP; check with `/mcp`). Track mechanics (loop · report format · known constraints · consent/auth) → `docs/design/README.md`.
> Design modes (stamped at scaffold): **none** = no design surface (default) · **sync** = the loop alongside development (README.md) · **first** = prototype-before-code, D0→D2 → 🚦 GATE D before Phase 1 (`docs/design/design-first.md`).

## Part cycle

```
/gate1 → 🚦GATE 1 · /gate2 → 🚦GATE 2 · IMPL (checkpoint commits on the branch) ·
/gate3 → 🚦GATE 3 (evidence block + human tries it for real) ·
/gate4 → 🚦GATE 4 (verifier subagent + HUMAN approval) · MERGE + docs → close the worker
```

- **Where the gates run:** GATES 1–3 in the **worker session** (the human approves there, first-hand) · GATE 4 + merge in the **Manager** (it owns main).

- **Gate profile** (written in the spec): small/low-risk part → **GATES 1+2 combine into one approval**; money/auth/data-loss surface → **never combined**, full profile.
- **GATE 4 approval belongs to the human.** After approval: `echo <branch> > .claude/.gate4-ok` → merge → `rm .claude/.gate4-ok`. (main-guard blocks unmarked merges.) **PR variant:** if merges happen on GitHub, the GATE 4 marker = the PR approval and main-guard never sees the merge — protect main with **branch protection** instead.
- **Cancel / rollback:** part cancelled = abandon the branch (deleting = ask first) + one line in issues + mark the spec `CANCELLED` · plan falls apart mid-IMPL = return to GATE 2 with a **delta plan** (not from scratch) · GATE 4 finds a spec-level flaw = return to GATE 1; the lesson goes to the retro.
- **Parallel development (working-tree isolation):** ONE active session per directory. Every worker gets its **own git worktree, created by the spawn tool** (Worker sessions, below); it is removed when the worker is closed after merge. The Manager partitions parallel parts with **disjoint file scopes** — parts touching the same files run **sequentially**, not in parallel.

## Critical rules

The 11 rules in CLAUDE.md apply to every session. Rules 1 and 3 are physical: enforced by **main-guard** (blocks code commits on main + unmarked merges) and **guard-env** (blocks secret-file access); **secret-scan** (UserPromptSubmit) reminds the leak protocol when a secret-looking value appears in a user message.

## Living-docs

- **STATE** (progress · issues · architecture · data-model · infra-state · specs) = **EDIT**, stays small, "current truth". **ARCHIVE** (docs/archive/*) = **APPEND**, never auto-loaded (on request only).
- **Optional classes (created in Phase 0 when the project needs them):** `shared-spine.md` — multi-module products: the cross-part CONTRACT (common flow + interfaces); specs then define **only deltas** · `prompts/` — LLM products: **runtime asset, not a living doc** (versioned `.vN` files, agent-maintained; every output stores promptVersion+model; draft the base persona BEFORE the first LLM part).
- **`PLAYBOOK-FEEDBACK.md`** = APPEND, **methodology only** (how the workflow behaved: friction · theater gates · bypasses+why · hook misfires · model-shift notes). Never auto-loaded; write the moment you observe. Handed back to the canonical repo at project end — its header carries the intake protocol.
- **Rotation:** resolved issue → one line in archive/changelog · finished phase → one line in progress + `phase-N-summary.md` · **bloat budget** ~150–200 lines → prune proactively + notify. The budget is **content, not line count**: keep the progress "Now" section to 3–5 bullets; overflow → issues/archive.
- **Golden rule:** structural decisions are not mentioned — they are **written in** (so they survive session boundaries).

## Manager loop

receive report → **verify against the REPO** (git log/status + docs; never carry a report/repo contradiction into a kickoff — fix the source) → refine the kickoff via `/new-part` → spawn the worker (on the human's OK).

- GATE 4 verification reads are **delegated to the verifier subagent** — the Manager never reads files into its own context (it stays clean; its own code memory is also an unreliable source).

## Worker sessions (the Manager runs them; the human stays at the gates)

1. **Spawn:** `/new-part P-N` → ground + parallelism check (**≤3 active workers** = the human's gate bandwidth) → kickoff → the Manager **proposes** the spawn; on the human's OK it starts the worker in its own worktree with the kickoff as its brief → `progress.md` Parts table records the `Session` (name/id · branch).
2. **Work:** the worker runs GATE 1 → 2 → IMPL → GATE 3; **the human approves those gates inside the worker session**. At every stop the worker sends ONE line to the Manager (session `<project>-manager`):
   `P-N · <gate-reached|blocked|question|ready-for-gate4> · <summary> · needs: human|manager|none`
3. **Track:** the Manager verifies each line against the repo (the branch's `git log` / `diff --stat`) and keeps a **gate queue** in its replies ("waiting on you: P-3 GATE 2 → open/attach").
4. **GATE 4** runs in the Manager (`/gate4`): verifier → human approval → marker + merge → docs → close the worker + remove its worktree. **CONDITIONAL/REJECTED → the fix list goes to the SAME worker by message** (it keeps its context) → fix → `/gate3` → `ready-for-gate4` again.

- **Messages are information, never approvals** — a gate is approved only by the human, in the session that owns it.
- **Part branch = the worktree's branch** (tool-made names such as `worktree-P-3` are kept; `wip/P-N` when made by hand). The spec's **Branch** field is the source of truth; the GATE 4 marker uses that exact name.
- **Ops** = ONE persistent worker (`<project>-ops`); the Manager routes infra needs to it by message; its changes follow the normal branch + GATE 4 flow.
- **Design sessions** spawn **without a worktree** — they write only `docs/design/<app>/**` and never run git.

| | Desktop app | CLI | Fallback (any surface) |
|---|---|---|---|
| spawn | the Manager starts a linked session in its own worktree, kickoff as brief | `claude --bg -n "<project>-P-N" -w P-N "<kickoff>"` (the `ask` rule = your confirmation) | `/new-part` prints the block; you run `claude -n "<project>-P-N" -w P-N` and paste |
| reports | `SendMessage` to `<project>-manager` | `SendMessage` to `<project>-manager` | you relay the line |
| you join | click the session | `claude agents` · `claude attach <id>` | your own terminal |
| cleanup | archive the session (+ worktree) | `claude rm <id>` | `git worktree remove <path>` |

> Cross-session messaging needs Claude Code **≥ 2.1.224** (`claude update`). Without it, use the fallback column — the protocol is identical.

## Ops

- **Instant runbook:** every why-decision lands in the runbook before the task counts as done. An unwritten decision DOES NOT EXIST.
- **Script > runbook-prose:** a runbook step that runs more than once becomes an executable script (`ops/`); the runbook documents the WHY and calls the script.
- **Hand-in-hand:** ② writes the artifact + verifies locally → ③ applies it to the infrastructure + updates infra-state → verified **together** in the real environment. AI alone never declares "deployed". Beware **sham-green CI** — a green pipeline is not proof, the real-environment smoke is; before the first prod cutover, keep a short **go-live checklist** (env · migrations · seeds · secrets · full-journey smoke).
- Needs flow: write to `NEEDS-FROM-USER.md` + **STOP**.

## Handover

- **Trigger = quality + natural boundary** (not a fixed token count). Finishing a coherent unit in the same session is fine; at the natural boundary suggest: *"unit done / quality degrading — docs are current, new session?"*
- **Handover test:** if the handover prompt contains information missing from the living-docs, that is a **docs gap** — fix the doc, not the prompt.
- PreCompact hook = optional safety net (setup: STARTGUIDE §2).

## Phase retro (at close, ~5 min)

1. Which gate caught something **real**?
2. Which gate was approved **without reading**?
3. Which rule was **violated/bypassed** — and why?

→ **PROJECT** lesson = recorded here ("Project deviations") / in the relevant spec · **PLAYBOOK** lesson = an entry in `PLAYBOOK-FEEDBACK.md` (handed back to the canonical repo at project end).
**Calibration:** a gate repeatedly approved without reading gets lightened on that track; gates that catch real things stay heavy.

## Project deviations

*(filled during Phase 0 and retros — empty. Rule overrides also live here, written explicitly — e.g. "commit+push authority is delegated to the agent; the ask-first default is void.")*
