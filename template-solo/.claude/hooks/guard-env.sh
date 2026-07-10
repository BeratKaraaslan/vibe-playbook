#!/usr/bin/env bash
# PreToolUse hook: physically blocks ANY access to secret files (.env*) — CLAUDE.md rule 3, "hook > instruction".
# Covers: direct tool paths (Read/Edit/Write/Grep), Bash subcommands (cat/cp/source/redirects/scripts),
# glob forms (.env*, .env.?) and case variants (.ENV — macOS FS is case-insensitive).
# ONLY .env.example / .env.sample / .env.template are fully allowed.
# On a block the model must STOP and ask the user — never retry via another path.
# This is a safety net against accidents/drift, not hermetic against a malicious agent —
# the settings.json deny list + CLAUDE.md rule 3 are the other layers.
# NOTE: the python block sits inside bash single quotes — NEVER use ' inside the python code (use \x27).
set -u
input=$(cat 2>/dev/null || true)
command -v python3 >/dev/null 2>&1 || exit 0

printf '%s' "$input" | python3 -c '
import json, os, re, sys

I = re.IGNORECASE

def allowed_example(t):
    return re.search(r"\.env\.(example|sample|template)$", t, I)

def is_secret_path(p):
    # exact path: .env or .env.<suffix>, except the allowed example forms
    return (re.search(r"(^|/)\.env(\.[\w\-]+)?$", p, I)
            and not allowed_example(p))

def is_secret_token(t):
    # command token: may carry glob chars that expand to real env files (.env*, .env.*, .env?)
    if allowed_example(t):
        return False
    if re.search(r"(^|/)\.env(\.[\w\-]+)?$", t, I):
        return True
    if re.search(r"(^|/)\.env[\w.\-]*[*?]", t, I):
        return True
    return False

try:
    d = json.load(sys.stdin)
except Exception:
    sys.exit(0)

ti = d.get("tool_input", {}) or {}
bad = []

for key in ("file_path", "path", "notebook_path"):
    v = ti.get(key)
    if isinstance(v, str):
        if is_secret_path(v):
            bad.append(v)
        else:
            # symlink defense: a differently-named link pointing at a secret file
            rp = os.path.realpath(v)
            if rp != os.path.abspath(v) and is_secret_path(rp):
                bad.append(v + " -> " + rp)

# Grep tool glob key: "*.env" style patterns can select real env files
g = ti.get("glob")
if isinstance(g, str) and re.search(r"\.env(?![a-z])", g, I) and not re.search(r"\.env\.(example|sample|template)", g, I):
    bad.append(g)

cmd = ti.get("command")
if isinstance(cmd, str):
    # path-shaped .env tokens incl. trailing globs; prefix covers quotes/redirects/separators.
    # does NOT catch code refs like process.env (letter before the dot fails the prefix class).
    for m in re.finditer(r"(?:^|[\s\"\x27=(<>;|&:])((?:[\w.\-/]*/)?\.env[\w.\-]*[*?]*)", cmd, I):
        if is_secret_token(m.group(1)):
            bad.append(m.group(1))

if bad:
    sys.stderr.write(
        "BLOCKED (guard-env): secret file access: %s. "
        "The .env file is OFF-LIMITS in every form (direct read, subcommand, copy, glob, script); "
        "only .env.example is accessible. STOP NOW: report this to the user and WAIT for their "
        "approval — do NOT retry via another path. Env values are provided by the human "
        "(NEEDS-FROM-USER.md)." % ", ".join(sorted(set(bad))))
    sys.exit(2)
sys.exit(0)
'
exit $?
