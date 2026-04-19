# /sync-push — Push Claude Config Updates to antifragile-claude-code

Push local Claude Code configuration updates to the shared antifragile-claude-code repo.
Run this AFTER you've made changes (new skills, updated rules, new agents, etc.)

## What This Does

1. Ensures the antifragile repo is cloned locally at `/tmp/antifragile-push`
2. Pulls latest from remote first (to avoid conflicts)
3. Copies local config → repo (ADDITIVE ONLY — never overwrites, never deletes)
4. Pushes global + project CLAUDE.md to `assets/claude-md/{hostname}-*.md`
5. Extracts Insights-tagged sections to `assets/insights/{hostname}.md`
6. Commits with a descriptive message
7. Pushes to GitHub

## Rules (CRITICAL)
- NEVER delete files from the repo — only ADD new ones
- NEVER overwrite a repo file if it already exists
- Commit message must show: hostname, date, what was added
- The repo uses category-based skill layout (`assets/skills/dev/`, `assets/skills/gtm/`, etc.)
- New skills go into `assets/skills/dev/` by default (unless they clearly belong in another category)

## Skill Category Mapping
- `dev/` — Development skills (react, nextjs, python, golang, testing, debugging, etc.)
- `security/` — Security scanning and auditing skills
- `devops/` — Infrastructure, Docker, K8s, CI/CD skills
- `gtm/` — Go-to-market, sales, outreach skills
- `marketing/` — SEO, content, copywriting, ads skills
- `thinking/` — Reasoning, brainstorming, debate skills
- `ops/` — Operational skills (deploy, monitoring, healthcheck)
- `learning/` — Learning and knowledge extraction skills

## Steps

### Step 0: Pre-Push Personal Data Scan (CRITICAL — runs BEFORE any push)

Before copying ANY files to the repo, scan all files that will be pushed for personal data:

```bash
echo "🔒 Pre-push personal data scan..."
PERSONAL_FOUND=0

# Load per-user scan patterns (never synced — lives only on each machine).
# If the user has ~/.claude/.sync-scan-patterns, source it. Otherwise use
# generic defaults that work for any machine/user.
USERNAMES=""
DOMAINS=""
CLIENTS=""
EMAILS=""
HOSTNAME_PREFIX=""
GENERIC_SECRETS="sk_live_|sk_test_|ghp_[a-zA-Z0-9]{36}|xox[baprs]-|AKIA[0-9A-Z]{16}|-----BEGIN (RSA |EC |DSA )?PRIVATE KEY-----"

if [ -f "$HOME/.claude/.sync-scan-patterns" ]; then
  # shellcheck disable=SC1091
  source "$HOME/.claude/.sync-scan-patterns"
  echo "  Loaded personal scan patterns from ~/.claude/.sync-scan-patterns"
else
  echo "  ℹ  No ~/.claude/.sync-scan-patterns found — using generic patterns only."
  echo "     Copy assets/sync-scan-patterns.template to ~/.claude/.sync-scan-patterns"
  echo "     and fill in YOUR usernames/domains/clients for stronger protection."
fi

# Always scan for: current user's shell username and generic secrets
CURRENT_USER="$(whoami)"
# Build dynamic pattern list (skip empty ones)
check_pattern() {
  local label="$1"
  local pattern="$2"
  [ -z "$pattern" ] && return 0
  for dir in ~/.claude/commands ~/.claude/agents ~/.claude/rules ~/.claude/skills; do
    [ -d "$dir" ] || continue
    if grep -rlE "$pattern" "$dir" 2>/dev/null | head -5 | grep -q .; then
      echo "  ⚠️  Found $label in:"
      grep -rlE "$pattern" "$dir" 2>/dev/null | head -5 | sed 's/^/    /'
      PERSONAL_FOUND=$((PERSONAL_FOUND + 1))
    fi
  done
}

# Always check current user's home/username (auto-detected, no config needed)
check_pattern "current user path" "/Users/$CURRENT_USER|/home/$CURRENT_USER"

# Config-driven checks (only if user has set them)
[ -n "$USERNAMES" ]       && check_pattern "personal usernames"    "$USERNAMES"
[ -n "$DOMAINS" ]         && check_pattern "personal domains"      "$DOMAINS"
[ -n "$CLIENTS" ]         && check_pattern "client names"          "$CLIENTS"
[ -n "$EMAILS" ]          && check_pattern "personal emails"       "$EMAILS"
[ -n "$GENERIC_SECRETS" ] && check_pattern "secrets/tokens"        "$GENERIC_SECRETS"

# Always check for cache/transcript dirs
for dir in ~/.claude/commands ~/.claude/agents ~/.claude/rules ~/.claude/skills; do
  if [ -d "$dir" ] && find "$dir" -name ".cache" -type d 2>/dev/null | grep -q .; then
    echo "  ⚠️  Found cache directories in $dir"
    find "$dir" -name ".cache" -type d 2>/dev/null | sed 's/^/    /'
    PERSONAL_FOUND=$((PERSONAL_FOUND + 1))
  fi
done

if [ "$PERSONAL_FOUND" -gt 0 ]; then
  echo ""
  echo "❌ BLOCKED: $PERSONAL_FOUND personal data issue(s) found."
  echo "   Fix these before pushing. Replace with generic equivalents:"
  echo "   - /Users/\$USER → /Users/username or ~"
  echo "   - Your real domains → yourdomain.com"
  echo "   - Client names → MyApp, MyProject"
  echo "   - Delete .cache/ directories"
  echo ""
  echo "   DO NOT PUSH until all personal data is removed."
else
  echo "✅ No personal data found — safe to push."
fi
```

If personal data is found, STOP and fix it before proceeding. Do NOT push files containing personal data.

1. Clone or pull latest repo:
```bash
if [ -d /tmp/antifragile-push/.git ]; then
  cd /tmp/antifragile-push && git pull --rebase origin master
else
  rm -rf /tmp/antifragile-push
  git clone https://github.com/AntifragileTech/antifragile-claude-code.git /tmp/antifragile-push
fi
```

2. Run the additive sync (Python script for precision):
```bash
python3 -c "
import os, shutil
from pathlib import Path

HOME = Path.home()
CLAUDE = HOME / '.claude'
REPO = Path('/tmp/antifragile-push/assets')

added = 0
skipped = 0

# Build set of existing skill names in repo (across all category dirs)
repo_skills = set()
for cat_dir in (REPO / 'skills').iterdir():
    if cat_dir.is_dir():
        for skill_dir in cat_dir.iterdir():
            if skill_dir.is_dir():
                repo_skills.add(skill_dir.name)

# Sync new skills (local → repo, into dev/ by default)
print('Skills:')
for skill_dir in sorted((CLAUDE / 'skills').iterdir()):
    if skill_dir.is_dir() and skill_dir.name not in repo_skills:
        dest = REPO / 'skills' / 'dev' / skill_dir.name
        shutil.copytree(skill_dir, dest)
        added += 1
        print(f'  + {skill_dir.name} (NEW → dev/)')

# Sync new agents
print('Agents:')
for f in sorted((CLAUDE / 'agents').iterdir()):
    if f.is_file() and not (REPO / 'agents' / f.name).exists():
        shutil.copy2(f, REPO / 'agents' / f.name)
        added += 1
        print(f'  + {f.name} (NEW)')
    else:
        skipped += 1

# Sync new commands
print('Commands:')
for f in sorted((CLAUDE / 'commands').iterdir()):
    if f.is_file() and not (REPO / 'commands' / f.name).exists():
        shutil.copy2(f, REPO / 'commands' / f.name)
        added += 1
        print(f'  + {f.name} (NEW)')
    else:
        skipped += 1

# Sync new rules
print('Rules:')
for root, dirs, files in os.walk(CLAUDE / 'rules'):
    for f in sorted(files):
        src = Path(root) / f
        rel = src.relative_to(CLAUDE / 'rules')
        dst = REPO / 'rules' / rel
        if not dst.exists():
            dst.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(src, dst)
            added += 1
            print(f'  + {rel} (NEW)')
        else:
            skipped += 1

# Sync hooks script
print('Hooks:')
hooks_src = HOME / 'bin' / 'claude-hooks.sh'
hooks_dst = REPO / 'claude-hooks.sh'
if hooks_src.exists() and hooks_dst.exists():
    if hooks_src.read_bytes() != hooks_dst.read_bytes() and hooks_src.stat().st_mtime > hooks_dst.stat().st_mtime:
        shutil.copy2(hooks_src, hooks_dst)
        added += 1
        print('  ~ claude-hooks.sh (UPDATED — local is newer)')
    else:
        skipped += 1
        print('  = claude-hooks.sh (unchanged)')

print(f'\n=== Summary: {added} added, {skipped} unchanged ===')
"
```

3. Push global CLAUDE.md (section-level sync):
```bash
python3 << 'CLAUDEMD_PUSH'
import socket, shutil
from pathlib import Path

HOME = Path.home()
REPO = Path("/tmp/antifragile-push/assets/claude-md")
REPO.mkdir(parents=True, exist_ok=True)

raw_host = socket.gethostname()
import os
prefix = os.environ.get("HOSTNAME_PREFIX", "")  # from ~/.claude/.sync-scan-patterns
short_host = raw_host
if prefix:
    short_host = short_host.removeprefix(prefix) if hasattr(str, "removeprefix") else (short_host[len(prefix):] if short_host.startswith(prefix) else short_host)
short_host = short_host.replace(".local", "").replace(" ", "-")

# Push global CLAUDE.md
global_cmd = HOME / ".claude" / "CLAUDE.md"
if global_cmd.exists():
    dest = REPO / f"{short_host}-global.md"
    # Always overwrite our own machine's copy — this is OUR latest state
    shutil.copy2(global_cmd, dest)
    print(f"  + {short_host}-global.md (pushed global CLAUDE.md)")
else:
    print("  No global ~/.claude/CLAUDE.md found — skipping")

# Push project CLAUDE.md from home dir if it exists
project_cmd = HOME / "CLAUDE.md"
if project_cmd.exists():
    dest = REPO / f"{short_host}-project.md"
    shutil.copy2(project_cmd, dest)
    print(f"  + {short_host}-project.md (pushed project CLAUDE.md)")
CLAUDEMD_PUSH
```

4. Extract and push Insights sections from CLAUDE.md files:
```bash
python3 << 'INSIGHTS_PUSH'
import re, os, socket
from pathlib import Path

HOME = Path.home()
REPO = Path("/tmp/antifragile-push/assets/insights")
REPO.mkdir(parents=True, exist_ok=True)

# Short hostname for file naming (e.g., "M2-Max" from "Sumits-M2-Max.local")
raw_host = socket.gethostname()
import os
prefix = os.environ.get("HOSTNAME_PREFIX", "")  # from ~/.claude/.sync-scan-patterns
short_host = raw_host
if prefix:
    short_host = short_host.removeprefix(prefix) if hasattr(str, "removeprefix") else (short_host[len(prefix):] if short_host.startswith(prefix) else short_host)
short_host = short_host.replace(".local", "").replace(" ", "-")

# Collect all CLAUDE.md files to scan
claude_files = []
# Global CLAUDE.md
global_cmd = HOME / ".claude" / "CLAUDE.md"
if global_cmd.exists():
    claude_files.append(("global", global_cmd))
# Project CLAUDE.md in home dir
project_cmd = HOME / "CLAUDE.md"
if project_cmd.exists():
    claude_files.append(("project-home", project_cmd))

extracted = 0
for label, filepath in claude_files:
    content = filepath.read_text(encoding="utf-8")
    
    # Extract sections tagged with (Insights ...)
    # Match ### or ## headings with (Insights ...) in them, plus their body
    pattern = r'(#{2,3}\s+[^\n]*\(Insights[^\)]*\)[^\n]*\n(?:(?!#{2,3}\s).*\n?)*)'
    matches = re.findall(pattern, content)
    
    if matches:
        out_file = REPO / f"{short_host}.md"
        # Read existing content to avoid duplicates
        existing = out_file.read_text(encoding="utf-8") if out_file.exists() else ""
        
        new_sections = []
        for section in matches:
            section = section.strip()
            # Check if this section header already exists in the file
            header_line = section.split("\n")[0].strip()
            if header_line not in existing:
                new_sections.append(section)
                extracted += 1
        
        if new_sections:
            with open(out_file, "a", encoding="utf-8") as f:
                if existing and not existing.endswith("\n\n"):
                    f.write("\n\n")
                if not existing:
                    f.write(f"# Insights from {short_host}\n")
                    f.write(f"# Auto-extracted from CLAUDE.md — DO NOT EDIT MANUALLY\n")
                    f.write(f"# These sections get merged into CLAUDE.md on other machines via /sync-pull\n\n")
                for s in new_sections:
                    f.write(s + "\n\n")
            print(f"  + {out_file.name}: {len(new_sections)} new section(s) from {label}")
        else:
            print(f"  = {short_host}.md: all sections already present")

if extracted == 0:
    print("  No new Insights sections to push")
else:
    print(f"\n  Total: {extracted} Insights section(s) extracted to {short_host}.md")
INSIGHTS_PUSH
```

5. Final personal data scan on repo staging area (CRITICAL — last gate before commit):
```bash
echo ""
echo "🔒 Final scan on repo staging area..."
cd /tmp/antifragile-push
REPO_ISSUES=0

# Scan ALL text files in the repo for personal data patterns
# Load per-user patterns for final repo-side scan
if [ -f "$HOME/.claude/.sync-scan-patterns" ]; then
  source "$HOME/.claude/.sync-scan-patterns"
fi
# Build pattern from config + auto-detected current user
PATTERNS_LIST=()
[ -n "${USERNAMES:-}" ]       && PATTERNS_LIST+=("$USERNAMES")
[ -n "${DOMAINS:-}" ]         && PATTERNS_LIST+=("$DOMAINS")
[ -n "${CLIENTS:-}" ]         && PATTERNS_LIST+=("$CLIENTS")
[ -n "${EMAILS:-}" ]          && PATTERNS_LIST+=("$EMAILS")
[ -n "${GENERIC_SECRETS:-}" ] && PATTERNS_LIST+=("$GENERIC_SECRETS")
PATTERNS_LIST+=("/Users/$(whoami)|/home/$(whoami)")
# Join with | separator
IFS='|' PATTERNS="${PATTERNS_LIST[*]}"
# Fallback if user has no config — use generic safe default
[ -z "$PATTERNS" ] && PATTERNS="sk_live_|ghp_[a-zA-Z0-9]{36}|-----BEGIN.*PRIVATE KEY-----"

FOUND_FILES=$(grep -rl "$PATTERNS" assets/ 2>/dev/null | grep -v '.json$' | head -20)
if [ -n "$FOUND_FILES" ]; then
  echo "  ⚠️  Personal data found in repo files:"
  echo "$FOUND_FILES" | while read f; do
    echo "    $f:"
    grep -n "$PATTERNS" "$f" 2>/dev/null | head -3 | sed 's/^/      /'
  done
  REPO_ISSUES=$((REPO_ISSUES + 1))
fi

# Also scan CLAUDE.md copies and insights
FOUND_MD=$(grep -rl "$PATTERNS" assets/claude-md/ assets/insights/ 2>/dev/null | head -10)
if [ -n "$FOUND_MD" ]; then
  echo "  ⚠️  Personal data in CLAUDE.md/insights files:"
  echo "$FOUND_MD" | while read f; do
    echo "    $f:"
    grep -n "$PATTERNS" "$f" 2>/dev/null | head -3 | sed 's/^/      /'
  done
  REPO_ISSUES=$((REPO_ISSUES + 1))
fi

# Machine JSON is OK — it's supposed to have hostname/user
# But check it doesn't have project paths
# Re-use same PATTERNS set above for machine-file scan
FOUND_MACHINE=$(grep -lE "$PATTERNS" assets/machines/*.json 2>/dev/null)
if [ -n "$FOUND_MACHINE" ]; then
  echo "  ⚠️  Project names leaked into machine signature:"
  echo "$FOUND_MACHINE"
  REPO_ISSUES=$((REPO_ISSUES + 1))
fi

if [ "$REPO_ISSUES" -gt 0 ]; then
  echo ""
  echo "❌ BLOCKED: Personal data found in repo staging area."
  echo "   Clean the files above before committing."
  echo "   DO NOT proceed to commit."
  # Exit the script block — don't commit
  exit 1
else
  echo "✅ Repo staging area clean — safe to commit."
fi
```

6. Write machine signature and commit with git notes (only runs if step 5 passed):
```bash
cd /tmp/antifragile-push

# Write machine signature to manifest
# Use HOSTNAME_PREFIX from ~/.claude/.sync-scan-patterns if set (per-user config)
if [ -f "$HOME/.claude/.sync-scan-patterns" ]; then
  source "$HOME/.claude/.sync-scan-patterns"
fi
SHORT_HOST=$(hostname -s | sed "s/^${HOSTNAME_PREFIX:-}//; s/\.local$//")
mkdir -p assets/machines
cat > "assets/machines/${SHORT_HOST}.json" << MACHINE_EOF
{
  "hostname": "$(hostname)",
  "short_name": "${SHORT_HOST}",
  "os": "$(uname -s) $(uname -r)",
  "arch": "$(uname -m)",
  "last_push": "$(date -u '+%Y-%m-%dT%H:%M:%SZ')",
  "user": "$(whoami)"
}
MACHINE_EOF

git add -A
if ! git diff --cached --quiet; then
  # Commit with machine-tagged message
  COMMIT_MSG="sync(${SHORT_HOST}): $(date '+%Y-%m-%d %H:%M') — config + CLAUDE.md + insights"
  git commit -m "$COMMIT_MSG"
  
  # Add detailed git note with machine signature
  COMMIT_SHA=$(git rev-parse HEAD)
  git notes add -f -m "$(cat << NOTE_EOF
Machine: ${SHORT_HOST} ($(hostname))
OS: $(uname -s) $(uname -r) ($(uname -m))
Pushed at: $(date '+%Y-%m-%d %H:%M:%S %Z')
User: $(whoami)
Files changed: $(git diff --name-only HEAD~1 HEAD 2>/dev/null | wc -l | tr -d ' ')
Summary: $(git diff --stat HEAD~1 HEAD 2>/dev/null | tail -1)
NOTE_EOF
)" "$COMMIT_SHA"
  
  # Push commits and notes
  git push origin master
  git push origin refs/notes/commits 2>/dev/null || true
  echo "✅ Pushed from ${SHORT_HOST} to antifragile-claude-code"
else
  echo "Nothing new to push — already in sync"
fi
```

7. Clean up:
```bash
rm -rf /tmp/antifragile-push
```
