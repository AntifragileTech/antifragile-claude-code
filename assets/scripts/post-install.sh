#!/bin/bash
# Post-install bootstrap — runs after install.sh completes
# Copies bootstrap command and reminds user to run it

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

COMMANDS_DIR="$HOME/.claude/commands"
SCRIPTS_DIR="$HOME/.claude/scripts"
mkdir -p "$COMMANDS_DIR" "$SCRIPTS_DIR"

# Copy bootstrap command
SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
if [ -f "$SCRIPT_DIR/commands/bootstrap-projects.md" ]; then
  cp "$SCRIPT_DIR/commands/bootstrap-projects.md" "$COMMANDS_DIR/bootstrap-projects.md"
  echo -e "${GREEN}Installed /bootstrap-projects command${NC}"
fi

# Copy skill security scanner
if [ -f "$SCRIPT_DIR/scripts/skill-security-scan.sh" ]; then
  cp "$SCRIPT_DIR/scripts/skill-security-scan.sh" "$SCRIPTS_DIR/skill-security-scan.sh"
  chmod +x "$SCRIPTS_DIR/skill-security-scan.sh"
  echo -e "${GREEN}Installed skill security scanner (auto-runs on skill write/edit)${NC}"
fi

# Check if any project dirs exist without CLAUDE.md
echo ""
echo -e "${YELLOW}=== Project Bootstrap Check ===${NC}"

FOUND=0
MISSING=0
for dir in ~/Projects ~/Code ~/Vibe\ Code ~/Developer ~/repos ~/src ~/work; do
  if [ -d "$dir" ]; then
    for project in "$dir"/*/; do
      [ -d "$project" ] || continue
      # Check for code indicators
      if ls "$project"/{package.json,requirements.txt,composer.json,Cargo.toml,go.mod,Makefile} 2>/dev/null | head -1 > /dev/null 2>&1; then
        FOUND=$((FOUND + 1))
        if [ ! -f "$project/CLAUDE.md" ]; then
          MISSING=$((MISSING + 1))
        fi
      fi
    done
  fi
done

if [ "$MISSING" -gt 0 ]; then
  echo -e "${YELLOW}Found $FOUND projects, $MISSING missing CLAUDE.md${NC}"
  echo ""
  echo "Run this in a Claude Code session to auto-generate missing CLAUDE.md files:"
  echo ""
  echo "  /bootstrap-projects"
  echo ""
  echo "This scans your project directories and creates CLAUDE.md + memory dirs"
  echo "for each project. Safe to run multiple times — never overwrites existing files."
else
  echo -e "${GREEN}All $FOUND projects already have CLAUDE.md — nothing to do.${NC}"
fi
