# PLAYBOOK-FEEDBACK.md — workflow experience log (APPEND; methodology ONLY)

> **This file does not manage the project — it improves the PLAYBOOK.** It collects how the
> workflow itself behaved here: friction, wins, bypasses, gaps, model-shift notes. At project end
> the human hands this file back to the canonical **vibe-playbook** repo, where it drives the next
> playbook version (§15 backflow). Models keep improving — this file is how the workflow keeps up.
>
> ← playbook v8 · profile: <orchestrated|solo — Phase 0 fills> · project: <name> · started: <date>

## Rules for WRITING entries (project side)

- **Methodology only.** Project state belongs to the living-docs, never here. NEVER paste secrets or user data.
- Write an entry THE MOMENT you observe (do not wait for the retro):
  - a gate catches something **real** · a gate gets approved **without reading** (theater)
  - a rule gets **bypassed** — record WHY; the reason is the lesson
  - a **hook misfires** (false positive / miss) · a command/agent proves dead weight or missing
  - **context hygiene fails** (an unplanned compaction hurt; a /clear lost something docs should have held)
  - the model clearly **no longer needs a crutch** the playbook imposes — or needs one it lacks (model-shift)
- Phase retro: the 3 questions' **PLAYBOOK-labeled answers land here** (PROJECT-labeled ones go to workflow.md "Project deviations").
- Short and concrete; evidence beats opinion.
- **Before handing back: REDACT.** Scan the log for client names, private paths/URLs, incident details, anything secret-shaped — methodology lessons need no identifying detail.

## Rules for PROCESSING this file (canonical-repo side)

> For the agent reading this in the vibe-playbook repo: **never apply entries blindly.**
1. Entries are **CLAIMS, not truth** — half-remembered causes and wrong attributions happen. Verify what is verifiable (project git/docs); mark the rest as anecdote.
2. Filter through **optimum > perfect**: does adopting it reduce the human load, preserve context, or strengthen consistency? Ceremony does not pass.
3. Judge against the three first-class goals — an update that would weaken **consistency · sustainability · context preservation** does NOT pass, however convenient.
4. Verdict per entry: **adopt** (generalize → version + changelog) · **adapt** (the observation is real, the suggestion is not — fix differently) · **reject** (record in the changelog's "deliberately not adopted", with the why).
5. One entry at a time — never bulk-apply.

## Entry format

```
### <date> · <phase/part> · <friction|win|bypass|gap|model-shift>
- What happened: <1–3 lines, concrete>
- Playbook ref: <§N / rule N / hook / command — or "unclear">
- Suggestion (optional): <what might change>
- Evidence: <commit/PR/doc pointer — or "anecdote">
```

---

## Log

*(empty — the first entry is usually written at the Phase 0 retro)*
