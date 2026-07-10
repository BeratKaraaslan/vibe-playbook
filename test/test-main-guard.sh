#!/usr/bin/env bash
# main-guard suite: "nothing enters main without GATE 4" (8 scenarios, in a temp git repo).
# Usage: test-main-guard.sh <path-to-main-guard.sh>
set -u
MG="${1:?usage: test-main-guard.sh <hook-path>}"
MG="$(cd "$(dirname "$MG")" && pwd)/$(basename "$MG")"
PASS=0; FAIL=0

check() { # check <expected-exit> <name> <json>
  printf '%s' "$3" | bash "$MG" >/dev/null 2>&1
  local got=$?
  if [ "$got" -eq "$1" ]; then PASS=$((PASS+1)); echo "  OK  $2"
  else FAIL=$((FAIL+1)); echo "  XX  $2 — expected $1, got $got"; fi
}
j() { printf '{"tool_name":"Bash","tool_input":{"command":"%s"}}' "$1"; }

REPO=$(mktemp -d)
cd "$REPO"
git init -q -b main
git config user.email t@t.t; git config user.name t
mkdir -p docs .claude
echo x > README.md; echo y > app.js
git add -A; git commit -qm init

echo z >> app.js; git add app.js
check 2 "code commit on main blocked" "$(j 'git commit -m x')"
git restore --staged app.js; git checkout -q -- app.js

echo note >> docs/n.md; echo p >> progress.md; git add -A
check 0 "docs-only commit on main free" "$(j 'git commit -m docs')"
git commit -qm docs

check 2 "unmarked merge blocked" "$(j 'git merge wip/P-1')"

echo "wip/P-9" > .claude/.gate4-ok
check 2 "wrong-branch marker blocked" "$(j 'git merge wip/P-1')"

echo "wip/P-1" > .claude/.gate4-ok
check 0 "merge with correct marker free" "$(j 'git merge --no-ff wip/P-1')"
rm .claude/.gate4-ok

git switch -qc wip/P-1
echo w >> app.js; git add app.js
check 0 "code commit on part branch free" "$(j 'git commit -m checkpoint')"

check 0 "non-git command free" "$(j 'npm run test')"

git switch -q main
check 0 "git log --merges free (no false positive)" "$(j 'git log --merges')"

# --- reviewer-found edge cases (v8) ---
echo z2 >> app.js; git add app.js
check 2 "git -C . commit blocked (flag form)" "$(j 'git -C . commit -m x')"
check 2 "git -c k=v commit blocked (flag form)" "$(j 'git -c user.name=t commit -m x')"
check 2 "cherry-pick on main blocked" "$(j 'git cherry-pick abc1234')"
git restore --staged app.js; git checkout -q -- app.js

echo "wip/P-1" > .claude/.gate4-ok
check 2 "prefix branch NOT approved (wip/P-1 marker vs wip/P-10 merge)" "$(j 'git merge wip/P-10')"
check 0 "exact branch still approved" "$(j 'git merge wip/P-1')"
rm .claude/.gate4-ok

check 0 "git log --grep commit free (no false positive)" "$(j 'git log --grep commit')"

# protected-branch configurability
git switch -qc trunk
echo t >> app.js; git add app.js
check 0 "trunk unprotected by default" "$(j 'git commit -m x')"
export VIBE_PROTECTED_BRANCHES="main master trunk"
check 2 "trunk protected via VIBE_PROTECTED_BRANCHES" "$(j 'git commit -m x')"
unset VIBE_PROTECTED_BRANCHES
git restore --staged app.js; git checkout -q -- app.js

cd /; rm -rf "$REPO"
echo "RESULT: $PASS passed, $FAIL failed"
exit $FAIL
