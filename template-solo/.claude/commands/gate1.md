---
description: Write a part spec (from module-specs/_TEMPLATE.md) — stops at GATE 1
argument-hint: <part-id> (e.g. P-3)
disable-model-invocation: true
---

Write the spec for part $ARGUMENTS:

1. READ FIRST: `module-specs/_TEMPLATE.md` · `progress.md` · the relevant PRD/architecture sections.
2. Fill the template. **Propose a gate profile:** small/low-risk → `gates-1+2-combined`; money/auth/data-loss surface → `full` (never combined).
3. **DO NOT ASSUME:** product decision → ask the user; technical unknown you cannot decide → `open-questions.md`.
4. Save as `module-specs/<part>.md` → 🚦 **GATE 1:** present for approval and **STOP** — no code, no plan.

**Combined profile (`gates-1+2-combined`):** draft the plan TOO and present spec + plan as ONE approval. On approval: write the plan into the spec's "## Approved plan (GATE 2)" section, set status `gate2-approved`, and skip /gate2.
