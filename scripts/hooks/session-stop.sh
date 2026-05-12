#!/bin/bash
# Stop hook: Checks for uncommitted changes and temp artifacts before
# session ends. Warns via additionalContext but never blocks.

set -euo pipefail

if ! command -v jq &>/dev/null; then exit 0; fi
INPUT=$(cat)

# Safety: prevent infinite loops
STOP_HOOK_ACTIVE=$(echo "$INPUT" | jq -r '.stop_hook_active // "false"')
[[ "$STOP_HOOK_ACTIVE" == "true" ]] && exit 0

CWD=$(echo "$INPUT" | jq -r '.cwd // empty')
[[ -z "$CWD" ]] && exit 0

WARNINGS=()

# 1. Check for uncommitted changes
if command -v git &>/dev/null && [[ -d "${CWD}/.git" ]]; then
  DIRTY=$(git -C "$CWD" status --porcelain 2>/dev/null || true)
  if [[ -n "$DIRTY" ]]; then
    CHANGE_COUNT=$(echo "$DIRTY" | wc -l | tr -d ' ')
    WARNINGS+=("Uncommitted changes detected (${CHANGE_COUNT} files). Consider committing or stashing.")
  fi
fi

# 2. Check for temp/debug artifacts (Now explicitly hunting Atlas scratchpads)
TEMP_FILES=""
if [[ -d "$CWD" ]]; then
  TEMP_FILES=$(find "$CWD" -maxdepth 4 \( -name '*.tmp' -o -name '*.bak' -o -name 'debug-*' -o -name 'scratch-*' \) -not -path '*/node_modules/*' -not -path '*/.git/*' 2>/dev/null || true)
fi

if [[ -n "$TEMP_FILES" ]]; then
  TEMP_COUNT=$(printf '%s\n' "$TEMP_FILES" | sed '/^$/d' | wc -l | tr -d ' ')
  WARNINGS+=("Found ${TEMP_COUNT} temp/debug artifact(s) in workspace. Clean up orphaned scratchpads: *.tmp, *.bak, debug-*, scratch-*")
fi

[[ ${#WARNINGS[@]} -eq 0 ]] && exit 0

COMPILED=$(printf -- "- %s\n" "${WARNINGS[@]}")
COMPILED_ESCAPED=$(printf '%b' "$COMPILED" | jq -Rs '.')

cat <<EOF
{
  "systemMessage": ${COMPILED_ESCAPED}
}
EOF
exit 0