#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORK_DIR="$(mktemp -d)"
CANONICAL_FILE="${WORK_DIR}/canonical-commands.txt"
failures=0

cleanup() {
  rm -rf "${WORK_DIR}"
}
trap cleanup EXIT

report_pass() {
  local name="$1"
  echo "[PASS] ${name}"
}

report_fail() {
  local name="$1"
  shift
  echo "[FAIL] ${name}"
  for detail in "$@"; do
    echo "       - ${detail}"
  done
  failures=$((failures + 1))
}

extract_frontmatter_name() {
  local file="$1"
  grep -E '^name:[[:space:]]*' "${file}" | head -n 1 | sed -E "s/^name:[[:space:]]*['\"]?([^'\"[:space:]]+)['\"]?.*$/\1/"
}

collect_canonical_commands() {
  (
    cd "${ROOT_DIR}"
    find skills -mindepth 2 -maxdepth 2 -type f -path 'skills/design-*/SKILL.md' -print
    if [[ -f "skills/frontend-design/SKILL.md" ]]; then
      echo "skills/frontend-design/SKILL.md"
    fi
  ) | LC_ALL=C sort | while IFS= read -r rel; do
    name="$(extract_frontmatter_name "${ROOT_DIR}/${rel}")"
    if [[ -n "${name}" ]]; then
      printf '/%s\n' "${name}"
    fi
  done | LC_ALL=C sort -u
}

collect_design_commands_from_file() {
  local file="$1"
  grep -oE '/(design-[a-z-]+|frontend-design)' "${file}" | LC_ALL=C sort -u || true
}

as_inline_list() {
  local file="$1"
  tr '\n' ' ' < "${file}" | sed -E 's/[[:space:]]+/ /g; s/[[:space:]]$//'
}

check_file_matches_canonical_set() {
  local rel="$1"
  local actual_file="${WORK_DIR}/actual-$(echo "${rel}" | tr '/.' '__').txt"

  collect_design_commands_from_file "${ROOT_DIR}/${rel}" > "${actual_file}"

  local missing_file="${WORK_DIR}/missing-$(echo "${rel}" | tr '/.' '__').txt"
  local extra_file="${WORK_DIR}/extra-$(echo "${rel}" | tr '/.' '__').txt"

  comm -23 "${CANONICAL_FILE}" "${actual_file}" > "${missing_file}" || true
  comm -13 "${CANONICAL_FILE}" "${actual_file}" > "${extra_file}" || true

  if [[ -s "${missing_file}" || -s "${extra_file}" ]]; then
    local detail="${rel}"
    if [[ -s "${missing_file}" ]]; then
      detail+=" missing: $(as_inline_list "${missing_file}")"
    fi
    if [[ -s "${extra_file}" ]]; then
      detail+=" extra: $(as_inline_list "${extra_file}")"
    fi
    echo "${detail}"
    return 1
  fi

  return 0
}

check_docs_match_canonical_set() {
  local assertion="command-sync-docs-match-canonical-set"
  local problems=()
  local files=(
    "README.md"
    "docs/ARCHITECTURE.md"
  )

  for rel in "${files[@]}"; do
    if ! detail="$(check_file_matches_canonical_set "${rel}")"; then
      problems+=("${detail}")
    fi
  done

  if [[ ${#problems[@]} -eq 0 ]]; then
    report_pass "${assertion}"
  else
    report_fail "${assertion}" "${problems[@]}"
  fi
}

check_agent_reference_sentence() {
  local assertion="command-sync-agent-reference-sentence"
  local fragment="Recognized design skills are any slash command matching"
  local problems=()
  local files=(
    "agents/aurora.agent.md"
    "agents/sentry.agent.md"
  )

  for rel in "${files[@]}"; do
    if ! grep -qF "${fragment}" "${ROOT_DIR}/${rel}"; then
      problems+=("${rel} missing reference sentence fragment: ${fragment}")
    fi
  done

  if [[ ${#problems[@]} -eq 0 ]]; then
    report_pass "${assertion}"
  else
    report_fail "${assertion}" "${problems[@]}"
  fi
}

check_design_critique_list_matches_canonical_set() {
  local assertion="command-sync-design-critique-list-matches-canonical-set"
  local rel="skills/design-critique/SKILL.md"

  if detail="$(check_file_matches_canonical_set "${rel}")"; then
    report_pass "${assertion}"
  else
    report_fail "${assertion}" "${detail}"
  fi
}

check_design_help_map_matches_canonical_set() {
  local assertion="command-sync-design-help-map-matches-canonical-set"
  local rel="skills/design-help/SKILL.md"

  if detail="$(check_file_matches_canonical_set "${rel}")"; then
    report_pass "${assertion}"
  else
    report_fail "${assertion}" "${detail}"
  fi
}

check_no_nonexistent_command_references() {
  local assertion="command-sync-no-nonexistent-command-references"
  local files=(
    "README.md"
    "docs/ARCHITECTURE.md"
    "skills/design-critique/SKILL.md"
    "skills/design-help/SKILL.md"
  )

  local problems=()
  local rel
  for rel in "${files[@]}"; do
    local actual_file="${WORK_DIR}/scan-$(echo "${rel}" | tr '/.' '__').txt"
    local extra_file="${WORK_DIR}/scan-extra-$(echo "${rel}" | tr '/.' '__').txt"

    collect_design_commands_from_file "${ROOT_DIR}/${rel}" > "${actual_file}"
    comm -13 "${CANONICAL_FILE}" "${actual_file}" > "${extra_file}" || true

    if [[ -s "${extra_file}" ]]; then
      problems+=("${rel} references non-canonical commands: $(as_inline_list "${extra_file}")")
    fi
  done

  if [[ ${#problems[@]} -eq 0 ]]; then
    report_pass "${assertion}"
  else
    report_fail "${assertion}" "${problems[@]}"
  fi
}

collect_canonical_commands > "${CANONICAL_FILE}"

if [[ ! -s "${CANONICAL_FILE}" ]]; then
  report_fail "command-sync-canonical-command-set-is-non-empty" "No canonical commands discovered from skills frontmatter"
else
  report_pass "command-sync-canonical-command-set-is-non-empty"
fi

check_docs_match_canonical_set
check_agent_reference_sentence
check_design_critique_list_matches_canonical_set
check_design_help_map_matches_canonical_set
check_no_nonexistent_command_references

if [[ ${failures} -ne 0 ]]; then
  echo ""
  echo "check-design-command-sync: FAILED (${failures} assertion(s) failed)"
  exit 1
fi

echo ""
echo "check-design-command-sync: PASSED"
