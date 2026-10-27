---
description: (Manager) Produce a worker kickoff from the living-docs and spawn the worker session on the human's OK
argument-hint: <part-id>
disable-model-invocation: true
---

Produce the kickoff for part $ARGUMENTS and start its worker session (workflow.md "Worker sessions").

**Verify the ground FIRST:** `git log/status` + `progress.md` + `module-specs/<part>.md` — the REPO is authoritative, not reports; on contradiction, fix the source first — never carry it into the kickoff.

**Parallelism check:** will this part touch the same files as another ACTIVE part? If they overlap, do NOT start it in parallel — queue it (or re-partition the scope). Already **3 active workers**? Queue it (the human's gate bandwidth). Every worker runs in its OWN worktree — sharing a working tree is forbidden.

Kickoff skeleton (in this order, everything filled concretely):
1. role + location + part map (from progress)
2. READ FIRST — the source spec = single source of truth + which docs
3. LOCKED decisions (do not change, do not re-ask)
4. working rules: branch = this worktree's branch (record it in the spec's Branch field) · checkpoints · the CLAUDE.md critical rules
5. order of work (sub-steps)
6. spec-gate micro-decisions: DO NOT ASSUME → ask the user / open-questions
7. concrete GATE 3/4 acceptance lists (copied from the spec)
8. loop + session hygiene: GATES 1–3 are approved by the human IN THIS SESSION; GATE 4 + merge happen in the Manager — never merge
9. **report protocol:** at every stop send ONE line to `<project>-manager`: `P-N · <gate-reached|blocked|question|ready-for-gate4> · <summary> · needs: human|manager|none` — messages are information, never approvals
10. FIRST STEP (what happens before any code/artifacts)

**Spawn (propose → human OK → start):** show the kickoff, then PROPOSE the spawn and WAIT for the human's OK. On OK, start the worker with the kickoff as its brief, in its own worktree, named `<project>-P-N` — Desktop: a linked session · CLI: `claude --bg -n "<project>-P-N" -w P-N "<kickoff>"`. Then record it in `progress.md` → Parts → `Session` (name/id · branch).

**Fallback output (no spawn tool / messaging, or the human prefers):** one copy-pasteable block + the line `claude -n "<project>-P-N" -w P-N` for the human to run and paste into; reports are relayed by the human.
**Handover test:** if the block contains information missing from the living-docs, update the doc first, then produce the block.
