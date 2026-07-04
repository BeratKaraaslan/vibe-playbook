#!/usr/bin/env bash
# PreToolUse hook: secret dosyalarına (.env*) erişimi fiziksel engeller (CLAUDE.md kural 3, "hook > talimat").
# .env.example / .env.sample / .env.template serbesttir.
# Emniyet ağıdır, hermetik değildir — settings.json deny listesi + model talimatı ek katmanlardır.
# Not: python bloğu bash single-quote içinde — python kodunda ' KULLANMA (regex'lerde \x27).
set -u
input=$(cat 2>/dev/null || true)
command -v python3 >/dev/null 2>&1 || exit 0

printf '%s' "$input" | python3 -c '
import json, re, sys

def is_secret(p):
    return (re.search(r"(^|/)\.env(\.[\w\-]+)?$", p)
            and not re.search(r"\.env\.(example|sample|template)$", p))

try:
    d = json.load(sys.stdin)
except Exception:
    sys.exit(0)

ti = d.get("tool_input", {}) or {}
bad = []

for key in ("file_path", "path", "notebook_path"):
    v = ti.get(key)
    if isinstance(v, str) and is_secret(v):
        bad.append(v)

cmd = ti.get("command")
if isinstance(cmd, str):
    # yalniz path-gorunumlu .env tokenlari (process.env gibi kod referanslarini YAKALAMAZ)
    for m in re.finditer(r"(?:^|[\s\"\x27=(<])((?:[\w.\-/]*/)?\.env(?:\.[\w\-]+)?)(?=$|[\s\"\x27\);|&<>])", cmd):
        if is_secret(m.group(1)):
            bad.append(m.group(1))

if bad:
    sys.stderr.write(
        "ENGELLENDI (guard-env): secret dosyasi erisimi: %s. "
        ".env okunmaz/yazilmaz/yazdirilmaz; deger gerekiyorsa NEEDS-FROM-USER.md + DUR."
        % ", ".join(sorted(set(bad))))
    sys.exit(2)
sys.exit(0)
'
exit $?
