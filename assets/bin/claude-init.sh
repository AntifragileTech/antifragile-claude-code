#!/bin/bash
# claude-init.sh — Initialize a project directory with a CLAUDE.md template

set -e

TEMPLATE="$HOME/templates/CLAUDE.md"

if [ -z "$1" ]; then
  echo "Usage: claude-init.sh <project-directory>"
  exit 1
fi

PROJECT_DIR="$1"

if [ ! -d "$PROJECT_DIR" ]; then
  echo "Error: Directory '$PROJECT_DIR' does not exist."
  exit 1
fi

TARGET="$PROJECT_DIR/CLAUDE.md"

if [ -f "$TARGET" ]; then
  echo "CLAUDE.md already exists in $PROJECT_DIR — skipping."
  exit 0
fi

cp "$TEMPLATE" "$TARGET"
echo "Created CLAUDE.md in $PROJECT_DIR"
echo "Open it and fill in the placeholder sections for your project."
