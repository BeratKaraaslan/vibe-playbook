#!/usr/bin/env bash
# PreToolUse(Bash) hook: guards the invariant "nothing enters a protected branch without GATE 4"
# (CLAUDE.md rule 1) against the AGENT's accidental/drifting paths.
# This is an ACCIDENT GUARD, not a security boundary: novel command shapes, wrapper scripts, or
# PR-side merges bypass string matching — pair with GitHub/GitLab branch protection for hard
# guarantees (a merge done on GitHub never touches this hook).
#  - blocks CODE commits on protected branches; docs-only commits allowed (*.md, docs/,
#    module-specs/, memory-seed/, .gitignore, .env.example, LICENSE). NOTE: .claude/ is
#    CONTROL-PLANE, not docs — hook/settings/command changes need a branch + GATE 4.
#  - blocks COMPOUND commands containing a commit (e.g. `… && git commit`) on protected branches:
#    the guard cannot see files created later in the same call (TOCTOU) — commit standalone.
#  - counts UNTRACKED files as code changes.
#  - blocks `git cherry-pick` outright; `git merge` needs .claude/.gate4-ok with the EXACT branch.
#  - honors `git -C <path>` (checks the TARGET repo) and flag forms like `git -c k=v commit`.
# Protected branches: VIBE_PROTECTED_BRANCHES="main master trunk" or edit the line below.
set -u
input=$(cat 2>/dev/null || true)
if ! command -v python3 >/dev/null 2>&1; then
  printf 'BLOCKED (main-guard): python3 is required by the hooks and was not found — install python3 (or knowingly remove the hooks).\n' >&2
  exit 2
fi

PROTECTED_BRANCHES="${VIBE_PROTECTED_BRANCHES:-main master}"

cmd=$(printf '%s' "$input" | python3 -c '
import json, sys
try:
    d = json.load(sys.stdin)
except Exception:
    sys.exit(0)
print(d.get("tool_input", {}).get("command", ""))' 2>/dev/null) || exit 0
[ -n "$cmd" ] || exit 0
case "$cmd" in *git*) : ;; *) exit 0 ;; esac

# strip a trailing shell comment so a branch name hidden in "# …" cannot satisfy the token match
cmd_nc=$(printf '%s' "$cmd" | sed 's/[[:space:]]#.*$//')

# honor `git -C <path>`: run every check against the TARGET repo, not the hook's cwd
gitC=$(printf '%s' "$cmd_nc" | sed -nE 's/.*git[[:space:]]+-C[[:space:]]+([^[:space:];|&]+).*/\1/p' | head -1)
if [ -n "$gitC" ]; then
  git() { command git -C "$gitC" "$@"; }
fi

branch=$(git symbolic-ref --quiet --short HEAD 2>/dev/null || true)
[ -n "$branch" ] || exit 0
case " $PROTECTED_BRANCHES " in
  *" $branch "*) : ;;
  *) exit 0 ;;
esac

deny() { printf 'BLOCKED (main-guard): %s\n' "$1" >&2; exit 2; }

# git subcommand matcher tolerant of intervening flags: `git commit`, `git -C . commit`, `git -c k=v commit`
GIT_PRE='(^|[;&|]|[[:space:]])git([[:space:]]+-[A-Za-z0-9-]+([[:space:]]+[^-[:space:]][^[:space:];|&]*)?)*[[:space:]]+'

# --- commit protection (docs-only on protected branches) ---
if printf '%s' "$cmd_nc" | grep -qE "${GIT_PRE}commit([[:space:]]|\$)"; then
  # TOCTOU guard: files created earlier in the SAME call are invisible to the checks below
  if printf '%s' "$cmd_nc" | grep -qE '(&&|;|\|)'; then
    deny "compound command containing a commit on $branch — run the commit as a STANDALONE command so the guard can see the real tree state"
  fi
  docs_re='(^|/)(docs|module-specs|memory-seed)(/|$)|\.md$|^\.gitignore$|^\.env\.example$|^LICENSE'
  offenders=$({ git diff --cached --name-only; git diff --name-only; git ls-files --others --exclude-standard; } 2>/dev/null | sort -u | grep -vE "$docs_re" || true)
  if [ -n "$offenders" ]; then
    short=$(printf '%s\n' "$offenders" | head -5 | tr '\n' ' ')
    deny "no CODE commits on $branch — open a part branch (git switch -c wip/P-N). Non-docs files (staged, modified or untracked all count): $short"
  fi
fi

# --- cherry-pick protection (lands code without the merge ritual) ---
if printf '%s' "$cmd_nc" | grep -qE "${GIT_PRE}cherry-pick([[:space:]]|\$)"; then
  deny "cherry-pick onto $branch bypasses GATE 4 — use the merge ritual (.claude/.gate4-ok) instead."
fi

# --- merge protection (GATE 4 marker required, EXACT branch token) ---
if printf '%s' "$cmd_nc" | grep -qE "${GIT_PRE}merge([[:space:]]|\$)"; then
  flag=".claude/.gate4-ok"
  [ -f "$flag" ] || deny "GATE 4 approval is not marked. AFTER human approval run: echo <branch-name> > .claude/.gate4-ok"
  approved=$(head -1 "$flag" | tr -d '[:space:]')
  [ -n "$approved" ] || deny ".gate4-ok is empty — it must contain the approved branch name."
  # exact-token match (quotes stripped): wip/P-1 must NOT approve wip/P-10; "wip/P-1" must not false-block
  printf '%s' "$cmd_nc" | tr -s '[:space:]' '\n' | tr -d "'\"" | grep -qxF -- "$approved" \
    || deny ".gate4-ok is for branch '$approved'; this command does not merge exactly that branch. Update the marker if it is wrong."
fi

exit 0
