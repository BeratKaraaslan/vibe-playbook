---
description: Implementation plan from the approved spec — stops at GATE 2
argument-hint: <part-id>
disable-model-invocation: true
---

Produce the plan for part $ARGUMENTS:

1. Check that the spec is gate1-approved (`module-specs/<part>.md` status field). If not, STOP → the /gate1 flow comes first.
2. The spec is the **single source of truth** — the plan never exceeds the spec's scope; needing to = update the spec first (back to GATE 1).
3. Step-by-step plan: files · order of work · test strategy (**mock-first**) · risks.
4. 🚦 **GATE 2:** present for approval and **STOP**. *(A `gates-1+2-combined` part never reaches this command — /gate1 handles both in one approval.)*

On approval — **the plan is state and state lives on disk:** write the approved plan into the spec under "## Approved plan (GATE 2)" and set the status to `gate2-approved`. A `/clear` or a compaction must never be able to lose the plan; implementer excerpts come from this section, not from chat.

First task after that: the part branch — `git switch -c wip/<part>`.
