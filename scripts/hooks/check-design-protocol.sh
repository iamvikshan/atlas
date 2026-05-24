#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

EXPECTED_DESIGN_SKILL_COUNT=18

DESIGN_SKILLS=()
while IFS= read -r rel; do
  DESIGN_SKILLS+=("${rel}")
done < <(
  cd "${ROOT_DIR}"
  find skills -mindepth 2 -maxdepth 2 -type f -path 'skills/design-*/SKILL.md' -print | LC_ALL=C sort
)

NEW_DESIGN_SKILLS=(
  "skills/design-arrange/SKILL.md"
  "skills/design-overdrive/SKILL.md"
  "skills/design-typeset/SKILL.md"
)

failures=0

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

check_design_skill_cardinality() {
  local assertion="protocol-design-skill-cardinality-is-${EXPECTED_DESIGN_SKILL_COUNT}"
  local actual="${#DESIGN_SKILLS[@]}"

  if [[ "${actual}" -eq "${EXPECTED_DESIGN_SKILL_COUNT}" ]]; then
    report_pass "${assertion}"
  else
    report_fail "${assertion}" "Expected ${EXPECTED_DESIGN_SKILL_COUNT} design skill files but found ${actual}" "Discovered files: ${DESIGN_SKILLS[*]}"
  fi
}

check_mandatory_preparation() {
  local assertion="protocol-all-${#DESIGN_SKILLS[@]}-design-skills-have-mandatory-preparation"
  local missing=()

  for rel in "${DESIGN_SKILLS[@]}"; do
    if ! grep -q '^## MANDATORY PREPARATION$' "${ROOT_DIR}/${rel}"; then
      missing+=("${rel}")
    fi
  done

  if [[ ${#missing[@]} -eq 0 ]]; then
    report_pass "${assertion}"
  else
    report_fail "${assertion}" "Missing section in: ${missing[*]}"
  fi
}

check_frontend_context_protocol_references() {
  local assertion="protocol-all-${#DESIGN_SKILLS[@]}-reference-frontend-context-protocol"
  local missing=()

  for rel in "${DESIGN_SKILLS[@]}"; do
    local file="${ROOT_DIR}/${rel}"
    if ! grep -q '/frontend-design' "${file}" || ! grep -q 'Context Gathering Protocol' "${file}"; then
      missing+=("${rel}")
    fi
  done

  if [[ ${#missing[@]} -eq 0 ]]; then
    report_pass "${assertion}"
  else
    report_fail "${assertion}" "Missing protocol references in: ${missing[*]}"
  fi
}

check_new_skills_frontmatter_name_matches_folder() {
  local assertion="new-skills-frontmatter-name-matches-folder"
  local missing=()

  for rel in "${NEW_DESIGN_SKILLS[@]}"; do
    local file="${ROOT_DIR}/${rel}"
    local expected
    expected="$(basename "$(dirname "${rel}")")"

    local actual
    actual="$(grep -E '^name:[[:space:]]*' "${file}" | head -n 1 | sed -E 's/^name:[[:space:]]*"?([^" ]+)"?.*$/\1/')"

    if [[ -z "${actual}" || "${actual}" != "${expected}" ]]; then
      missing+=("${rel}")
    fi
  done

  if [[ ${#missing[@]} -eq 0 ]]; then
    report_pass "${assertion}"
  else
    report_fail "${assertion}" "Frontmatter name mismatch in: ${missing[*]}"
  fi
}

check_new_skills_provenance_and_notice_present() {
  local assertion="new-skills-provenance-and-notice-present"
  local missing=()

  for rel in "${NEW_DESIGN_SKILLS[@]}"; do
    local file="${ROOT_DIR}/${rel}"
    local dir="${ROOT_DIR}/$(dirname "${rel}")"
    local notice="${dir}/NOTICE.md"

    if ! grep -q 'Adapted from pbakaus/impeccable' "${file}"; then
      missing+=("${rel} (missing provenance comment)")
    fi

    if [[ ! -f "${notice}" ]]; then
      missing+=("$(dirname "${rel}")/NOTICE.md (missing file)")
      continue
    fi

    if ! grep -qi 'impeccable' "${notice}" || ! grep -q 'Original work:' "${notice}"; then
      missing+=("$(dirname "${rel}")/NOTICE.md (missing attribution details)")
    fi
  done

  if [[ ${#missing[@]} -eq 0 ]]; then
    report_pass "${assertion}"
  else
    report_fail "${assertion}" "Missing provenance/notice checks:" "${missing[*]}"
  fi
}

check_new_skills_reference_frontend_context_protocol() {
  local assertion="new-skills-reference-frontend-context-protocol"
  local missing=()

  for rel in "${NEW_DESIGN_SKILLS[@]}"; do
    local file="${ROOT_DIR}/${rel}"
    if ! grep -q '/frontend-design' "${file}" || ! grep -q 'Context Gathering Protocol' "${file}"; then
      missing+=("${rel}")
    fi
  done

  if [[ ${#missing[@]} -eq 0 ]]; then
    report_pass "${assertion}"
  else
    report_fail "${assertion}" "Missing protocol references in: ${missing[*]}"
  fi
}

check_critique_onboard_stop_guard() {
  local assertion="protocol-critique-onboard-have-stop-without-context-guard"
  local missing=()

  local targets=(
    "skills/design-critique/SKILL.md"
    "skills/design-onboard/SKILL.md"
  )

  for rel in "${targets[@]}"; do
    local file="${ROOT_DIR}/${rel}"
    if ! grep -q 'STOP and run' "${file}" || ! grep -q 'teach-design' "${file}"; then
      missing+=("${rel}")
    fi
  done

  if [[ ${#missing[@]} -eq 0 ]]; then
    report_pass "${assertion}"
  else
    report_fail "${assertion}" "Missing stop guard text in: ${missing[*]}"
  fi
}

check_no_claude_placeholders() {
  local assertion="protocol-no-claude-placeholder-terms-introduced"
  local placeholder_pattern='AskUserQuestionTool|ReadFileTool|WriteFileTool|EditFileTool|MultiEdit|TodoWrite|exit_plan_mode|attempt_completion'

  local output
  output="$({
    for rel in "${DESIGN_SKILLS[@]}"; do
      grep -nE "${placeholder_pattern}" "${ROOT_DIR}/${rel}" || true
    done
  } | sed '/^$/d')"

  if [[ -z "${output}" ]]; then
    report_pass "${assertion}"
  else
    report_fail "${assertion}" "Found placeholder terms:" "${output}"
  fi
}

check_frontend_canonical_context_protocol() {
  local assertion="protocol-frontend-design-has-canonical-context-gathering-protocol"
  local file="${ROOT_DIR}/skills/frontend-design/SKILL.md"

  if grep -q '^## Context Gathering Protocol$' "${file}"; then
    report_pass "${assertion}"
  else
    report_fail "${assertion}" "Missing canonical heading in: skills/frontend-design/SKILL.md"
  fi
}

check_delight_anti_slop_mapping_presence() {
  local assertion="protocol-animate-onboard-have-delight-anti-slop-mapping"
  local missing=()

  local targets=(
    "skills/design-animate/SKILL.md"
    "skills/design-onboard/SKILL.md"
  )

  for rel in "${targets[@]}"; do
    if ! grep -qi 'delight anti-slop mapping' "${ROOT_DIR}/${rel}"; then
      missing+=("${rel}")
    fi
  done

  if [[ ${#missing[@]} -eq 0 ]]; then
    report_pass "${assertion}"
  else
    report_fail "${assertion}" "Missing delight anti-slop mapping section in: ${missing[*]}"
  fi
}

check_design_skill_cardinality
check_mandatory_preparation
check_frontend_context_protocol_references
check_new_skills_frontmatter_name_matches_folder
check_new_skills_provenance_and_notice_present
check_new_skills_reference_frontend_context_protocol
check_critique_onboard_stop_guard
check_no_claude_placeholders
check_frontend_canonical_context_protocol
check_delight_anti_slop_mapping_presence

if [[ ${failures} -ne 0 ]]; then
  echo ""
  echo "check-design-protocol: FAILED (${failures} assertion(s) failed)"
  exit 1
fi

echo ""
echo "check-design-protocol: PASSED"
