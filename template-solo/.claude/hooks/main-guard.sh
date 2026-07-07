#!/usr/bin/env bash
# PreToolUse(Bash) hook: physically protects the invariant "nothing enters main without GATE 4" (CLAUDE.md rule 1).
#  - blocks CODE commits on main/master (docs-only commits allowed: *.md, docs/, module-specs/,
#    memory-seed/, .claude/, .gitignore, .env.example, LICENSE)
#  - on main/master, `git merge` passes only if .claude/.gate4-ok contains the branch being merged
#    (marker: AFTER human approval → `echo <branch> > .claude/.gate4-ok`)
# A drift/forgetting safety net; not a guarantee against bad intent.
set -u
input=$(cat 2>/dev/null || true)
command -v python3 >/dev/null 2>&1 || exit 0

cmd=$(printf '%s' "$input" | python3 -c '
import json, sys
try:
    d = json.load(sys.stdin)
except Exception:
    sys.exit(0)
print(d.get("tool_input", {}).get("command", ""))' 2>/dev/null) || exit 0
[ -n "$cmd" ] || exit 0
case "$cmd" in *git*) : ;; *) exit 0 ;; esac

branch=$(git symbolic-ref --quiet --short HEAD 2>/dev/null || true)
[ "$branch" = "main" ] || [ "$branch" = "master" ] || exit 0

deny() { printf 'BLOCKED (main-guard): %s\n' "$1" >&2; exit 2; }

# --- commit protection (docs-only on main) ---
if printf '%s' "$cmd" | grep -qE '(^|[;&|]|[[:space:]])git[[:space:]]+(-[^[:space:]]+[[:space:]]+)*commit([[:space:]]|$)'; then
  docs_re='(^|/)(docs|module-specs|memory-seed)(/|$)|^\.claude/|\.md$|^\.gitignore$|^\.env\.example$|^LICENSE'
  offenders=$({ git diff --cached --name-only; git diff --name-only; } 2>/dev/null | sort -u | grep -vE "$docs_re" || true)
  if [ -n "$offenders" ]; then
    short=$(printf '%s\n' "$offenders" | head -5 | tr '\n' ' ')
    deny "no CODE commits on main — open a part branch (git switch -c wip/P-N). Code files: $short(note: unstaged changes count too; main must carry no code changes at all)"
  fi
fi

# --- merge protection (GATE 4 marker required) ---
if printf '%s' "$cmd" | grep -qE '(^|[;&|]|[[:space:]])git[[:space:]]+(-[^[:space:]]+[[:space:]]+)*merge([[:space:]]|$)'; then
  flag=".claude/.gate4-ok"
  [ -f "$flag" ] || deny "GATE 4 approval is not marked. AFTER human approval run: echo <branch-name> > .claude/.gate4-ok"
  approved=$(head -1 "$flag" | tr -d '[:space:]')
  [ -n "$approved" ] || deny ".gate4-ok is empty — it must contain the approved branch name."
  printf '%s' "$cmd" | grep -qF "$approved" || deny ".gate4-ok is for branch '$approved'; this command does not merge that branch. Update the marker if it is wrong."
fi

exit 0
