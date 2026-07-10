# Design track — single source of truth (optional; delete docs/design/ if unused)

> Decision-maker: **Claude Design** (MCP — Claude Code **from the terminal**, mandatory).
> The Manager runs this track (writes briefs, receives reports, keeps the ledger) — it does not design by hand.

## The loop (every screen/task — same skeleton)

```
1) BRIEF      Manager writes the brief → docs/design/<G-task>/brief.md (from _TEMPLATE-brief.md)
2) PROTOTYPE  Design session drives the Claude Design canvas (/design) — iterate until approved
3) HANDOFF    Design: Export → Handoff bundle → lands in the terminal session
4) IMPLEMENT  Code side converts to real components — DESIGN TOKENS ONLY, no hardcoded colors/spacing
5) GUARDIAN   design-system-guardian gate (CODE SIDE ONLY) — no PR before it passes
6) MERGE      GATE 3 (visual, human tries it) → PR/merge
7) REPORT     fixed-format report to the Manager → STATUS.md ledger updated
```

## Known constraints & field lessons

- **Claude Design is READ-ONLY on the repo** — it never commits; code enters only via handoff → implement.
- **Claude Design cannot read `.claude/agents/`** — Design-side conformance comes from the published Design System (+ [design-system-notes.md](design-system-notes.md)); the guardian gates only the Code side.
- Keep a `DESIGN-CONTEXT.md` **inside the web-app directory** (where Design's read-only access can SEE it): the design session writes the as-built truth there after every screen — both sides share one context.
- **Front-load hybrid:** design the global shell screens up-front (spec-independent, stable); design module screens JIT **after their spec locks** — designing earlier means rework when the spec changes.

## Report format (design session → Manager, every cycle)

```
SCREEN: <name> (<route>)  ·  SKIN/THEME: <which>
STATUS: prototype ✅/⬜ · implement ✅/⬜ · guardian ✅/⬜ · PR <#|⬜>
DONE: <1–3 lines — components, states>
DEVIATION/DECISION: <brief deviations? guardian findings? missing tokens?>
BLOCKER: <needs Manager/user decision — or "none">
NEXT: <next screen/suggestion>
```

Ledger → [STATUS.md](STATUS.md): a screen is "done" only when prototype · implement+guardian · PR are ALL green.
