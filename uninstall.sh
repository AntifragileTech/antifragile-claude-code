#!/usr/bin/env bash
set -euo pipefail

# Antifragile Claude Code — Uninstaller (Manifest-based rollback)
# Usage:
#   bash uninstall.sh --module 4       # Remove only dev skills
#   bash uninstall.sh --module 2 3     # Remove modules 2 and 3
#   bash uninstall.sh --all            # Remove everything installed by Antifragile Claude Code
#   bash uninstall.sh --list           # Show what can be uninstalled

CLAUDE_DIR="$HOME/.claude"
MANIFEST_DIR="$CLAUDE_DIR/.power-pack"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

print_header() {
    echo ""
    echo -e "${RED}=== Antifragile Claude Code — Uninstaller ===${NC}"
    echo ""
}

list_installed() {
    echo "Installed modules available for rollback:"
    if [ ! -d "$MANIFEST_DIR" ]; then
        echo "  (none — Antifragile Claude Code not installed)"
        return 1
    fi

    local found=0
    for manifest in "$MANIFEST_DIR"/module-*.manifest 2>/dev/null; do
        [ -f "$manifest" ] || continue
        found=1
        local name=$(basename "$manifest" .manifest)
        local count=$(grep -cv "^#" "$manifest" 2>/dev/null || echo 0)
        local date=$(head -1 "$manifest" | grep "^#" | sed 's/^# //')
        echo -e "  ${GREEN}$name${NC}: $count items (installed $date)"
    done

    if [ "$found" -eq 0 ]; then
        echo "  (no manifests found)"
        return 1
    fi

    echo ""
    echo "Usage:"
    echo "  bash uninstall.sh --module 4       # Remove module 4"
    echo "  bash uninstall.sh --module 2 3     # Remove modules 2 and 3"
    echo "  bash uninstall.sh --all            # Remove everything"
}

# Map module number to manifest name
module_to_manifest() {
    local mod="$1"
    case "$mod" in
        0) echo "module-0-core-setup" ;;
        1) echo "module-1-rules" ;;
        2) echo "module-2-agents" ;;
        3) echo "module-3-commands" ;;
        4) echo "module-4-dev-skills" ;;
        5) echo "module-5-security-skills" ;;
        6) echo "module-6-devops-skills" ;;
        7) echo "module-7-gtm-skills" ;;
        8) echo "module-8-marketing-skills" ;;
        9) echo "module-9-thinking-skills" ;;
        *) echo "" ;;
    esac
}

# Remove items listed in a manifest file
rollback_manifest() {
    local manifest_file="$1"
    local manifest_name=$(basename "$manifest_file" .manifest)

    if [ ! -f "$manifest_file" ]; then
        echo -e "  ${YELLOW}$manifest_name${NC}: no manifest found — skipping"
        return
    fi

    local removed=0
    local missing=0
    local special=0

    while IFS= read -r item; do
        # Skip comments
        [[ "$item" =~ ^# ]] && continue
        [ -z "$item" ] && continue

        # Special entries (like CLAUDE.md modifications)
        if [[ "$item" == *":auto-discovery-appended"* ]]; then
            special=$((special + 1))
            echo -e "  ${YELLOW}Note${NC}: CLAUDE.md auto-discovery section was added by module 0."
            echo "         To remove it, edit ~/.claude/CLAUDE.md and delete the"
            echo "         '## Skill Auto-Discovery (CRITICAL)' section manually."
            continue
        fi

        # Remove files and directories
        if [ -e "$item" ]; then
            rm -rf "$item"
            removed=$((removed + 1))
        else
            missing=$((missing + 1))
        fi
    done < "$manifest_file"

    echo -e "  ${GREEN}$manifest_name${NC}: $removed removed, $missing already gone"
    if [ "$special" -gt 0 ]; then
        echo -e "  ${YELLOW}$manifest_name${NC}: $special manual steps noted above"
    fi

    # Remove the manifest itself
    rm -f "$manifest_file"
}

# Clean up empty directories left behind
cleanup_empty_dirs() {
    for dir in "$CLAUDE_DIR/skills" "$CLAUDE_DIR/agents" "$CLAUDE_DIR/commands" "$CLAUDE_DIR/rules"; do
        if [ -d "$dir" ]; then
            # Remove empty subdirectories
            find "$dir" -type d -empty -delete 2>/dev/null || true
        fi
    done

    # Remove manifest dir if empty
    if [ -d "$MANIFEST_DIR" ] && [ -z "$(ls -A "$MANIFEST_DIR" 2>/dev/null)" ]; then
        rmdir "$MANIFEST_DIR" 2>/dev/null || true
    fi
}

print_footer() {
    echo ""
    echo -e "${BLUE}=== Rollback Complete ===${NC}"
    cleanup_empty_dirs
    echo "  Empty directories cleaned up."
    echo -e "  ${GREEN}Restart Claude Code for changes to take effect.${NC}"
    echo ""
}

# --- Main ---

print_header

if [ $# -eq 0 ]; then
    echo "Usage:"
    echo "  bash uninstall.sh --list           # Show installed modules"
    echo "  bash uninstall.sh --module 4       # Remove module 4"
    echo "  bash uninstall.sh --module 2 3     # Remove modules 2 and 3"
    echo "  bash uninstall.sh --all            # Remove everything"
    exit 0
fi

if [ "${1:-}" = "--list" ]; then
    list_installed
    exit 0
fi

if [ "${1:-}" = "--all" ]; then
    echo -e "${RED}Removing ALL Antifragile Claude Code modules...${NC}"
    echo ""

    if [ ! -d "$MANIFEST_DIR" ]; then
        echo "  No manifests found — nothing to uninstall."
        exit 0
    fi

    for manifest in "$MANIFEST_DIR"/module-*.manifest; do
        [ -f "$manifest" ] || continue
        rollback_manifest "$manifest"
    done

    print_footer
    exit 0
fi

if [ "${1:-}" = "--module" ]; then
    shift
    if [ $# -eq 0 ]; then
        echo "Error: specify module numbers (e.g., --module 4 or --module 2 3)"
        exit 1
    fi

    for mod in "$@"; do
        local_name=$(module_to_manifest "$mod")
        if [ -z "$local_name" ]; then
            echo -e "  ${RED}Unknown module: $mod${NC}"
            continue
        fi
        manifest_path="$MANIFEST_DIR/${local_name}.manifest"
        rollback_manifest "$manifest_path"
    done

    print_footer
    exit 0
fi

echo "Unknown option: $1"
echo "Run 'bash uninstall.sh' for usage."
exit 1
