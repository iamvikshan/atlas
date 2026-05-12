#!/bin/bash
set -euo pipefail

HOOK="${1:-}"
if [[ ! "$HOOK" =~ ^[a-zA-Z0-9_-]+$ ]]; then
  echo "atlas: invalid hook name '$HOOK'" >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_PATH="${SCRIPT_DIR}/${HOOK}.sh"

if [[ ! -f "$SCRIPT_PATH" ]]; then
  echo "atlas: $HOOK hook not found" >&2
  exit 1
fi

# Use exec to replace the process, perfectly preserving stdin/stdout
shift
exec bash "$SCRIPT_PATH" "$@"