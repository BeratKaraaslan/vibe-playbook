#!/usr/bin/env bash
# PreCompact hook (OPSİYONEL — kurulum: STARTGUIDE §2; varsayılan settings.json'da KAYITLI DEĞİL).
# Compaction'ı durduramaz/dayatmaz; yapabildiği: zemin fotoğrafını diske sabitlemek + insana haber vermek.
# Böylece compaction sonrası "durum neydi?" sorusunun cevabı context özetine değil diske dayanır.
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
  echo "## $(date '+%Y-%m-%d %H:%M') — compaction (tetik: $trigger)"
  echo '```'
  echo "branch: $(git branch --show-current 2>/dev/null || echo '?')"
  git status --short 2>/dev/null | head -30
  git log --oneline -5 2>/dev/null
  echo '```'
  echo
} >> "$snap" 2>/dev/null

echo "PreCompact: zemin fotoğrafı $snap dosyasına eklendi. progress.md güncel mi kontrol edin; devir bir seçenek." >&2
exit 0
