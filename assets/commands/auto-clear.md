---
description: "Auto-save all context, commit changes, write handoff, then prompt for /clear"
allowed-tools: Bash, Read, Write, Edit, Glob, Grep, TodoWrite
---

# Auto-Clear: Smart Session Reset

You are performing an automated pre-clear sequence. Execute ALL steps below before telling the user to run /clear.

## Step 1: Check for Code Changes (Git-Aware)
First, check if the current directory is a git repo: `git rev-parse --is-inside-work-tree 2>/dev/null`

**If inside a git repo:**
- Run `git status --short`
- If there are changes: stage relevant files and create a commit with a descriptive message
- If changes exist but shouldn't be committed (WIP): run `git stash push -m "auto-clear-stash-$(date +%Y%m%d-%H%M)"`
- If clean: skip

**If NOT a git repo (local files, HTML projects, cPanel sites, etc.):**
- List files modified in this session based on conversation history
- Note their paths in the handoff document so the user knows what changed
- Suggest: "These files were modified but aren't version-controlled. Consider backing up or initializing git."
- Do NOT try to run any git commands — just document what changed

## Step 2: Save Session Learnings to Memory
Review the conversation for:
- Any user preferences or corrections → save as feedback memory
- Any project decisions or context → save as project memory
- Any new external references → save as reference memory
Write memory files to `~/.claude/projects/*/memory/` using proper frontmatter format.

## Step 3: Write Handoff Document
Create/update the handoff file with:
```
Current task status (what's done, what's remaining)
Files modified this session (with full paths)
Key decisions made
Next steps with specific file paths and line numbers
Any blockers or open questions
Whether project uses git or is local-only
```
Save to the project's memory directory.

## Step 4: Update Todo Status
If TodoWrite was used this session, mark completed items and note pending ones.

## Step 5: Check Background Tasks
Run `ps aux | grep -i claude | grep -v grep` to check for background agents.
If any are running, warn the user before clearing.

## Step 6: Report Context Usage
Tell the user:
- How many messages were in this session
- What was accomplished
- What's saved for next session
- Whether changes are committed (git) or just documented (non-git)
- "Run /clear now — all context has been preserved."

## Step 7: Generate Resume Hint
Output a one-line prompt the user can paste to resume:
```
Continue from handoff: [brief description of where we left off]
```
