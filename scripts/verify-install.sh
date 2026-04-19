#!/usr/bin/env bash
# Antifragile Claude Code — Install Verifier
# Runs the same checks as /doctor. Exits 0 on success, 1 on any critical failure.
# Created: 07:24 19-Apr-2026

set -uo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

PASS=0
FAIL=0
WARN=0

check_pass() { echo -e "  ${GREEN}✓${NC} $*"; PASS=$((PASS+1)); }
check_fail() { echo -e "  ${RED}✗${NC} $*"; FAIL=$((FAIL+1)); }
check_warn() { echo -e "  ${YELLOW}⚠${NC} $*"; WARN=$((WARN+1)); }
section()    { echo -e "\n${BLUE}== $* ==${NC}"; }

section "Machine"
echo "  Host: $(hostname -s) | OS: $(uname -s) $(uname -r) | User: $(whoami)"

section "PATH"
if echo "$PATH" | tr ':' '\n' | grep -q "^$HOME/bin$"; then
  check_pass "~/bin in PATH"
else
  check_fail "~/bin NOT in PATH — add 'export PATH=\"\$HOME/bin:\$PATH\"' to ~/.zshrc"
fi

section "Bin scripts"
for s in context-status.sh claude-hooks.sh; do
  p="$HOME/bin/$s"
  if [ -f "$p" ] && [ -x "$p" ]; then
    check_pass "$s (executable)"
  elif [ -f "$p" ]; then
    check_warn "$s exists but not executable — chmod +x $p"
  else
    check_fail "$s MISSING"
  fi
done

section "context-status.sh functional test"
if [ -x "$HOME/bin/context-status.sh" ]; then
  OUT=$("$HOME/bin/context-status.sh" 2>&1 || true)
  if echo "$OUT" | grep -qE "~[0-9]+K/[0-9]+"; then
    check_pass "output: $OUT"
  else
    check_warn "runs but format unexpected: $OUT"
  fi
else
  check_fail "not executable or missing"
fi

section "CLAUDE.md sections"
CMD="$HOME/.claude/CLAUDE.md"
if [ -f "$CMD" ]; then
  echo "  File: $(wc -l < "$CMD" | tr -d ' ') lines"
  for sec in \
      "Response Timestamps" \
      "Skill Auto-Discovery" \
      "File Lifecycle Timestamps" \
      "Large File Handling Rules" \
      "Large File Generation Rules" \
      "Project Notes File" \
      "Session Continuation Prompt" \
      "Sub-Agent / Parallel Task Rules" \
      "Agent Swarm Monitoring"; do
    if grep -q "$sec" "$CMD"; then
      check_pass "$sec"
    else
      check_fail "$sec MISSING — run scripts/merge-claude-md.sh"
    fi
  done
else
  check_fail "~/.claude/CLAUDE.md MISSING"
fi

section "settings.json hooks"
S="$HOME/.claude/settings.json"
if [ -f "$S" ]; then
  if grep -q '"hooks"' "$S"; then
    HOOKS=$(grep -oE '"(PreToolUse|PostToolUse|Stop|SessionStart|UserPromptSubmit)"' "$S" | sort -u | wc -l | tr -d ' ')
    check_pass "hooks configured ($HOOKS event type(s))"
  else
    check_warn "no hooks key in settings.json"
  fi
else
  check_warn "settings.json missing (optional)"
fi

section "Inventory"
SKILLS=$(ls -1 "$HOME/.claude/skills" 2>/dev/null | wc -l | tr -d ' ')
AGENTS=$(ls -1 "$HOME/.claude/agents" 2>/dev/null | wc -l | tr -d ' ')
COMMANDS=$(ls -1 "$HOME/.claude/commands" 2>/dev/null | wc -l | tr -d ' ')
RULES=$(find "$HOME/.claude/rules" -type f -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
echo "  Skills:   $SKILLS"
echo "  Agents:   $AGENTS"
echo "  Commands: $COMMANDS"
echo "  Rules:    $RULES files"
[ "$SKILLS"   -ge 100 ] && check_pass "skill count ok"    || check_warn "skill count low (expected 500+)"
[ "$AGENTS"   -ge 10  ] && check_pass "agent count ok"    || check_warn "agent count low (expected 60+)"
[ "$COMMANDS" -ge 20  ] && check_pass "command count ok"  || check_warn "command count low (expected 90+)"

section "External CLIs"
for tool in gh jq git node python3 uv brew; do
  if command -v "$tool" >/dev/null 2>&1; then
    check_pass "$tool present"
  else
    check_fail "$tool NOT installed — run scripts/install-deps.sh"
  fi
done
# code-review-graph is optional
if command -v code-review-graph >/dev/null 2>&1; then
  check_pass "code-review-graph present (optional)"
else
  check_warn "code-review-graph not installed (optional — installed on-demand via /save)"
fi

section "GitHub auth"
if command -v gh >/dev/null 2>&1; then
  if gh auth status >/dev/null 2>&1; then
    check_pass "gh authenticated"
  else
    check_warn "gh not authenticated — run: gh auth login"
  fi
fi

section "Summary"
TOTAL=$((PASS+FAIL+WARN))
echo -e "  ${GREEN}PASS${NC}: $PASS  |  ${RED}FAIL${NC}: $FAIL  |  ${YELLOW}WARN${NC}: $WARN  (of $TOTAL)"

if [ "$FAIL" -gt 0 ]; then
  echo -e "\n${RED}❌ $FAIL critical check(s) failed — review above.${NC}"
  exit 1
else
  echo -e "\n${GREEN}✅ Install verified. You're good to go.${NC}"
  exit 0
fi
