---
description: Drive part $ARGUMENTS through its full cycle (spec→gates→implement→verify→merge), stopping at every gate
argument-hint: <part-id> (e.g. P-3)
disable-model-invocation: true
---

Drive part $ARGUMENTS end to end. **STOP at every 🚦 — approval belongs to the human.**

1. **Ground check:** `git status` clean? `progress.md` + `module-specs/<part>.md` current? On contradiction, fix the source first.
2. Read the spec's **Status** field and continue from where the part stands:
   - no spec → `/gate1` flow → 🚦 GATE 1 *(combined with GATE 2 if the gate profile says so)*
   - spec approved → `/gate2` → 🚦 GATE 2 → create the branch (`git switch -c wip/<part>`)
   - plan approved → **dispatch the implementer in batches, not drips**: small part = the WHOLE approved plan in one dispatch; larger part = coherent batches of 2–4 steps per dispatch (one dispatch at a time — never two writers). The implementer makes a checkpoint commit per step either way. After EVERY dispatch: verify the ground — `git log`/`git diff --stat` vs the report; never proceed on the report alone.
   - implemented → `/gate3` → 🚦 GATE 3 (evidence block + the human tries it for real)
   - green → `/gate4` → 🚦 GATE 4 (verifier subagent + human approval)
   - approved → merge ritual: `echo wip/<part> > .claude/.gate4-ok` → merge → `rm .claude/.gate4-ok`
3. Update the docs (progress · issues · docs/archive/changelog · spec status) → run `/tidy` → recommend **`/clear`** (part boundary = the solo equivalent of a fresh session).

Delegation-first throughout (CLAUDE.md rule 12): questions → scout, changes → implementer; your context carries decisions and compact reports only. The branch lifecycle (create → checkpoints → merge) runs without permission prompts — the human control points are the GATES; the invariants are hook-guarded.
