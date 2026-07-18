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
git switch -q main

# --- external-review v8.1 regressions ---
j2() { printf '{"tool_name":"Bash","tool_input":{"command":%s}}' "$(python3 -c 'import json,sys; print(json.dumps(sys.argv[1]))' "$1")"; }

check 2 "compound create+commit blocked (TOCTOU guard)" "$(j2 'echo y >> app.js && git add app.js && git commit -m code')"

echo brandnew > brand-new.js
check 2 "untracked code file counts as offender" "$(j2 'git commit -m docs')"
rm brand-new.js

mkdir -p .claude/hooks
echo weakened > .claude/hooks/main-guard.sh
git add -A
check 2 ".claude control-plane commit is NOT docs-only" "$(j2 'git commit -m docs')"
git reset -q; rm -rf .claude/hooks

echo "wip/P-1" > .claude/.gate4-ok
check 0 "quoted merge target allowed (no false block)" "$(j2 'git merge "wip/P-1"')"
check 2 "marker hidden in shell comment still blocked" "$(j2 'git merge wip/P-10 # wip/P-1')"
rm .claude/.gate4-ok

# git -C targets the SUB repo, not the hook cwd
mkdir -p sub && ( cd sub && git init -qb main && git config user.email t@t.t && git config user.name t \
  && echo m > r.md && git add -A && git commit -qm i && echo code > c.js && git add c.js )
git switch -qc feature 2>/dev/null || git switch -q feature
check 2 "git -C checks the target repo (protected sub, unprotected cwd)" "$(j2 'git -C sub commit -m x')"
git switch -q main
rm -rf sub

# --- external-review v8.4 regressions ---
# F-03: the marker must match the actual merge OPERAND, not any token in the command
echo "wip/P-1" > .claude/.gate4-ok
check 2 "merge P-10 with approved name smuggled into -m message blocked" "$(j2 'git merge wip/P-10 -m wip/P-1')"
check 2 "merge P-10 with approved name in --strategy-option blocked" "$(j2 'git merge wip/P-10 --strategy-option wip/P-1')"
check 0 "merge P-1 with -m note (real operand approved) free" "$(j2 'git merge wip/P-1 -m note')"
rm .claude/.gate4-ok
# F-04: absolute-path git is still a git invocation
echo z3 >> app.js; git add app.js
check 2 "absolute-path /usr/bin/git commit blocked" "$(j2 '/usr/bin/git commit -m code')"
git restore --staged app.js; git checkout -q -- app.js
# F-04: a shell operator INSIDE a quoted commit message is not a compound command (no false block)
echo d1 >> docs/n.md; git add -A
check 0 "docs commit with quoted ; in message allowed (no false positive)" "$(j2 'git commit -m "docs: a; b"')"
git commit -qm docs
# v8.4: git merge --abort/--continue/--quit conclude an in-progress merge (no new branch) — allowed
check 0 "merge --abort on main allowed (concludes in-progress merge)" "$(j2 'git merge --abort')"
check 0 "merge --continue on main allowed" "$(j2 'git merge --continue')"
check 0 "merge --quit on main allowed" "$(j2 'git merge --quit')"
# a control merge chained after a branch merge must NOT launder the governed operand merge
echo "wip/P-1" > .claude/.gate4-ok
check 2 "operand merge stays governed when chained before --continue" "$(j2 'git merge wip/P-10 && git merge --continue')"
rm .claude/.gate4-ok
# F-17: fail-closed on malformed / unexpected hook input
check 2 "malformed hook input fails closed" '{bad'
check 2 "non-dict tool_input fails closed" '{"tool_name":"Bash","tool_input":"x"}'
check 0 "empty stdin allowed (nothing to guard)" ''

cd /; rm -rf "$REPO"
echo "RESULT: $PASS passed, $FAIL failed"
exit $FAIL
