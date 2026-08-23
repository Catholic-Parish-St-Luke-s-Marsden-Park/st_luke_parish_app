# Command: phase-close

## Purpose
Close the current phase cleanly.

## Required actions
1. Save the agent-specific plan artifact
2. Save or update the journal
3. Update memory
4. Update feature index
5. Prepare commit metadata
6. Stop for user approval

See `.claude/hooks/after-phase.md` for the full checklist this command performs.
