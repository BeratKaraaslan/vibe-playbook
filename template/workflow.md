# workflow.md — working rules (normative summary)

> **← playbook v6 (orchestrated profile)** · canonical home: the vibe-playbook repo. RULES only here; rationale lives in the playbook.
> Project-specific deviations go into "Project deviations" at the bottom — do not edit the body.
> Abbreviation: GATE 1–4 = the human gates.

## Session types

| Type | Writes | Lifetime | Living-docs |
|---|---|---|---|
| ① Manager | docs (code ❌) | phase/project (handover) | progress · issues · open-questions |
| ② Development | code | per-part (fresh) | module-specs/`<part>`.md |
| ③ Ops | config/scripts (product code ❌) | persistent = cache; source = runbooks | infra-state · docs/ops/* |
| ④ Design | UI code | per-task (G-numbered) | docs/design/* |

> For design (G) work the **decision-maker is Claude Design** (connected via MCP). The connection requires Claude Code **in the terminal (CLI)** — mandatory.

## Part cycle

```
/spec → 🚦GATE 1 · /plan → 🚦GATE 2 · IMPL (checkpoint commits on the branch) ·
/gate3 → 🚦GATE 3 (evidence block + human tries it for real) ·
/review → 🚦GATE 4 (verifier subagent + HUMAN approval) · MERGE + docs → new session
```

- **Gate profile** (written in the spec): small/low-risk part → **GATES 1+2 combine into one approval**; money/auth/data-loss surface → **never combined**, full profile.
- **GATE 4 approval belongs to the human.** After approval: `echo <branch> > .claude/.gate4-ok` → merge → `rm .claude/.gate4-ok`. (main-guard blocks unmarked merges.)
- **Cancel / rollback:** part cancelled = abandon the branch (deleting = ask first) + one line in issues + mark the spec `CANCELLED` · plan falls apart mid-IMPL = return to GATE 2 with a **delta plan** (not from scratch) · GATE 4 finds a spec-level flaw = return to GATE 1; the lesson goes to the retro.
- **Parallel development (working-tree isolation):** ONE active session per directory. Parallel parts run in separate **git worktrees**: `git worktree add ../<project>-<part> wip/<part>` (the kickoff specifies); after merge `git worktree remove ../<project>-<part>`. The Manager partitions parallel parts with **disjoint file scopes** — parts touching the same files run **sequentially**, not in parallel.

## Critical rules

The 11 rules in CLAUDE.md apply to every session. Rules 1 and 3 are physical: enforced by **main-guard** (blocks code commits on main + unmarked merges) and **guard-env** (blocks secret-file access); **secret-scan** (UserPromptSubmit) reminds the leak protocol when a secret-looking value appears in a user message.

## Living-docs

- **STATE** (progress · issues · architecture · data-model · infra-state · specs) = **EDIT**, stays small, "current truth". **ARCHIVE** (docs/archive/*) = **APPEND**, never auto-loaded (on request only).
- **Rotation:** resolved issue → one line in archive/changelog · finished phase → one line in progress + `phase-N-summary.md` · **bloat budget** ~150–200 lines → prune proactively + notify.
- **Golden rule:** structural decisions are not mentioned — they are **written in** (so they survive session boundaries).

## Manager loop

receive report → **verify against the REPO** (git log/status + docs; never carry a report/repo contradiction into a kickoff — fix the source) → refine the kickoff via `/new-part` → run it in a fresh session.

- GATE 4 verification reads are **delegated to the verifier subagent** — the Manager never reads files into its own context (it stays clean; its own code memory is also an unreliable source).

## Ops

- **Instant runbook:** every why-decision lands in the runbook before the task counts as done. An unwritten decision DOES NOT EXIST.
- **Hand-in-hand:** ② writes the artifact + verifies locally → ③ applies it to the infrastructure + updates infra-state → verified **together** in the real environment. AI alone never declares "deployed".
- Needs flow: write to `NEEDS-FROM-USER.md` + **STOP**.

## Handover

- **Trigger = quality + natural boundary** (not a fixed token count). Finishing a coherent unit in the same session is fine; at the natural boundary suggest: *"unit done / quality degrading — docs are current, new session?"*
- **Handover test:** if the handover prompt contains information missing from the living-docs, that is a **docs gap** — fix the doc, not the prompt.
- PreCompact hook = optional safety net (setup: STARTGUIDE §2).

## Phase retro (at close, ~5 min)

1. Which gate caught something **real**?
2. Which gate was approved **without reading**?
3. Which rule was **violated/bypassed** — and why?

→ **PROJECT** lesson = recorded here ("Project deviations") / in the relevant spec · **PLAYBOOK** lesson = changelog candidate for the canonical repo.
**Calibration:** a gate repeatedly approved without reading gets lightened on that track; gates that catch real things stay heavy.

## Project deviations

*(filled during Phase 0 and retros — empty)*
