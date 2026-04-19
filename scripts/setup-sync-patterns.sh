#!/usr/bin/env bash
#
# ╔═══════════════════════════════════════════════════════════════════╗
# ║  SETUP — Per-user /sync-push scan patterns                        ║
# ╠═══════════════════════════════════════════════════════════════════╣
# ║  Interactive helper that generates ~/.claude/.sync-scan-patterns  ║
# ║  with YOUR usernames, domains, clients, and hostname prefix.      ║
# ║                                                                   ║
# ║  This file is local-only — NEVER synced to the repo.              ║
# ║  Each team member generates their own.                            ║
# ╚═══════════════════════════════════════════════════════════════════╝
#
# Created: 07:36 19-Apr-2026

set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TEMPLATE="$REPO_ROOT/assets/sync-scan-patterns.template"
DST="$HOME/.claude/.sync-scan-patterns"

echo -e "${BLUE}== Per-user /sync-push scan patterns setup ==${NC}"
echo ""

if [ -f "$DST" ]; then
  echo -e "${YELLOW}⚠  $DST already exists.${NC}"
  read -r -p "Overwrite? [y/N]: " yn
  [[ "$yn" =~ ^[Yy] ]] || { echo "Aborted."; exit 0; }
fi

mkdir -p "$HOME/.claude"

echo "Enter values to protect. Leave blank to skip any category."
echo "Use pipe (|) to separate multiple values."
echo ""

read -r -p "Your personal usernames (e.g. alice\.smith|asmith): " usernames
read -r -p "Your real domains (e.g. acme\.com|widgets-corp): " domains
read -r -p "Client project codewords (e.g. PROJECT-X|BigClient): " clients
read -r -p "Your personal emails (e.g. alice@gmail\.com): " emails
HOST_RAW="$(hostname -s)"
echo "  Your hostname: $HOST_RAW"
read -r -p "Hostname prefix to strip (e.g. 'Alices-' from 'Alices-MacBook-Pro'): " hostname_prefix

# Load template for GENERIC_SECRETS line
GENERIC_SECRETS=""
if [ -f "$TEMPLATE" ]; then
  GENERIC_SECRETS=$(grep '^GENERIC_SECRETS=' "$TEMPLATE" | head -1)
fi

cat > "$DST" << EOF
# Antifragile Claude Code — Personal sync-scan patterns
# Generated: $(date '+%Y-%m-%d %H:%M:%S')
# Host: $HOST_RAW  |  User: $(whoami)
# This file is local-only. NEVER synced to the repo.

USERNAMES="$usernames"
DOMAINS="$domains"
CLIENTS="$clients"
EMAILS="$emails"
HOSTNAME_PREFIX="$hostname_prefix"
${GENERIC_SECRETS:-GENERIC_SECRETS="sk_live_|ghp_[a-zA-Z0-9]{36}|-----BEGIN.*PRIVATE KEY-----"}
EOF

chmod 600 "$DST"  # protect — contains potentially sensitive patterns

echo ""
echo -e "${GREEN}✓${NC} Wrote $DST"
echo ""
echo "From now on, /sync-push will scan for YOUR personal data before pushing."
echo "Re-run this script any time to update patterns."
