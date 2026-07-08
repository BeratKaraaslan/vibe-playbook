#!/usr/bin/env bash
# guard-env suite: direct access + subcommand + glob + case + redirect bypass attempts (28 scenarios).
# Usage: test-guard-env.sh <path-to-guard-env.sh>
set -u
HOOK="${1:?usage: test-guard-env.sh <hook-path>}"
PASS=0; FAIL=0

check() { # check <expected-exit> <name> <json>
  printf '%s' "$3" | bash "$HOOK" >/dev/null 2>&1
  local got=$?
  if [ "$got" -eq "$1" ]; then PASS=$((PASS+1)); echo "  OK  $2"
  else FAIL=$((FAIL+1)); echo "  XX  $2 — expected $1, got $got"; fi
}
bash_j() { printf '{"tool_name":"Bash","tool_input":{"command":%s}}' "$(python3 -c 'import json,sys; print(json.dumps(sys.argv[1]))' "$1")"; }

echo "== MUST BLOCK (exit 2) =="
check 2 "Read .env"                     '{"tool_name":"Read","tool_input":{"file_path":"/p/.env"}}'
check 2 "Read subdir api/.env"          '{"tool_name":"Read","tool_input":{"file_path":"api/.env"}}'
check 2 "Edit .env.local"               '{"tool_name":"Edit","tool_input":{"file_path":".env.local"}}'
check 2 "Write .env.production"         '{"tool_name":"Write","tool_input":{"file_path":".env.production","content":"x"}}'
check 2 "Grep path=.env"                '{"tool_name":"Grep","tool_input":{"pattern":"KEY","path":".env"}}'
check 2 "Grep glob=*.env"               '{"tool_name":"Grep","tool_input":{"pattern":"KEY","path":".","glob":"*.env"}}'
check 2 "bash: cat .env"                "$(bash_j 'cat .env')"
check 2 "bash: cat .env* (GLOB)"        "$(bash_j 'cat .env*')"
check 2 "bash: cat .env.* (GLOB)"       "$(bash_j 'cat .env.*')"
check 2 "bash: cat .ENV (CASE)"         "$(bash_j 'cat .ENV')"
check 2 "bash: echo x >.env (no-space redirect)" "$(bash_j 'echo KEY=x >.env')"
check 2 "bash: source .env"             "$(bash_j 'source .env && npm start')"
check 2 "bash: cp .env /tmp/copy"       "$(bash_j 'cp .env /tmp/copy')"
check 2 "bash: mv .env.example .env (second token)" "$(bash_j 'mv .env.example .env')"
check 2 "bash: base64 .env"             "$(bash_j 'base64 .env')"
check 2 "bash: python open(.env)"       "$(bash_j 'python3 -c "print(open(\".env\").read())"')"
check 2 "bash: grep KEY ./.env"         "$(bash_j 'grep KEY ./.env')"
check 2 "bash: F=.env var assignment"   "$(bash_j 'F=.env; cat $F')"

echo "== MUST STAY FREE (exit 0) =="
check 0 "Read .env.example"             '{"tool_name":"Read","tool_input":{"file_path":".env.example"}}'
check 0 "Write .env.example"            '{"tool_name":"Write","tool_input":{"file_path":".env.example","content":"# X="}}'
check 0 "bash: cp .env.example backup"  "$(bash_j 'cp .env.example /tmp/example')"
check 0 "bash: cat .env.sample"         "$(bash_j 'cat .env.sample')"
check 0 "bash: process.env code"        "$(bash_j 'node -e "console.log(process.env.NODE_ENV)"')"
check 0 "Write app.js (contains process.env)" '{"tool_name":"Write","tool_input":{"file_path":"src/app.js","content":"const k = process.env.KEY;"}}'
check 0 "bash: npm i dotenv"            "$(bash_j 'npm install dotenv')"
check 0 "bash: config.environment.ts"   "$(bash_j 'grep foo config.environment.ts')"
check 0 "Grep glob=*.environment.ts"    '{"tool_name":"Grep","tool_input":{"pattern":"x","glob":"*.environment.ts"}}'
check 0 "bash: plain command"           "$(bash_j 'npm run test')"

echo "RESULT: $PASS passed, $FAIL failed"
exit $FAIL
