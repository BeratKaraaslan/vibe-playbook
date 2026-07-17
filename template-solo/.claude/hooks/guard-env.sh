#!/usr/bin/env bash
# PreToolUse hook: blocks the COMMON ACCIDENTAL paths to secret files (.env*) — CLAUDE.md rule 3,
# "hook > instruction". Covers: direct tool paths (Read/Edit/Write/Grep), plain Bash subcommands
# (cat/cp/source/redirects), glob forms (.env*, .env.local.backup), case variants (.ENV — macOS FS
# is case-insensitive), direct symlinks on tool paths, and Grep globs.
# ONLY .env.example / .env.sample / .env.template are fully allowed.
# This is an ACCIDENT GUARD, not a security boundary: a script or subprocess that opens the file
# itself (python/node/helper .sh, hardlinks, variable-built paths) is beyond string matching —
# for OS-level guarantees use Claude Code sandboxing + keep secrets outside the working tree.
# Fail-closed: if python3 is missing, every guarded call is blocked (python3 is a stated requirement).
# On a block the model must STOP and ask the user — never retry via another path.
# NOTE: the python block sits inside bash single quotes — NEVER use ' inside the python code (use \x27).
set -u
input=$(cat 2>/dev/null || true)
if ! command -v python3 >/dev/null 2>&1; then
  printf 'BLOCKED (guard-env): python3 is required by the hooks and was not found — install python3 (or knowingly remove the hooks).\n' >&2
  exit 2
fi

printf '%s' "$input" | python3 -c '
import json, os, re, sys

I = re.IGNORECASE

def allowed_example(t):
    return re.search(r"\.env\.(example|sample|template)$", t, I)

def is_secret_path(p):
    # exact path: .env with ANY number of suffix segments (.env.local.backup), except allowed forms
    return (re.search(r"(^|/)\.env(\.[\w\-]+)*$", p, I)
            and not allowed_example(p))

def is_secret_token(t):
    # command token: may carry glob chars that expand to real env files (.env*, .env.*, .env?)
    if allowed_example(t):
        return False
    if re.search(r"(^|/)\.env(\.[\w\-]+)*$", t, I):
        return True
    if re.search(r"(^|/)\.env[\w.\-]*[*?]", t, I):
        return True
    return False

data = sys.stdin.read()
if not data.strip():
    sys.exit(0)
try:
    d = json.loads(data)
    if not isinstance(d, dict):
        raise ValueError
except Exception:
    sys.stderr.write("BLOCKED (guard-env): malformed hook input — if you upgraded Claude Code, update or remove the hooks.")
    sys.exit(2)

ti = d.get("tool_input", {})
if not isinstance(ti, dict):
    sys.stderr.write("BLOCKED (guard-env): malformed hook input (tool_input) — update or remove the hooks.")
    sys.exit(2)
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

# Grep glob: block if ANY env-ish token in the glob is a real env form
# (an allowed .env.example elsewhere in the same glob must NOT launder the rest)
g = ti.get("glob")
if isinstance(g, str):
    # (?![A-Za-z0-9]) keeps ".environment.ts" out: after ".env" only a dot/glob/end counts
    toks = re.findall(r"\.env(?![A-Za-z0-9])[\w.\-]*", g, I)
    if any(not allowed_example(t) for t in toks):
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
        "The .env file is OFF-LIMITS (direct read, subcommand, copy, glob, script); "
        "only .env.example is accessible. STOP NOW: report this to the user and WAIT for their "
        "approval — do NOT retry via another path. Env values are provided by the human "
        "(NEEDS-FROM-USER.md)." % ", ".join(sorted(set(bad))))
    sys.exit(2)
sys.exit(0)
'
exit $?
