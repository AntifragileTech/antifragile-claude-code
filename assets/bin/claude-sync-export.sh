#!/bin/bash
# Claude Code Config Export
# Creates a portable bundle of all Claude Code customizations
# Run on SOURCE device, then transfer bundle to TARGET device

set -e

EXPORT_DIR="/tmp/claude-sync-bundle"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
BUNDLE_NAME="claude-config-$TIMESTAMP.tar.gz"

echo "=== Claude Code Config Export ==="
echo ""

rm -rf "$EXPORT_DIR"
mkdir -p "$EXPORT_DIR"/{skills,bin,memory}

# 1. CLAUDE.md files
echo "[1/6] Exporting CLAUDE.md files..."
[ -f "$HOME/CLAUDE.md" ] && cp "$HOME/CLAUDE.md" "$EXPORT_DIR/project-CLAUDE.md"
[ -f "$HOME/.claude/CLAUDE.md" ] && cp "$HOME/.claude/CLAUDE.md" "$EXPORT_DIR/global-CLAUDE.md"

# 2. Settings
echo "[2/6] Exporting settings.json..."
[ -f "$HOME/.claude/settings.json" ] && cp "$HOME/.claude/settings.json" "$EXPORT_DIR/settings.json"

# 3. Skills
echo "[3/6] Exporting custom skills..."
if [ -d "$HOME/.claude/skills" ]; then
  cp -r "$HOME/.claude/skills/"* "$EXPORT_DIR/skills/" 2>/dev/null || true
  SKILL_COUNT=$(find "$EXPORT_DIR/skills" -name "SKILL.md" | wc -l | tr -d ' ')
  echo "       Found $SKILL_COUNT skills"
fi

# 4. Hook scripts
echo "[4/6] Exporting hook scripts..."
[ -f "$HOME/bin/claude-hooks.sh" ] && cp "$HOME/bin/claude-hooks.sh" "$EXPORT_DIR/bin/"
[ -f "$HOME/bin/deploy-and-check.sh" ] && cp "$HOME/bin/deploy-and-check.sh" "$EXPORT_DIR/bin/"

# 5. Auto memory
echo "[5/6] Exporting auto memory files..."
find "$HOME/.claude/projects" -path "*/memory/*" -name "*.md" -exec cp {} "$EXPORT_DIR/memory/" \; 2>/dev/null || true
MEM_COUNT=$(find "$EXPORT_DIR/memory" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
echo "       Found $MEM_COUNT memory files"

# 6. Create manifest
echo "[6/6] Creating manifest..."
cat > "$EXPORT_DIR/MANIFEST.md" << 'MANIFEST'
# Claude Code Config Bundle

## Contents
- `project-CLAUDE.md` → Install to `~/CLAUDE.md`
- `global-CLAUDE.md` → Install to `~/.claude/CLAUDE.md`
- `settings.json` → Install to `~/.claude/settings.json`
- `skills/` → Install to `~/.claude/skills/`
- `bin/` → Install to `~/bin/`
- `memory/` → Install to `~/.claude/projects/<project>/memory/`

## Install on target device
Run: bash claude-sync-import.sh
MANIFEST

# Create import script inside the bundle
cat > "$EXPORT_DIR/claude-sync-import.sh" << 'IMPORT'
#!/bin/bash
set -e
echo "=== Claude Code Config Import ==="
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "[1/5] Installing CLAUDE.md files..."
[ -f "$SCRIPT_DIR/project-CLAUDE.md" ] && cp "$SCRIPT_DIR/project-CLAUDE.md" "$HOME/CLAUDE.md" && echo "       → ~/CLAUDE.md"
[ -f "$SCRIPT_DIR/global-CLAUDE.md" ] && mkdir -p "$HOME/.claude" && cp "$SCRIPT_DIR/global-CLAUDE.md" "$HOME/.claude/CLAUDE.md" && echo "       → ~/.claude/CLAUDE.md"

echo "[2/5] Installing settings.json..."
if [ -f "$SCRIPT_DIR/settings.json" ]; then
  mkdir -p "$HOME/.claude"
  cp "$SCRIPT_DIR/settings.json" "$HOME/.claude/settings.json"
  echo "       → ~/.claude/settings.json"
fi

echo "[3/5] Installing skills..."
if [ -d "$SCRIPT_DIR/skills" ]; then
  mkdir -p "$HOME/.claude/skills"
  cp -r "$SCRIPT_DIR/skills/"* "$HOME/.claude/skills/"
  SKILL_COUNT=$(find "$HOME/.claude/skills" -name "SKILL.md" | wc -l | tr -d ' ')
  echo "       → $SKILL_COUNT skills installed"
fi

echo "[4/5] Installing hook scripts..."
mkdir -p "$HOME/bin"
if [ -d "$SCRIPT_DIR/bin" ]; then
  cp "$SCRIPT_DIR/bin/"* "$HOME/bin/" 2>/dev/null || true
  chmod +x "$HOME/bin/"*.sh 2>/dev/null || true
  echo "       → ~/bin/"
fi

echo "[5/5] Installing memory files..."
if [ -d "$SCRIPT_DIR/memory" ] && [ "$(ls -A "$SCRIPT_DIR/memory" 2>/dev/null)" ]; then
  TARGET_MEM="$HOME/.claude/projects/-Users-$(whoami)/memory"
  mkdir -p "$TARGET_MEM"
  cp "$SCRIPT_DIR/memory/"*.md "$TARGET_MEM/" 2>/dev/null || true
  echo "       → $TARGET_MEM/"
fi

echo ""
echo "=== Import complete! ==="
echo "Restart Claude Code to pick up all changes."
IMPORT
chmod +x "$EXPORT_DIR/claude-sync-import.sh"

# Package it
cd /tmp
tar czf "$BUNDLE_NAME" -C "$EXPORT_DIR" .
FINAL_PATH="/tmp/$BUNDLE_NAME"

echo ""
echo "=== Export complete! ==="
echo "Bundle: $FINAL_PATH"
echo "Size: $(du -h "$FINAL_PATH" | cut -f1)"
echo ""
echo "Transfer to second device and run:"
echo "  mkdir -p /tmp/claude-import && tar xzf $BUNDLE_NAME -C /tmp/claude-import && bash /tmp/claude-import/claude-sync-import.sh"
