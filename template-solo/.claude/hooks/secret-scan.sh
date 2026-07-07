#!/usr/bin/env bash
# UserPromptSubmit hook: if the user message contains a secret-looking value, reminds the model
# of the leak protocol (CLAUDE.md rule 3) at exactly that moment. DOES NOT BLOCK — the action is the model's.
# (False-positive cost ~zero: only one reminder line is added.)
# NOTE: the python block sits inside bash single quotes — NEVER use ' inside the python code.
set -u
input=$(cat 2>/dev/null || true)
command -v python3 >/dev/null 2>&1 || exit 0

printf '%s' "$input" | python3 -c '
import json, re, sys

try:
    d = json.load(sys.stdin)
except Exception:
    sys.exit(0)

p = d.get("prompt", "") or ""
pats = [
    r"(?:postgres(?:ql)?|mysql|mongodb(?:\+srv)?|redis|amqp|mssql)://[^\s/@]+:[^\s@]+@",  # conn-string with userinfo
    r"\bsk-[A-Za-z0-9_-]{16,}",
    r"\bAKIA[0-9A-Z]{16}\b",
    r"\bghp_[A-Za-z0-9]{30,}",
    r"\bgithub_pat_[A-Za-z0-9_]{20,}",
    r"-----BEGIN [A-Z ]*PRIVATE KEY-----",
    r"\beyJ[A-Za-z0-9_-]{20,}\.[A-Za-z0-9_-]{10,}",  # JWT
    r"(?i)\b(api[_-]?key|secret|token|password|passwd)\b\s*[=:]\s*\S{8,}",
]
if any(re.search(x, p) for x in pats):
    print("WARNING (secret-scan): the user message may contain a secret-looking value. "
          "Apply the LEAK PROTOCOL (CLAUDE.md rule 3): NEVER repeat the value; never write it to any "
          "file/doc/command; if it landed anywhere, DELETE it immediately; notify the user and RECOMMEND "
          "ROTATION (chat history cannot be truly deleted — rotation is the only permanent fix); "
          "the right place is .env/panel, and the human places the value.")
sys.exit(0)
'
exit 0
