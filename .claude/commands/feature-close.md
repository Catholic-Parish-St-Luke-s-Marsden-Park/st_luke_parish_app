# Command: feature-close

## Purpose
Prepare the feature for PR readiness.

## Required actions
1. Confirm all phases completed
2. Confirm verification report exists
3. Rebase with latest main
4. Resolve conflicts
5. Rerun validation
6. Update test summary
7. Update release and PR artifacts
8. Confirm/refresh the feature's row in `.claude/context/feature-index.md`
9. Stop for user approval

See `.claude/hooks/before-pr.md` for the full checklist this command performs.
