# /sync-push — Push Claude Config Updates to antifragile-claude-code

Push local Claude Code configuration updates to the shared antifragile-claude-code repo.
Run this AFTER you've made changes (new skills, updated rules, new agents, etc.)

## What This Does

1. Ensures the antifragile repo is cloned locally at `/tmp/antifragile-push`
2. Pulls latest from remote first (to avoid conflicts)
3. Copies local config → repo (ADDITIVE ONLY — never overwrites, never deletes)
4. Commits with a descriptive message
5. Pushes to GitHub

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

# Scan local config files that will be pushed
for dir in ~/.claude/commands ~/.claude/agents ~/.claude/rules ~/.claude/skills; do
  if [ -d "$dir" ]; then
    # Check for real usernames in paths
    if grep -rl '/Users/sumitghugharwal\|/home/sumit\|sumitghugharwal' "$dir" 2>/dev/null | head -5 | grep -q .; then
      echo "  ⚠️  Found personal username in:"
      grep -rl '/Users/sumitghugharwal\|/home/sumit\|sumitghugharwal' "$dir" 2>/dev/null | head -5
      PERSONAL_FOUND=$((PERSONAL_FOUND + 1))
    fi
    # Check for project-specific domains/emails
    if grep -rl 'novauptime\.com\|ghugharwal-uptime\|wareone\|monitor@nova' "$dir" 2>/dev/null | head -5 | grep -q .; then
      echo "  ⚠️  Found project-specific domains in:"
      grep -rl 'novauptime\.com\|ghugharwal-uptime\|wareone\|monitor@nova' "$dir" 2>/dev/null | head -5
      PERSONAL_FOUND=$((PERSONAL_FOUND + 1))
    fi
    # Check for client names
    if grep -rl 'LMSGUM\|Vibe Code/Clients' "$dir" 2>/dev/null | head -5 | grep -q .; then
      echo "  ⚠️  Found client names in:"
      grep -rl 'LMSGUM\|Vibe Code/Clients' "$dir" 2>/dev/null | head -5
      PERSONAL_FOUND=$((PERSONAL_FOUND + 1))
    fi
    # Check for cache/transcript data
    if find "$dir" -name ".cache" -type d 2>/dev/null | grep -q .; then
      echo "  ⚠️  Found cache directories in:"
      find "$dir" -name ".cache" -type d 2>/dev/null
      PERSONAL_FOUND=$((PERSONAL_FOUND + 1))
    fi
  fi
done

if [ "$PERSONAL_FOUND" -gt 0 ]; then
  echo ""
  echo "❌ BLOCKED: $PERSONAL_FOUND personal data issue(s) found."
  echo "   Fix these before pushing. Replace with generic equivalents:"
  echo "   - /Users/sumitghugharwal → /Users/username or ~"
  echo "   - novauptime.com → yourdomain.com"
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

3. Commit and push:
```bash
cd /tmp/antifragile-push && git add -A
if ! git diff --cached --quiet; then
  git commit -m "sync: $(hostname) @ $(date '+%Y-%m-%d %H:%M') — added new config"
  git push origin master
  echo "Pushed to antifragile-claude-code"
else
  echo "Nothing new to push — already in sync"
fi
```

4. Clean up:
```bash
rm -rf /tmp/antifragile-push
```
