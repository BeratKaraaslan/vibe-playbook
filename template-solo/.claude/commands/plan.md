---
description: Implementation plan from the approved spec — stops at GATE 2
---

Produce the plan for part $ARGUMENTS:

1. Check that the spec is gate1-approved (`module-specs/<part>.md` status field). If not, STOP → the /spec flow comes first.
2. The spec is the **single source of truth** — the plan never exceeds the spec's scope; needing to = update the spec first (back to GATE 1).
3. Step-by-step plan: files · order of work · test strategy (**mock-first**) · risks.
4. 🚦 **GATE 2:** present for approval and **STOP**. *(If the gate profile is `gates-1+2-combined`, this is one approval together with the spec.)*

First task after approval: the part branch — `git switch -c wip/<part>`.
