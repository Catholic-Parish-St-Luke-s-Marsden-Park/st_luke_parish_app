#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-$(pwd)}"
ACTION="${2:-}"
FEATURE_ID="${3:-}"
FEATURE_SLUG="${4:-}"
PHASE="${5:-}"
TIMESTAMP="$(date +%Y-%m-%d_%H-%M)"
FEATURE_NAME="${FEATURE_ID}-${FEATURE_SLUG}"

cd "$ROOT"

usage() {
  echo "Usage:"
  echo "  $0 <root> start-feature <feature-id> <feature-slug>"
  echo "  $0 <root> complete-phase <feature-id> <feature-slug> <ba|coder|tester|verifier|deployer>"
  echo "  $0 <root> prepare-pr <feature-id> <feature-slug>"
  exit 1
}

require_git_repo() {
  git rev-parse --is-inside-work-tree >/dev/null 2>&1 || { echo 'Not a git repo'; exit 1; }
}

branch_name() {
  echo "feature/${FEATURE_ID}-${FEATURE_SLUG}"
}

agent_name_for_phase() {
  case "$1" in
    ba) echo "BA_AGENT" ;;
    coder) echo "CODER_AGENT" ;;
    tester) echo "TESTER_AGENT" ;;
    verifier) echo "VERIFIER_AGENT" ;;
    deployer) echo "DEPLOYER_AGENT" ;;
    *) echo "UNKNOWN_AGENT" ;;
  esac
}

commit_type_for_phase() {
  case "$1" in
    ba) echo "docs" ;;
    coder) echo "feat" ;;
    tester) echo "test" ;;
    verifier) echo "docs" ;;
    deployer) echo "chore" ;;
    *) echo "chore" ;;
  esac
}

append_memory_log() {
  local message="$1"
  python3 - <<PY
from pathlib import Path
p = Path('.claude/memory.md')
text = p.read_text()
marker = '## Latest Session Logs\n'
entry = '- ${TIMESTAMP}: ${message}\n'
if marker in text:
    text = text.replace(marker, marker + entry, 1)
else:
    text += '\n## Latest Session Logs\n' + entry
p.write_text(text)
PY
}

update_memory_state() {
  local feature="$1"
  local branch="$2"
  local phase="$3"
  local agent="$4"
  python3 - <<PY
from pathlib import Path
p = Path('.claude/memory.md')
lines = p.read_text().splitlines()
replacements = {
    '- **Current Feature:**': '- **Current Feature:** ${feature}',
    '- **Current Branch:**': '- **Current Branch:** ${branch}',
    '- **Current Phase:**': '- **Current Phase:** ${phase}',
    '- **Active Agent:**': '- **Active Agent:** ${agent}',
    '- **Awaiting User Approval:**': '- **Awaiting User Approval:** yes',
}
for i, line in enumerate(lines):
    for prefix, new_line in replacements.items():
        if line.startswith(prefix):
            lines[i] = new_line
p.write_text('\n'.join(lines) + '\n')
PY
}

create_phase_plan() {
  local phase="$1"
  local agent
  agent="$(agent_name_for_phase "$phase")"
  local plan_file=".claude/plans/${phase}/${TIMESTAMP}-${FEATURE_NAME}.md"
  cat > "$plan_file" <<EOF2
# ${agent} Plan

- Feature ID: ${FEATURE_ID}
- Feature Slug: ${FEATURE_SLUG}
- Branch: $(branch_name)
- Phase: ${phase}
- Timestamp: ${TIMESTAMP}

## Inputs
- Root CLAUDE.md
- .claude/memory.md
- Prior approved phase artifact

## Objectives
- Fill in during this phase

## Outputs
- Fill in during this phase

## Risks / Notes
- Add notes here

## Handoff
- Wait for user approval before next phase
EOF2
  echo "$plan_file"
}

create_journal() {
  local phase="$1"
  local journal_file=".claude/journal/${TIMESTAMP}-${FEATURE_NAME}-${phase}.md"
  cat > "$journal_file" <<EOF2
# Journal Entry

- Feature ID: ${FEATURE_ID}
- Feature Slug: ${FEATURE_SLUG}
- Branch: $(branch_name)
- Phase: ${phase}
- Timestamp: ${TIMESTAMP}

## Files Changed
- Add file paths

## Commands Run
- Add executed commands

## Results
- Add outcomes here

## Risks / Follow-up
- Add follow-up items

## Next Handoff
- Wait for user approval
EOF2
  echo "$journal_file"
}

create_verification_report() {
  local report_file=".claude/verification/${TIMESTAMP}-${FEATURE_NAME}.md"
  cat > "$report_file" <<EOF2
# Verification Report

- Feature ID: ${FEATURE_ID}
- Feature Slug: ${FEATURE_SLUG}
- Branch: $(branch_name)
- Timestamp: ${TIMESTAMP}

## Requirement Traceability
| Requirement ID | Requirement Summary | Code Evidence | Test Evidence | Status |
|---|---|---|---|---|

## Findings
- Add findings

## Verdict
- pass / conditional pass / fail
EOF2
  echo "$report_file"
}

start_feature() {
  require_git_repo
  git fetch origin main || true
  git checkout main
  git pull origin main || true
  git checkout -b "$(branch_name)"

  local plan_file
  plan_file="$(create_phase_plan ba)"
  local journal_file
  journal_file="$(create_journal ba)"

  update_memory_state "${FEATURE_NAME}" "$(branch_name)" "ba" "BA_AGENT"
  append_memory_log "Started feature ${FEATURE_NAME} on branch $(branch_name)"

  git add .claude/plans/ba .claude/journal .claude/memory.md
  git commit -m "docs(feature-${FEATURE_ID}): start ${FEATURE_SLUG}

Agent: BA_AGENT
Feature: ${FEATURE_NAME}
Branch: $(branch_name)
Plan: ${plan_file}
Journal: ${journal_file}
Memory: .claude/memory.md" || true

  echo "Started feature: ${FEATURE_NAME}"
}

complete_phase() {
  local phase="$1"
  local agent
  agent="$(agent_name_for_phase "$phase")"
  local plan_file
  plan_file="$(create_phase_plan "$phase")"
  local journal_file
  journal_file="$(create_journal "$phase")"
  local verification_file=""

  if [[ "$phase" == "verifier" ]]; then
    verification_file="$(create_verification_report)"
  fi

  update_memory_state "${FEATURE_NAME}" "$(branch_name)" "${phase}" "${agent}"
  append_memory_log "Completed phase ${phase} for ${FEATURE_NAME}"

  # Stage SDLC bookkeeping artifacts plus the actual working tree (app code,
  # tests, pubspec, platform folders, etc.) so phase commits are never
  # docs-only. .gitignore already excludes build/.dart_tool/etc.
  git add -A
  git commit -m "$(commit_type_for_phase "$phase")(feature-${FEATURE_ID}): ${phase} phase for ${FEATURE_SLUG}

Agent: ${agent}
Feature: ${FEATURE_NAME}
Branch: $(branch_name)
Plan: ${plan_file}
Journal: ${journal_file}
Verification: ${verification_file:-n/a}
Memory: .claude/memory.md" || true

  echo "Completed phase: ${phase}"
}

prepare_pr() {
  require_git_repo

  if [[ -n "$(git status --porcelain)" ]]; then
    echo "Refusing to rebase: working tree has uncommitted changes." >&2
    echo "Commit them (e.g. via complete-phase) before running prepare-pr." >&2
    exit 1
  fi

  git fetch origin main || true
  git rebase origin/main || true

  local pr_note=".claude/releases/${TIMESTAMP}-${FEATURE_NAME}-pr-ready.md"
  cat > "$pr_note" <<EOF2
# PR Readiness Note

- Feature ID: ${FEATURE_ID}
- Feature Slug: ${FEATURE_SLUG}
- Branch: $(branch_name)
- Timestamp: ${TIMESTAMP}

## Checklist
- [ ] Rebased with latest main
- [ ] Merge conflicts resolved
- [ ] dart format completed
- [ ] flutter analyze completed
- [ ] flutter test completed
- [ ] build validation completed
- [ ] test summary updated
- [ ] verification reviewed
- [ ] journal updated
- [ ] memory updated
- [ ] user approval recorded
EOF2

  append_memory_log "Prepared PR artifacts for ${FEATURE_NAME}"

  git add .claude/releases .claude/memory.md
  git commit -m "chore(feature-${FEATURE_ID}): prepare pr for ${FEATURE_SLUG}

Agent: DEPLOYER_AGENT
Feature: ${FEATURE_NAME}
Branch: $(branch_name)
Plan: .claude/plans/deployer/
Journal: .claude/journal/
Memory: .claude/memory.md
PR Note: ${pr_note}" || true

  echo "Prepared PR note: ${pr_note}"
}

if [[ -z "${ACTION}" ]]; then
  usage
fi

case "$ACTION" in
  start-feature)
    start_feature
    ;;
  complete-phase)
    [[ -z "${PHASE}" ]] && usage
    complete_phase "$PHASE"
    ;;
  prepare-pr)
    prepare_pr
    ;;
  *)
    usage
    ;;
esac
