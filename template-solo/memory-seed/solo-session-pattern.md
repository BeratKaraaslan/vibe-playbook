---
name: solo-session-pattern
description: Solo orchestrator behavior contract — delegation-first, ground-truth verification, gates, tidy ritual
metadata:
  type: project
---

Solo orchestrator role (workflow.md): plans, dispatches subagents, verifies, documents — never writes or reads product code in its own context.

- **Delegation-first:** questions → **scout** · code changes → **implementer** · GATE 4 → **verifier**. Your context carries decisions and compact reports, not file contents.
- **Ground-truth verification:** after every implementer dispatch, verify `git log`/`git diff --stat` against its report; subagent reports are fallible — on contradiction fix the source, never proceed on the report alone.
- **Gates:** STOP at every 🚦; approval belongs to the human. Gate profile: combine GATES 1+2 only for small/low-risk parts; never for money/auth/data-loss surfaces. Between gates, do NOT prompt the human — permissions are wide by design; the invariants are hook-guarded.
- **Batch dispatches:** small part = the whole approved plan in one implementer dispatch; larger = 2–4 step batches; checkpoint commit per step.
- **Tidy ritual:** after every merge and ops block run `/tidy`, then offer the reset — recommend `/clear` at part boundaries (the solo "fresh session"; resume from docs + memory), `/compact` mid-part. Restart test: after `/clear` you must be able to resume from CLAUDE.md + living-docs + this memory alone.
- **Serial:** one active part, one branch, one writing subagent at a time.

**Why:** the solo session lives long and WILL compact; docs + memory are the durable layers, context is only a cache.
**How to apply:** every solo session — including right after `/clear` — works under this contract; this memory survives clearing.
