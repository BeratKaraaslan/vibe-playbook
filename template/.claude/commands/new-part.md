---
description: (Manager) Produce a fresh-session kickoff draft from the living-docs
argument-hint: <part-id>
disable-model-invocation: true
---

Produce the kickoff for part $ARGUMENTS.

**Verify the ground FIRST:** `git log/status` + `progress.md` + `module-specs/<part>.md` — the REPO is authoritative, not reports; on contradiction, fix the source first — never carry it into the kickoff.

**Parallelism check:** will this part touch the same files as another ACTIVE part? If they overlap, do NOT start it in parallel — queue it (or re-partition the scope). If disjoint and it will run in parallel, add a **worktree instruction** to the kickoff: `git worktree add ../<project>-<part> wip/<part>` — the work happens in that directory (sharing a working tree is forbidden).

Kickoff skeleton (in this order, everything filled concretely):
1. role + location + part map (from progress)
2. READ FIRST — the source spec = single source of truth + which docs
3. LOCKED decisions (do not change, do not re-ask)
4. working rules: branch (`wip/<part>`) · checkpoints · the CLAUDE.md critical rules
5. order of work (sub-steps)
6. spec-gate micro-decisions: DO NOT ASSUME → ask the user / open-questions
7. concrete GATE 3/4 acceptance lists (copied from the spec)
8. loop + session hygiene (suggest handover at the natural boundary)
9. FIRST STEP (what happens before any code/artifacts)

**Output:** one copy-pasteable block.
**Handover test:** if the block contains information missing from the living-docs, update the doc first, then produce the block.
