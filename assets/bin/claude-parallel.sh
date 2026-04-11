#!/bin/bash
# claude-parallel.sh — Create a tmux session for a project with 3 windows

set -e

if [ -z "$1" ]; then
  echo "Usage: claude-parallel.sh <project-name>"
  exit 1
fi

PROJECT="$1"

# Check if session already exists
if tmux has-session -t "$PROJECT" 2>/dev/null; then
  echo "Session '$PROJECT' already exists. Attaching..."
  tmux attach-session -t "$PROJECT"
  exit 0
fi

# Create new session with first window named "claude"
tmux new-session -d -s "$PROJECT" -n "claude"

# Create additional windows
tmux new-window -t "$PROJECT" -n "terminal"
tmux new-window -t "$PROJECT" -n "server"

# Select the first window
tmux select-window -t "$PROJECT:claude"

# Attach to the session
tmux attach-session -t "$PROJECT"
