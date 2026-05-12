#!/bin/bash
set -euo pipefail

if ! command -v jq &>/dev/null; then exit 0; fi
INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')

# 1. Protect the Terminal
if [[ "$TOOL_NAME" == "execute/runInTerminal" || "$TOOL_NAME" == "execute/createAndRunTask" ]]; then
  RAW_CMD=$(echo "$INPUT" | jq -r '.tool_input.command // empty')
  CMD=$(printf '%s' "$RAW_CMD" | tr '[:upper:]' '[:lower:]' | tr -s '[:space:]')
  CMD=$(printf '%s' "$CMD" | sed 's/-rf/-r -f/g; s/-fr/-f -r/g')
  if printf '%s\n' "$CMD" | grep -qE '(^|[^[:alnum:]_./-])([^[:space:]]+/)*rm([[:space:]].*-r.*-f|[[:space:]].*-f.*-r)|(^|[^[:alnum:]_./-])drop[[:space:]]+database([[:space:]]|$)|(^|[^[:alnum:]_./-])drop[[:space:]]+table([[:space:]]|$)|(^|[^[:alnum:]_./-])truncate[[:space:]]+table([[:space:]]|$)|(^|[^[:alnum:]_./-])([^[:space:]]+/)*chmod([[:space:]]+-R)?[[:space:]]+[0-7]*777([[:space:]]|$)'; then
    cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "additionalContext": "CRITICAL SECURITY WARNING: You are attempting to run a highly destructive terminal command. This is strictly forbidden without explicit user consent. Halt and ask the user."
  }
}
EOF
    exit 0
  fi
  exit 0
fi

# 2. Protect Blind Edits
case "$TOOL_NAME" in
  editFiles|replace_string_in_file|multi_replace_string_in_file) ;;
  *) exit 0 ;;
esac

FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.filePath // .tool_input.files[0] // empty')
[[ -z "$FILE_PATH" ]] && exit 0

TRANSCRIPT_PATH=$(echo "$INPUT" | jq -r '.transcript_path // empty')
[[ -z "$TRANSCRIPT_PATH" || ! -f "$TRANSCRIPT_PATH" ]] && exit 0

BASENAME="${FILE_PATH##*/}"
if grep -qF "$FILE_PATH" "$TRANSCRIPT_PATH" 2>/dev/null; then exit 0; fi

ESCAPED_BASENAME=$(printf '%s' "$BASENAME" | sed 's/[][\.^$*+?{}|()]/\\&/g')
if grep -Eq "(^|[\\/])${ESCAPED_BASENAME}([\"'[:space:]]|$)" "$TRANSCRIPT_PATH" 2>/dev/null; then exit 0; fi

cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "additionalContext": "WARNING: You are editing ${BASENAME} but there is no evidence you read it in this session. Read files before editing to avoid blind modifications."
  }
}
EOF
exit 0