---
description: "Recover context from previous sessions — reads handoff, memory, git log, and recovered session files"
allowed-tools: Bash, Read, Write, Edit, Glob, Grep, TodoWrite
---

# Session Recovery — Restore Previous Context

Recover and restore context from previous sessions for the current project.

## Step 1: Identify Current Project

```bash
CWD=$(pwd)
PROJECT_NAME=$(basename "$CWD")
PROJECT_DIR_KEY=$(echo "$CWD" | sed 's|/|-|g')
MEMORY_DIR="$HOME/.claude/projects/${PROJECT_DIR_KEY}/memory"
```

## Step 2: Read All Context Sources (priority order)

### 2a. Project-Local Handoff (highest priority)
```bash
cat "$MEMORY_DIR/handoff.md" 2>/dev/null
```

### 2b. All Project Memory Files
```bash
ls "$MEMORY_DIR/" 2>/dev/null
```
Read every `.md` file in the memory directory.

### 2c. Recovered Session Files
Check for recovered sessions matching this project name:
```bash
ls ~/recovered-sessions/${PROJECT_NAME}/ 2>/dev/null
```
If found, read only the LAST 200 lines of the most recent file — these can be 500KB+:
```bash
LATEST=$(ls -t ~/recovered-sessions/${PROJECT_NAME}/*.md 2>/dev/null | head -1)
[ -n "$LATEST" ] && tail -200 "$LATEST"
```

### 2d. Git History
```bash
git log --oneline -10 2>/dev/null
git status --short 2>/dev/null
git diff --stat 2>/dev/null
```

### 2e. Project CLAUDE.md
```bash
head -50 CLAUDE.md 2>/dev/null
```

## Step 3: Present Recovery Summary

```
=== SESSION RECOVERY for <PROJECT_NAME> ===
Directory: <path>
Last Active: <handoff timestamp or git log date>

## Previous Work
- <from handoff + git log>

## Current State
- Branch: <git branch>
- Uncommitted: <git status>
- Build: <if known>

## Key Decisions
- <from memory files>

## Next Steps
- <from handoff>

## Tech Stack
- <from CLAUDE.md>
=== END RECOVERY ===
```

## Step 4: Continue

Ask: "Here's where we left off. What would you like to work on?"
