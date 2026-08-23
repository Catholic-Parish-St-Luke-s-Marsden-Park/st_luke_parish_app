#!/usr/bin/env bash
set -euo pipefail

MEMORY_FILE=".claude/memory.md"

if [[ -f "$MEMORY_FILE" ]]; then
  echo "--- SDLC State ($MEMORY_FILE) ---"
  awk '/^## Active State/{flag=1; next} /^## /{flag=0} flag' "$MEMORY_FILE"
fi

exit 0
