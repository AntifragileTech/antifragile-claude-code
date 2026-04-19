#!/usr/bin/env bash
#
# ╔═══════════════════════════════════════════════════════════════════╗
# ║  SAFETY CONTRACT — read before running on a machine with content  ║
# ╠═══════════════════════════════════════════════════════════════════╣
# ║  This script will NEVER:                                          ║
# ║   • Overwrite any file the user has customized locally            ║
# ║   • Delete any existing skill, agent, command, or rule            ║
# ║   • Replace an existing ~/bin script (even if content differs)    ║
# ║   • Touch memory files, handoff docs, NOTES.md, or project data   ║
# ║   • Remove any CLAUDE.md section or modify existing sections      ║
# ║   • Replace existing hook handlers in settings.json               ║
# ║                                                                   ║
# ║  This script WILL:                                                ║
# ║   • Add NEW skills/agents/commands/rules not already installed    ║
# ║   • Append MISSING CLAUDE.md sections (header match, no overlap)  ║
# ║   • Add NEW hook event types to settings.json                     ║
# ║   • Add NEW permissions.allow entries (never remove any)          ║
# ║   • Append PATH line to ~/.zshrc if ~/bin not in PATH             ║
# ║   • Install NEW bin scripts to ~/bin/ only if missing             ║
# ║                                                                   ║
# ║  Backups: CLAUDE.md gets timestamped backup before ANY write      ║
# ╚═══════════════════════════════════════════════════════════════════╝
#
# Antifragile Claude Code — Bootstrap Orchestrator
# Runs the full install pipeline in order:
#   1. install-deps.sh     — brew, gh, jq, node, python, uv
#   2. install.sh (root)   — skills, agents, commands, rules, bin scripts
#   3. merge-claude-md.sh  — smart CLAUDE.md section merge
#   4. PATH + hooks        — shell rc + settings.json
#   5. verify-install.sh   — /doctor-style validation
#
# Usage:
#   bash scripts/bootstrap.sh                  # interactive
#   bash scripts/bootstrap.sh --yes            # non-interactive
#   bash scripts/bootstrap.sh --dry-run        # show actions without executing
#   bash scripts/bootstrap.sh --skip-deps      # skip brew/gh install
#   bash scripts/bootstrap.sh --skip-verify    # skip final verification
# Created: 07:24 19-Apr-2026

set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
export REPO_ROOT

# Flags
YES=0
DRYRUN=0
SKIP_DEPS=0
SKIP_VERIFY=0

for arg in "$@"; do
  case "$arg" in
    --yes|-y)        YES=1 ;;
    --dry-run)       DRYRUN=1 ;;
    --skip-deps)     SKIP_DEPS=1 ;;
    --skip-verify)   SKIP_VERIFY=1 ;;
    --help|-h)
      head -20 "$0" | grep '^#' | sed 's/^# *//'
      exit 0
      ;;
  esac
done
export YES DRYRUN

# OS check
if [ "$(uname -s)" != "Darwin" ]; then
  echo -e "${RED}This installer is macOS-only.${NC}"
  exit 1
fi

echo ""
echo -e "${BLUE}╔═══════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Antifragile Claude Code — Bootstrap              ║${NC}"
echo -e "${BLUE}╠═══════════════════════════════════════════════════╣${NC}"
echo -e "${BLUE}║  Host: $(hostname -s)$(printf '%*s' $((43 - ${#HOSTNAME})) '')║${NC}"
echo -e "${BLUE}║  Date: $(date '+%Y-%m-%d %H:%M:%S')                     ║${NC}"
echo -e "${BLUE}║  Mode: $([ "$YES" = 1 ] && echo "non-interactive" || echo "interactive")$([ "$DRYRUN" = 1 ] && echo " + DRY-RUN")                   ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════╝${NC}"
echo ""

# Phase 1 — deps
if [ "$SKIP_DEPS" = "0" ]; then
  echo -e "${YELLOW}▶ Phase 1: External dependencies${NC}"
  bash "$SCRIPT_DIR/install-deps.sh"
  echo ""
else
  echo -e "${YELLOW}⏭  Skipping dependency install${NC}"
fi

# Phase 2 — skills/agents/commands/rules/bin (use existing modular install.sh)
# IMPORTANT: pass --skip-deps and --skip-verify because bootstrap.sh runs
# install-deps.sh (Phase 1) and verify-install.sh (Phase 5) itself. Without
# these flags, install.sh would re-run them, causing duplicate work and
# multiple CLAUDE.md backup files.
echo -e "${YELLOW}▶ Phase 2: Skills, agents, commands, rules, bin scripts${NC}"
if [ "$DRYRUN" = "1" ]; then
  echo "  [DRY-RUN] would run: bash $REPO_ROOT/install.sh --skip-deps --skip-merge --skip-verify"
else
  bash "$REPO_ROOT/install.sh" --skip-deps --skip-merge --skip-verify < /dev/null || echo -e "  ${YELLOW}(install.sh returned non-zero — continuing)${NC}"
fi
echo ""

# Phase 3 — CLAUDE.md smart merge
echo -e "${YELLOW}▶ Phase 3: CLAUDE.md smart merge${NC}"
bash "$SCRIPT_DIR/merge-claude-md.sh"
echo ""

# Phase 4 — PATH + hooks
echo -e "${YELLOW}▶ Phase 4: PATH + hooks + bin scripts${NC}"

# ~/bin in PATH
ensure_path_line() {
  local rc="$1"
  [ -f "$rc" ] || return 0
  if ! grep -q 'HOME/bin' "$rc" 2>/dev/null; then
    if [ "$DRYRUN" = "1" ]; then
      echo "  [DRY-RUN] would append PATH line to $rc"
    else
      echo '' >> "$rc"
      echo '# Added by antifragile-claude-code bootstrap on '"$(date '+%Y-%m-%d')" >> "$rc"
      echo 'export PATH="$HOME/bin:$PATH"' >> "$rc"
      echo -e "  ${GREEN}✓${NC} PATH added to $rc (restart terminal to apply)"
    fi
  else
    echo -e "  ${GREEN}✓${NC} PATH already set in $rc"
  fi
}
ensure_path_line "$HOME/.zshrc"
ensure_path_line "$HOME/.bashrc"

# Copy bin scripts — ADDITIVE ONLY
# If the user has customized a bin script locally, we NEVER overwrite it.
# Only install scripts that don't exist yet.
if [ -d "$REPO_ROOT/assets/bin" ]; then
  mkdir -p "$HOME/bin"
  for script in "$REPO_ROOT/assets/bin"/*; do
    [ -f "$script" ] || continue
    name=$(basename "$script")
    dst="$HOME/bin/$name"
    if [ -f "$dst" ]; then
      # User has their own version — NEVER overwrite
      if ! cmp -s "$script" "$dst"; then
        echo -e "  ${YELLOW}⊘${NC} $name exists and differs — keeping YOUR version"
      else
        echo -e "  ${GREEN}=${NC} $name already present (identical)"
      fi
    else
      if [ "$DRYRUN" = "1" ]; then
        echo "  [DRY-RUN] would install new $name"
      else
        cp "$script" "$dst"
        chmod +x "$dst"
        echo -e "  ${GREEN}+${NC} $name installed (new)"
      fi
    fi
  done
fi

# claude-hooks.sh — same additive rule
if [ -f "$REPO_ROOT/assets/claude-hooks.sh" ]; then
  dst="$HOME/bin/claude-hooks.sh"
  if [ -f "$dst" ]; then
    if ! cmp -s "$REPO_ROOT/assets/claude-hooks.sh" "$dst"; then
      echo -e "  ${YELLOW}⊘${NC} claude-hooks.sh exists and differs — keeping YOUR version"
    fi
  else
    if [ "$DRYRUN" = "1" ]; then
      echo "  [DRY-RUN] would install new claude-hooks.sh"
    else
      cp "$REPO_ROOT/assets/claude-hooks.sh" "$dst"
      chmod +x "$dst"
      echo -e "  ${GREEN}+${NC} claude-hooks.sh installed (new)"
    fi
  fi
fi

# Merge hooks from settings.json.template
TEMPLATE="$REPO_ROOT/assets/settings.json.template"
SETTINGS="$HOME/.claude/settings.json"
if [ -f "$TEMPLATE" ]; then
  if [ "$DRYRUN" = "1" ]; then
    echo "  [DRY-RUN] would merge hooks from settings.json.template"
  else
    python3 - "$TEMPLATE" "$SETTINGS" << 'PYEOF'
import json, sys
from pathlib import Path

tmpl_path, dst_path = sys.argv[1], sys.argv[2]
tmpl = json.loads(Path(tmpl_path).read_text())
if Path(dst_path).exists():
    dst = json.loads(Path(dst_path).read_text())
else:
    dst = {}

changed = False
# Merge hooks: add any event types missing locally
if "hooks" in tmpl:
    dst.setdefault("hooks", {})
    for event, handlers in tmpl["hooks"].items():
        if event not in dst["hooks"]:
            dst["hooks"][event] = handlers
            changed = True
            print(f"  + hooks.{event} added")

# Merge permissions.allow additively
if "permissions" in tmpl and "allow" in tmpl.get("permissions", {}):
    dst.setdefault("permissions", {}).setdefault("allow", [])
    existing = set(dst["permissions"]["allow"])
    for perm in tmpl["permissions"]["allow"]:
        if perm not in existing:
            dst["permissions"]["allow"].append(perm)
            existing.add(perm)
            changed = True

if changed:
    Path(dst_path).parent.mkdir(parents=True, exist_ok=True)
    Path(dst_path).write_text(json.dumps(dst, indent=2))
    print("  settings.json updated")
else:
    print("  settings.json — already has all template hooks/permissions")
PYEOF
  fi
fi

echo ""

# Phase 5 — verify
if [ "$SKIP_VERIFY" = "0" ]; then
  echo -e "${YELLOW}▶ Phase 5: Verification${NC}"
  bash "$SCRIPT_DIR/verify-install.sh" || true
else
  echo -e "${YELLOW}⏭  Skipping verification${NC}"
fi

echo ""
echo -e "${GREEN}✅ Bootstrap complete.${NC}"
echo ""
echo "Next steps:"
echo "  1. Restart your terminal (for PATH changes to take effect)"
echo "  2. Restart Claude Code (to pick up new hooks/skills/commands)"
echo "  3. If gh was installed but not authed: gh auth login"
