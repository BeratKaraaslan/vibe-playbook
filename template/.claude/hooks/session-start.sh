#!/usr/bin/env bash
# SessionStart hook (startup | resume | clear | compact): prints a compact GROUND header into the
# session's context — branch, uncommitted-file count, last commits, the progress.md "Now" section.
# "Hook > instruction": the doc-map rule "read progress.md at session start" and the restart test
# after /clear or compaction no longer depend on the model remembering to look. Worktree-aware
# (rooted at the session's own tree). Context-only: it NEVER blocks (always exit 0).
set -u
input=$(cat 2>/dev/null || true)
cwd=$(printf '%s' "$input" | python3 -c '
import json, sys
try:
    print(json.load(sys.stdin).get("cwd", "") or "")
except Exception:
    print("")' 2>/dev/null || true)
root=$(git -C "${cwd:-${CLAUDE_PROJECT_DIR:-$PWD}}" rev-parse --show-toplevel 2>/dev/null) || exit 0

branch=$(git -C "$root" branch --show-current 2>/dev/null || echo '?')
dirty=$(git -C "$root" status --porcelain 2>/dev/null | wc -l | tr -d ' ')
echo "GROUND (session-start hook; the repo is authoritative — full board: progress.md + issues.md)"
echo "- tree: $root"
echo "- branch: ${branch:-detached} · uncommitted files: $dirty"
echo "- last commits:"
git -C "$root" log --oneline -3 2>/dev/null | sed 's/^/    /'
if [ -f "$root/progress.md" ]; then
  echo "- progress.md \"Now\":"
  awk '/^## Now/{f=1;next} /^## /{f=0} f && /^- /' "$root/progress.md" 2>/dev/null | head -6 | sed 's/^/    /'
fi
exit 0
