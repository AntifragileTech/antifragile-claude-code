---
description: "Scan all project dirs → create missing CLAUDE.md + memory + handoff for every project"
allowed-tools: Bash, Read, Write, Edit, Glob, Grep, TodoWrite
---

# Bootstrap Projects — Full Setup

Scan the user's project directories and for EVERY project create: CLAUDE.md, memory directory, and initial handoff file. Safe to run multiple times — NEVER overwrites existing files.

## Step 1: Find Project Root

Ask: "Where are your project directories?" Check these defaults if not specified:
- ~/Projects, ~/Code, ~/Developer, ~/repos, ~/src, ~/work

## Step 2: Scan and Report

Use a Python script to find all code projects (has package.json, requirements.txt, composer.json, Cargo.toml, go.mod, Makefile, or source files). Check 2 levels deep for monorepos. Report:
- Total projects found
- How many already have CLAUDE.md
- How many need CLAUDE.md
- How many need memory dirs
- How many need handoff files

Ask user to confirm before proceeding.

## Step 3: For Each Project — Create CLAUDE.md (if missing)

Read project files to understand it:
1. **package.json** → name, scripts, dependencies
2. **requirements.txt / pyproject.toml** → Python deps
3. **composer.json** → PHP framework
4. **.env / .env.example** → KEY names only (NEVER values)
5. **README.md** → description
6. **Folder structure** → top-level dirs
7. **Dockerfile / docker-compose.yml** → deployment info

Generate CLAUDE.md with:
```markdown
# <Project Name>

## Overview
<One-line description>

## Tech Stack
- Framework: <detected>
- Language: <detected>
- Database: <if found>
- External services: <from deps>

## Key Commands
<dev, build, test, deploy commands>

## Environment Variables
<KEY names only, never values>

## Project Structure
<top-level dirs>

## Deployment
<deploy info or "Not configured">
```

**Rules:** NEVER include env var values. NEVER overwrite existing CLAUDE.md. Under 80 lines each.

## Step 4: For Each Project — Create Memory Directory

```bash
PROJECT_DIR_KEY=$(echo "<project-path>" | sed 's|/|-|g')
mkdir -p "$HOME/.claude/projects/${PROJECT_DIR_KEY}/memory"
```

## Step 5: For Each Project — Create Initial Handoff (if missing)

Only if `handoff.md` doesn't already exist in the memory dir:

```markdown
# Session Handoff — <DATE>
## Directory: <project-path>
## Status: NEW — No previous sessions recorded

### Tech Stack
<from CLAUDE.md>

### Git Status
<output of git status --short, or "Not a git repo">

### Recent Git History
<output of git log --oneline -5, or "No git history">

### Notes
First bootstrap — no session history yet. Future sessions will auto-update this file.
```

## Step 6: Report Summary

| Project | CLAUDE.md | Memory Dir | Handoff | Action |
|---------|-----------|------------|---------|--------|
| ProjectA | CREATED | CREATED | CREATED | New setup |
| ProjectB | EXISTS | EXISTS | EXISTS | Skipped |
| ProjectC | CREATED | CREATED | CREATED | New setup |

Total: X CLAUDE.md created, Y memory dirs created, Z handoffs created, W skipped.
