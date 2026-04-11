# Rollback — Uninstall Modules

> Remove any or all Antifragile Claude Code modules. Only removes what the pack installed — your pre-existing setup is never touched.

## How Rollback Works (Important)

The rollback is **safe for existing users**. If you had skills, agents, or commands BEFORE installing the pack, they will NOT be removed. Here's why:

- **Script rollback** (`uninstall.sh`): Uses manifest files created during install. The installer only records files it actually copied (skips existing ones). So pre-existing files are never in the manifest.
- **Prompt rollback**: Clones the repo and cross-references your installed files against the repo's file list. Only files that match the pack's known contents are removed.

**Example**: You had `react-expert` before installing → the installer skipped it → it's not in any manifest → rollback won't touch it.

## Before Running Any Rollback

1. Open a **new Claude Code session** (don't reuse an existing one)
2. Make sure your working directory is your **home folder** (`~` on Mac/Linux, `C:\Users\YourName` on Windows)
3. Copy and paste one of the prompts below

---

## Option A: Remove specific modules (Prompt — All platforms)

```
I want to rollback specific Antifragile Claude Code modules. ONLY remove files that came from the pack — do NOT touch any pre-existing files.

Modules to remove: [CHANGE THIS — e.g., 4 7 8]

### Step 1: Get the pack's file list
Clone the repo to get the definitive list of what the pack contains:
git clone --depth 1 https://github.com/AntifragileTech/antifragile-claude-code.git /tmp/ccpp

### Step 2: Cross-reference and remove by module

For each module number I listed, do the following:

- Module 0 (Core Setup): Check ~/.claude/CLAUDE.md — if it has a "## Skill Auto-Discovery (CRITICAL)" section, remove ONLY that section (not the whole file)
- Module 1 (Rules): For each .md file in /tmp/ccpp/assets/rules/*/*.md, check if the same file exists in ~/.claude/rules/. If yes, remove it.
- Module 2 (Agents): For each .md file in /tmp/ccpp/assets/agents/*.md, check if the same filename exists in ~/.claude/agents/. If yes, remove it.
- Module 3 (Commands): For each .md file in /tmp/ccpp/assets/commands/*.md, check if the same filename exists in ~/.claude/commands/. If yes, remove it.
- Module 4 (Dev Skills): For each directory in /tmp/ccpp/assets/skills/dev/, check if same directory exists in ~/.claude/skills/. If yes, remove it.
- Module 5 (Security Skills): For each directory in /tmp/ccpp/assets/skills/security/, check if same directory exists in ~/.claude/skills/. If yes, remove it.
- Module 6 (DevOps Skills): For each directory in /tmp/ccpp/assets/skills/devops/, check if same directory exists in ~/.claude/skills/. If yes, remove it.
- Module 7 (GTM Skills): For each directory in /tmp/ccpp/assets/skills/gtm/, check if same directory exists in ~/.claude/skills/. If yes, remove it.
- Module 8 (Marketing Skills): For each directory in /tmp/ccpp/assets/skills/marketing/, check if same directory exists in ~/.claude/skills/. If yes, remove it.
- Module 9 (Thinking Skills): For each directory in /tmp/ccpp/assets/skills/thinking/, check if same directory exists in ~/.claude/skills/. If yes, remove it.

### Step 3: Confirm before deleting
Show me the total count per module and a few example filenames. Ask for my confirmation before deleting anything.

### Step 4: Clean up
After deletion:
- Remove empty directories in ~/.claude/skills/, ~/.claude/agents/, ~/.claude/commands/, ~/.claude/rules/
- Remove ~/.claude/.power-pack/ manifest directory if it exists
- rm -rf /tmp/ccpp
- Report what was removed
```

---

## Option B: Remove everything the pack installed (Prompt — All platforms)

```
I want to completely remove everything the Antifragile Claude Code pack installed, but KEEP any files that existed before the pack was installed.

### Step 1: Get the pack's file list
git clone --depth 1 https://github.com/AntifragileTech/antifragile-claude-code.git /tmp/ccpp

### Step 2: Build the removal list
Write a Python script to /tmp/rollback.py that:

1. Lists every file/directory in the pack's assets:
   - Skills: all directories under /tmp/ccpp/assets/skills/dev/, security/, devops/, gtm/, marketing/, thinking/
   - Agents: all .md files in /tmp/ccpp/assets/agents/
   - Commands: all .md files in /tmp/ccpp/assets/commands/
   - Rules: all .md files in /tmp/ccpp/assets/rules/*/ (preserving subdirectory structure)

2. For each pack item, checks if a matching item exists in ~/.claude/ at the corresponding path

3. Prints a summary: X skills, Y agents, Z commands, W rules found for removal

4. Asks "Proceed with removal? (y/n)" and waits for input

5. If confirmed, removes only the matched items

6. Cleans up empty directories

7. Removes ~/.claude/.power-pack/ if it exists

8. Prints final report

Run the script: python3 /tmp/rollback.py

### Step 3: Also check CLAUDE.md
If ~/.claude/CLAUDE.md contains "## Skill Auto-Discovery (CRITICAL)", remove that section only.

### Step 4: Clean up
rm -rf /tmp/ccpp /tmp/rollback.py
Report the final counts.
```

---

## Option C: Script-based rollback (Mac/Linux — Most precise)

If you installed using `install.sh`, manifests were saved that track exactly what was installed:

```bash
# Clone the repo (or use your existing copy)
git clone --depth 1 https://github.com/AntifragileTech/antifragile-claude-code.git /tmp/ccpp

# See what's installed
bash /tmp/ccpp/uninstall.sh --list

# Remove specific modules
bash /tmp/ccpp/uninstall.sh --module 4 7

# Remove everything
bash /tmp/ccpp/uninstall.sh --all

# Clean up
rm -rf /tmp/ccpp
```

This is the safest option because the manifests record the exact files that were copied during installation (pre-existing files are never recorded).

---

## What rollback preserves

Rollback **never** touches:
- Your own custom skills, agents, or commands that existed before installing
- Your `~/.claude/settings.json`
- Your project-level `CLAUDE.md` files (only the auto-discovery section in `~/.claude/CLAUDE.md` is removed)
- Any Claude Code configuration not part of the Antifragile Claude Code pack
