#!/usr/bin/env bash
# PreToolUse(Bash) hook: "main'e KAPI 4'süz giriş yok" invariantını fiziksel korur (CLAUDE.md kural 1).
#  - main/master üzerinde KOD commit'ini bloklar (docs-only commit serbest: *.md, docs/, module-specs/,
#    memory-seed/, .claude/, .gitignore, .env.example, LICENSE)
#  - main/master üzerinde `git merge`, yalnız .claude/.gate4-ok dosyası merge edilen branch adını
#    içeriyorsa geçer (işaret: insan onayı SONRASI `echo <branch> > .claude/.gate4-ok`)
# Drift/unutma emniyetidir; kötü niyete karşı garanti değildir.
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

deny() { printf 'ENGELLENDİ (main-guard): %s\n' "$1" >&2; exit 2; }

# --- commit koruması (main'de yalnız docs-only) ---
if printf '%s' "$cmd" | grep -qE '(^|[;&|]|[[:space:]])git[[:space:]]+(-[^[:space:]]+[[:space:]]+)*commit([[:space:]]|$)'; then
  docs_re='(^|/)(docs|module-specs|memory-seed)(/|$)|^\.claude/|\.md$|^\.gitignore$|^\.env\.example$|^LICENSE'
  offenders=$({ git diff --cached --name-only; git diff --name-only; } 2>/dev/null | sort -u | grep -vE "$docs_re" || true)
  if [ -n "$offenders" ]; then
    short=$(printf '%s\n' "$offenders" | head -5 | tr '\n' ' ')
    deny "main üzerinde KOD commit'i yok — parça branch'i aç (git switch -c wip/P-N). Kod dosyaları: $short(not: unstaged değişiklikler de sayılır; main'de kod değişikliği hiç bulunmamalı)"
  fi
fi

# --- merge koruması (KAPI 4 işareti şart) ---
if printf '%s' "$cmd" | grep -qE '(^|[;&|]|[[:space:]])git[[:space:]]+(-[^[:space:]]+[[:space:]]+)*merge([[:space:]]|$)'; then
  flag=".claude/.gate4-ok"
  [ -f "$flag" ] || deny "KAPI 4 onayı işaretli değil. İnsan onayından SONRA: echo <branch-adı> > .claude/.gate4-ok"
  approved=$(head -1 "$flag" | tr -d '[:space:]')
  [ -n "$approved" ] || deny ".gate4-ok boş — onaylanan branch adını içermeli."
  printf '%s' "$cmd" | grep -qF "$approved" || deny ".gate4-ok '$approved' branch'i için; bu komut onu merge etmiyor. Yanlışsa işareti güncelle."
fi

exit 0
