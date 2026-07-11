# Vibe-Coding Orchestration Playbook

> Reusable methodology + base-project flow for multi-session AI development.
> Domain-neutral: copied into every new project, specialized during Phase 0.
> **Three first-class goals:** consistency · sustainability · context preservation.
>
> **Version: v8** (2026-07-10) · canonical home = this repo, copies are derivatives (§15) · changes → [CHANGELOG.md](CHANGELOG.md)
> **Since v3:** the skeleton is no longer prose — [`template/`](template/) is real files; new project = copy + `template/STARTGUIDE.md` (§14).
> **Since v5:** two profiles — [`template/`](template/) (**orchestrated**: multi-session) · [`template-solo/`](template-solo/) (**solo**: one session + subagents, §17).
> **Since v6:** the whole repo is English and ships as an npm package (`npx vibe-playbook init <solo|orchestrated>`).
> **Since v7:** the first real §15 backflow — field lessons from the origin project's retro (design-track mechanics · spine/prompts doc classes · the PR-flow note · script>runbook · anti-gold-plating).
> **Since v8:** the first external-review intake — hook hardening (symlink/flag/cherry-pick/exact-branch/configurable branches), gate-uniform command names (`/gate1–4`, `/wip` — no Claude Code built-in shadowing), packaging fixes (tests ship, CI, profile stamp).

---

## 0. Core principle

Development flows as **vibe coding** (the AI advances in small steps, the human steers) — but the flow is not free-form: **human gates are mandatory.** The AI flows freely between gates, stops at the gates, and waits. Wherever money/auth/credits/prod are involved there is no vibe — there is **oversight**.

**Continuity lives in two layers:** (1) **repo living-docs** (project state) + (2) **memory** (session behavior). No critical information stays inside a single session's context — every decision is written into a doc ("it must outlive the session boundary").

---

## 1. Session types (4 roles)

| Type | Writes? | Lifetime | Responsibility | Its living-docs |
|---|---|---|---|---|
| **① Manager** | Code ❌ / Docs ✅ | Phase/project-long (handed over) | Process owner: splits the phase into parts · refines kickoffs · audits gates · pins decisions | progress.md · issues.md · open-questions.md |
| **② Development** | Code ✅ | Per-part (fresh) | Codes one part (P-numbered) end to end: spec→plan→impl→test→review→merge | module-specs/`<part>`.md |
| **③ Ops / DevOps** | Config/scripts ✅, product code ❌ | **PERSISTENT** (cache — ↓) | Manual & infra: server · panel (Dokploy etc.) · domain/DNS · environments · CI/CD infra · secret placement · backup/monitoring | **infra-state.md** · docs/ops/`<runbook>`.md |
| **④ Design** | UI code ✅ | Per-task (G-numbered) | Visual/UI parts; design-system-guardian guardrail; design track | docs/design/STATUS.md · `<G-task>`/brief.md |

> **The Manager "writes no code" ≠ sits idle.** The Manager owns the docs and the process: updates living-docs, produces kickoffs, pins decisions, audits gates.

> **The design decision-maker = Claude Design** (connected to Claude Code via **MCP**). For that connection, running Claude Code **from the terminal (CLI) is MANDATORY** — ④ Design (G) work runs in a terminal session.

### Why the Ops session is SEPARATE — and what "persistent" really means

Doing manual/infra work inside the manager or dev session: (a) **floods** that session's context with operational noise, (b) **pollutes** development tracking. Hence SEPARATE.

"Persistent" is an **optimization, not a design pillar**: the source of truth is always **runbooks + infra-state**; the session context is only a warmed **cache** (the comfort of not re-reading files). A persistent session goes through compaction many times, and summary loss is insidious — hence two rules:

1. **Instant runbook:** every significant why-decision (why this port, why this PAT type, which env lives where) lands in the runbook before the task counts as done. A decision not written into docs DOES NOT EXIST.
2. **Anti-confabulation:** the Ops session answers "why X?" questions from the **runbook**, not from its own memory; if the runbook does not have it, it says **"not recorded"** — it does not invent.

As long as these two rules hold, persistence is harmless comfort; when they do not, a persistent session is no better than a fresh one. *(Test: a fresh Ops session must be able to do the same job from the runbooks alone.)*

---

## 2. Human gates (the backbone of quality)

Every development part goes through this cycle:

```
Write SPEC            → 🚦 GATE 1: spec approval (no code — stops a wrong direction at the cheapest point)
PLAN (plan mode)      → 🚦 GATE 2: plan approval
IMPL                  → the agent flows (vibe); small CHECKPOINT commits on the part branch (§9)
TEST (/gate3 proof)   → 🚦 GATE 3: mechanical evidence block (test/lint/typecheck) + try it in the browser/for real
CRITICAL REVIEW       → 🚦 GATE 4: verifier subagent + the Manager reads deep (§4.3);
                         the HUMAN reads the findings report + spot-checks critical diffs; APPROVAL IS THE HUMAN'S
MERGE + docs          → the ONLY way into main (enforced by the main-guard hook — §12) → checkpoint → new session
```

- **The GATE 4 profile varies by track:** code track (money/auth) = heavy (the full flow above); design track = light (no money, only as much as the security surface); ops = "verify together" (§6).
- **The gate profile also flexes per part (a proactive answer to gate fatigue):** for a small/low-risk part the Manager **combines GATES 1+2 into one approval** (spec+plan presented together); NEVER combined on money/auth/data-loss surfaces. The profile is written into the spec's `gate profile` field (module-specs template). *(The §15 retro calibration still applies — this handles the predictable portion up front.)*
- **Phase gates** (above the part gates): Phase 0 plan approval (the biggest) · when the backbone is done · when each major part is done.

### 2.1 Off the happy path (cancel / rollback — cheap thanks to the branch model)

- **Part cancelled:** the branch is abandoned (deleting = destructive → ask first) · one line of rationale in issues/changelog · the spec is marked `CANCELLED` · progress updated.
- **The plan falls apart mid-IMPL:** do not restart from scratch — return to GATE 2 with a **delta plan** (what changed + why), continue on approval.
- **GATE 4 finds a spec-level flaw:** not a patch but a rollback — return to GATE 1, fix the spec; the lesson is noted for the retro (§15).

---

## 3. Phase & part structure

- **Phase 0 = PLANNING (no code):** the Manager produces all docs → 🚦 the biggest gate (decisions lock here). Output: the living-docs set + `phase-kickoffs.md` (draft commands for later phases). Phase 0 ends by deriving the **project-specific `.claude/` configuration** via **`/adapt`** — domain-expert agents · verifier invariants (the placeholder must not survive Phase 0 empty) · the stack's real allow-list · optional doc classes (spine/prompts/design/go-live). The proposal rides the Phase 0 gate; the §12 minimal-set rule applies (every agent is carried maintenance — items are approved one by one). Re-run `/adapt` when a new domain surface appears mid-project.
- **Phase N:** split into parts — code parts `P1, P2…` · design `G1, G2…` · ops work in its own flow. **Partitioning rule:** parts that will run in parallel must have **disjoint file scopes** (client/backend etc.); parts touching the same files run sequentially, not in parallel — the conflict/code-loss risk is cut at partitioning time.
- Every part starts in a **fresh session** (clean context). The Manager refines the part's kickoff.

---

## 4. The Manager loop (the core)

```
Loop:  a working/ops session drafts/reports
   →   the MANAGER verifies the ground against the REPO (git+docs), carries no contradictions
   →   the MANAGER refines the next fresh-session KICKOFF
   →   you run it in a fresh session
```

### 4.1 The ground-truth verification rule (non-negotiable)

The Manager does NOT take a closing session's report **on faith.** It **VERIFIES** with `git log/status` + the relevant living-docs; if the report and the repo contradict, the contradiction is **not carried** into the kickoff — the source gets fixed. *(This single rule catches silent drifts like "is prod at app. or apex", "port 3000 or 3100", "was the artifact actually written".)*

### 4.2 The kickoff skeleton (every fresh-session prompt, in this order)

```
role + location + part map
→ READ FIRST (source spec = the single source of truth; which docs)
→ LOCKED decisions (do not change, do not re-ask)
→ working rules (tree/commits/security/environment)
→ order of work (sub-steps)
→ spec-gate micro-decisions (DO NOT ASSUME; product decision → ask the user)
→ concrete GATE 3/4 acceptance lists
→ loop + session hygiene
→ FIRST STEP (what happens before any code/artifacts)
```

### 4.3 Gate-approval discipline (at critical moments like GATE 4)

The Manager verifies claims from the code — but **NOT by reading files into its own context**: verification is delegated to a read-only **verifier subagent** (it reads the files, runs the tests independently if needed) and returns only a **compact verdict + evidence** to the Manager. Then the user receives an **"approval text to paste into the session"** block — the decision lives in one place and proceeds consistently.

- **Why a subagent:** the Manager's context is long-lived and precious. Files read leave residue → (a) the context fills early → early handover; (b) **stale code memory**: a file read during P7 has changed by P9, and the Manager rules on old ground while believing it "knows the code". The natural extension of ground-truth verification (§4.1): **the Manager's own code memory is also an unreliable source** — every verdict comes from a fresh read. *(Bonus: the same strong model with a clean context catches more than it does reading through its own residue.)*
- **The boundary (a definition, not a limitation):** delegation is only for **verification reads** — tasks with a fully defined input, a single report as output, and no product decision in the middle. **Development work is not moved into subagents:** interactive dev sessions (which the user watches and can dictate to) remain the unit of development; fixes arising from findings go back to dev sessions. *(The solo profile deliberately inverts this trade — §17.)*

---

## 5. The Ops / DevOps session (manual & infra)

**Scope:** server provisioning · panel setup (Dokploy/Coolify/…) · domain & DNS · opening environments (staging/prod) · CI/CD infrastructure · registry/secret placement · backup + monitoring setup · every "non-code, done-by-hand" task.

**Persistence:** an optimization — the source is the runbook, the context is a cache; the **instant-runbook + anti-confabulation** rules apply (§1). When the context fills, it **hands over via infra-state + runbooks** (same hygiene).

**Its living-docs:**
- `infra-state.md` — **the board**: the CURRENT truth of the installed infrastructure (server, environments, domains, services, ports, "which secret lives where"). A state doc = EDIT, stays small. Manager/dev **read**, Ops **writes**.
- `docs/ops/<runbook>.md` — step-by-step durable instructions + **why-decisions** (e.g. "port 23 because…", "classic PAT because fine-grained broke on X").
- **Script > runbook-prose:** a runbook step that runs more than once becomes an **executable script** (`ops/` — e.g. `backup.sh`, `restore-test.sh`); the runbook then documents the WHY and calls the script. *(The ops counterpart of "hook > instruction" — field-proven.)*

**Sync (through the living-docs):**
```
Dev/Manager   → NEEDS-FROM-USER.md ("this infra/env/secret is needed") → STOP
Ops session   → sets it up + updates infra-state.md + the runbook
Everyone      → reads infra-state.md and knows the truth (nobody assumes)
```

**Security:** secrets never in code/repo; in `.env`/panel. The guard-env hook applies in the Ops session too.

---

## 6. The hand-in-hand protocol (artifact ↔ installation bridge)

Deploy/infra work is not something one session can declare "done" alone:
```
② Dev session:   writes the ARTIFACT (Dockerfile · CI workflow · deploy config) + verifies LOCALLY
③ Ops session:   APPLIES the artifact to the infrastructure (panel/creds/deploy) + updates infra-state
Together:        VERIFY in the real environment (smoke/restore test); AI alone never declares "deployed"
```
The Manager coordinates this bridge (which artifact is ready, which ops step is waiting).

Beware **sham-green CI** *(field lesson)*: a green pipeline is not proof — the real-environment smoke is; a CD job can stay green while verifying nothing. Before the first prod cutover, a short **go-live checklist** (env · migrations · seeds · secrets · full-journey smoke) pays for itself — the field case: three prod blockers that gates+CI missed were caught by a human walking the real journey on staging.

---

## 7. The living-docs system (the process lives on this)

**Two classes:**
- **STATE** (progress · issues · architecture · data-model · infra-state · specs) → **EDIT**, stays small, "the current truth".
- **ARCHIVE** (docs/archive/*) → **APPEND**, grows, **never auto-loaded** (on request only).

**The manifest:**

| Doc | Purpose | Life | Loading |
|---|---|---|---|
| `CLAUDE.md` | conventions + doc map + critical rules (LEAN) | Edit | automatic, every session |
| `progress.md` | status board (NOT a log) | Edit | session start |
| `issues.md` | OPEN items only | Edit (resolved → deleted) | session start |
| `architecture.md` · `data-model.md` | stack + system + schema | Edit | for relevant work |
| `infra-state.md` | the truth of installed infra | Edit | ops/deploy work |
| `module-specs/*` | one spec per part | Edit (stable once locked) | for that part |
| `open-questions.md` · `NEEDS-FROM-USER.md` | open decisions · needed keys/accounts | Edit | as needs arise |
| `phase-kickoffs.md` | draft commands for later phases | Edit | at phase transitions |
| `workflow.md` / this playbook | methodology (headed: "← playbook vN") | Edit (rare) | reference |
| `shared-spine.md` *(optional — multi-module products; created in Phase 0 when needed)* | the cross-part CONTRACT: the common flow + the interfaces every part plugs into; specs then define **only deltas** | Edit | for relevant work |
| `prompts/` *(optional — LLM products)* | **runtime asset, NOT a living doc**: versioned prompt files (`.vN`), agent-maintained; every output stores `promptVersion`+`model` (debug/rollback/A-B) | versioned asset | runtime (code reads it) |
| `docs/archive/*` · `docs/ops/*` · `docs/design/*` | history · runbooks · design | Append | **on request** |

LLM products, one timing rule: **draft the base persona BEFORE the first LLM part** — otherwise every output gets re-toned later (asset timing is decision timing, §8).

**Rotation:** issue resolved → one line in the changelog · a completed phase collapses to one line in progress · each phase end → `phase-N-summary.md` · **bloat budget** ~150–200 lines → prune proactively + notify. **The budget is CONTENT, not line count** *(field lesson: a status board can stay under the line budget while one "Now" cell swells into a 4 kB paragraph)* — keep the progress "Now" section to 3–5 bullets; overflow goes to issues/archive.

**The golden rule:** a structural decision/change is **never just said inline** — it is **written into** the relevant spec/issues/architecture (it must outlive the session boundary). If it only affects the current screen → say it; if it changes a decision recorded in a doc → have the doc updated.

---

## 8. NEEDS · open-questions · decision timing

- **NEEDS-FROM-USER:** when the AI needs a key/account/manual step it writes it down + **STOPS**; when you provide it, it is marked "fulfilled".
- **open-questions:** when the Manager cannot decide. **DO NOT ASSUME →** it goes here. Product decisions go to the user; technical decisions to the Manager, with rationale.
- **Decision timing (dependency):** some decisions **depend on a measurement/previous step** — "measure first, then decide; the **order is mandatory**". An early decision = damage/debt. Dependent decisions are tracked in open-questions as an **ordered dependent pair**.

---

## 9. Working agreements (the durable behavior contract)

Rules kept in memory + CLAUDE.md that keep sessions consistent with each other. Adapted per project; the typical core:

- **Commit discipline (branch + checkpoint):** a part flows on its own branch (`wip/P-N`, `feat/…` — NO direct work on main). Small **checkpoint commits are free and encouraged** — the loss window (crash · wrong tool call · muscle-memory reflex) never opens. **The invariant: nothing enters main without GATE 4.** The review diff is one command: `git diff main...<branch>`. Optionally the history is squashed/curated after GATE 4 (only on that branch, with prior permission). **PR variant** *(field-proven)*: when merges happen on GitHub (PRs), the GATE 4 marker = the PR approval itself and **main-guard never sees the merge** — protect the invariant with **branch protection** on main instead; the hook keeps guarding local commits.
- **Git safety:** with uncommitted work, **`git restore/stash/clean/checkout --` NEVER**; ask first for destructive ops (force/reset/branch delete). *(Checkpoint discipline already shrinks this risk.)*
- **Hook > instruction:** any hygiene rule that can be enforced is applied via a **harness hook**, not a model instruction (guard-env = secrets · **main-guard = blocks code commits on main + GATE4-unmarked merges** · PreCompact = handover state). Instructions get forgotten/skipped; hooks do not. The general principle: **every enforceable invariant goes into a hook, every automatable proof into a script** (/gate3) — human attention is reserved for real judgment.
- **Secret hygiene:** `.env` is never read/printed (**PreToolUse guard hook** enforces it — in every form: direct read, subcommand, glob, script; only `.env.example` is accessible); never hardcoded. On a guard-env block: STOP — report to the user and wait for approval; never retry via another path. **The leak protocol (user-side leaks):** if the user pastes a sensitive value into chat (DB URL, API key…) — the value is NOT repeated, not written into any file/doc/command; if it landed anywhere it is deleted IMMEDIATELY; the user is notified + **rotation is recommended** *(the honest limit: chat history cannot be truly deleted — the only permanent fix is rotation)*; the right place is `.env`/panel, and the human places it. The **secret-scan hook** (UserPromptSubmit, §12) reminds the model of the protocol at exactly that moment — it does not block, it nudges.
- **Anti-confabulation (general):** the rule in §1 is not only for Ops — it applies to **every** session that has been through compaction: "why X?" is answered from the docs; if the docs do not have it, **"not recorded"** — nothing is invented.
- **Context discipline (a question ≠ a status report):** while a phase is running, the user's question gets **the short answer requested** — re-dumping the whole phase workflow/status with every question bloats the context and kills readability. The full status summary only when asked or at gates.
- **Working-tree isolation (parallel sessions):** in git the working tree is ONE — two sessions in the same directory cannot work on two branches "at the same time"; one crushes/pollutes the other's work (conflicts + code loss). The rule: one active dev session per directory at a time; **parallel parts in separate `git worktree`s** (`git worktree add ../<project>-<part> wip/<part>`, removed after merge); checkpoint commit before any branch switch. Scope disjointness is ensured at partitioning time (§3); /new-part runs a parallelism check.
- **Tests:** external-service/LLM calls are **mock-first** (deterministic + free); real calls only via a controlled measurement script.
- **Environment rules:** project-specific footguns (ports, version pins, "this command runs from this path") — in the spec/memory.
- **The language rule (English docs):** chat language follows the user (any language is fine) — but **ALL documentation** (living-docs, specs, runbooks, commit messages, code comments) is written in **ENGLISH**. Rationale: fewer tokens (Turkish tokenizes measurably more expensively) · the model follows English instructions more reliably · consistent terminology across sessions. The templates are English end to end; the rule is enforced as CLAUDE.md rule 11. *(Since v6 the canonical repo itself — playbook, changelog, README — is English too.)*

---

## 10. Session hygiene & handover

- **The trigger = quality + a natural boundary, NOT a fixed token count.** A fresh session is higher quality than a compacted one — that is what handover is for. The context budget varies by model (200k vs 1M); **while technical capacity remains, finishing a coherent unit in the same session is allowed** — handing over half-done work usually costs more. At the natural boundary, the suggestion: *"This unit is done / quality is starting to degrade. I suggest a new session; the docs are current. Approve?"*
- **The safety net (OPTIONAL, not coercive):** the model CANNOT introspect its remaining context — "let the agent notice fullness" is unreliable; reliable tracking lives with the human + the harness. A project that wants it installs the **PreCompact hook** (**at project start, by choice** — not in the default setup): it runs before compaction fires → secures the handover state into the living-docs + notifies the user. It **does not force a handover** — after compaction the same session may continue. Projects without the hook run the same hygiene through human tracking *(the context% in the statusline helps)*.
- **Handover channels:** worker/ops → a **status report** + current living-docs. The Manager → a **handover prompt** + memory + living-docs.
- **The handover test (the Manager's symmetric of the Ops test):** if the handover prompt contains information that is not in the living-docs, that is not the prompt's richness — it is **a docs gap**; the doc gets fixed, not the prompt. The handover prompt serves comfort, not truth; the source is always the living-docs.
- Ideal granularity: one session per part; for a big part, one per sub-step.

---

## 11. Memory (behavior durability)

- **`manager-session-pattern`** (memory): how the Manager role works — the kickoff skeleton, ground-truth verification, gate-approval discipline, working agreements, the handover rule. The first Manager session saves it from `memory-seed/` (STARTGUIDE); it carries to later Manager sessions without interruption.
- **Mechanism note (set expectations right):** memory is **bound to the project directory and is role-blind** — *every* session in the project sees the same index; "the Manager loads it" is not selectivity, it is because the content happens to be Manager behavior. Role selectivity comes from the **kickoff**, not from memory.
- Memory = the **behavior/preference** information the repo does NOT record. Project state lives in the repo; behavior lives in memory. The two do not overlap.

---

## 12. The `.claude/` structure (solid from day one)

```
.claude/
├─ settings.json       # permissions: allow (safe read/build/test) · ask (commit/merge/push/checkout…) ·
│                      #   deny (.env reads, rm -rf, force-push, git clean) + hook registrations
├─ hooks/
│  ├─ guard-env.sh     # PreToolUse: blocks the common ACCIDENTAL paths to secret files (.env*, any suffix
│  │                   #   depth) — direct paths, subcommands, globs, case variants, direct symlinks, Grep
│  │                   #   globs (.env.example stays allowed) · accident guard, NOT a security boundary
│  ├─ secret-scan.sh   # UserPromptSubmit: if the user message smells like a secret, reminds the leak protocol (§9)
│  ├─ main-guard.sh    # PreToolUse(Bash): blocks CODE commits (untracked count) + compound-commit TOCTOU +
│  │                   #   cherry-picks + GATE4-unmarked merges on protected branches (VIBE_PROTECTED_BRANCHES)
│  │                   #   · exact-branch marker · git -C targets the RIGHT repo · docs-only commits free
│  │                   #   (.claude/ is control-plane, NOT docs) · accident guard — PR merges need branch protection
│  └─ pre-compact.sh   # (OPTIONAL — by choice at project start) PreCompact: ground snapshot + notification (§10)
├─ agents/             # verifier (GATE 4, §4.3) — the MINIMAL set; spec-writer/test-writer/design-guardian
│                      #   are added only once proven load-bearing (every agent is carried maintenance).
│                      #   verifier: pin a strong model + grow a project-specific checklist in it (Phase 0)
└─ commands/           # /gate1 (spec) · /gate2 (plan) · /gate3 (mechanical proof) · /gate4 (review) ·
                       #   /wip (checkpoint commit) · /new-part · /adapt (Phase 0: derive the project-specific
                       #   configuration) — names deliberately avoid Claude Code built-ins
```

---

## 13. Tracks (parallel, different gate profiles)

| Track | Numbering | Heavy gate | Note |
|---|---|---|---|
| **Code** | P1, P2… | GATE 4 (money/auth) | branch + checkpoint commits (§9); NO entry into main without GATE 4 |
| **Design** | G1, G2… | GATE 3 (visual/browser) | decision-maker: **Claude Design** (MCP; Claude Code **terminal mandatory**) · guardian guardrail; docs/design/ + STATUS |
| **Ops** | (ad-hoc) | "verify together" | persistent(cache) session; infra-state + runbooks |

**The design-track loop (field-proven; template: `docs/design/README.md`):**
```
brief (docs/design/<task>/brief.md) → Claude Design prototype (READ-ONLY on the repo; no commits)
→ Export / Handoff bundle → Code implements (design tokens only — no hardcoded values)
→ design-system-guardian gate (CODE SIDE ONLY) → PR → fixed-format report to the Manager → STATUS ledger
```
- **Known constraint:** Claude Design **cannot read `.claude/agents/`** — Design-side conformance comes from the published Design System (+ `design-system-notes.md`); the guardian gates only the Code side.
- **Two field lessons:** keep a `DESIGN-CONTEXT.md` **inside the web-app directory** (Design's read-only access can SEE it — the as-built truth both sides share) · **front-load hybrid**: global shell screens up-front, module screens JIT after their spec locks (designing before the spec locks = rework).

---

## 14. The base-project skeleton (copy & use) — orchestrated profile

> This section describes the **orchestrated** (multi-session) profile; for the **solo** (one session + subagents) variant → §17 / [`template-solo/`](template-solo/).

> **Since v3 this skeleton is MATERIALIZED as [`template/`](template/) in the canonical repo** — a new project = copy the contents of `template/` (or `npx vibe-playbook init orchestrated`) + follow [`STARTGUIDE.md`](template/STARTGUIDE.md). Rationale: every bootstrap from prose was a re-interpretation and drift started at birth; real files are the single source of truth, and skeleton changes are versioned too (§15). `workflow.md` is the playbook's **normative summary** (rules only; the rationale stays here) — so the kernel/rationale split emerged without restructuring the playbook. **Language: everything is ENGLISH** (§9 language rule — everything that enters an agent's context is English).

```
template/  →  <new-repo>/
├─ STARTGUIDE.md          # human: setup steps + the Phase 0 kickoff command + option switches
├─ workflow.md            # the playbook's NORMATIVE summary (headed "← playbook vN"; ends with "Project deviations")
├─ CLAUDE.md              # LEAN: doc map + 11 critical rules (auto-loaded)
├─ progress.md · issues.md            # state boards (start empty; loaded at session start)
├─ open-questions.md · NEEDS-FROM-USER.md · .env.example · gitignore (→ .gitignore at init)
├─ PRD.md · architecture.md · data-model.md      # the plan track (filled during Phase 0)
├─ infra-state.md         # the Ops session board (infra truth)
├─ module-specs/_TEMPLATE.md          # the spec template (incl. the gate-profile field — §2)
├─ phase-kickoffs.md
├─ docs/
│  ├─ archive/changelog.md            # + phase-N-summary.md at phase ends
│  ├─ ops/_TEMPLATE-runbook.md        # steps + a why-decisions section (the anti-confabulation source)
│  └─ design/{STATUS.md, design-system-notes.md}   # optional (delete if unused)
├─ .claude/               # the §12 structure — hooks are tested, working files
└─ memory-seed/manager-session-pattern.md   # the first Manager session saves it to memory (STARTGUIDE §3)
```

**Generalization:** fill in everything project-specific (domain, stack, business rules) during Phase 0. **The domain-independent core:** 4 session types · human gates · tracks · the living-docs lifecycle · hand-in-hand · the kickoff skeleton · working agreements · memory.

---

## 15. The playbook's own lifecycle (meta-learning)

The playbook is code too — **versioned process-code** (the same treatment as "prompts/ are code"). Living-docs learn about the project *itself*; this section sets up the **methodology's** learning. Without this channel, fork-drift is inevitable: every project's workflow.md drifts in its own direction, lessons never flow back to base, and the next project starts from a stale template.

- **Canonical home:** this repo. The single truth lives here; scratchpad/project copies are derivatives.
- **Version + changelog:** every meaningful change gets a version + a CHANGELOG line. A project copy is headed **"← playbook vN"** → which project derived from which version stays visible.
- **The phase retro (the Manager asks, ~5 min, at phase close):**
  1. Which gate caught something **real**?
  2. Which gate did you approve **without reading / from the summary**?
  3. Which rule was **violated/bypassed** — and why?
  Answers are labeled: **PROJECT** (recorded into that project's workflow/spec) · **PLAYBOOK** (a changelog candidate for base).
- **Gate calibration:** if the same gate keeps getting "approved without reading", it is **lightened** on that track; a gate that catches real things stays heavy. Gates are not only added — they are **calibrated**; in an unmeasured system approval turns theatrical (gate fatigue).
- **The backflow artifact (v7.1):** every template ships **`PLAYBOOK-FEEDBACK.md`** — an append-only, **methodology-only** log (friction · theater gates · bypasses+why · hook misfires · missing/dead doc classes · context-hygiene failures · **model-shift notes**: crutches the improving models no longer need, or new ones they do). Retro PLAYBOOK answers land there, and sessions add entries the moment they observe something — the backflow no longer depends on end-of-project archaeology. At project end the human hands the file to this repo.
- **Intake protocol (this side — NEVER apply blindly):** entries are **claims, not truth** — verify what is verifiable, mark the rest anecdote → filter through optimum>perfect (does it reduce the human load / preserve context?) → judge against the three first-class goals (an update that weakens consistency/sustainability/context does not pass, however convenient) → verdict per entry: **adopt / adapt / reject** (rejections recorded in the changelog with the why) → one entry at a time, never bulk. *(The file carries this protocol in its own header, so it travels with the file.)*
- **Backflow:** PLAYBOOK-labeled lessons are recorded here + the version increments; the next project copies the current version.

---

## 16. Summary flow

```
Phase 0 (plan)──[🚦APPROVAL]──> split Phase N into parts
     │
     ├─ ② Development (P): spec[🚦]→plan[🚦]→impl(checkpoints)→test[🚦]→review[🚦]→merge→checkpoint
     ├─ ④ Design (G):      docs/design + guardian; GATE 3 is the heavy one (visual)
     └─ ③ Ops:             infra-state + runbooks; hand-in-hand (artifact↔installation)
     │
  ① The MANAGER coordinates every track: report→VERIFY(verifier subagent)→refine kickoff→audit gates
     │
  at the natural boundary → [new-session suggestion 🚦] → handover (docs + memory + prompt) → fresh session
     │              (the PreCompact safety net in the background — §10)
     │
  phase close → RETRO (3 questions) → PROJECT lessons into the workflow · PLAYBOOK lessons into base (§15)
```

> **How the three goals are protected:** CONSISTENCY = decisions are written into living-docs + ground-truth verification (no source is trusted blindly, including the Manager's own memory) · SUSTAINABILITY = the state/archive split + bloat budget + handover channels + phase retro/backflow · CONTEXT PRESERVATION = session types with separate contexts + the fresh-session preference + the verifier subagent (the Manager's context stays clean) + the PreCompact safety net.

---

## 17. The second profile: SOLO — single-session vibe (`template-solo/`)

The same methodology has two profiles; **the DNA is shared** (the living-docs system · human gates · hooks · English docs · anti-confabulation · meta-learning). The difference is the **audience** as much as how work is distributed:

| | **Orchestrated** (`template/`) | **Solo** (`template-solo/`) |
|---|---|---|
| **Made for** | **software developers** — read specs/diffs, coordinate sessions | **vibe coders** (and developers in vibe mode) — the agent drives the mechanics; the human steers in plain language |
| Sessions | multi-session (4 roles) | **ONE session + subagents** |
| Development | interactive dev sessions | the **implementer** subagent |
| Code reading | the dev session's job | the **scout** subagent (code never enters the main context) |
| Parallelism | parallel tracks via worktrees | SERIAL — one branch, one writing subagent |
| Permissions | standard (commit/merge ask first) | **WIDE** (Edit/Write, commit, merge pre-allowed — the control points are the GATES, the invariants live in hooks) |
| Ceremony | higher (kickoffs/handovers) | low (the `/part` driver; no kickoffs/handovers) |
| When | big work, parallel tracks, long phases | small/medium work, solo flow, speed |

**Architecture:** the main session = the **orchestrator** (manager + dispatcher). Product code is neither written nor read in the main context — the scout answers, the implementer changes, the verifier verifies; only **compact reports** return to the orchestrator. §4.3's "development is not moved into subagents" boundary is **deliberately inverted** in solo: the user watches the orchestrator's reports instead of the raw dev stream *(the trade: visibility into the work ↓, single-session comfort ↑)*. The gates remain the human's exactly as before; **ground-truth verification applies unchanged** — a subagent report is as fallible as a session report; after every implementer dispatch it is verified with `git log`/`diff --stat`. Hooks fire on subagent tool calls too — the guards hold everywhere.

**Autonomy (human dependency shrinks to the gates):** BETWEEN gates the human is never stopped — permissions are deliberately wide (Edit/Write, `git commit/merge` pre-allowed; push/reset/rebase still ask, destructive ops are denied). This is safe because control does not live in the permission prompt: **gates carry the human approvals, hooks carry the invariants** (main-guard blocks a GATE4-unmarked merge anyway). Dispatches go **in batches**: a small part = the whole approved plan in one dispatch; bigger = packages of 2–4 steps; the implementer makes a checkpoint commit per step — history stays granular, interruptions stay few.

**Context hygiene (the heart of solo) — three layers:**
1. **Prevention (delegation-first, rule 12):** file contents never enter the main context → the context fills slowly by nature; the main context carries decisions + summaries.
2. **Safe reset (`/tidy`, rule 13):** after every merge/ops block — the docs are synced to the ground, rotation is done, "decisions that live only in chat" are swept into the docs → the reset is offered: **`/clear` at a part boundary (RECOMMENDED — the solo equivalent of orchestrated's fresh session)**, `/compact` mid-part. **The honest limit:** the model CANNOT wipe its own context (`/clear`/`/compact` are user commands) — what it can do: keep the context from filling, make the reset zero-risk, and offer it as one keystroke. Quality order: `/clear` at a boundary > `/compact` > unplanned auto-compaction (even that is safe — snapshot + docs discipline). **The restart test** (the solo counterpart of the handover test): after `/clear`, a fresh session must continue from CLAUDE.md + living-docs + memory alone. *(Memory survives `/clear` → behavior in memory, state in docs, cleaning is cheap. So solo's "one session" means one window/flow — NOT one lifelong context; orchestrated's fresh-session hygiene lives on in solo as `/clear` at part boundaries.)*
3. **The safety net (PreCompact default-ON):** a solo session lives long; compaction WILL come — the hook that is optional in orchestrated is the default in solo.

**The audience line, honestly drawn:** solo removes the *mechanical* developer dependencies (branches, commits, merges, worktrees — the agent runs them; GATE 4 is presented plain-language-first with a technical appendix). It does NOT remove the *judgment* dependency: the gates still ask a human "is this what I wanted? does it work when I try it?" — that judgment is the safety backbone, and on money/auth surfaces it matters most. A vibe coder supplies judgment; a developer can additionally read the appendix.

**Profile switching:** the living-docs layer is identical in both profiles (same file names, same spec template) → switching mid-project is possible: `.claude/` + `workflow.md` + `CLAUDE.md` change, the docs stay as they are. **Start solo, switch to orchestrated when parallelism appears** — that is the supported path.
