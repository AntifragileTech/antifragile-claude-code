#!/usr/bin/env bash
# Antifragile Claude Code — Dependency Installer
# Installs: Homebrew, gh CLI, jq, git, python3, node, uv
# Optional (opt-in): code-review-graph
# macOS only. Zsh/Bash only.
# Created: 07:24 19-Apr-2026

set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

YES="${YES:-0}"
DRYRUN="${DRYRUN:-0}"

say() { echo -e "${BLUE}[deps]${NC} $*"; }
ok()  { echo -e "  ${GREEN}✓${NC} $*"; }
warn(){ echo -e "  ${YELLOW}⚠${NC} $*"; }
err() { echo -e "  ${RED}✗${NC} $*"; }

run() {
  if [ "$DRYRUN" = "1" ]; then
    echo "  [DRY-RUN] $*"
  else
    "$@"
  fi
}

confirm() {
  local prompt="$1"
  local default="${2:-Y}"
  if [ "$YES" = "1" ]; then return 0; fi
  local yn
  read -r -p "  $prompt [${default}/n]: " yn || true
  yn="${yn:-$default}"
  [[ "$yn" =~ ^[Yy] ]]
}

# --- OS check ---
OS="$(uname -s)"
case "$OS" in
  Darwin)
    ok "macOS detected — proceeding with Homebrew-based install"
    ;;
  Linux)
    warn "Linux detected. This installer uses Homebrew (macOS)."
    warn "On Linux, install these manually with your package manager:"
    warn "  Ubuntu/Debian: sudo apt install git gh jq python3 nodejs && curl -LsSf https://astral.sh/uv/install.sh | sh"
    warn "  Fedora/RHEL:   sudo dnf install git gh jq python3 nodejs && curl -LsSf https://astral.sh/uv/install.sh | sh"
    warn "Then re-run: bash scripts/bootstrap.sh --skip-deps"
    exit 0
    ;;
  MINGW*|MSYS*|CYGWIN*)
    warn "Windows (Git Bash/Cygwin) detected."
    warn "This installer targets macOS Homebrew. On Windows you have two options:"
    warn "  1. WSL2 (recommended): install Ubuntu, then run this installer inside WSL"
    warn "  2. Install deps via winget or scoop:"
    warn "     winget install Git.Git GitHub.cli jqlang.jq Python.Python.3 OpenJS.NodeJS astral-sh.uv"
    warn "Then re-run: bash scripts/bootstrap.sh --skip-deps"
    exit 0
    ;;
  *)
    err "Unsupported OS: $OS — this installer targets macOS."
    err "Install git, gh, jq, python3, node, uv manually, then run: bash scripts/bootstrap.sh --skip-deps"
    exit 1
    ;;
esac

# --- 1. Homebrew ---
say "Checking Homebrew..."
if ! command -v brew >/dev/null 2>&1; then
  warn "Homebrew not installed."
  if confirm "Install Homebrew?"; then
    run /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # Add brew to PATH for this session (Apple Silicon default path)
    if [ -d "/opt/homebrew/bin" ]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [ -d "/usr/local/bin/brew" ]; then
      eval "$(/usr/local/bin/brew shellenv)"
    fi
  else
    err "Cannot proceed without Homebrew."
    exit 1
  fi
else
  ok "Homebrew present ($(brew --version | head -1))"
fi

# --- 2. Core CLIs via brew ---
install_brew_if_missing() {
  local pkg="$1"
  local bin="${2:-$1}"
  if command -v "$bin" >/dev/null 2>&1; then
    ok "$pkg present"
  else
    say "Installing $pkg..."
    run brew install "$pkg"
    ok "$pkg installed"
  fi
}

install_brew_if_missing git
install_brew_if_missing gh
install_brew_if_missing jq
install_brew_if_missing python@3.12 python3
install_brew_if_missing node

# --- 3. gh auth ---
if command -v gh >/dev/null 2>&1; then
  if gh auth status >/dev/null 2>&1; then
    ok "gh CLI authenticated"
  else
    warn "gh CLI not authenticated"
    if confirm "Run 'gh auth login' now?"; then
      run gh auth login
    else
      warn "Skipping gh auth — run 'gh auth login' later"
    fi
  fi
fi

# --- 4. uv (Python tool installer) ---
if ! command -v uv >/dev/null 2>&1; then
  say "Installing uv..."
  run brew install uv
  ok "uv installed"
else
  ok "uv present"
fi

# --- 5. code-review-graph (optional, on-demand only) ---
# Do not auto-install; /save invokes it on a per-project basis.
# Available via: uv tool install code-review-graph
if command -v code-review-graph >/dev/null 2>&1; then
  ok "code-review-graph present (optional)"
else
  warn "code-review-graph not installed (optional — install with 'uv tool install code-review-graph' when needed by /save)"
fi

# --- 6. Claude Code (check only — install is separate) ---
if command -v claude >/dev/null 2>&1; then
  ok "Claude Code CLI present"
else
  warn "Claude Code CLI not detected. Install from https://claude.com/claude-code"
fi

say "Dependency install complete."
