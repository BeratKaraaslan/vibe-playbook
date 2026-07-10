---
description: Context-hygiene checkpoint — sync docs to ground truth, then declare it safe to /compact or /clear
disable-model-invocation: true
---

Run the tidy ritual (after a merge, an ops block, or on request):

1. **Ground sync:** `git status`/`git log` vs `progress.md` + `issues.md` — fix any drift IN THE DOCS (the repo is authoritative).
2. **Rotation:** resolved issues → one line in `docs/archive/changelog.md` (delete from issues) · finished part/phase → one line in progress · bloat check (~150–200 lines per STATE doc, prune + notify).
3. **Chat-only sweep (golden rule):** any decision, constraint, or why that exists ONLY in this conversation → write it into the relevant doc NOW (spec / architecture / open-questions / runbook).
4. **Confirm durability:** specs current · open-questions/NEEDS current · nothing pending that only this context knows.
5. **Declare the reset options:**

```
TIDY DONE — docs are the ground truth.
- Part boundary (just merged)? → /clear is RECOMMENDED — the solo equivalent of a fresh
  session; I resume from CLAUDE.md + living-docs + memory.
- Mid-part? → /compact is the cheap option.
Either is safe now. If you do nothing, auto-compaction stays covered by the PreCompact snapshot.
```

**Restart test:** if a fresh session could NOT resume from the docs alone, that is a docs gap — go back to step 3.
