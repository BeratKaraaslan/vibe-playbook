#!/usr/bin/env bash
# PreCompact hook: pins the ground snapshot to disk before compaction + notifies the human.
# Registered BY DEFAULT in the solo profile; OPTIONAL in orchestrated (setup: STARTGUIDE §2).
# It cannot stop/force compaction; after compaction "what was the state?" is answered from disk.
# Honest failure: if the snapshot cannot be written, say so and exit non-zero — never fake success.
set -u
input=$(cat 2>/dev/null || true)
trigger=$(printf '%s' "$input" | python3 -c '
import json, sys
try:
    print(json.load(sys.stdin).get("trigger", "?"))
except Exception:
    print("?")' 2>/dev/null || echo "?")

root="${CLAUDE_PROJECT_DIR:-$PWD}"
snap="$root/docs/archive/compact-snapshots.md"

if ! mkdir -p "$root/docs/archive" 2>/dev/null; then
  echo "PreCompact: FAILED to create $root/docs/archive — ground snapshot NOT written." >&2
  exit 1
fi

if {
  echo "## $(date '+%Y-%m-%d %H:%M') — compaction (trigger: $trigger)"
  echo '```'
  echo "branch: $(git -C "$root" branch --show-current 2>/dev/null || echo '?')"
  git -C "$root" status --short 2>/dev/null | head -30
  git -C "$root" log --oneline -5 2>/dev/null
  echo '```'
  echo
} >> "$snap" 2>/dev/null; then
  echo "PreCompact: ground snapshot appended to docs/archive/compact-snapshots.md (trigger: $trigger). Check that progress.md is current; a reset is an option." >&2
else
  echo "PreCompact: FAILED to write $snap — ground snapshot NOT written." >&2
  exit 1
fi
exit 0
