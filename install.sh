#!/usr/bin/env bash
set -euo pipefail

# Antifragile Claude Code — Installer Script (with rollback support)
# Usage:
#   bash install.sh              # Install everything
#   bash install.sh --module 4   # Install only dev skills
#   bash install.sh --module 2 3 # Install modules 2 and 3
#   bash install.sh --list       # List available modules
#   bash install.sh --status     # Show what's installed

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ASSETS_DIR="$SCRIPT_DIR/assets"
CLAUDE_DIR="$HOME/.claude"
MANIFEST_DIR="$CLAUDE_DIR/.power-pack"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

print_header() {
    echo ""
    echo -e "${BLUE}=== Antifragile Claude Code ===${NC}"
    echo ""
}

list_modules() {
    echo "Available modules:"
    echo "  0  Core Setup       — CLAUDE.md auto-discovery rules"
    echo "  1  Coding Rules     — 29 rule files (common + language-specific)"
    echo "  2  Agents           — 68 specialized agents"
    echo "  3  Commands         — 84 slash commands"
    echo "  4  Dev Skills       — 188 framework & language skills"
    echo "  5  Security Skills  — 40 security & fuzzing skills"
    echo "  6  DevOps Skills    — 46 infrastructure skills"
    echo "  7  GTM Skills       — 86 go-to-market skills"
    echo "  8  Marketing Skills — 39 marketing & CRO skills"
    echo "  9  Thinking Skills  — 115 reasoning & meta skills"
    echo ""
    echo "Usage:"
    echo "  bash install.sh              # Install ALL modules"
    echo "  bash install.sh --module 4   # Install only module 4"
    echo "  bash install.sh --module 2 3 # Install modules 2 and 3"
    echo "  bash install.sh --status     # Show installed modules"
}

show_status() {
    echo "Installed modules:"
    if [ ! -d "$MANIFEST_DIR" ]; then
        echo "  (none — Antifragile Claude Code not installed)"
        return
    fi
    for manifest in "$MANIFEST_DIR"/module-*.manifest 2>/dev/null; do
        [ -f "$manifest" ] || continue
        local name=$(basename "$manifest" .manifest)
        local count=$(wc -l < "$manifest" | tr -d ' ')
        local date=$(head -1 "$manifest" | grep "^#" | sed 's/^# //')
        echo -e "  ${GREEN}$name${NC}: $count items (installed $date)"
    done
    echo ""
    echo "To rollback: bash uninstall.sh --module 4  OR  bash uninstall.sh --all"
}

# Initialize manifest tracking
init_manifest() {
    mkdir -p "$MANIFEST_DIR"
}

# Start a new manifest for a module
start_manifest() {
    local module_id="$1"
    CURRENT_MANIFEST="$MANIFEST_DIR/module-${module_id}.manifest"
    # If manifest exists, we append (for re-runs that add new items)
    if [ ! -f "$CURRENT_MANIFEST" ]; then
        echo "# $TIMESTAMP" > "$CURRENT_MANIFEST"
    fi
}

# Record an installed item in the manifest
record_item() {
    local path="$1"
    # Only record if not already in manifest
    if ! grep -qxF "$path" "$CURRENT_MANIFEST" 2>/dev/null; then
        echo "$path" >> "$CURRENT_MANIFEST"
    fi
}

# Safe copy with manifest tracking
safe_copy_files() {
    local src="$1" dst="$2" label="$3"
    local installed=0 skipped=0

    mkdir -p "$dst"

    for item in "$src"/*; do
        [ -e "$item" ] || continue
        local name=$(basename "$item")
        local target="$dst/$name"

        if [ -e "$target" ]; then
            skipped=$((skipped + 1))
        else
            cp -r "$item" "$target"
            record_item "$target"
            installed=$((installed + 1))
        fi
    done

    echo -e "  ${GREEN}$label${NC}: $installed installed, $skipped skipped"
}

install_core_setup() {
    echo -e "${YELLOW}Module 0: Core Setup${NC}"
    start_manifest "0-core-setup"
    mkdir -p "$CLAUDE_DIR"

    if [ ! -f "$CLAUDE_DIR/CLAUDE.md" ]; then
        touch "$CLAUDE_DIR/CLAUDE.md"
    fi

    if grep -q "Skill Auto-Discovery" "$CLAUDE_DIR/CLAUDE.md" 2>/dev/null; then
        echo "  Already configured — skipping"
    else
        cat >> "$CLAUDE_DIR/CLAUDE.md" << 'AUTODISC'

## Skill Auto-Discovery (CRITICAL)
You have hundreds of installed skills, commands, and agents. Before starting ANY task, scan the available skills list for relevant matches. DO NOT ask the user to invoke skills manually — proactively use them.

### Skill Matching Rules
1. Before writing code: Check if a language/framework-specific skill exists.
2. Before debugging: Use systematic-debugging or debug-like-expert.
3. Before security work: Use Trail of Bits skills (semgrep, codeql, etc.).
4. Before DevOps/Infra: Use DevOps skills (terraform, k8s, docker, etc.).
5. Before UI/UX work: Use ui-ux-pro-max, frontend-design, design-system.
6. Before planning: Use writing-plans, brainstorming, or plan.
7. Before code review: Use code-review, security-review, or language-specific reviewer.
8. Before testing: Use test-driven-development, tdd-workflow, e2e-testing.
9. Before marketing/content: Match to CRO, SEO, copywriting, email skills.
10. Before deploying: Use pre-deploy, verification-loop, deployment-patterns.
AUTODISC
        record_item "CLAUDE.md:auto-discovery-appended"
        echo -e "  ${GREEN}Auto-discovery added to CLAUDE.md${NC}"
    fi
}

install_rules() {
    echo -e "${YELLOW}Module 1: Coding Rules${NC}"
    start_manifest "1-rules"
    for subdir in "$ASSETS_DIR"/rules/*/; do
        [ -d "$subdir" ] || continue
        local name=$(basename "$subdir")
        safe_copy_files "$subdir" "$CLAUDE_DIR/rules/$name" "Rules/$name"
    done
}

install_agents() {
    echo -e "${YELLOW}Module 2: Agents${NC}"
    start_manifest "2-agents"
    safe_copy_files "$ASSETS_DIR/agents" "$CLAUDE_DIR/agents" "Agents"
}

install_commands() {
    echo -e "${YELLOW}Module 3: Commands${NC}"
    start_manifest "3-commands"
    safe_copy_files "$ASSETS_DIR/commands" "$CLAUDE_DIR/commands" "Commands"
}

install_skills_category() {
    local category="$1" label="$2"
    local src="$ASSETS_DIR/skills/$category"
    [ -d "$src" ] || return
    safe_copy_files "$src" "$CLAUDE_DIR/skills" "$label"
}

install_dev_skills() {
    echo -e "${YELLOW}Module 4: Dev Skills${NC}"
    start_manifest "4-dev-skills"
    install_skills_category "dev" "Dev Skills"
}

install_security_skills() {
    echo -e "${YELLOW}Module 5: Security Skills${NC}"
    start_manifest "5-security-skills"
    install_skills_category "security" "Security Skills"
}

install_devops_skills() {
    echo -e "${YELLOW}Module 6: DevOps Skills${NC}"
    start_manifest "6-devops-skills"
    install_skills_category "devops" "DevOps Skills"
}

install_gtm_skills() {
    echo -e "${YELLOW}Module 7: GTM Skills${NC}"
    start_manifest "7-gtm-skills"
    install_skills_category "gtm" "GTM Skills"
}

install_marketing_skills() {
    echo -e "${YELLOW}Module 8: Marketing Skills${NC}"
    start_manifest "8-marketing-skills"
    install_skills_category "marketing" "Marketing Skills"
}

install_thinking_skills() {
    echo -e "${YELLOW}Module 9: Thinking Skills${NC}"
    start_manifest "9-thinking-skills"
    install_skills_category "thinking" "Thinking Skills"
}

print_summary() {
    echo ""
    echo -e "${BLUE}=== Final Counts ===${NC}"
    local skills=$(find "$CLAUDE_DIR/skills" -maxdepth 1 -type d 2>/dev/null | tail -n +2 | wc -l | tr -d ' ')
    local agents=$(find "$CLAUDE_DIR/agents" -maxdepth 1 -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
    local commands=$(find "$CLAUDE_DIR/commands" -maxdepth 1 -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
    local rules=$(find "$CLAUDE_DIR/rules" -name "*.md" -not -name "README.md" 2>/dev/null | wc -l | tr -d ' ')

    echo "  Skills:   $skills"
    echo "  Agents:   $agents"
    echo "  Commands: $commands"
    echo "  Rules:    $rules"
    echo ""
    echo -e "  Manifests saved to: ${BLUE}~/.claude/.power-pack/${NC}"
    echo -e "  To rollback: ${YELLOW}bash uninstall.sh --module 4${NC}  or  ${YELLOW}bash uninstall.sh --all${NC}"
    echo ""
    echo -e "${GREEN}Done! Restart Claude Code for changes to take effect.${NC}"
}

# --- Main ---

print_header
init_manifest

if [ "${1:-}" = "--list" ]; then
    list_modules
    exit 0
fi

if [ "${1:-}" = "--status" ]; then
    show_status
    exit 0
fi

if [ "${1:-}" = "--module" ]; then
    shift
    for mod in "$@"; do
        case "$mod" in
            0) install_core_setup ;;
            1) install_rules ;;
            2) install_agents ;;
            3) install_commands ;;
            4) install_dev_skills ;;
            5) install_security_skills ;;
            6) install_devops_skills ;;
            7) install_gtm_skills ;;
            8) install_marketing_skills ;;
            9) install_thinking_skills ;;
            *) echo "Unknown module: $mod" ;;
        esac
    done
    print_summary
    exit 0
fi

# Install everything
install_core_setup
install_rules
install_agents
install_commands
install_dev_skills
install_security_skills
install_devops_skills
install_gtm_skills
install_marketing_skills
install_thinking_skills
print_summary
