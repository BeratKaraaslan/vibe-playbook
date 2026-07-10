---
description: Small checkpoint commit on the part branch
disable-model-invocation: true
---

Make a checkpoint commit:

1. Branch check: if on main, STOP (main-guard blocks anyway) — switch to the part branch.
2. `git status` + review the changed files; unrelated/unexpected file → do not commit it, report it.
3. Meaningful small commit: `checkpoint(<part>): <what was done>`.
4. One-line status: what is done, what comes next.
