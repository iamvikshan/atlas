#!/bin/bash
set -euo pipefail

if ! command -v jq &>/dev/null; then exit 0; fi
INPUT=$(cat)
CWD=$(echo "$INPUT" | jq -r '.cwd // empty')
[[ -z "$CWD" ]] && exit 0

CONTEXT_PARTS=()

# -- 1. THE MANIFEST CHECK (CRITICAL) --
if [[ ! -f "${CWD}/.atlas/manifest.json" ]]; then
  CONTEXT_PARTS+=("SYSTEM DIRECTIVE: Workspace uninitialized. .atlas/manifest.json is MISSING. You MUST delegate to killua and oracle to scan the repo and generate this manifest BEFORE proceeding with the user's request.")
fi

# -- 2. Repo memories --
MEMORIES_DIR="${CWD}/memories/repo"
if [[ -d "$MEMORIES_DIR" ]]; then
  MEMORY_SUMMARY=""
  for f in "$MEMORIES_DIR"/*.json; do
    [[ -f "$f" ]] || continue
    SUBJECT=$(jq -r '.subject // empty' "$f" 2>/dev/null)
    FACT=$(jq -r '.fact // empty' "$f" 2>/dev/null)
    [[ -n "$SUBJECT" && -n "$FACT" ]] && MEMORY_SUMMARY="${MEMORY_SUMMARY}- ${SUBJECT}: ${FACT}\n"
  done
  MEMORY_SUMMARY=${MEMORY_SUMMARY%\\n}
  [[ -n "$MEMORY_SUMMARY" ]] && CONTEXT_PARTS+=("Project conventions:\n${MEMORY_SUMMARY}")
fi

# -- Compile and emit --
[[ ${#CONTEXT_PARTS[@]} -eq 0 ]] && exit 0
COMPILED=$(printf "%s\n" "${CONTEXT_PARTS[@]}")
COMPILED_ESCAPED=$(printf '%b' "$COMPILED" | jq -Rs '.')

cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": ${COMPILED_ESCAPED}
  }
}
EOF
exit 0