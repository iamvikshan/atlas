#!/bin/bash
set -euo pipefail

if ! command -v jq &>/dev/null; then exit 0; fi
INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')

# 1. Protect the Terminal
if [[ "$TOOL_NAME" == "run_command" ]]; then
  RAW_CMD=$(echo "$INPUT" | jq -r '.tool_input.CommandLine // empty')
  CMD=$(printf '%s' "$RAW_CMD" | tr '[:upper:]' '[:lower:]' | tr -s '[:space:]')
  # Normalize common long options to their short equivalents so greedy patterns
  # like "rm --recursive --force" are detected by the short-flag grep.
  CMD=$(printf '%s' "$CMD" | sed 's/--recursive/ -r /g; s/--recurse/ -r /g; s/--force/ -f /g; s/-rf/-r -f/g; s/-fr/-f -r/g')
  if printf '%s\n' "$CMD" | grep -qE '(^|[^[:alnum:]_./-])([^[:space:]]+/)*rm([[:space:]].*-r.*-f|[[:space:]].*-f.*-r)|(^|[^[:alnum:]_./-])drop[[:space:]]+database([[:space:]]|$)|(^|[^[:alnum:]_./-])drop[[:space:]]+table([[:space:]]|$)|(^|[^[:alnum:]_./-])truncate[[:space:]]+table([[:space:]]|$)|(^|[^[:alnum:]_./-])([^[:space:]]+/)*chmod([[:space:]]+-R)?[[:space:]]+[0-7]*777([[:space:]]|$)'; then
    cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "CRITICAL SECURITY WARNING: You are attempting to run a highly destructive terminal command. This is strictly forbidden without explicit user consent. Halt and ask the user."
  }
}
EOF
    exit 0
  fi
  exit 0
fi

# 2. Protect Blind Edits
case "$TOOL_NAME" in
  write_to_file|replace_file_content|multi_replace_file_content) ;;
  *) exit 0 ;;
esac

# Collect all candidate file paths from possible input locations so multi-file
# operations are validated (handles .files array plus TargetFile/filePath).
FILE_PATHS_JSON=$(echo "$INPUT" | jq -c '[ .tool_input.files[]? , .tool_input.TargetFile? , .tool_input.filePath? ] | map(select(. != null and . != "")) | unique' )
if [ "$(printf '%s' "$FILE_PATHS_JSON" | jq 'length')" -eq 0 ]; then
  exit 0
fi

TRANSCRIPT_PATH=$(echo "$INPUT" | jq -r '.transcript_path // empty')
[[ -z "$TRANSCRIPT_PATH" || ! -f "$TRANSCRIPT_PATH" ]] && exit 0

# Iterate each candidate and ensure the session transcript contains either the
# full path or the basename; if any file lacks evidence, deny the blind edit.
while IFS= read -r FILE_PATH; do
  BASENAME="${FILE_PATH##*/}"
  if grep -qF "$FILE_PATH" "$TRANSCRIPT_PATH" 2>/dev/null; then
    continue
  fi

  ESCAPED_BASENAME=$(printf '%s' "$BASENAME" | sed 's/[][.\\^$*+?{}|()]/\\\\&/g')
  if grep -Eq "(^|[\\/])${ESCAPED_BASENAME}([\"'[:space:]]|$)" "$TRANSCRIPT_PATH" 2>/dev/null; then
    continue
  fi

  cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "WARNING: You are editing ${BASENAME} but there is no evidence you read it in this session. Read files before editing to avoid blind modifications."
  }
}
EOF
  exit 0
done < <(printf '%s' "$FILE_PATHS_JSON" | jq -r '.[]')

exit 0
