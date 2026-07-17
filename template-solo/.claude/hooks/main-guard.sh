#!/usr/bin/env bash
# PreToolUse(Bash) hook: guards the invariant "nothing enters a protected branch without GATE 4"
# (CLAUDE.md rule 1) against the AGENT's accidental/drifting paths.
# This is an ACCIDENT GUARD, not a security boundary: novel command shapes, wrapper scripts, or
# PR-side merges bypass it — pair with GitHub/GitLab branch protection for hard guarantees
# (a merge done on GitHub never touches this hook).
#  - blocks CODE commits on protected branches; docs-only commits allowed (*.md, docs/,
#    module-specs/, memory-seed/, .gitignore, .env.example, LICENSE). NOTE: .claude/ is
#    CONTROL-PLANE, not docs — hook/settings/command changes need a branch + GATE 4.
#  - blocks COMPOUND commands containing a commit (e.g. `… && git commit`) on protected branches:
#    the guard cannot see files created later in the same call (TOCTOU) — commit standalone.
#  - counts UNTRACKED files as code changes.
#  - blocks `git cherry-pick` outright; `git merge` needs .claude/.gate4-ok with the EXACT branch
#    as the actual merge OPERAND (a name smuggled into -m/--strategy-option no longer satisfies it).
#  - honors `git -C <path>` (checks the TARGET repo) and path/flag forms (`/usr/bin/git`, `git -c k=v`).
# Command parsing is done ONCE in python (shlex) — proper quote/operator handling, not layered regex.
# Fail-closed: python3 missing OR malformed hook input → block. Protected: VIBE_PROTECTED_BRANCHES.
# NOTE: the python block sits inside bash single quotes — NEVER use ' inside the python code (use \x27).
set -u
input=$(cat 2>/dev/null || true)
if ! command -v python3 >/dev/null 2>&1; then
  printf 'BLOCKED (main-guard): python3 is required by the hooks and was not found — install python3 (or knowingly remove the hooks).\n' >&2
  exit 2
fi

PROTECTED_BRANCHES="${VIBE_PROTECTED_BRANCHES:-main master}"

# One python pass: emits 7 lines — STATUS, GITC, COMMIT, COMPOUND, CHERRY, MERGE, OPERAND.
# STATUS: empty|malformed|nogit|parsefail|ok. Only "ok" carries the remaining fields.
parsed=$(printf '%s' "$input" | python3 -c '
import json, os, re, shlex, sys

data = sys.stdin.read()
if not data.strip():
    print("empty"); sys.exit(0)
try:
    d = json.loads(data)
    if not isinstance(d, dict): raise ValueError
    ti = d.get("tool_input", {})
    if not isinstance(ti, dict): raise ValueError
    cmd = ti.get("command", "")
    if not isinstance(cmd, str): raise ValueError
except Exception:
    print("malformed"); sys.exit(0)

if "git" not in cmd:
    print("nogit"); sys.exit(0)

try:
    lex = shlex.shlex(cmd, posix=True, punctuation_chars=True)
    lex.whitespace_split = True
    tokens = list(lex)
except Exception:
    print("parsefail"); sys.exit(0)

COMPOUND_OPS = {";", "&&", "||", "|"}
GLOBAL_VALUE_OPTS = {"-C", "-c", "--git-dir", "--work-tree", "--namespace", "--super-prefix", "--exec-path"}
MERGE_VALUE_OPTS = {"-m", "--message", "-F", "--file", "-s", "--strategy", "-X", "--strategy-option", "--into-name"}
ENV_ASSIGN = re.compile(r"^[A-Za-z_][A-Za-z0-9_]*=")

def is_op(t):
    return len(t) > 0 and all(ch in ";&|()<>" for ch in t)

segments = [[]]
has_compound = False
for t in tokens:
    if is_op(t):
        if t in COMPOUND_OPS:
            has_compound = True
        segments.append([])
    else:
        segments[-1].append(t)

def parse_git(seg):
    i = 0
    while i < len(seg) and (seg[i] in ("command", "exec", "builtin", "time", "nice", "sudo") or ENV_ASSIGN.match(seg[i])):
        i += 1
    if i >= len(seg) or os.path.basename(seg[i]) != "git":
        return (False, None, None, None)
    i += 1
    gitc = None
    while i < len(seg):
        t = seg[i]
        if t == "-C" and i + 1 < len(seg):
            gitc = seg[i + 1]; i += 2; continue
        if t in GLOBAL_VALUE_OPTS and i + 1 < len(seg):
            i += 2; continue
        if t.startswith("-"):
            i += 1; continue
        break
    if i >= len(seg):
        return (True, None, gitc, None)
    sub = seg[i]; i += 1
    operand = None
    if sub == "merge":
        while i < len(seg):
            t = seg[i]
            if t in MERGE_VALUE_OPTS and i + 1 < len(seg):
                i += 2; continue
            if t.startswith("-"):
                i += 1; continue
            operand = t; break
    return (True, sub, gitc, operand)

commit = cherry = merge = 0
operand = ""
gitc = ""
for seg in segments:
    isg, sub, gc, op = parse_git(seg)
    if not isg:
        continue
    if gc and not gitc:
        gitc = gc
    if sub == "commit":
        commit = 1
    elif sub == "cherry-pick":
        cherry = 1
    elif sub == "merge":
        merge = 1
        if op is not None:
            operand = op

if not (commit or cherry or merge):
    print("nogit"); sys.exit(0)

print("ok")
print(gitc)
print(commit)
print(1 if (has_compound and commit) else 0)
print(cherry)
print(merge)
print(operand)
' 2>/dev/null) || exit 0

{ IFS= read -r STATUS
  IFS= read -r GITC
  IFS= read -r COMMIT
  IFS= read -r COMPOUND
  IFS= read -r CHERRY
  IFS= read -r MERGE
  IFS= read -r OPERAND
} <<EOF
$parsed
EOF

deny() { printf 'BLOCKED (main-guard): %s\n' "$1" >&2; exit 2; }

case "${STATUS:-}" in
  empty|nogit|"") exit 0 ;;
  malformed) deny "malformed hook input — if you upgraded Claude Code, update or remove the hooks." ;;
  parsefail)
    br=$(git symbolic-ref --quiet --short HEAD 2>/dev/null || true)
    case " $PROTECTED_BRANCHES " in
      *" $br "*) deny "could not parse this command safely on $br — run it as a simpler standalone command." ;;
    esac
    exit 0 ;;
  ok) : ;;
  *) exit 0 ;;
esac

# honor `git -C <path>`: run every check against the TARGET repo, not the hook's cwd
if [ -n "$GITC" ]; then
  git() { command git -C "$GITC" "$@"; }
fi

branch=$(git symbolic-ref --quiet --short HEAD 2>/dev/null || true)
[ -n "$branch" ] || exit 0
case " $PROTECTED_BRANCHES " in
  *" $branch "*) : ;;
  *) exit 0 ;;
esac

# --- commit protection (docs-only on protected branches) ---
if [ "$COMMIT" = "1" ]; then
  # TOCTOU guard: files created earlier in the SAME call are invisible to the checks below
  if [ "$COMPOUND" = "1" ]; then
    deny "compound command containing a commit on $branch — run the commit as a STANDALONE command so the guard can see the real tree state"
  fi
  docs_re='(^|/)(docs|module-specs|memory-seed)(/|$)|\.md$|^\.gitignore$|^\.env\.example$|^LICENSE'
  offenders=$({ git diff --cached --name-only; git diff --name-only; git ls-files --others --exclude-standard; } 2>/dev/null | sort -u | grep -vE "$docs_re" || true)
  if [ -n "$offenders" ]; then
    short=$(printf '%s\n' "$offenders" | head -5 | tr '\n' ' ')
    deny "no CODE commits on $branch — open a part branch (git switch -c wip/P-N). Non-docs files (staged, modified or untracked all count): $short"
  fi
fi

# --- cherry-pick protection (lands code without the merge ritual) ---
if [ "$CHERRY" = "1" ]; then
  deny "cherry-pick onto $branch bypasses GATE 4 — use the merge ritual (.claude/.gate4-ok) instead."
fi

# --- merge protection (GATE 4 marker required, EXACT branch as the merge OPERAND) ---
if [ "$MERGE" = "1" ]; then
  flag=".claude/.gate4-ok"
  [ -f "$flag" ] || deny "GATE 4 approval is not marked. AFTER human approval run: echo <branch-name> > .claude/.gate4-ok"
  approved=$(head -1 "$flag" | tr -d '[:space:]')
  [ -n "$approved" ] || deny ".gate4-ok is empty — it must contain the approved branch name."
  if [ "$OPERAND" != "$approved" ]; then
    deny ".gate4-ok is for branch '$approved'; this command does not merge exactly that branch (operand: '${OPERAND:-none}'). Update the marker if it is wrong."
  fi
fi

exit 0
