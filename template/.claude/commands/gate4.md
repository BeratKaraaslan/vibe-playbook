---
description: GATE 4 flow (in the Manager) — the verifier subagent verifies; findings + approval step are presented
argument-hint: <part-id>
disable-model-invocation: true
---

Start the GATE 4 review flow (part: $ARGUMENTS) — it runs in the **Manager** session (it owns main):

1. Read the spec's **GATE 4 acceptance list** + **locked decisions** + the **Branch** field (the exact branch name).
2. Delegate to the **verifier** agent — input: the acceptance list + scope (`git diff <base>...<branch>` — <base> = the base branch in CLAUDE.md, default `main`) + the worker's **worktree path** (the branch is checked out there — run the tests in it); output: a VERDICT/EVIDENCE/RISKS/TESTS report. Do NOT read the verification files into YOUR own context (the manager context stays clean).
   **`full` gate-profile parts:** ALSO run the built-in `/code-review high <branch>` — a second lens (bug hunt); the verifier stays the acceptance/invariants lens.
3. Present to the user:
   - (a) the verifier findings report (compact) — plus the `/code-review` findings on `full` parts,
   - (b) critical diff spots — a file:line list, money/auth/data surfaces first,
   - (c) the full diff command: `git diff <base>...<branch>`.
4. 🚦 **APPROVAL BELONGS TO THE HUMAN.** On approval, in order:
   `echo <branch> > .claude/.gate4-ok` → merge → `rm .claude/.gate4-ok` → update the docs (progress · issues · docs/archive/changelog) → **close the worker + remove its worktree** (Desktop: archive the session · CLI: `claude rm <id>` · by hand: `git worktree remove <path>`) → clear its `Session` cell in progress.md.

Never attempt a merge before approval (main-guard blocks it anyway). **REJECTED/CONDITIONAL:** send the fix list to the SAME worker by message (it keeps its part context) → it fixes, re-runs `/gate3`, reports `ready-for-gate4` → re-run this flow.
