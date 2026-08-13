#!/usr/bin/env bash
# Static checks on the jira-task-management family's SKILL.md files — run
# from a checkout of this repo:
#   bash tools/test/jira-skills-static-check.sh
#
# Lighter analog of osac-workspace's tools/test/jira-skills-smoke.sh, checking
# the native skills/ tree directly instead of a materialized-from-vendor copy.
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
ROOT=$(cd "${SCRIPT_DIR}/../.." && pwd)

fail() { echo "FAIL: $*" >&2; exit 1; }
pass() { echo "PASS: $*"; }

test_skills_reference_shared_script() {
  local skill file
  for skill in jira-task-management report-bug capture-tasks-from-meeting-notes osac-feature; do
    file="${ROOT}/skills/${skill}/SKILL.md"
    # osac-feature's sourcing logic lives in a nested reference, not SKILL.md
    [[ "$skill" == "osac-feature" ]] && file="${ROOT}/skills/osac-feature/references/bash-patterns.md"
    grep -q 'jira-safe-create\.sh' "$file" \
      || fail "${skill}: missing jira-safe-create.sh reference in ${file}"
    pass "${skill}: references shared script"
  done
}

test_no_fixed_tmp_paths() {
  if rg -q '/tmp/(issue-body|jira-create)' "${ROOT}/skills/jira-task-management" \
      "${ROOT}/skills/report-bug" \
      "${ROOT}/skills/capture-tasks-from-meeting-notes" \
      "${ROOT}/skills/osac-feature" 2>/dev/null; then
    fail "fixed /tmp paths still present in skill docs"
  fi
  pass "no fixed /tmp create paths in affected skills"
}

test_no_inline_create_in_examples() {
  # Matches the antipattern string wherever it appears, then checks a few
  # lines of *preceding* context (not just the match line itself) for a
  # "Never do this" / "Do not" qualifier — jira-task-management documents the
  # antipattern under a "**Never do this:**" heading one line above the
  # example, so a same-line-only check would false-positive on it.
  local skill file line_nums line_no context
  for skill in jira-task-management report-bug capture-tasks-from-meeting-notes osac-feature; do
    file="${ROOT}/skills/${skill}/SKILL.md"
    [[ "$skill" == "osac-feature" ]] && file="${ROOT}/skills/osac-feature/references/bash-patterns.md"
    line_nums=$(rg -n 'KEY=\$\(jira issue create' "$file" 2>/dev/null | cut -d: -f1 || true)
    for line_no in $line_nums; do
      context=$(sed -n "$((line_no > 3 ? line_no - 3 : 1)),${line_no}p" "$file")
      grep -qiE 'never |do not ' <<<"$context" && continue
      fail "${skill}: inline KEY=\$(jira issue create...) pattern in example at ${file}:${line_no}"
    done
    pass "${skill}: no inline create antipattern in examples"
  done
}

test_osac_feature_no_duplicate_helpers() {
  if rg -q '^TEMP_FILES=\(\)' "${ROOT}/skills/osac-feature/SKILL.md" "${ROOT}/skills/osac-feature/references/bash-patterns.md"; then
    fail "osac-feature: inline TEMP_FILES block should be removed (use shared script)"
  fi
  pass "osac-feature: no duplicate temp helpers"
}

test_skills_reference_shared_script
test_no_fixed_tmp_paths
test_no_inline_create_in_examples
test_osac_feature_no_duplicate_helpers

echo ""
echo "All jira skill static checks passed."
