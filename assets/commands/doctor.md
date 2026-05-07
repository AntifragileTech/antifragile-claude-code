---
description: "Diagnose and fix Claude Code config on any machine — checks CLAUDE.md rules, bin scripts, PATH, hooks, skills, and sync health"
allowed-tools: Bash, Read, Write, Edit, Grep, Glob
---

<!-- Created: 07:05 19-Apr-2026 -->

# /doctor — Config Diagnostic & Auto-Fix

You are performing a full health check of the user's Claude Code installation. This command is intended to be run on a NEW machine (after install) or after `/sync-pull` to verify everything came through correctly.

## Execute ALL checks below. Report each as ✅ PASS or ❌ FAIL with remediation.

## Step 1: Collect Machine Info

```bash
echo "=== MACHINE INFO ==="
echo "Hostname: $(hostname -s)"
echo "OS: $(uname -s) $(uname -r) ($(uname -m))"
echo "User: $(whoami)"
echo "Shell: $SHELL"
echo "Date: $(date '+%Y-%m-%d %H:%M:%S %Z')"
echo ""
```

## Step 2: PATH Includes `~/bin`

```bash
echo "=== PATH CHECK ==="
if echo "$PATH" | tr ':' '\n' | grep -q "^$HOME/bin$"; then
  echo "✅ ~/bin is in PATH"
else
  echo "❌ ~/bin NOT in PATH"
  echo "   FIX: Add to ~/.zshrc (or ~/.bashrc):"
  echo "        export PATH=\"\$HOME/bin:\$PATH\""
  echo "   Then restart your terminal or run: source ~/.zshrc"
fi
echo ""
```

## Step 3: Bin Scripts Present & Executable

```bash
echo "=== BIN SCRIPTS ==="
REQUIRED_SCRIPTS=(context-status.sh claude-hooks.sh)
for script in "${REQUIRED_SCRIPTS[@]}"; do
  path="$HOME/bin/$script"
  if [ -f "$path" ]; then
    if [ -x "$path" ]; then
      echo "✅ $script (executable)"
    else
      echo "⚠️  $script exists but NOT executable"
      echo "   FIX: chmod +x $path"
    fi
  else
    echo "❌ $script MISSING"
    echo "   FIX: Run /sync-pull, or copy from antifragile-claude-code/assets/bin/"
  fi
done
echo ""
```

## Step 4: context-status.sh Actually Runs

```bash
echo "=== CONTEXT-STATUS.SH FUNCTIONAL TEST ==="
if command -v context-status.sh >/dev/null 2>&1 || [ -x "$HOME/bin/context-status.sh" ]; then
  OUTPUT=$("$HOME/bin/context-status.sh" 2>&1)
  if echo "$OUTPUT" | grep -qE "~[0-9]+K/[0-9]+"; then
    echo "✅ Output: $OUTPUT"
  else
    echo "❌ Runs but output malformed: $OUTPUT"
    echo "   FIX: Check transcript file path permissions"
  fi
else
  echo "❌ context-status.sh not executable via PATH"
fi
echo ""
```

## Step 5: Global CLAUDE.md Has Required Rule Sections

```bash
echo "=== CLAUDE.md RULES CHECK ==="
CMD_FILE="$HOME/.claude/CLAUDE.md"
if [ ! -f "$CMD_FILE" ]; then
  echo "❌ ~/.claude/CLAUDE.md MISSING"
  echo "   FIX: Run /sync-pull to pull rules from antifragile repo"
else
  echo "File: $CMD_FILE ($(wc -l < "$CMD_FILE") lines)"
  REQUIRED_SECTIONS=(
    "Response Timestamps"
    "Skill Auto-Discovery"
    "File Lifecycle Timestamps"
    "Large File Handling Rules"
    "Project Notes File"
    "Session Continuation Prompt"
    "Large File Generation Rules"
    "Sub-Agent / Parallel Task Rules"
    "Agent Swarm Monitoring"
  )
  MISSING=0
  for section in "${REQUIRED_SECTIONS[@]}"; do
    if grep -q "$section" "$CMD_FILE"; then
      echo "  ✅ $section"
    else
      echo "  ❌ $section MISSING"
      MISSING=$((MISSING + 1))
    fi
  done
  if [ "$MISSING" -gt 0 ]; then
    echo ""
    echo "   FIX: $MISSING section(s) missing. Run /sync-pull to merge from other machines."
  fi
fi
echo ""
```

## Step 6: Hooks Configured in settings.json

```bash
echo "=== HOOKS CHECK ==="
SETTINGS="$HOME/.claude/settings.json"
if [ ! -f "$SETTINGS" ]; then
  echo "❌ ~/.claude/settings.json MISSING"
else
  if grep -q '"hooks"' "$SETTINGS"; then
    HOOK_COUNT=$(grep -oE '"(PreToolUse|PostToolUse|Stop|SessionStart)"' "$SETTINGS" | sort -u | wc -l | tr -d ' ')
    echo "✅ Hooks configured ($HOOK_COUNT hook types)"
    grep -oE '"(PreToolUse|PostToolUse|Stop|SessionStart)"' "$SETTINGS" | sort -u | sed 's/^/   /'
  else
    echo "❌ NO hooks configured in settings.json"
    echo "   FIX: Copy hooks section from antifragile repo's settings.json.template"
  fi
fi
echo ""
```

## Step 7: Inventory Counts vs Expected

```bash
echo "=== INVENTORY ==="
SKILLS=$(ls -1 "$HOME/.claude/skills" 2>/dev/null | wc -l | tr -d ' ')
AGENTS=$(ls -1 "$HOME/.claude/agents" 2>/dev/null | wc -l | tr -d ' ')
COMMANDS=$(ls -1 "$HOME/.claude/commands" 2>/dev/null | wc -l | tr -d ' ')
RULES=$(find "$HOME/.claude/rules" -type f -name "*.md" 2>/dev/null | wc -l | tr -d ' ')

echo "Skills:   $SKILLS"
echo "Agents:   $AGENTS"
echo "Commands: $COMMANDS"
echo "Rules:    $RULES files"

# Warn if way too few
if [ "$SKILLS" -lt 100 ]; then
  echo "⚠️  Skill count very low — expected 500+. Run /sync-pull"
fi
if [ "$AGENTS" -lt 10 ]; then
  echo "⚠️  Agent count very low — expected 60+. Run /sync-pull"
fi
if [ "$COMMANDS" -lt 20 ]; then
  echo "⚠️  Command count very low — expected 80+. Run /sync-pull"
fi
echo ""
```

## Step 8: Sync Repo Reachable

```bash
echo "=== SYNC REPO CONNECTIVITY ==="
if command -v gh >/dev/null 2>&1; then
  if gh auth status 2>&1 | grep -q "Logged in"; then
    ACTIVE=$(gh auth status 2>&1 | grep -A1 "Active account: true" | head -2 | tail -1 || gh auth status 2>&1 | grep "Logged in" | head -1)
    echo "✅ gh CLI authenticated"
    gh auth status 2>&1 | grep -E "Logged in|Active account" | head -4 | sed 's/^/   /'
  else
    echo "❌ gh CLI not authenticated"
    echo "   FIX: gh auth login"
  fi
else
  echo "⚠️  gh CLI not installed (sync still works via https, but not recommended)"
fi

# Test clone access
if git ls-remote https://github.com/AntifragileTech/antifragile-claude-code.git HEAD >/dev/null 2>&1; then
  echo "✅ antifragile-claude-code repo reachable"
else
  echo "❌ Cannot reach antifragile-claude-code repo"
fi
echo ""
```

## Step 9: Memory Directory Structure

```bash
echo "=== MEMORY DIRECTORIES ==="
MEM_ROOT="$HOME/.claude/projects"
LOGS="$HOME/.claude/logs"
if [ -d "$MEM_ROOT" ]; then
  PROJ_COUNT=$(ls -1 "$MEM_ROOT" 2>/dev/null | wc -l | tr -d ' ')
  echo "✅ Project memory root: $PROJ_COUNT project(s)"
else
  echo "⚠️  No project memory yet (normal for fresh install)"
fi
if [ -d "$LOGS" ]; then
  echo "✅ Logs dir: $LOGS"
  ls -la "$LOGS" 2>/dev/null | tail -n +2 | awk '{print "   " $9 " (" $5 " bytes)"}' | head -5
else
  echo "⚠️  Logs dir missing — will be created on first /save"
fi
echo ""
```

## Step 10: Final Summary + Auto-Fix Offer

After running all checks, produce a summary like:

```
=== DOCTOR SUMMARY ===
PASS: X checks
FAIL: Y checks
WARN: Z checks

Critical fixes needed:
1. <specific fix with exact command>
2. <specific fix with exact command>

Want me to auto-fix? I can:
- Make ~/bin scripts executable
- Add ~/bin to PATH in ~/.zshrc
- Run /sync-pull to pull missing CLAUDE.md sections
- Copy hooks from template to settings.json

Reply: 'fix all' to apply all fixes, or 'fix N' for specific items.
```

## Auto-Fix Mode (when user replies "fix all" or "fix N")

For each failed check, apply the fix:

**Fix: ~/bin in PATH**
```bash
SHELL_RC="$HOME/.zshrc"
[ "$SHELL" = "/bin/bash" ] && SHELL_RC="$HOME/.bashrc"
if ! grep -q 'export PATH="\$HOME/bin:\$PATH"' "$SHELL_RC" 2>/dev/null; then
  echo '' >> "$SHELL_RC"
  echo '# Added by /doctor on '"$(date '+%Y-%m-%d')" >> "$SHELL_RC"
  echo 'export PATH="$HOME/bin:$PATH"' >> "$SHELL_RC"
  echo "✅ Added ~/bin to PATH in $SHELL_RC (restart terminal to apply)"
fi
```

**Fix: chmod +x bin scripts**
```bash
chmod +x "$HOME/bin/"*.sh 2>/dev/null && echo "✅ Made bin scripts executable"
```

**Fix: Missing CLAUDE.md sections**
Tell the user: "Run `/sync-pull` — it will merge missing sections from other machines. If still missing after sync, the section hasn't been pushed yet from any other machine."

**Fix: Hooks in settings.json**
Clone the antifragile repo, read `assets/settings.json.template`, extract the `hooks` object, and merge it into the user's `~/.claude/settings.json` using Python:
```python
import json
from pathlib import Path

template = json.load(open("/tmp/antifragile-push/assets/settings.json.template"))
settings_path = Path.home() / ".claude" / "settings.json"
settings = json.load(open(settings_path)) if settings_path.exists() else {}

if "hooks" in template and "hooks" not in settings:
    settings["hooks"] = template["hooks"]
    json.dump(settings, open(settings_path, "w"), indent=2)
    print("✅ Hooks merged into settings.json")
```

## Output Format

- Use ✅ ❌ ⚠️ emoji prefixes consistently
- Group by step
- Show exact fix commands
- End with a single "summary line" the user can read at a glance
