#!/bin/bash
# claude-checkpoint.sh — Headless Claude checkpoint runner
# Usage: ./claude-checkpoint.sh [project-dir]
# Creates a structured progress snapshot without opening an interactive session.

PROJECT_DIR="${1:-$(pwd)}"
CHECKPOINT_DIR="$HOME/.claude/logs"
mkdir -p "$CHECKPOINT_DIR"

TIMESTAMP=$(date +%Y%m%d-%H%M%S)
OUTFILE="$CHECKPOINT_DIR/checkpoint-$TIMESTAMP.md"

claude -p "You are a progress checkpoint recorder. Do the following:

1. Run 'git log --oneline -10' to get recent commits
2. Run 'git diff --name-only HEAD' to list changed files
3. Run 'git status --short' to see working tree state
4. Check for any open TODO files in the current directory

Then write a structured checkpoint to: $OUTFILE

Format:
# Checkpoint — $(date '+%Y-%m-%d %H:%M')
## Project: $PROJECT_DIR
## What Changed (last 10 commits)
## Modified Files (uncommitted)
## Current Status
## Blockers / Notes
## Next Steps

Be concise. This file will be read at the start of the next session." \
  --allowedTools "Bash,Read,Write" \
  --print \
  2>/dev/null

if [ -f "$OUTFILE" ]; then
  echo "Checkpoint saved: $OUTFILE"
else
  echo "Checkpoint may not have been written — check $CHECKPOINT_DIR/"
fi
