# Design-first mode — prototype before code

> **← playbook v9** · Present because this project was scaffolded with `--design first`.
> Prototypes live in **Claude Design cloud projects**; this repo is the **control-plane** (briefs, prompts, ledgers, pointer files) until handoff. After GATE D, the build phase uses the sync loop ([README.md](README.md) steps 4–7) for implement → guardian → report.

## The pipeline (runs between the Phase 0 gate and Phase 1)

```
D0  BRIEF     distill a ~15-line design brief PER APP from PRD/architecture
              — NEVER feed the full strategy/PRD doc to the design tool
                (context waste + strategy leakage)
D1  SYSTEM    design-system project in Claude Design: 2 alternative art directions
              → human picks → iterate → LOCK → publish.
              The published DS is READ-ONLY canon for app sessions.
D2  PACKAGES  screen packages per app — conversion-critical flow first;
              one consolidated revise per package (PART A–D), ≤2 big turns,
              then micro-fix batches
(±) REVIEW    optional: external adversarial review of the prototypes (fresh eyes)
H   HANDOFF   export the DS bundle + tokens into the repo
🚦 GATE D     ONCE per project: ALL prototypes human-approved AND flows/rules
              locked in the living docs → Phase 1 with the normal per-part gates
```

## Birth is manual, life is MCP takeover

1. The design session DRAFTS the opening prompt (project-birth settings + first-package spec) → saves it to `docs/design/<app>/prompts/` with a status header (`DRAFT → APPROVED → APPLIED → SUPERSEDED`), then STOPS.
2. The HUMAN starts the project — pastes it into a NEW Claude Design chat, or (preferred where the Design template is enabled) runs `/design <brief>` from Claude Code — and reviews the first build.
3. The HUMAN drops the pointer file `docs/design/<app>/<app>-mcp.text` — content: the project URL + "auth via /design-login".
4. Only after the pointer exists: consent via `/design consent` (an ongoing grant — revoke with `/design revoke`), then direct MCP surgery for all later packages/fixes.

Hard rules: sessions **NEVER create cloud projects** · no pointer file = no MCP writes · consent is the human's explicit `/design consent` grant (a deliberate consent boundary — revocable any time).

## Consolidated revises

ONE big revise per package — skeleton: [prompts/_TEMPLATE-revise-prompt.md](prompts/_TEMPLATE-revise-prompt.md):
`PART A` new screens · `PART B` modifications · `PART C` flow relink · `PART D` DO-NOT-DESIGN (scope guard).
Cap: **≤2 big turns per package**, then micro-fix batches only. Human revisions route through the Manager — the Manager folds them into the next consolidated prompt for the app session.

## Concurrency (multi-app)

- **Ownership partition:** a design session writes ONLY `docs/design/<app>/**` — nothing else.
- **Shared canon goes through the Manager:** flows/rules/architecture discoveries are reported; the Manager (with the human) writes them into the living docs. Design sessions never edit shared docs.
- **Design sessions never run git** — the human commits at quiet points.
- No worktrees: the Manager spawns design sessions in the main checkout (`/design-kickoff`) — there is no code yet; the ownership partition prevents collisions.

## Where decisions land (golden rule)

Business logic, flows, and rules pinned during prototyping are **written into the EXISTING living docs in the same session they are decided**: `architecture.md` · `data-model.md` · `module-specs/` skeletons · `open-questions.md`. Deliberately NO separate decision registry — the living docs are the registry.

## Per-app layout (materialized during D0 — not before)

```
docs/design/<app>/
├─ brief.md          (from ../_TEMPLATE-brief.md — app-level scope)
├─ prompts/          (birth + revise prompts, status-headed)
├─ ledger.md         (screen/package inventory + status — GATE D reads this)
└─ <app>-mcp.text    (dropped BY THE HUMAN after reviewing the first build)
```

Prototypes stay CLOUD-ONLY until H — cloning the repo does not show them (by design).

## Gotchas (field-proven)

- Strip host-injected `data-omelette-injected` blocks before re-uploading a `.dc.html` — or you bake the host runtime into the doc.
- Edits = exact-anchor splices; run `node --check` after every splice.
- Template holes: dotted lookups only (`{{ a.b }}`); ternaries fail silently.
- Verify via JS against the **device-frame subtree** (not `document.body` — source literals pollute it); ≤~8 actions per exec.
- `serve_url` tokens expire ~1h and are never user-facing (share only the claude.ai project/artifact links).

## Honest limits

- The shipped `.mcp.json` still needs ONE interactive per-user approval on first use — a checked-in settings.json cannot pre-approve it.
- Design-system access = `/design-login`; writes = `/design consent` (ongoing grant; `/design revoke`). The endpoint in `.mcp.json` is undocumented — verify with `/mcp`.
- **2026-12-14:** the standalone Claude Design site closes — new designs become claude.ai artifacts; standalone project links (incl. old `<app>-mcp.text` pointers) stop working. A full design-track rework is deferred; until then keep the loop, record the new artifact URL in the pointer file.
