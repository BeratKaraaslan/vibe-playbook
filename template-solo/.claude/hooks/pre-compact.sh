#!/usr/bin/env bash
# PreCompact hook: pins the ground snapshot to disk before compaction + notifies the human.
# Registered BY DEFAULT in the solo profile; OPTIONAL in orchestrated (setup: STARTGUIDE §2).
# After compaction "what was the state?" is answered from disk.
# Honest failure: if the snapshot cannot be written, exit 2 — under current Claude Code ONLY exit 2
# blocks compaction, so blocking is the honest response (context is not lost silently; the human
# fixes docs/archive perms or removes the hook). A snapshot path that resolves OUTSIDE the project
# is refused rather than followed (containment).
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
  exit 2
fi

# Containment: if docs/archive is a symlink escaping the project root, refuse (do not append outside).
arch_real=$(cd "$root/docs/archive" 2>/dev/null && pwd -P || echo "")
root_real=$(cd "$root" 2>/dev/null && pwd -P || echo "$root")
case "$arch_real/" in
  "$root_real"/*) : ;;
  *) echo "PreCompact: docs/archive resolves outside the project ($arch_real) — refusing to write the snapshot." >&2; exit 2 ;;
esac

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
  exit 2
fi
exit 0
