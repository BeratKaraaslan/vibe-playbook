# Design-first mode — prototype before code (SOLO)

> **← playbook v8** · Present because this project was scaffolded with `--design first`.
> Prototypes live in **Claude Design cloud projects**; this repo is the **control-plane** (briefs, prompts, ledger, pointer files) until handoff. After GATE D, the build phase uses the sync loop ([README.md](README.md) steps 4–7) for implement → guardian → report.

**Solo serial variant:** ONE session (the solo orchestrator) drives D0 → D1 → D2 **sequentially** — usually one app surface. Same birth-manual / life-MCP rules and prompt skeletons as the orchestrated profile; [STATUS.md](STATUS.md) is the ledger; the kickoff block lives in STARTGUIDE §3b — there is deliberately no extra command.

## The pipeline (runs between the Phase 0 gate and Phase 1)

```
D0  BRIEF     distill a ~15-line design brief from PRD/architecture
              — NEVER feed the full strategy/PRD doc to the design tool
                (context waste + strategy leakage)
D1  SYSTEM    design-system project in Claude Design: 2 alternative art directions
              → human picks → iterate → LOCK → publish.
              The published DS is READ-ONLY canon afterwards.
D2  PACKAGES  screen packages — conversion-critical flow first;
              one consolidated revise per package (PART A–D), ≤2 big turns,
              then micro-fix batches
(±) REVIEW    optional: external adversarial review of the prototypes (fresh eyes)
H   HANDOFF   export the DS bundle + tokens into the repo
🚦 GATE D     ONCE per project: ALL prototypes human-approved AND flows/rules
              locked in the living docs → Phase 1 with the normal per-part gates
```

## Birth is manual, life is MCP takeover

1. The session DRAFTS the opening prompt (project-birth settings + first-package spec) → saves it to `docs/design/prompts/` with a status header (`DRAFT → APPROVED → APPLIED → SUPERSEDED`), then STOPS.
2. The HUMAN pastes it into a NEW Claude Design chat and reviews the first build in the UI.
3. The HUMAN drops the pointer file `docs/design/<app>-mcp.text` — content: the project URL + "auth via /design-login".
4. Only after the pointer exists: the session runs `/design-consent` and does direct MCP surgery for all later packages/fixes.

Hard rules: the session **NEVER creates cloud projects** · no pointer file = no MCP writes · `/design-consent` is per-session **by design** (a deliberate consent boundary, not a defect).

*(Multiple app surfaces? Nest per app — `docs/design/<app>/{brief.md, prompts/, ledger.md, <app>-mcp.text}` — and run them one after another, never in parallel: solo is serial by design.)*

## Consolidated revises

ONE big revise per package — skeleton: [prompts/_TEMPLATE-revise-prompt.md](prompts/_TEMPLATE-revise-prompt.md):
`PART A` new screens · `PART B` modifications · `PART C` flow relink · `PART D` DO-NOT-DESIGN (scope guard).
Cap: **≤2 big turns per package**, then micro-fix batches only. Your revisions arrive in chat — fold them into the next consolidated prompt, never as one-off dribbles.

## Where decisions land (golden rule)

Business logic, flows, and rules pinned during prototyping are **written into the EXISTING living docs in the same session they are decided**: `architecture.md` · `data-model.md` · `module-specs/` skeletons · `open-questions.md`. Deliberately NO separate decision registry — the living docs are the registry.

## Gotchas (field-proven)

- Strip host-injected `data-omelette-injected` blocks before re-uploading a `.dc.html` — or you bake the host runtime into the doc.
- Edits = exact-anchor splices; run `node --check` after every splice.
- Template holes: dotted lookups only (`{{ a.b }}`); ternaries fail silently.
- Verify via JS against the **device-frame subtree** (not `document.body` — source literals pollute it); ≤~8 actions per exec.
- `serve_url` tokens expire ~1h and are never user-facing (share only claude.ai/design links).

## Honest limits

- The shipped `.mcp.json` still needs ONE interactive per-user approval on first use — a checked-in settings.json cannot pre-approve it.
- Auth = `/design-login`; writes = per-session `/design-consent`. Terminal (CLI) Claude Code is mandatory for the connection.
