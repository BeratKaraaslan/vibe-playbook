---
description: GATE 4 flow — the verifier subagent verifies; findings + approval step are presented
---

Start the GATE 4 review flow (part: $ARGUMENTS):

1. Read the spec's **GATE 4 acceptance list** + **locked decisions**.
2. Delegate to the **verifier** agent — input: the acceptance list + scope (`git diff main...<branch>`); output: a VERDICT/EVIDENCE/RISKS/TESTS report. Do NOT read the verification files into YOUR own context (the orchestrator context stays clean).
3. Present to the user — **plain language first** (the reader may not read code):
   - (a) a plain-language summary: what this part does now, what the verifier CONFIRMED, what risks remain, and **what the user should try by hand** to convince themselves,
   - (b) technical appendix for those who read code: the verifier report + critical diff spots (file:line, money/auth/data surfaces first) + the full diff command `git diff main...<branch>`.
4. 🚦 **APPROVAL BELONGS TO THE HUMAN.** On approval, in order:
   `echo <branch> > .claude/.gate4-ok` → merge → `rm .claude/.gate4-ok` → update the docs (progress · issues · docs/archive/changelog) → run `/tidy` (safe-to-compact point).

Never attempt a merge before approval (main-guard blocks it anyway). REJECTED/CONDITIONAL: dispatch the findings back to the implementer as fix steps.
