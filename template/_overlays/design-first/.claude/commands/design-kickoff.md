---
description: (Manager, design-first mode) Produce a per-app design-session kickoff from the living docs
argument-hint: <app>
disable-model-invocation: true
---

Produce the design-session kickoff for app $ARGUMENTS.

**Verify the ground FIRST:** `git log/status` + `docs/design/STATUS.md` + `docs/design/<app>/ledger.md` (if present) — the REPO is authoritative, not reports; on contradiction, fix the source first.

**Birth-state check — does `docs/design/<app>/<app>-mcp.text` exist?**
- **Absent → the kickoff targets BIRTH:** the design session drafts the opening prompt into `docs/design/<app>/prompts/` (from `docs/design/prompts/_TEMPLATE-birth-prompt.md`, status DRAFT) and STOPS — the human pastes it into a NEW Claude Design chat, reviews the first build in the UI, and drops the pointer file. Sessions NEVER create cloud projects.
- **Present → the kickoff targets MCP takeover:** `/design-consent`, then package-by-package surgery (consolidated revises PART A–D, ≤2 big turns per package, then micro-fix batches).

Kickoff skeleton (in this order, everything filled concretely):
1. role + app + package map (from the ledger / STATUS)
2. READ FIRST — `docs/design/design-first.md` · `docs/design/<app>/brief.md` · the ledger · the published Design System (**READ-ONLY canon** — never written by app sessions)
3. LOCKED decisions (do not change, do not re-ask)
4. working rules: write ONLY `docs/design/<app>/**` · shared canon (flows/rules/architecture) goes through the Manager · NEVER run git · NEVER create cloud projects
5. order of work (packages — conversion-critical flow first)
6. DO NOT ASSUME micro-decisions → route them to the Manager/user
7. package approval = the human in the Claude Design UI (never a self-check)
8. session hygiene (report per package — the design README's report format; suggest handover at the natural boundary)
9. FIRST STEP (what happens before anything else)

**Output:** one copy-pasteable block.
**Handover test:** if the block contains information missing from the living docs, update the doc first, then produce the block.
