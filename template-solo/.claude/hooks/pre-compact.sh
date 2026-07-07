#!/usr/bin/env bash
# PreCompact hook (OPTIONAL — see STARTGUIDE §2; NOT registered in the default settings.json).
# It cannot stop/force compaction; what it can do: pin the ground snapshot to disk + notify the human.
# So after compaction, "what was the state?" is answered from disk, not from the context summary.
set -u
input=$(cat 2>/dev/null || true)
trigger=$(printf '%s' "$input" | python3 -c '
import json, sys
try:
    print(json.load(sys.stdin).get("trigger", "?"))
except Exception:
    print("?")' 2>/dev/null || echo "?")

mkdir -p docs/archive
snap="docs/archive/compact-snapshots.md"
{
  echo "## $(date '+%Y-%m-%d %H:%M') — compaction (trigger: $trigger)"
  echo '```'
  echo "branch: $(git branch --show-current 2>/dev/null || echo '?')"
  git status --short 2>/dev/null | head -30
  git log --oneline -5 2>/dev/null
  echo '```'
  echo
} >> "$snap" 2>/dev/null

echo "PreCompact: ground snapshot appended to $snap (trigger: $trigger). Check that progress.md is current; a handover is an option." >&2
exit 0
