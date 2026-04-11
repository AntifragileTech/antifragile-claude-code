# Full Install — Everything

> Installs all 514 skills, 68 agents, 84 commands, 29 rules, and configures CLAUDE.md auto-discovery.

**Estimated time**: ~5 minutes

## Copy this prompt into Claude Code:

```
I want you to install the complete Antifragile Claude Code from a GitHub repo. Follow these exact steps:

### Step 0: Preflight check
Before anything else, verify these tools are available:
1. Run `git --version` — if git is not installed, stop and tell me how to install it for my OS
2. Run `python3 --version` (or `python --version`) — if Python 3 is not available, stop and tell me how to install it
3. Run `mkdir -p ~/.claude` to ensure the target directory exists

If both git and python3 are available, proceed:

### Step 1: Clone the repo
git clone --depth 1 https://github.com/AntifragileTech/antifragile-claude-code.git /tmp/ccpp

### Step 2: Install everything with this Python script

Write this script to /tmp/install_power_pack.py and execute it:

import os, shutil

REPO = "/tmp/ccpp/assets"
CLAUDE = os.path.expanduser("~/.claude")

def safe_copy_dir(src_dir, dst_dir, label):
    """Copy directories from src to dst, skip existing."""
    os.makedirs(dst_dir, exist_ok=True)
    installed = 0
    skipped = 0
    for item in sorted(os.listdir(src_dir)):
        src = os.path.join(src_dir, item)
        dst = os.path.join(dst_dir, item)
        if os.path.isdir(src):
            if os.path.exists(dst):
                skipped += 1
            else:
                shutil.copytree(src, dst)
                installed += 1
        elif os.path.isfile(src) and not os.path.exists(dst):
            shutil.copy2(src, dst)
            installed += 1
        elif os.path.isfile(src):
            skipped += 1
    print(f"  {label}: {installed} installed, {skipped} skipped")
    return installed, skipped

print("=== Antifragile Claude Code Installer ===\n")

# Skills (from all subcategories)
total_i, total_s = 0, 0
skills_dst = os.path.join(CLAUDE, "skills")
for category in ["dev", "security", "devops", "gtm", "marketing", "thinking"]:
    cat_dir = os.path.join(REPO, "skills", category)
    if os.path.isdir(cat_dir):
        i, s = safe_copy_dir(cat_dir, skills_dst, f"Skills/{category}")
        total_i += i
        total_s += s
print(f"  Skills total: {total_i} installed, {total_s} skipped\n")

# Agents
safe_copy_dir(os.path.join(REPO, "agents"), os.path.join(CLAUDE, "agents"), "Agents")

# Commands
safe_copy_dir(os.path.join(REPO, "commands"), os.path.join(CLAUDE, "commands"), "Commands")

# Rules (nested directories)
rules_src = os.path.join(REPO, "rules")
rules_dst = os.path.join(CLAUDE, "rules")
for subdir in sorted(os.listdir(rules_src)):
    src = os.path.join(rules_src, subdir)
    dst = os.path.join(rules_dst, subdir)
    if os.path.isdir(src):
        safe_copy_dir(src, dst, f"Rules/{subdir}")
    elif os.path.isfile(src) and not os.path.exists(dst):
        os.makedirs(rules_dst, exist_ok=True)
        shutil.copy2(src, dst)

# Final counts
skills = len([d for d in os.listdir(skills_dst) if os.path.isdir(os.path.join(skills_dst, d))])
agents = len([f for f in os.listdir(os.path.join(CLAUDE, "agents")) if f.endswith(".md")])
commands = len([f for f in os.listdir(os.path.join(CLAUDE, "commands")) if f.endswith(".md")])

print(f"\n=== Final Counts ===")
print(f"Skills:   {skills}")
print(f"Agents:   {agents}")
print(f"Commands: {commands}")
print(f"\nDone! Restart Claude Code for changes to take effect.")

### Step 3: Set up CLAUDE.md auto-discovery

Check if ~/.claude/CLAUDE.md exists. If not, create it. Then check if it already contains "Skill Auto-Discovery". If yes, skip this step. If not, read the file /tmp/ccpp/prompts/00-core-setup.md — it contains the exact block to append. Copy that block (everything between "## Skill Auto-Discovery" and the end marker) and append it to the END of ~/.claude/CLAUDE.md. This is critical — it tells Claude to auto-discover and proactively invoke skills when relevant tasks come up.

### Step 4: Clean up

rm -rf /tmp/ccpp /tmp/install_power_pack.py

### Step 5: Report

Tell me the final counts and confirm everything installed successfully.
```
