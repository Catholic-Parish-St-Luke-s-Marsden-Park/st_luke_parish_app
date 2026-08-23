#!/usr/bin/env bash
set -euo pipefail

NAME="$(python3 -c "
import json, sys
try:
    data = json.load(sys.stdin)
    print(data.get('subagent_name', data.get('agent_name', '')))
except Exception:
    pass
" 2>/dev/null || true)"

echo "--- Phase agent finished${NAME:+ ($NAME)} ---"
echo "Review the artifact it produced, then run /phase-close before starting the next phase."

exit 0
