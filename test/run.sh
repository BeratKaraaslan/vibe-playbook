#!/usr/bin/env bash
# Runs all hook suites against BOTH templates. Exit nonzero on any failure.
set -u
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
FAILED=0

for tpl in template template-solo; do
  echo "### $tpl / guard-env"
  bash "$ROOT/test/test-guard-env.sh" "$ROOT/$tpl/.claude/hooks/guard-env.sh" || FAILED=1
  echo "### $tpl / main-guard"
  bash "$ROOT/test/test-main-guard.sh" "$ROOT/$tpl/.claude/hooks/main-guard.sh" || FAILED=1
  echo
done

if [ "$FAILED" -eq 0 ]; then echo "ALL SUITES PASSED"; else echo "FAILURES PRESENT"; fi
exit $FAILED
