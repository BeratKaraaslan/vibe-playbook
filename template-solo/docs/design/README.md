# Design track — single source of truth (mode-managed: `--design none` scaffolds omit docs/design/)

> Decision-maker: **Claude Design** (MCP — Claude Code **from the terminal**, mandatory).
> The orchestrator runs this track (writes briefs, keeps the ledger) — code lands via the **implementer** subagent.

## The loop (every screen/task — same skeleton)

```
1) BRIEF      Orchestrator writes the brief → docs/design/<G-task>/brief.md (from _TEMPLATE-brief.md)
2) PROTOTYPE  Drive the Claude Design canvas — iterate until the human approves
3) HANDOFF    Design: Export → Handoff bundle → lands in the terminal session
4) IMPLEMENT  implementer subagent converts to real components — DESIGN TOKENS ONLY, no hardcoded colors/spacing
5) GUARDIAN   design-guardian agent audit (.claude/agents/design-guardian.md — CODE SIDE ONLY) — no merge before it passes
6) MERGE      GATE 3 (visual, human tries it) → the normal merge ritual
7) LEDGER     fixed-format report recorded → STATUS.md ledger updated
```

## Known constraints & field lessons

- **Claude Design is READ-ONLY on the repo** — it never commits; code enters only via handoff → implement.
- **Claude Design cannot read `.claude/agents/`** — Design-side conformance comes from the published Design System (+ [design-system-notes.md](design-system-notes.md)); the guardian gates only the Code side.
- Keep a `DESIGN-CONTEXT.md` **inside the web-app directory** (where Design's read-only access can SEE it): write the as-built truth there after every screen — both sides share one context.
- **Front-load hybrid:** design the global shell screens up-front (spec-independent, stable); design module screens JIT **after their spec locks** — designing earlier means rework when the spec changes.
- **Mechanical adherence (optional):** a lint rule banning raw hex/px in UI code enforces tokens-only mechanically — stack-specific hardening the human can adopt.

## Report format (recorded in the ledger, every cycle)

```
SCREEN: <name> (<route>)  ·  SKIN/THEME: <which>
STATUS: prototype ✅/⬜ · implement ✅/⬜ · guardian ✅/⬜ · merge ✅/⬜
DONE: <1–3 lines — components, states>
DEVIATION/DECISION: <brief deviations? guardian findings? missing tokens?>
BLOCKER: <needs the user's decision — or "none">
NEXT: <next screen/suggestion>
```

Ledger → [STATUS.md](STATUS.md): a screen is "done" only when prototype · implement+guardian · merge are ALL green.
