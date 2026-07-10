---
description: GATE 3 mechanical evidence — run test+lint+typecheck, print a compact evidence block
argument-hint: [part-id]
disable-model-invocation: true
---

GATE 3 mechanical evidence step ($ARGUMENTS):

1. Use the Test/Lint/Typecheck commands from CLAUDE.md. If they are not filled in, detect them from `package.json`/`Makefile` and propose recording them in CLAUDE.md.
2. Run all three (mark whatever the project lacks as `—`).
3. Print a COMPACT block in this format (NOT a raw output dump — the human reads it in 10 seconds):

```
GATE 3 EVIDENCE — <part> @ <branch>
test:      ✅/❌  (n passed / n failed — if red, a one-line summary of the first failure)
lint:      ✅/❌
typecheck: ✅/❌
Manual verification list (the spec's GATE 3 acceptance list):
- [ ] <item — the human tries it for real>
```

4. Any ❌: GATE 3 is NOT presented to the human — propose fixes first. Only a green table goes to the gate.
