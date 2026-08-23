#!/usr/bin/env bash
set -euo pipefail

CMD="$(python3 -c "
import json, sys
try:
    data = json.load(sys.stdin)
    print(data.get('tool_input', {}).get('command', ''))
except Exception:
    pass
")"

BRANCH="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo '')"

if [[ "$BRANCH" == "main" ]] && echo "$CMD" | grep -Eq '(^|;|&&|\|\|?)\s*git\s+(commit|push)\b'; then
  echo "Blocked: direct 'git commit'/'git push' on main is not allowed by .claude/git/branching-policy.md. Use a feature branch (start one via .claude/scripts/agent_orchestrator.sh start-feature)." >&2
  exit 2
fi

if echo "$CMD" | grep -Eq '(^|;|&&|\|\|?)\s*git\s+push\b.*(--force\b|--force-with-lease\b|-f\b)'; then
  echo "Blocked: force-push is not allowed by .claude/git/branching-policy.md. Rebase and push normally, or ask the user to force-push manually if truly required." >&2
  exit 2
fi

if echo "$CMD" | grep -Eq '(^|;|&&|\|\|?)\s*git\s+branch\s+.*(-[dD]\b|--delete\b).*\bmain\b'; then
  echo "Blocked: deleting the main branch is not allowed." >&2
  exit 2
fi

exit 0
