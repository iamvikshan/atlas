#!/bin/bash
# UserPromptSubmit hook: Injects strict context to prevent small-model hallucination,
# enforces official subagents, detects Autopilot keywords (ULW, YOLO),
# and blocks anti-patterns (skip tests, skip review).

set -euo pipefail

# jq is required for JSON parsing -- degrade silently if missing
if ! command -v jq &>/dev/null; then
  exit 0
fi

INPUT=$(cat)

PROMPT=$(printf '%s' "$INPUT" | jq -r '.prompt // empty')
if [[ -z "$PROMPT" ]]; then
  exit 0
fi

# 1. Base Reinforcement (Always injected to ground smaller models)
# This replaces the need for the user to manually type "use tools" or "don't create agents" but use only the official subagents: sentry, metis, oracle, killua, ekko, aurora, forge, nova, prometheus.
MESSAGE=$(cat <<'EOF'
SYSTEM REINFORCEMENT: Follow your strict workflow. DO NOT hallucinate or invent custom subagents.
ONLY delegate to the official roster of subagents provided by the system. If a task requires a tool or capability you don't have, say you can't do it instead of making it up.
Actively use your available tools to research; tavily, context7 and exa mcps - do not guess, nor use your built-in search tools, but the specified ones. Do not skip steps or lie to please.
EOF
)

# 2. Check for Autopilot keywords (whole words, case-insensitive)
if printf '%s\n' "$PROMPT" | grep -iqE '(^|[^[:alnum:]_])(ULW|YOLO)([^[:alnum:]_]|$)'; then
  MESSAGE="${MESSAGE}\n\nMODE OVERRIDE: Autopilot mode detected. Proceed autonomously without user stops. Auto-commit after sentry approval. Present final summary when all work is done."
fi

# 3. Check for anti-patterns (case-insensitive)
PROMPT_LOWER=$(printf '%s' "$PROMPT" | tr '[:upper:]' '[:lower:]' | sed "s/[‘’]/'/g")
if [[ "$PROMPT_LOWER" == *"without testing"* || \
      "$PROMPT_LOWER" == *"skip tests"* || \
      "$PROMPT_LOWER" == *"skip review"* || \
      "$PROMPT_LOWER" == *"don't test"* || \
      "$PROMPT_LOWER" == *"no tests"* || \
      "$PROMPT_LOWER" == *"just do it"* ]]; then
  MESSAGE="${MESSAGE}\n\nWARNING: The user's prompt suggests skipping quality gates. All tests and reviews are MANDATORY per Core Philosophy. Proceed with full quality enforcement."
fi

# Escape the combined message for valid JSON output
MESSAGE_ESCAPED=$(printf '%b' "$MESSAGE" | jq -Rs '.')

cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "UserPromptSubmit",
    "additionalContext": ${MESSAGE_ESCAPED}
  }
}
EOF

exit 0