# Hook: before-pr

- fetch latest main
- rebase onto main
- resolve conflicts
- rerun tests and validation
- update test summary
- update PR readiness note
- walk `.claude/git/merge-to-main-checklist.md` top to bottom against real evidence (done by pr-agent)
- fill in `.claude/git/pr-template.md` (done by pr-agent)
- wait for user approval
