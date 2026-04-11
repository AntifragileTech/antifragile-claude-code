#!/bin/bash
# claude-export.sh — Export entire Claude Code setup for migration to another machine
# Usage: claude-export.sh [output-dir]

set -e

OUTPUT_DIR="${1:-$HOME/claude-migration}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BUNDLE="$OUTPUT_DIR/claude-setup-$TIMESTAMP"

echo "=== Claude Code Setup Export ==="
echo "Exporting to: $BUNDLE"
echo ""

mkdir -p "$BUNDLE/claude-config"
mkdir -p "$BUNDLE/bin"
mkdir -p "$BUNDLE/templates"
mkdir -p "$BUNDLE/shell"

# 1. Claude Code config files
echo "[1/6] Exporting Claude Code config..."
[ -f "$HOME/.claude/settings.json" ] && cp "$HOME/.claude/settings.json" "$BUNDLE/claude-config/"
[ -f "$HOME/.claude/CLAUDE.md" ] && cp "$HOME/.claude/CLAUDE.md" "$BUNDLE/claude-config/"
[ -f "$HOME/.claude/keybindings.json" ] && cp "$HOME/.claude/keybindings.json" "$BUNDLE/claude-config/"

# 2. Global CLAUDE.md (home directory)
echo "[2/6] Exporting global CLAUDE.md..."
[ -f "$HOME/CLAUDE.md" ] && cp "$HOME/CLAUDE.md" "$BUNDLE/claude-config/GLOBAL_CLAUDE.md"

# 3. Scripts
echo "[3/6] Exporting scripts..."
cp -r "$HOME/bin/"* "$BUNDLE/bin/" 2>/dev/null || echo "  No scripts in ~/bin"

# 4. Templates
echo "[4/6] Exporting templates..."
cp -r "$HOME/templates/"* "$BUNDLE/templates/" 2>/dev/null || echo "  No templates"

# 5. Shell config (extract only Claude-related additions)
echo "[5/6] Exporting shell config..."
cp "$HOME/.zshrc" "$BUNDLE/shell/zshrc-full-backup"
# Extract Claude-specific lines
sed -n '/# Shell history/,$ p' "$HOME/.zshrc" > "$BUNDLE/shell/zshrc-claude-additions"

# 6. List of installed plugins (for reference)
echo "[6/6] Documenting plugins..."
if [ -f "$HOME/.claude/settings.json" ]; then
  python3 -c "
import json
with open('$HOME/.claude/settings.json') as f:
    d = json.load(f)
plugins = d.get('enabledPlugins', {})
print('Enabled Plugins:')
for p, v in plugins.items():
    if v:
        print(f'  - {p}')
" > "$BUNDLE/claude-config/plugins-list.txt"
fi

# Create install script inside the bundle
cat > "$BUNDLE/install.sh" << 'INSTALL_EOF'
#!/bin/bash
# install.sh — Install Claude Code setup on a new machine
# Usage: ./install.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== Claude Code Setup Install ==="
echo "Source: $SCRIPT_DIR"
echo ""

# Pre-checks
if ! command -v claude &>/dev/null; then
  echo "WARNING: Claude Code CLI not found. Install it first:"
  echo "  npm install -g @anthropic-ai/claude-code"
  echo ""
  read -p "Continue anyway? (y/n) " -n 1 -r
  echo
  [[ ! $REPLY =~ ^[Yy]$ ]] && exit 1
fi

# 1. Claude Code config
echo "[1/6] Installing Claude Code config..."
mkdir -p "$HOME/.claude"
for f in settings.json CLAUDE.md keybindings.json; do
  if [ -f "$SCRIPT_DIR/claude-config/$f" ]; then
    if [ -f "$HOME/.claude/$f" ]; then
      echo "  ~/.claude/$f exists — backing up to ~/.claude/$f.bak"
      cp "$HOME/.claude/$f" "$HOME/.claude/$f.bak"
    fi
    cp "$SCRIPT_DIR/claude-config/$f" "$HOME/.claude/$f"
    echo "  Installed ~/.claude/$f"
  fi
done

# 2. Global CLAUDE.md
if [ -f "$SCRIPT_DIR/claude-config/GLOBAL_CLAUDE.md" ]; then
  echo "[2/6] Installing global CLAUDE.md..."
  if [ -f "$HOME/CLAUDE.md" ]; then
    echo "  ~/CLAUDE.md exists — backing up to ~/CLAUDE.md.bak"
    cp "$HOME/CLAUDE.md" "$HOME/CLAUDE.md.bak"
  fi
  cp "$SCRIPT_DIR/claude-config/GLOBAL_CLAUDE.md" "$HOME/CLAUDE.md"
  echo "  Installed ~/CLAUDE.md"
else
  echo "[2/6] No global CLAUDE.md to install — skipping"
fi

# 3. Scripts
echo "[3/6] Installing scripts..."
mkdir -p "$HOME/bin"
if ls "$SCRIPT_DIR/bin/"* &>/dev/null; then
  cp "$SCRIPT_DIR/bin/"* "$HOME/bin/"
  chmod +x "$HOME/bin/"*
  echo "  Installed scripts to ~/bin/"
else
  echo "  No scripts to install"
fi

# 4. Templates
echo "[4/6] Installing templates..."
mkdir -p "$HOME/templates"
if ls "$SCRIPT_DIR/templates/"* &>/dev/null; then
  cp "$SCRIPT_DIR/templates/"* "$HOME/templates/"
  echo "  Installed templates to ~/templates/"
else
  echo "  No templates to install"
fi

# 5. Shell config
echo "[5/6] Installing shell config..."
if [ -f "$SCRIPT_DIR/shell/zshrc-claude-additions" ]; then
  # Check if already added
  if grep -q "# Shell history" "$HOME/.zshrc" 2>/dev/null; then
    echo "  Claude additions already in .zshrc — skipping"
  else
    echo "" >> "$HOME/.zshrc"
    cat "$SCRIPT_DIR/shell/zshrc-claude-additions" >> "$HOME/.zshrc"
    echo "  Appended Claude config to ~/.zshrc"
  fi
else
  echo "  No shell additions to install"
fi

# 6. Plugins reminder
echo "[6/6] Plugin setup..."
if [ -f "$SCRIPT_DIR/claude-config/plugins-list.txt" ]; then
  echo ""
  echo "  The following plugins were enabled on the source machine:"
  cat "$SCRIPT_DIR/claude-config/plugins-list.txt"
  echo ""
  echo "  To install plugins, run: claude /plugins"
fi

echo ""
echo "=== Installation Complete ==="
echo ""
echo "Next steps:"
echo "  1. Run: source ~/.zshrc"
echo "  2. Run: claude   (to verify it works)"
echo "  3. Install plugins listed above if needed"
echo "  4. Install tmux: brew install tmux"
echo "  5. Install Homebrew if not present: https://brew.sh"
INSTALL_EOF

chmod +x "$BUNDLE/install.sh"

# Create a README
cat > "$BUNDLE/README.md" << 'README_EOF'
# Claude Code Migration Bundle

## What's included
- `claude-config/` — settings.json, CLAUDE.md, keybindings.json
- `bin/` — shell scripts (claude-parallel.sh, claude-init.sh, claude-export.sh)
- `templates/` — CLAUDE.md project template
- `shell/` — zshrc additions (aliases, history, PATH, ccstart function)
- `install.sh` — one-command installer for the new machine

## How to use on your new machine

1. Copy this entire folder to the new machine (USB, AirDrop, cloud drive, etc.)
2. Open Terminal on the new machine
3. Run:
   ```bash
   cd /path/to/claude-setup-TIMESTAMP
   ./install.sh
   source ~/.zshrc
   ```

## Prerequisites on new machine
- Homebrew: https://brew.sh
- Node.js: `brew install node`
- Claude Code: `npm install -g @anthropic-ai/claude-code`
- tmux: `brew install tmux`
README_EOF

# Create tar archive
echo ""
echo "Creating archive..."
cd "$OUTPUT_DIR"
tar -czf "claude-setup-$TIMESTAMP.tar.gz" "claude-setup-$TIMESTAMP"

echo ""
echo "=== Export Complete ==="
echo ""
echo "Bundle: $BUNDLE/"
echo "Archive: $OUTPUT_DIR/claude-setup-$TIMESTAMP.tar.gz"
echo ""
echo "Transfer the .tar.gz to your new machine, then run:"
echo "  tar -xzf claude-setup-$TIMESTAMP.tar.gz"
echo "  cd claude-setup-$TIMESTAMP"
echo "  ./install.sh"
